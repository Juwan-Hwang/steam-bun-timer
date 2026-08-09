package com.steambun.steam_bun_timer

import android.annotation.SuppressLint
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioRecord
import android.media.MediaRecorder
import android.net.Uri
import android.location.Location
import android.location.LocationManager
import android.location.LocationListener
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.view.KeyEvent
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL_FOREGROUND = "com.steambun.steam_bun_timer/foreground"
    private val CHANNEL_VOICE = "com.steambun.steam_bun_timer/voice"
    private val CHANNEL_LOCATION = "com.steambun.steam_bun_timer/location"
    private val NOTIFICATION_CHANNEL_ID = "steam_bun_timer"
    private val NOTIFICATION_ID = 1

    private var methodChannel: MethodChannel? = null
    private var voiceChannel: MethodChannel? = null
    private var isForegroundActive = false

    /// 音量键拦截开关 — 仅在有活跃批次时拦截
    private var interceptVolumeKeys = false

    // P3-1: 原始亮度倍数（-1 = 跟随系统）
    private var originalBrightness: Float = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── 前台服务 + 音量键 MethodChannel ──
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_FOREGROUND)
        // 注册 MediaSession 按键回调 — 前台服务 MediaSession 收到后台媒体按键时转发给 Flutter
        TimerForegroundService.onMediaKey = { keyCode ->
            methodChannel?.invokeMethod("onKeyEvent", keyCode)
        }

        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startForeground" -> {
                    val title = call.argument<String>("title") ?: "蒸馒头计时器"
                    val content = call.argument<String>("content") ?: "运行中"
                    TimerForegroundService.start(this, title, content)
                    isForegroundActive = true
                    interceptVolumeKeys = true
                    result.success(null)
                }
                "updateNotification" -> {
                    val content = call.argument<String>("content") ?: ""
                    if (isForegroundActive) {
                        TimerForegroundService.update(this, content)
                    }
                    result.success(null)
                }
                "stopForeground" -> {
                    TimerForegroundService.stop(this)
                    isForegroundActive = false
                    interceptVolumeKeys = false
                    result.success(null)
                }
                "scheduleAlarm" -> {
                    val id = call.argument<Int>("id") ?: 0
                    val triggerAtMillis = call.argument<Long>("triggerAtMillis") ?: 0L
                    val title = call.argument<String>("title") ?: ""
                    val body = call.argument<String>("body") ?: ""
                    scheduleExactAlarm(id, triggerAtMillis, title, body)
                    result.success(null)
                }
                "cancelAlarm" -> {
                    val id = call.argument<Int>("id") ?: 0
                    cancelExactAlarm(id)
                    result.success(null)
                }
                "canScheduleExactAlarms" -> {
                    result.success(canScheduleExactAlarms())
                }
                "requestExactAlarmPermission" -> {
                    requestExactAlarmPermission()
                    result.success(null)
                }
                "hasNotificationPermission" -> {
                    result.success(hasNotificationPermission())
                }
                "requestNotificationPermission" -> {
                    requestNotificationPermission(result)
                }
                "isIgnoringBatteryOptimizations" -> {
                    result.success(isIgnoringBatteryOptimizations())
                }
                "requestIgnoreBatteryOptimizations" -> {
                    requestIgnoreBatteryOptimizations()
                    result.success(null)
                }
                // P3-1: 亮度控制 — 真正调用 WindowManager
                "setBrightness" -> {
                    val brightness = call.argument<Double>("brightness") ?: -1.0
                    setBrightness(brightness)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // ── 原生定位 MethodChannel — 不依赖 Google Play 服务 ──
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_LOCATION).setMethodCallHandler { call, result ->
            when (call.method) {
                "getLocation" -> getLocation(result)
                else -> result.notImplemented()
            }
        }

        // ── P1-1: 语音指令 MethodChannel ──
        // sherpa-onnx KWS 音频采集 - 原生层录音，Dart 层识别
        voiceChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_VOICE)
        voiceChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startAudioStream" -> {
                    val sampleRate = call.argument<Int>("sampleRate") ?: 16000
                    val started = startAudioRecording(sampleRate)
                    result.success(started)
                }
                "stopAudioStream" -> {
                    stopAudioRecording()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  P1-1: 音频采集 — 为 sherpa-onnx KWS 提供实时音频流
    // ═══════════════════════════════════════════════════════════════════════════

    private var audioRecord: AudioRecord? = null
    private var isRecording = false
    private var recordingThread: Thread? = null

    // 定位清理 — 存储待清理的 listeners 和超时 Runnable
    private val pendingLocationListeners = mutableListOf<LocationListener>()
    private var locationTimeoutRunnable: Runnable? = null

    private fun startAudioRecording(sampleRate: Int): Boolean {
        if (isRecording) return true

        // 检查录音权限
        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(arrayOf(android.Manifest.permission.RECORD_AUDIO), 1002)
            return false
        }

        val bufferSize = AudioRecord.getMinBufferSize(
            sampleRate,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )

        try {
            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                sampleRate,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                bufferSize
            )

            if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
                return false
            }

            audioRecord?.startRecording()
            isRecording = true

            // 启动录音线程
            recordingThread = Thread {
                val buffer = ByteArray(bufferSize)
                while (isRecording) {
                    val read = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                    if (read > 0) {
                        // 将音频数据发送给 Flutter
                        val audioData = buffer.copyOf(read)
                        runOnUiThread {
                            voiceChannel?.invokeMethod("onAudioData", audioData)
                        }
                    }
                }
            }
            recordingThread?.start()

            return true
        } catch (e: Exception) {
            Log.e("MainActivity", "Failed to start audio recording: ${e.message}")
            return false
        }
    }

    private fun stopAudioRecording() {
        isRecording = false
        // 先 stop() 解除 read() 阻塞，再 join() 等线程退出，最后 release()
        // 顺序不能反：release() 时线程可能还在 read() 中 → SIGSEGV
        try { audioRecord?.stop() } catch (_: Exception) {}
        recordingThread?.join(2000)
        if (recordingThread?.isAlive == true) {
            Log.w("MainActivity", "Recording thread still alive after join(2000), interrupting")
            recordingThread?.interrupt()
        }
        recordingThread = null
        audioRecord?.release()
        audioRecord = null
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  音量键拦截 — §第二层/第三层
    //  音量上键和下键都等同于「确认下一步 / 停止响铃」
    // ═══════════════════════════════════════════════════════════════════════════

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        when (keyCode) {
            KeyEvent.KEYCODE_VOLUME_UP,
            KeyEvent.KEYCODE_VOLUME_DOWN -> {
                if (interceptVolumeKeys) {
                    methodChannel?.invokeMethod("onKeyEvent", keyCode)
                    return true
                }
                return super.onKeyDown(keyCode, event)
            }
            // 蓝牙 HID 遥控器常见按键
            KeyEvent.KEYCODE_ENTER,           // 66 — 多数蓝牙自拍器
            KeyEvent.KEYCODE_HEADSETHOOK,     // 79 — 耳机线控/部分蓝牙遥控
            KeyEvent.KEYCODE_CALL,            // 5  — 部分蓝牙设备
            KeyEvent.KEYCODE_DPAD_CENTER,     // 23 — 部分蓝牙遥控/车载设备
            KeyEvent.KEYCODE_CAMERA -> {      // 27 — 蓝牙相机快门
                // 仅在有活跃批次时拦截，空闲时不吞线控/接听/快门系统行为
                if (interceptVolumeKeys) {
                    methodChannel?.invokeMethod("onKeyEvent", keyCode)
                    return true
                }
                return super.onKeyDown(keyCode, event)
            }
        }
        return super.onKeyDown(keyCode, event)
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        when (keyCode) {
            KeyEvent.KEYCODE_VOLUME_UP,
            KeyEvent.KEYCODE_VOLUME_DOWN -> {
                if (interceptVolumeKeys) return true
                return super.onKeyUp(keyCode, event)
            }
            KeyEvent.KEYCODE_ENTER,
            KeyEvent.KEYCODE_HEADSETHOOK,
            KeyEvent.KEYCODE_CALL,
            KeyEvent.KEYCODE_DPAD_CENTER,
            KeyEvent.KEYCODE_CAMERA -> {
                if (interceptVolumeKeys) return true
                return super.onKeyUp(keyCode, event)
            }
        }
        return super.onKeyUp(keyCode, event)
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  前台服务通知通道 — 保留用于通知通道创建
    //  实际的前台服务由 TimerForegroundService 处理
    // ═══════════════════════════════════════════════════════════════════════════

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "蒸馒头计时器",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "计时提醒通知"
                setSound(null, null)
            }
            nm.createNotificationChannel(channel)
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  精确闹钟 — §5.1 AlarmManager 兜底
    // ═══════════════════════════════════════════════════════════════════════════

    private fun scheduleExactAlarm(id: Int, triggerAtMillis: Long, title: String, body: String) {
        val am = getSystemService(ALARM_SERVICE) as AlarmManager

        val intent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra("title", title)
            putExtra("body", body)
            putExtra("id", id)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            this, id, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !am.canScheduleExactAlarms()) {
                // 无精确闹钟权限，使用非精确闹钟降级
                am.set(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
            } else {
                am.setExact(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
            }
        } catch (e: SecurityException) {
            Log.w("MainActivity", "精确闹钟权限不足: ${e.message}")
            am.set(AlarmManager.RTC_WAKEUP, triggerAtMillis, pendingIntent)
        }
    }

    private fun cancelExactAlarm(id: Int) {
        val am = getSystemService(ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this, id, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        am.cancel(pendingIntent)
    }

    private fun canScheduleExactAlarms(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val am = getSystemService(ALARM_SERVICE) as AlarmManager
            return am.canScheduleExactAlarms()
        }
        return true
    }

    private fun requestExactAlarmPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            try {
                val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                intent.data = Uri.parse("package:$packageName")
                startActivity(intent)
            } catch (_: Exception) {
                try {
                    startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = Uri.parse("package:$packageName")
                    })
                } catch (_: Exception) {}
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  通知权限 — Android 13+
    // ═══════════════════════════════════════════════════════════════════════════

    private fun hasNotificationPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return true
        return ContextCompat.checkSelfPermission(
            this, android.Manifest.permission.POST_NOTIFICATIONS
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(true)
            return
        }
        // 不再无条件返回 true — 跳转设置页后用户可能未授权
        // Flutter 侧已改用 permission_handler 正确请求运行时权限
        // 此方法保留作为 fallback：永久拒绝时跳转设置页
        try {
            val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
            intent.putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            startActivity(intent)
        } catch (_: Exception) {}
        result.success(false)
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  电池优化 — §5.1 厂商白名单引导
    // ═══════════════════════════════════════════════════════════════════════════

    private fun isIgnoringBatteryOptimizations(): Boolean {
        val pm = getSystemService(POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    private fun requestIgnoreBatteryOptimizations() {
        try {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
            intent.data = Uri.parse("package:$packageName")
            startActivity(intent)
        } catch (_: Exception) {
            try {
                startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
            } catch (_: Exception) {}
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  原生定位 — 使用 Android LocationManager（NETWORK_PROVIDER）
    //  不依赖 Google Play 服务，室内可用基站/Wi-Fi 定位
    // ═══════════════════════════════════════════════════════════════════════════

    @SuppressLint("MissingPermission")
    private fun getLocation(result: MethodChannel.Result) {
        val lm = getSystemService(LOCATION_SERVICE) as LocationManager

        // 权限检查
        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION)
            != PackageManager.PERMISSION_GRANTED &&
            ContextCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_COARSE_LOCATION)
            != PackageManager.PERMISSION_GRANTED) {
            result.error("NO_PERMISSION", "缺少定位权限", null)
            return
        }

        // 打印所有 Provider 状态用于排查
        val allProviders = lm.allProviders
        for (p in allProviders) {
            Log.d("MainActivity", "Provider: $p, enabled=${lm.isProviderEnabled(p)}")
        }

        // 1. 先取各 Provider 的最后已知位置（瞬时返回，无需等待）
        val providers = listOf(LocationManager.NETWORK_PROVIDER, LocationManager.GPS_PROVIDER, LocationManager.PASSIVE_PROVIDER)
        var bestLast: Location? = null
        for (p in providers) {
            try {
                val loc = lm.getLastKnownLocation(p)
                Log.d("MainActivity", "LastKnown($p): ${loc?.latitude},${loc?.longitude} age=${if (loc != null) (System.currentTimeMillis() - loc.time) / 1000 else "null"}s")
                if (loc != null && (bestLast == null || loc.time > bestLast!!.time)) {
                    bestLast = loc
                }
            } catch (_: SecurityException) {}
        }
        // 最后已知位置在 10 分钟内 → 直接用
        if (bestLast != null && System.currentTimeMillis() - bestLast!!.time < 10 * 60 * 1000) {
            Log.d("MainActivity", "Using last known location: ${bestLast!!.latitude},${bestLast!!.longitude} from ${bestLast!!.provider}")
            result.success(mapOf("latitude" to bestLast!!.latitude, "longitude" to bestLast!!.longitude, "provider" to bestLast!!.provider))
            return
        }

        // 2. 并发请求所有可用 Provider — 谁先返回用谁
        val enabledProviders = providers.filter { 
            try { lm.isProviderEnabled(it) } catch (_: Exception) { false }
        }
        if (enabledProviders.isEmpty()) {
            if (bestLast != null) {
                result.success(mapOf("latitude" to bestLast!!.latitude, "longitude" to bestLast!!.longitude, "provider" to bestLast!!.provider))
            } else {
                result.error("NO_PROVIDER", "无可用定位服务", null)
            }
            return
        }

        Log.d("MainActivity", "Requesting updates from: $enabledProviders")
        val timeoutMs = 12000L
        var settled = false
        val listeners = mutableListOf<LocationListener>()

        // 超时兜底 — 先定义，listener 中可引用以提前移除
        val timeoutRunnable = Runnable {
            if (!settled) {
                settled = true
                for (l in listeners) {
                    try { lm.removeUpdates(l) } catch (_: Exception) {}
                }
                Log.w("MainActivity", "All providers timed out, bestLast=${bestLast?.latitude},${bestLast?.longitude}")
                if (bestLast != null) {
                    result.success(mapOf("latitude" to bestLast!!.latitude, "longitude" to bestLast!!.longitude, "provider" to bestLast!!.provider))
                } else {
                    result.error("TIMEOUT", "定位超时", null)
                }
            }
            locationTimeoutRunnable = null
            pendingLocationListeners.clear()
        }
        locationTimeoutRunnable = timeoutRunnable

        for (p in enabledProviders) {
            val listener = object : LocationListener {
                override fun onLocationChanged(location: Location) {
                    if (settled) return
                    settled = true
                    // 定位成功 → 移除超时回调，释放 result/listeners 引用
                    mainHandler.removeCallbacks(timeoutRunnable)
                    locationTimeoutRunnable = null
                    pendingLocationListeners.clear()
                    Log.d("MainActivity", "Got fresh location: ${location.latitude},${location.longitude} from ${location.provider} accuracy=${location.accuracy}m")
                    // 清理所有 listener
                    for (l in listeners) {
                        try { lm.removeUpdates(l) } catch (_: Exception) {}
                    }
                    result.success(mapOf("latitude" to location.latitude, "longitude" to location.longitude, "provider" to location.provider))
                }
                override fun onProviderDisabled(provider: String) {}
                override fun onProviderEnabled(provider: String) {}
                @Deprecated("deprecated")
                override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
            }
            listeners.add(listener)
            try {
                lm.requestLocationUpdates(p, 0L, 0F, listener, mainLooper)
                Log.d("MainActivity", "Registered listener for $p")
            } catch (e: SecurityException) {
                Log.w("MainActivity", "No permission for $p: ${e.message}")
            }
        }

        // 将已注册的 listeners 存入 pendingLocationListeners — 供 onDestroy 兜底清理
        pendingLocationListeners.addAll(listeners)

        mainHandler.postDelayed(timeoutRunnable, timeoutMs)
    }
    }

    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onDestroy() {
        super.onDestroy()
        // 兜底：Activity 被系统回收时释放麦克风资源
        if (isRecording) {
            stopAudioRecording()
        }
        // 清理待完成的定位请求 — 防止 listener 泄漏和 timeoutRunnable 触发已失效的 result
        locationTimeoutRunnable?.let { mainHandler.removeCallbacks(it) }
        locationTimeoutRunnable = null
        if (pendingLocationListeners.isNotEmpty()) {
            val lm = getSystemService(LOCATION_SERVICE) as? LocationManager
            for (l in pendingLocationListeners) {
                try { lm?.removeUpdates(l) } catch (_: Exception) {}
            }
            pendingLocationListeners.clear()
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  P3-1: 屏幕亮度控制 — 真正调用 WindowManager
    // ═══════════════════════════════════════════════════════════════════════════

    private fun setBrightness(brightness: Double) {
        val layoutParams = window.attributes
        if (brightness < 0) {
            // 恢复系统亮度
            layoutParams.screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
        } else {
            // 0.0 ~ 1.0 范围
            layoutParams.screenBrightness = brightness.toFloat().coerceIn(0.0f, 1.0f)
        }
        window.attributes = layoutParams
    }
}

// ═══════════════════════════════════════════════════════════════════════════
//  闹钟接收器 — AlarmManager 到点触发
// ═══════════════════════════════════════════════════════════════════════════

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra("title") ?: "蒸馒头计时器"
        val body = intent.getStringExtra("body") ?: ""
        // 读取复合 ID (batchNumber*10+slot) 作为通知 ID，确保多锅并行时各槽位独立展示
        val notifId = intent.getIntExtra("id", 8888)

        // 发送高优先级通知
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "steam_bun_alarm",
                "计时提醒",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "到点提醒"
                enableVibration(true)
            }
            nm.createNotificationChannel(channel)
        }

        // Android 14+ USE_FULL_SCREEN_INTENT 是受限权限
        // 计时类应用默认授予，但需检查 — 无权限时唤醒屏幕 + 高优先级通知降级
        val canFullScreen = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            nm.canUseFullScreenIntent()
        } else {
            true
        }

        // Android 10+ 限制后台 startActivity — 用 fullScreenIntent 替代
        // fullScreenIntent 在锁屏/熄屏时直接全屏显示，前台时作为 heads-up 通知
        val fullScreenIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            context, 0, fullScreenIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val builder = NotificationCompat.Builder(context, "steam_bun_alarm")
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_MAX)

        if (canFullScreen) {
            builder.setFullScreenIntent(fullScreenPendingIntent, true)
        } else {
            // 无全屏权限 — 唤醒屏幕让用户看到高优先级通知
            // acquire(3000) 已设超时自动释放，不可立即 release()
            // 立即 release 会导致屏幕瞬间熄灭，唤醒完全失效
            val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            @Suppress("DEPRECATION")
            val wl = pm.newWakeLock(
                PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP,
                "steam_bun:alarm"
            )
            wl.acquire(3000) // 3 秒后自动释放，不手动 release
        }

        // 设置 ContentIntent — 点击通知可打开 App
        builder.setContentIntent(fullScreenPendingIntent)

        val notification = builder.build()

        nm.notify(notifId, notification)
    }
}

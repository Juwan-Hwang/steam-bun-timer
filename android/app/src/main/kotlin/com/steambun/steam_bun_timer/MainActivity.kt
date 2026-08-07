package com.steambun.steam_bun_timer

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import android.view.KeyEvent
import android.view.WindowManager
import android.speech.SpeechRecognizer
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL_FOREGROUND = "com.steambun.steam_bun_timer/foreground"
    private val CHANNEL_VOICE = "com.steambun.steam_bun_timer/voice"
    private val NOTIFICATION_CHANNEL_ID = "steam_bun_timer"
    private val NOTIFICATION_ID = 1

    private var methodChannel: MethodChannel? = null
    private var voiceChannel: MethodChannel? = null
    private var isForegroundActive = false

    /// 音量键拦截开关 — 仅在有活跃批次时拦截
    private var interceptVolumeKeys = false

    // P1-1: 语音识别器
    private var speechRecognizer: SpeechRecognizer? = null
    private var isListening = false
    private var restartCount = 0
    private val maxRestarts = 10  // 连续重启上限，超过后停止

    // P3-1: 原始亮度倍数（-1 = 跟随系统）
    private var originalBrightness: Float = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── 前台服务 + 音量键 MethodChannel ──
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_FOREGROUND)
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

        // ── P1-1: 语音指令 MethodChannel ──
        voiceChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_VOICE)
        voiceChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    // 检查 SpeechRecognizer 是否可用
                    val available = SpeechRecognizer.isRecognitionAvailable(this)
                    result.success(available)
                }
                "startListening" -> {
                    val started = startVoiceListening()
                    result.success(started)
                }
                "stopListening" -> {
                    stopVoiceListening()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
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
                methodChannel?.invokeMethod("onKeyEvent", keyCode)
                return true
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
                return true
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
        // 通过 Activity Result API 请求
        // FlutterActivity 已处理权限请求回调
        try {
            val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
            intent.putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            startActivity(intent)
            result.success(true)
        } catch (_: Exception) {
            result.success(false)
        }
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
    //  P1-1: 语音指令 — Android SpeechRecognizer 关键词识别
    //  使用系统语音识别做轻量 KWS，识别结果匹配关键词后回调 Flutter
    // ═══════════════════════════════════════════════════════════════════════════

    private fun startVoiceListening(): Boolean {
        if (isListening) return true
        if (!SpeechRecognizer.isRecognitionAvailable(this)) {
            voiceChannel?.invokeMethod("onRecognitionFailed", null)
            return false
        }

        // 检查录音权限 — 无权限时请求而非直接失败
        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(arrayOf(android.Manifest.permission.RECORD_AUDIO), 1001)
            // 权限结果回调中重新尝试
            return false
        }

        // 连续重启超限 → 通知 Flutter 停用语音
        if (restartCount >= maxRestarts) {
            voiceChannel?.invokeMethod("onRecognitionFailed", null)
            isListening = false
            return false
        }

        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
        isListening = true
        voiceChannel?.invokeMethod("onListeningStarted", null)

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "zh-CN")
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
        }

        speechRecognizer?.setRecognitionListener(object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) {}
            override fun onBeginningOfSpeech() {
                // 成功开始监听 → 重置重启计数
                restartCount = 0
            }
            override fun onRmsChanged(rmsdB: Float) {}
            override fun onBufferReceived(buffer: ByteArray?) {}
            override fun onEndOfSpeech() {}
            override fun onError(error: Int) {
                if (isListening) {
                    restartCount++
                    speechRecognizer?.destroy()
                    speechRecognizer = null
                    // 延迟 500ms 重启
                    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                        if (isListening) startVoiceListening()
                    }, 500)
                }
            }

            override fun onResults(results: Bundle?) {
                val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                if (matches != null) {
                    val matchedCmd = matchVoiceCommand(matches)
                    if (matchedCmd >= 0) {
                        voiceChannel?.invokeMethod("onCommand", matchedCmd)
                    } else {
                        voiceChannel?.invokeMethod("onRecognitionFailed", null)
                    }
                }
                if (isListening) {
                    restartCount++
                    speechRecognizer?.destroy()
                    speechRecognizer = null
                    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                        if (isListening) startVoiceListening()
                    }, 300)
                }
            }

            override fun onPartialResults(partialResults: Bundle?) {
                val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                if (matches != null) {
                    val matchedCmd = matchVoiceCommand(matches)
                    if (matchedCmd >= 0) {
                        voiceChannel?.invokeMethod("onCommand", matchedCmd)
                        if (isListening) {
                            restartCount++
                            speechRecognizer?.destroy()
                            speechRecognizer = null
                            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                                if (isListening) startVoiceListening()
                            }, 300)
                        }
                    }
                }
            }

            override fun onEvent(eventType: Int, params: Bundle?) {}
        })

        speechRecognizer?.startListening(intent)
        return true
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 1001) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // 权限授予 → 重新启动监听
                val started = startVoiceListening()
                if (!started) {
                    // 权限已授予但仍未启动（如重启超限）
                    voiceChannel?.invokeMethod("onRecognitionFailed", null)
                }
            } else {
                // 权限拒绝 → 通知 Flutter
                voiceChannel?.invokeMethod("onRecognitionFailed", null)
            }
        }
    }

    private fun stopVoiceListening() {
        isListening = false
        restartCount = 0
        speechRecognizer?.stopListening()
        speechRecognizer?.destroy()
        speechRecognizer = null
    }

    /// 匹配语音指令 — 返回 VoiceCommand enum index（0-3），-1 = 未匹配
    /// 单字「好」不触发，至少「好了」二字才匹配
    private fun matchVoiceCommand(matches: List<String>): Int {
        for (text in matches) {
            val lower = text.lowercase()
            // 0: startBoiling 「开始烧水」
            if (lower.contains("烧水") || lower.contains("烧开")) return 0
            // 1: startSteaming 「开始蒸」
            if (lower.contains("开始蒸") || lower.contains("上锅")) return 1
            // 2: done 「好了」/「完成」/「确认」— 不匹配单字「好」
            if (lower.contains("好了") || lower.contains("完成") || lower.contains("确认") || lower.contains("结束了")) return 2
            // 3: addTwoMinutes 「加两分钟」
            if (lower.contains("加两分钟") || lower.contains("加2分钟") || lower.contains("加二分钟")) return 3
        }
        return -1
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

        // I2: Android 10+ 限制后台 startActivity — 用 fullScreenIntent 替代
        // fullScreenIntent 在锁屏/熄屏时直接全屏显示，前台时作为 heads-up 通知
        val fullScreenIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            context, 0, fullScreenIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val notification = NotificationCompat.Builder(context, "steam_bun_alarm")
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setAutoCancel(true)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .build()

        nm.notify(System.currentTimeMillis().toInt(), notification)
    }
}

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

    // P1-1: 语音识别器
    private var speechRecognizer: SpeechRecognizer? = null
    private var isListening = false

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
                    startVoiceListening()
                    result.success(null)
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
                // 通知 Flutter 层
                methodChannel?.invokeMethod("onKeyEvent", keyCode)
                // 返回 true 拦截系统音量调节
                return true
            }
        }
        return super.onKeyDown(keyCode, event)
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        when (keyCode) {
            KeyEvent.KEYCODE_VOLUME_UP,
            KeyEvent.KEYCODE_VOLUME_DOWN -> {
                // 拦截音量键的默认行为
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

    private fun startVoiceListening() {
        if (isListening) return
        if (!SpeechRecognizer.isRecognitionAvailable(this)) {
            voiceChannel?.invokeMethod("onRecognitionFailed", null)
            return
        }

        // 检查录音权限
        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED) {
            voiceChannel?.invokeMethod("onRecognitionFailed", null)
            return
        }

        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
        isListening = true

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "zh-CN")
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
        }

        speechRecognizer?.setRecognitionListener(object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) {}
            override fun onBeginningOfSpeech() {}
            override fun onRmsChanged(rmsdB: Float) {}
            override fun onBufferReceived(buffer: ByteArray?) {}
            override fun onEndOfSpeech() {}
            override fun onError(error: Int) {
                // 错误后自动重启监听（保持持续 KWS）
                if (isListening) {
                    speechRecognizer?.destroy()
                    speechRecognizer = null
                    // 延迟 500ms 重启，避免频繁崩溃
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
                // 识别完一组结果后自动重启
                if (isListening) {
                    speechRecognizer?.destroy()
                    speechRecognizer = null
                    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                        if (isListening) startVoiceListening()
                    }, 300)
                }
            }

            override fun onPartialResults(partialResults: Bundle?) {
                // 部分结果也尝试匹配，提高响应速度
                val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                if (matches != null) {
                    val matchedCmd = matchVoiceCommand(matches)
                    if (matchedCmd >= 0) {
                        voiceChannel?.invokeMethod("onCommand", matchedCmd)
                        // 匹配成功后重启
                        if (isListening) {
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
    }

    private fun stopVoiceListening() {
        isListening = false
        speechRecognizer?.stopListening()
        speechRecognizer?.destroy()
        speechRecognizer = null
    }

    /// 匹配语音指令 — 返回 VoiceCommand enum index（0-3），-1 = 未匹配
    private fun matchVoiceCommand(matches: List<String>): Int {
        for (text in matches) {
            val lower = text.lowercase()
            // 0: startBoiling 「开始烧水」
            if (lower.contains("烧水") || lower.contains("烧开")) return 0
            // 1: startSteaming 「开始蒸」
            if (lower.contains("开始蒸") || lower.contains("上锅")) return 1
            // 2: done 「好了」/「完成」/「确认」
            if (lower.contains("好了") || lower.contains("完成") || lower.contains("确认") || lower.contains("好")) return 2
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

        val notification = NotificationCompat.Builder(context, "steam_bun_alarm")
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setAutoCancel(true)
            .build()

        nm.notify(System.currentTimeMillis().toInt(), notification)

        // 同时通过 MethodChannel 通知 Flutter 层（如果 App 在前台）
        try {
            val mainIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            context.startActivity(mainIntent)
        } catch (_: Exception) {}
    }
}

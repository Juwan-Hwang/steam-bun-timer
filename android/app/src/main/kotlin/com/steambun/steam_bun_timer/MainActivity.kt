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
    private var isForegroundActive = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── 前台服务 + 音量键 MethodChannel ──
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_FOREGROUND)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startForeground" -> {
                    val title = call.argument<String>("title") ?: "蒸馒头计时器"
                    val content = call.argument<String>("content") ?: "运行中"
                    startForegroundNotification(title, content)
                    result.success(null)
                }
                "updateNotification" -> {
                    val content = call.argument<String>("content") ?: ""
                    updateNotification(content)
                    result.success(null)
                }
                "stopForeground" -> {
                    stopForegroundNotification()
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
    //  前台服务通知 — §5.1 保活
    // ═══════════════════════════════════════════════════════════════════════════

    private fun startForegroundNotification(title: String, content: String) {
        val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager

        // 创建通知通道
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "蒸馒头计时器",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "计时提醒通知"
                setSound(null, null) // 提醒声音由 Flutter 层控制
            }
            nm.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(content)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        try {
            nm.notify(NOTIFICATION_ID, notification)
            isForegroundActive = true
        } catch (e: SecurityException) {
            // 通知权限未授予
            Log.w("MainActivity", "通知权限未授予: ${e.message}")
        }
    }

    private fun updateNotification(content: String) {
        if (!isForegroundActive) return
        val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        val notification = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("蒸馒头计时器")
            .setContentText(content)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()
        try {
            nm.notify(NOTIFICATION_ID, notification)
        } catch (_: SecurityException) {}
    }

    private fun stopForegroundNotification() {
        val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        nm.cancel(NOTIFICATION_ID)
        isForegroundActive = false
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
            .setSmallIcon(android.R.drawable.ic_dialog_alarm)
            .setPriority(NotificationCompat.PRIORITY_MAX)
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

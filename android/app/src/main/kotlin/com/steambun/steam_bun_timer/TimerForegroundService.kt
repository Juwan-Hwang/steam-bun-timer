package com.steambun.steam_bun_timer

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.KeyEvent
import androidx.core.app.NotificationCompat

/// ═══════════════════════════════════════════════════════════════════════════
///  真正的前台服务 — §5.1 后台保活
///  通过 startForeground() 提升为前台服务，系统不会轻易杀死
/// ═══════════════════════════════════════════════════════════════════════════
class TimerForegroundService : Service() {

    companion object {
        private const val CHANNEL_ID = "steam_bun_timer_foreground"
        private const val NOTIFICATION_ID = 1

        const val EXTRA_TITLE = "title"
        const val EXTRA_CONTENT = "content"

        /// 🔴2: MediaSession 后台媒体按键回调 — 由 MainActivity 设置
        /// 前台服务持有活跃 MediaSession，蓝牙/线控按键在后台也能到达
        var onMediaKey: ((Int) -> Unit)? = null

        /// 从外部启动服务
        fun start(context: Context, title: String, content: String) {
            val intent = Intent(context, TimerForegroundService::class.java).apply {
                putExtra(EXTRA_TITLE, title)
                putExtra(EXTRA_CONTENT, content)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        /// 更新通知内容
        fun update(context: Context, content: String) {
            val intent = Intent(context, TimerForegroundService::class.java).apply {
                putExtra(EXTRA_CONTENT, content)
                action = "UPDATE"
            }
            context.startService(intent)
        }

        /// 停止服务
        fun stop(context: Context) {
            context.stopService(Intent(context, TimerForegroundService::class.java))
        }
    }

    private var title: String = "蒸馒头计时器"
    private var content: String = "运行中"
    private var mediaSession: MediaSession? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        setupMediaSession()
    }

    /// 🔴2: 创建 MediaSession 捕获后台媒体按键
    /// 前台服务运行期间，蓝牙耳机/线控的 PLAY/PAUSE/HEADSETHOOK 等按键
    /// 由系统路由到活跃 MediaSession，不再依赖 Activity 级 onKeyDown
    private fun setupMediaSession() {
        try {
            mediaSession = MediaSession(this, "SteamBunTimer")
            mediaSession?.setFlags(
                MediaSession.FLAG_HANDLES_MEDIA_BUTTONS or
                MediaSession.FLAG_HANDLES_TRANSPORT_CONTROLS
            )
            // 设置 PLAYING 状态让系统将媒体按键路由到此 session
            val state = PlaybackState.Builder()
                .setState(PlaybackState.STATE_PLAYING, 0, 1.0f)
                .build()
            mediaSession?.setPlaybackState(state)
            mediaSession?.setCallback(object : MediaSession.Callback() {
                override fun onMediaButtonEvent(mediaButtonIntent: Intent): Boolean {
                    val keyEvent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        mediaButtonIntent.getParcelableExtra(Intent.EXTRA_KEY_EVENT, KeyEvent::class.java)
                    } else {
                        @Suppress("DEPRECATION")
                        mediaButtonIntent.getParcelableExtra(Intent.EXTRA_KEY_EVENT) as? KeyEvent
                    }
                    if (keyEvent != null && keyEvent.action == KeyEvent.ACTION_DOWN) {
                        onMediaKey?.invoke(keyEvent.keyCode)
                        return true
                    }
                    return super.onMediaButtonEvent(mediaButtonIntent)
                }
            })
            mediaSession?.isActive = true
        } catch (e: Exception) {
            Log.w("TimerForegroundService", "MediaSession setup failed: ${e.message}")
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == "UPDATE") {
            content = intent.getStringExtra(EXTRA_CONTENT) ?: content
        } else {
            title = intent?.getStringExtra(EXTRA_TITLE) ?: title
            content = intent?.getStringExtra(EXTRA_CONTENT) ?: content
        }

        // 关键：调用 startForeground() 提升为前台服务
        // Android 14+ (API 34) 声明了 foregroundServiceType 必须用三参重载
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(NOTIFICATION_ID, buildNotification(),
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(NOTIFICATION_ID, buildNotification())
        }
        return START_STICKY
    }

    override fun onDestroy() {
        mediaSession?.isActive = false
        mediaSession?.release()
        mediaSession = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "蒸馒头计时器前台服务",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "计时保活服务"
                setShowBadge(false)
                setSound(null, null)
            }
            val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(content)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }
}

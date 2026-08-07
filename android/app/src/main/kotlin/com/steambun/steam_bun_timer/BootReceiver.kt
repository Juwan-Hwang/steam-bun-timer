package com.steambun.steam_bun_timer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/// 开机自启接收器 — 设备重启后恢复前台服务保活
/// 仅在关机前有活跃批次时启动，避免无条件空转（R3 修复）
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        // 读取 Flutter shared_preferences 写入的标志
        // Flutter 的 shared_preferences 包在 Android 上写入 FlutterSharedPreferences 文件，
        // 且所有 key 自动加 flutter. 前缀（N1 修复）
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val hasActive = prefs.getBoolean("flutter.has_active", false)
        if (!hasActive) return

        // 启动前台服务 — 保持进程存活
        // Flutter 引擎在用户打开 App 后启动，restoreFromPersistence 重建完整状态并重注册闹钟
        TimerForegroundService.start(context, "蒸馒头计时器", "恢复中…")
    }
}

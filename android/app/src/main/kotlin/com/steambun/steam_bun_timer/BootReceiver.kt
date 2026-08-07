package com.steambun.steam_bun_timer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/// 开机自启接收器 — 设备重启后恢复前台服务保活
/// 仅在关机前有活跃批次时启动，避免无条件空转（R3 修复）
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        // 检查关机前是否有活跃批次 — 由 Flutter 侧 ActiveBatchStorage 写入
        val prefs = context.getSharedPreferences("active_batch_meta", Context.MODE_PRIVATE)
        val hasActive = prefs.getBoolean("has_active", false)
        if (!hasActive) return

        // 启动前台服务 — 保持进程存活，AlarmManager 到点时可唤醒
        // Flutter 引擎在用户打开 App 后启动，restoreFromPersistence 重建完整状态
        TimerForegroundService.start(context, "蒸馒头计时器", "恢复中…")
    }
}

package com.steambun.steam_bun_timer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/// 开机自启接收器 — 设备重启后恢复前台服务保活
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return

        // 启动前台服务 — Flutter 引擎尚未运行，仅显示占位通知
        // Flutter 启动后会通过 MethodChannel 更新通知内容
        TimerForegroundService.start(context, "蒸馒头计时器", "恢复中…")
    }
}

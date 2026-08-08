/// 提醒管理器 — §5.2 提醒强度
/// 录音优先播报(缺失时 TTS 降级) + 振动 + 屏幕整屏变红大字闪烁
/// 直到确认才停止
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'announcement_player.dart';
import 'foreground_task_handler.dart';
import 'voice_command_service.dart';

/// 提醒级别
enum ReminderLevel {
  /// 动作节点 — TTS 循环播报 + 振动 + 红色闪烁
  action,
  /// 焖制轻提示 — 一声播报，非循环
  simmeringHint,
  /// 间歇提醒 — 每 30 秒一次
  intermittent,
}

/// 提醒请求
class ReminderRequest {
  final int batchNumber;
  final String batchId;
  final String recipeName;
  final String recipeId;
  final String actionText;
  final ReminderLevel level;

  const ReminderRequest({
    required this.batchNumber,
    required this.batchId,
    required this.recipeName,
    required this.recipeId,
    required this.actionText,
    this.level = ReminderLevel.action,
  });
}

/// 提醒管理器 — 单例
class ReminderManager {
  ReminderManager._();
  static final instance = ReminderManager._();

  final AudioPlayer _alarmPlayer = AudioPlayer();

  /// 当前活跃的提醒
  ReminderRequest? _activeReminder;
  ReminderRequest? get activeReminder => _activeReminder;

  /// 是否正在提醒
  bool get isReminding => _activeReminder != null;

  /// 循环播报定时器
  Timer? _loopTimer;

  /// 停止提醒回调（由 UI 层设置）
  VoidCallback? onReminderStop;

  /// 开始提醒
  Future<void> start(ReminderRequest request) async {
    if (_activeReminder != null) {
      // 仅当新请求优先级严格更低时才丢弃
      // 同级或更高 → 替换（多锅同时到点不丢提醒）
      if (request.level.index > _activeReminder!.level.index) return;
      // await 内部停止 — 防止 stop() 的 setAnnouncing(false) 覆盖新请求的 setAnnouncing(true)（R2 修复）
      await _stopInternal();
    }

    _activeReminder = request;

    // 播报期间暂停语音识别 — 防止自触发（I2 修复）
    VoiceCommandService.instance.setAnnouncing(true);

    // 播放语音播报（录音优先，TTS 兜底）
    await _playAnnouncement(request);

    // 🟡3: 播报期间可能被 stop() 中断 — 检查是否仍活跃，防止空转幽灵铃
    // stop() 会将 _activeReminder 置 null 并取消 _loopTimer
    // 若不检查，await 返回后仍会启动新 _playAlarmLoop + _loopTimer
    if (_activeReminder == null) return;

    // 动作节点级别：循环铃声 + 振动
    if (request.level == ReminderLevel.action) {
      _playAlarmLoop();
      _vibratePattern();
      // 每 8 秒重新播报语音
      _loopTimer?.cancel();
      _loopTimer = Timer.periodic(const Duration(seconds: 8), (_) {
        _playAnnouncement(request);
        _vibratePattern();
      });
    } else if (request.level == ReminderLevel.intermittent) {
      // 间歇提醒 — 播一次铃声 + 轻振动
      _playBeep();
      _vibrateOnce();
    }
    // simmeringHint 只播语音，不加铃声/振动
  }

  /// 内部停止 — 不触发 onReminderStop / setAnnouncing(false)
  /// 用于 start() 替换场景，避免回调竞态（R2 修复）
  /// 内部停止 — 不触发 onReminderStop / setAnnouncing(false)
  /// 用于 start() 替换场景，避免回调竞态（R2 修复）
  Future<void> _stopInternal() async {
    // 同步立即清除 _activeReminder — isReminding 立即变 false
    // 防止 _tick 中调用 stop() 不 await 时 _checkPendingReminders 被阻塞
    final reminder = _activeReminder;
    _activeReminder = null;

    _loopTimer?.cancel();
    _loopTimer = null;
    try { await _alarmPlayer.stop(); } catch (_) {}
    await AnnouncementPlayer.instance.stop();
    // I1-4: 取消两个闹钟槽位（current slot 0 + parallel slot 1）
    if (reminder != null) {
      final baseId = reminder.batchNumber * 10;
      ForegroundTaskHandler.instance.cancelExactAlarm(baseId);
      ForegroundTaskHandler.instance.cancelExactAlarm(baseId + 1);
    }
  }

  /// 停止所有提醒
  Future<void> stop() async {
    await _stopInternal();
    // 恢复语音识别
    VoiceCommandService.instance.setAnnouncing(false);
    onReminderStop?.call();
  }

  /// 播放语音播报
  Future<void> _playAnnouncement(ReminderRequest request) async {
    await AnnouncementPlayer.instance.play(AnnouncementRequest(
      number: request.batchNumber,
      recipeId: request.recipeId,
      actionText: request.actionText,
    ));
  }

  /// 循环播放铃声 — 录音文件缺失时仅靠振动
  Future<void> _playAlarmLoop() async {
    try {
      await _alarmPlayer.setReleaseMode(ReleaseMode.loop);
      await _alarmPlayer.setVolume(1.0);
      await _alarmPlayer.play(AssetSource('audio/alarm.mp3'));
    } catch (_) {
      // 铃声文件不存在，振动兜底已由 _vibratePattern 处理
    }
  }

  /// 单声提示音 — 录音文件缺失时静默
  Future<void> _playBeep() async {
    try {
      await _alarmPlayer.setReleaseMode(ReleaseMode.release);
      await _alarmPlayer.play(AssetSource('audio/beep.mp3'));
    } catch (_) {}
  }

  /// 振动模式 — 长振动 + 短暂停 + 长振动
  Future<void> _vibratePattern() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(pattern: [800, 400, 800]);
      }
    } catch (_) {}
  }

  /// 单次振动
  Future<void> _vibrateOnce() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 300);
      }
    } catch (_) {}
  }
}

/// 全屏红色闪烁提醒覆盖层 — §5.2 屏幕整屏变红大字闪烁
class ReminderOverlay extends StatefulWidget {
  final ReminderRequest reminder;
  final VoidCallback onConfirm;

  /// 永久关闭此提醒 — 点击「不再提醒」按钮时触发
  /// 与 onConfirm 不同：onConfirm 仅关闭当前提醒，后续仍会间歇提醒
  /// onDismissPermanently 关闭当前提醒且今后不再提醒此事
  final VoidCallback? onDismissPermanently;

  const ReminderOverlay({
    super.key,
    required this.reminder,
    required this.onConfirm,
    this.onDismissPermanently,
  });

  @override
  State<ReminderOverlay> createState() => _ReminderOverlayState();
}

class _ReminderOverlayState extends State<ReminderOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkCtrl;

  @override
  void initState() {
    super.initState();
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reminder;
    return AnimatedBuilder(
      animation: _blinkCtrl,
      builder: (context, _) {
        final isRed = _blinkCtrl.value > 0.5;
        return Material(
          color: isRed ? const Color(0xEFEF4444) : const Color(0xE7000000),
          child: SafeArea(
            child: Column(
              children: [
                // 主可点击区域 — 点击任意位置仅关闭当前提醒
                Expanded(
                  child: InkWell(
                    onTap: widget.onConfirm,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 超大编号
                          Text(
                            '${r.batchNumber}号',
                            style: const TextStyle(
                              fontSize: 120,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -4,
                            ),
                          ),
                          Text(
                            r.recipeName,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            r.actionText,
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 48),
                          // 提示操作
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(9999),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: const Text(
                              '点击屏幕 / 音量键 / 蓝牙键 确认',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 「不再提醒」按钮 — 永久关闭此事提醒
                if (widget.onDismissPermanently != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: TextButton.icon(
                      onPressed: widget.onDismissPermanently,
                      icon: const Icon(Icons.notifications_off_outlined, size: 20, color: Colors.white70),
                      label: const Text(
                        '不再提醒',
                        style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

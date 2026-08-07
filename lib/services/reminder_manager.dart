/// 提醒管理器 — §5.2 提醒强度
/// 最大音量铃声 + 川话语音播报 + 屏幕整屏变红大字闪烁
/// 直到确认才停止
library;

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'announcement_player.dart';

/// 提醒级别
enum ReminderLevel {
  /// 动作节点 — 最大音量铃声 + 语音播报 + 红色闪烁
  action,
  /// 焖制轻提示 — 一声轻提示，非循环
  simmeringHint,
  /// 间歇提醒 — 每 30 秒一次
  intermittent,
}

/// 提醒请求
class ReminderRequest {
  final int batchNumber;
  final String recipeName;
  final String recipeId;
  final String actionText;
  final ReminderLevel level;

  const ReminderRequest({
    required this.batchNumber,
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

  final _audioPlayer = AudioPlayer();

  /// 当前活跃的提醒
  ReminderRequest? _activeReminder;
  ReminderRequest? get activeReminder => _activeReminder;

  /// 是否正在提醒
  bool get isReminding => _activeReminder != null;

  /// 停止提醒回调（由 UI 层设置）
  VoidCallback? onReminderStop;

  /// 开始提醒
  Future<void> start(ReminderRequest request) async {
    if (_activeReminder != null) {
      // 已有提醒在运行，如果是更高级别则替换
      if (request.level.index <= _activeReminder!.level.index) return;
      stop();
    }

    _activeReminder = request;

    // 播放川话语音播报
    await _playAnnouncement(request);

    // 动作节点级别：循环播放铃声
    if (request.level == ReminderLevel.action) {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);
      // 铃声文件路径 — 需放入 assets/audio/
      try {
        await _audioPlayer.play(AssetSource('audio/alarm.mp3'));
      } catch (_) {
        // 音频文件不存在时静默降级
      }
    } else if (request.level == ReminderLevel.intermittent) {
      // 间歇提醒 — 播一次
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      try {
        await _audioPlayer.play(AssetSource('audio/beep.mp3'));
      } catch (_) {}
    }
    // simmeringHint 只播语音，不加铃声
  }

  /// 停止所有提醒
  Future<void> stop() async {
    await _audioPlayer.stop();
    _activeReminder = null;
    onReminderStop?.call();
  }

  /// 播放川话语音播报
  Future<void> _playAnnouncement(ReminderRequest request) async {
    final player = AnnouncementPlayer();
    await player.play(AnnouncementRequest(
      number: request.batchNumber,
      recipeId: request.recipeId,
      actionText: request.actionText,
    ));
  }
}

/// 全屏红色闪烁提醒覆盖层 — §5.2 屏幕整屏变红大字闪烁
class ReminderOverlay extends StatefulWidget {
  final ReminderRequest reminder;
  final VoidCallback onConfirm;

  const ReminderOverlay({
    super.key,
    required this.reminder,
    required this.onConfirm,
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
        );
      },
    );
  }
}

/// 出锅完美反馈 — 音效 + 震动编排（游戏化「完美通关」手感）
/// 震动鼓点: 哒(120) → 哒(190) → 咚!(255)，与 finish_sting.mp3 的
/// 「蒸汽嗤声 → 编钟上扬 → 锣声定音」逐拍对齐
/// 音效文件缺失时静默降级，震动与动效不受影响
library;

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class FinishFeedback {
  FinishFeedback._();

  /// 独立于播报引擎的播放器 — 出锅音效不打断/不被打断川话播报
  static final AudioPlayer _player = AudioPlayer();

  /// 触发一次完整的出锅反馈（音效 + 震动）
  static Future<void> celebrate() async {
    unawaited(_vibrateDrumroll());
    unawaited(_playSting());
  }

  /// 鼓点三段式震动 — 轻、中、重收尾，模拟「落盖定音」
  static Future<void> _vibrateDrumroll() async {
    try {
      if (await Vibration.hasVibrator() != true) return;
      await Vibration.vibrate(
        // [等待, 震动, 等待, 震动, 等待, 震动]
        pattern: [0, 70, 60, 110, 90, 260],
        intensities: [0, 120, 0, 190, 0, 255],
      );
    } catch (_) {
      // 老设备不支持自定义强度 → 退化为单次重震
      try {
        Vibration.vibrate(duration: 300);
      } catch (_) {}
    }
  }

  /// 出锅庆祝音效 — assets/audio/finish_sting.mp3（Suno 生成后放入）
  static Future<void> _playSting() async {
    try {
      await _player.play(AssetSource('audio/finish_sting.mp3'), volume: 1.0);
    } catch (_) {
      // 音频文件尚未生成/放入 assets → 静默降级
    }
  }
}

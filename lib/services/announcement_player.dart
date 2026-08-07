/// 川话播报引擎 — §5.2 分段录音拼接
/// 分三段：数字段 + 品种段 + 动作段，按顺序拼接播放
library;

import 'dart:collection';
import 'package:audioplayers/audioplayers.dart';

/// 播报段类型
enum AnnouncementSegment { number, variety, action }

class AnnouncementItem {
  final String text;
  final String audioAsset;
  const AnnouncementItem({required this.text, required this.audioAsset});
}

/// 川话播报文案清单 — §5.2 录音文案清单（V1 交付物）
class AnnouncementCatalog {
  AnnouncementCatalog._();

  /// 数字段（3条）— 编号回收复用最多 3 个
  static const numbers = [
    AnnouncementItem(text: '1号', audioAsset: 'number_1.wav'),
    AnnouncementItem(text: '2号', audioAsset: 'number_2.wav'),
    AnnouncementItem(text: '3号', audioAsset: 'number_3.wav'),
  ];

  /// 品种段（4条）
  static const varieties = [
    AnnouncementItem(text: '白馒头', audioAsset: 'variety_white_bun.wav'),
    AnnouncementItem(text: '甜馒头', audioAsset: 'variety_sweet_bun.wav'),
    AnnouncementItem(text: '小馒头', audioAsset: 'variety_small_bun.wav'),
    AnnouncementItem(text: '饼子', audioAsset: 'variety_flatbread.wav'),
  ];

  /// 动作段（5条）
  static const actions = [
    AnnouncementItem(text: '该烧水了', audioAsset: 'action_boil_water.wav'),
    AnnouncementItem(text: '该上锅了', audioAsset: 'action_put_on_steamer.wav'),
    AnnouncementItem(text: '发酵好了', audioAsset: 'action_fermentation_done.wav'),
    AnnouncementItem(text: '该关火了', audioAsset: 'action_turn_off_fire.wav'),
    AnnouncementItem(text: '可以揭锅了', audioAsset: 'action_uncover.wav'),
  ];

  static AnnouncementItem? getNumber(int n) =>
      (n >= 1 && n <= 3) ? numbers[n - 1] : null;

  static AnnouncementItem? getVariety(String recipeId) {
    final map = {
      'white_bun': varieties[0],
      'sweet_bun': varieties[1],
      'small_bun': varieties[2],
      'flatbread': varieties[3],
    };
    return map[recipeId];
  }

  static AnnouncementItem? getAction(String text) {
    for (final a in actions) {
      if (a.text == text) return a;
    }
    return null;
  }
}

/// 播报请求 — 编号 + 品种 + 动作
class AnnouncementRequest {
  final int number;
  final String recipeId;
  final String actionText;

  const AnnouncementRequest({
    required this.number,
    required this.recipeId,
    required this.actionText,
  });

  @override
  String toString() {
    final n = AnnouncementCatalog.getNumber(number);
    final v = AnnouncementCatalog.getVariety(recipeId);
    final a = AnnouncementCatalog.getAction(actionText);
    return '${n?.text ?? ''}${v?.text ?? ''}${a?.text ?? ''}';
  }
}

/// 川话播报引擎 — 单例
class AnnouncementPlayer {
  AnnouncementPlayer._();
  static final instance = AnnouncementPlayer._();
  factory AnnouncementPlayer() => instance;

  final _player = AudioPlayer();
  final Queue<String> _queue = Queue();
  bool _isPlaying = false;

  /// 播放一条完整的播报
  Future<void> play(AnnouncementRequest req) async {
    final segments = <String>[];
    final n = AnnouncementCatalog.getNumber(req.number);
    final v = AnnouncementCatalog.getVariety(req.recipeId);
    final a = AnnouncementCatalog.getAction(req.actionText);
    if (n != null) segments.add(n.audioAsset);
    if (v != null) segments.add(v.audioAsset);
    if (a != null) segments.add(a.audioAsset);
    for (final s in segments) {
      _queue.add(s);
    }
    await _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isPlaying) return;
    _isPlaying = true;
    while (_queue.isNotEmpty) {
      final asset = _queue.removeFirst();
      try {
        await _player.play(AssetSource('audio/$asset'));
        await _player.onPlayerComplete.first;
      } catch (_) {
        // 音频文件不存在时跳过
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    _isPlaying = false;
  }

  /// 停止播放
  Future<void> stop() async {
    _queue.clear();
    await _player.stop();
    _isPlaying = false;
  }
}

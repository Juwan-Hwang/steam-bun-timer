/// 川话播报引擎 — §5.2 分段录音拼接 (优先) + TTS 降级 (兜底)
/// 策略：
///   1. 优先尝试播放 assets/audio/ 下的预录川话分段音频
///   2. 若音频文件缺失或播放失败，自动降级到 TTS 合成语音
/// 这样有录音时用录音（纯正川味），没录音时也不静默
library;

import 'dart:collection';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

  /// 数字段（6条）— 1~6 号
  static const numbers = [
    AnnouncementItem(text: '1号', audioAsset: 'number_1.wav'),
    AnnouncementItem(text: '2号', audioAsset: 'number_2.wav'),
    AnnouncementItem(text: '3号', audioAsset: 'number_3.wav'),
    AnnouncementItem(text: '4号', audioAsset: 'number_4.wav'),
    AnnouncementItem(text: '5号', audioAsset: 'number_5.wav'),
    AnnouncementItem(text: '6号', audioAsset: 'number_6.wav'),
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
      (n >= 1 && n <= numbers.length) ? numbers[n - 1] : null;

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

  /// TTS 降级时使用的文案
  String get speechText {
    final n = AnnouncementCatalog.getNumber(number);
    final v = AnnouncementCatalog.getVariety(recipeId);
    final a = AnnouncementCatalog.getAction(actionText);
    return '${n?.text ?? ''} ${v?.text ?? ''} ${a?.text ?? ''}';
  }
}

/// 川话播报引擎 — 单例，录音优先 + TTS 兜底
class AnnouncementPlayer {
  AnnouncementPlayer._();
  static final instance = AnnouncementPlayer._();
  factory AnnouncementPlayer() => instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  final Queue<String> _queue = Queue();
  bool _isPlaying = false;
  bool _ttsReady = false;

  /// 最新的播报请求 — _isPlaying 时 play() 被跳过，用此字段补播
  AnnouncementRequest? _latestReq;

  /// 播放一条完整的播报
  Future<void> play(AnnouncementRequest req) async {
    _latestReq = req;
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
    await _processQueue(req);
  }

  /// 依次播放队列中的音频段；某段播放失败时切换到 TTS 兜底
  Future<void> _processQueue(AnnouncementRequest req) async {
    if (_isPlaying) return;
    _isPlaying = true;

    bool usedTtsFallback = false;

    while (_queue.isNotEmpty) {
      final asset = _queue.removeFirst();
      final ok = await _playAudioSegment(asset);
      if (!ok) {
        // 录音播放失败 → 整体切换到 TTS 播报完整文案
        _queue.clear();
        await _playTts(req);
        usedTtsFallback = true;
        break;
      }
    }

    // 队列为空且全程用录音 → 正常结束
    // 如果使用了 TTS 兜底，上面已经 break 了
    if (!usedTtsFallback) {
      // 全部用录音播放完毕
    }

    _isPlaying = false;

    // 播放期间如果有新的 play() 被跳过，补播最新的请求
    if (_latestReq != null && _latestReq != req) {
      final pending = _latestReq!;
      _latestReq = null;
      await play(pending);
    } else {
      _latestReq = null;
    }
  }

  /// 播放单个音频分段，返回是否成功
  /// P2-3: 用 onPlayerComplete + onPlayerStateChanged + 超时三路竞速
  /// 避免录音缺失时 onPlayerComplete 永不触发导致 _isPlaying 永久卡死
  Future<bool> _playAudioSegment(String asset) async {
    try {
      await _audioPlayer.play(AssetSource('audio/$asset'));
      // 竞速等待：
      //   onPlayerComplete → 成功
      //   onPlayerStateChanged 回到 stopped → 失败（文件缺失/播放错误）
      //   3 秒超时 → 失败
      final result = await Future.any([
        _audioPlayer.onPlayerComplete.first.then((_) => true),
        _audioPlayer.onPlayerStateChanged
            .where((s) => s == PlayerState.stopped)
            .first
            .then((_) => false),
        Future<bool>.delayed(const Duration(seconds: 5), () => false),
      ]);
      return result;
    } catch (_) {
      return false;
    }
  }

  /// TTS 降级播报
  Future<void> _playTts(AnnouncementRequest req) async {
    if (!_ttsReady) {
      try {
        await _tts.setLanguage('zh-CN');
        await _tts.setSpeechRate(0.45);
        await _tts.setVolume(1.0);
        await _tts.setPitch(1.0);
        _ttsReady = true;
      } catch (_) {
        // TTS 引擎不可用，彻底静默
        return;
      }
    }
    try {
      await _tts.speak(req.speechText);
    } catch (_) {}
  }

  /// 停止播放
  Future<void> stop() async {
    _queue.clear();
    _latestReq = null;
    try { await _audioPlayer.stop(); } catch (_) {}
    try { await _tts.stop(); } catch (_) {}
    _isPlaying = false;
  }
}

/// 川话播报引擎 — §5.2 分段录音拼接 (优先) + TTS 降级 (兜底)
/// 策略：
///   1. 优先尝试播放 assets/audio/ 下的预录川话分段音频
///   2. 若音频文件缺失或播放失败，自动降级到 TTS 合成语音
/// 这样有录音时用录音（纯正川味），没录音时也不静默
library;

import 'dart:async';
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

  /// stop() 标志 — 防止 stop 后仍触发 TTS 兜底或补播
  bool _stopped = false;

  /// 代际计数器 — 仅在实际启动新队列时递增（play() 早返回时不递增），
  /// 防止「播放中 play()」使旧 _processQueue 代际失效导致 _isPlaying 永久卡死（R1 修复）
  int _generation = 0;

  /// 播放一条完整的播报
  ///
  /// 如果当前正在播放，只记录 _latestReq 不入队——
  /// 避免新请求的分段与当前队列混排，且防止 _processQueue 结束时
  /// 补播已经入队并消费过的请求导致重复播报。
  Future<void> play(AnnouncementRequest req) async {
    _stopped = false;
    _latestReq = req;
    if (_isPlaying) return; // 正在播放 → 仅记录最新请求，待当前队列播完后补播

    _generation++; // 仅在实际启动新队列时递增

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
  ///
  /// _stopped 标志贯穿全程：stop() 调用后会中断 while 循环、
  /// 跳过 TTS 兜底、跳过补播——防止「确认时 TTS 突然开口」的竞态。
  Future<void> _processQueue(AnnouncementRequest req) async {
    if (_isPlaying) return;
    _isPlaying = true;
    final myGen = _generation;

    while (_queue.isNotEmpty && !_stopped && _generation == myGen) {
      final asset = _queue.removeFirst();
      final ok = await _playAudioSegment(asset);
      if (_generation != myGen) break; // 新 play() 或 stop() 已接管
      if (!ok) {
        _queue.clear();
        if (!_stopped && _generation == myGen) {
          await _playTts(req);
        }
        break;
      }
    }

    // 无条件复位 _isPlaying — 不门控代际，防止死锁（R1 修复）
    _isPlaying = false;

    if (_stopped) {
      _latestReq = null;
      return;
    }

    // 播放期间如果有新的 play() 被跳过，补播最新的请求
    // 代际不同 → 新 play() 已递增代际但 _isPlaying=true 导致早返回 → 需要补播
    // 代际相同 → 正常播完，检查是否有更晚的请求
    if (_latestReq != null && _latestReq != req) {
      final pending = _latestReq!;
      _latestReq = null;
      await play(pending);
    } else {
      _latestReq = null;
    }
  }

  /// 播放单个音频分段，返回是否成功
  /// 用 Completer + 独立订阅避免 Future.any 捕获上一段遗留的 stopped 状态
  Future<bool> _playAudioSegment(String asset) async {
    try {
      final completer = Completer<bool>();
      late StreamSubscription completeSub;
      late StreamSubscription stateSub;

      // 订阅必须在 play() 之前 — 极短音频可能在 play() 返回前就完成
      completeSub = _audioPlayer.onPlayerComplete.listen((_) {
        if (!completer.isCompleted) completer.complete(true);
      });
      stateSub = _audioPlayer.onPlayerStateChanged.listen((s) {
        if (s == PlayerState.stopped && !completer.isCompleted) {
          completer.complete(false);
        }
      });

      await _audioPlayer.play(AssetSource('audio/$asset'));

      final timer = Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) completer.complete(false);
      });

      final result = await completer.future;
      await completeSub.cancel();
      await stateSub.cancel();
      timer.cancel();
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
    _stopped = true;
    _queue.clear();
    _latestReq = null;
    try { await _audioPlayer.stop(); } catch (_) {}
    try { await _tts.stop(); } catch (_) {}
    _isPlaying = false;
  }
}

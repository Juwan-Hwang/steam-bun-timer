/// V2 语音指令服务 — §第四层 语音指令
/// 使用 sherpa-onnx 本地 KWS（关键词识别）实现
/// 基于 wenetspeech 中文模型
/// 纯离线识别，无需网络
/// 识别失败 → 震动两下提示没听清 → 优雅降级
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';
import 'package:vibration/vibration.dart';

/// 语音指令集 — §第四层 极简指令集
enum VoiceCommand {
  startBoiling, // 「开始烧水」
  startSteaming, // 「开始蒸」
  done, // 「好了」
  addTwoMinutes, // 「加两分钟」
}

extension VoiceCommandText on VoiceCommand {
  String get displayText {
    switch (this) {
      case VoiceCommand.startBoiling:
        return '开始烧水';
      case VoiceCommand.startSteaming:
        return '开始蒸';
      case VoiceCommand.done:
        return '好了';
      case VoiceCommand.addTwoMinutes:
        return '加两分钟';
    }
  }
}

/// 语音识别状态
enum VoiceRecognitionState {
  idle,
  listening,
  recognized,
  failed,
}

/// 语音指令回调
typedef VoiceCommandCallback = void Function(VoiceCommand command);

/// 语音快捷启动回调 — 返回配方 ID
typedef QuickStartCallback = void Function(String recipeId);

class VoiceCommandService {
  VoiceCommandService._();
  static final instance = VoiceCommandService._();

  VoiceCommandCallback? onCommand;
  QuickStartCallback? onQuickStart;
  VoidCallback? onRecognitionFailed;

  bool _isInitialized = false;
  bool _isEnabled = false;

  /// 播报中标志 — 为 true 时忽略语音识别结果，防止自触发
  bool _isAnnouncing = false;

  /// sherpa-onnx KWS 识别器
  KeywordSpotter? _spotter;
  OnlineStream? _stream;

  /// 音频采集
  static const int _sampleRate = 16000;

  /// 预分配的复用缓冲区 — 避免 ~50Hz 高频分配 Float32List 造成 GC 压力
  Float32List? _floatBufferCache;

  /// 模型是否可用
  bool _modelAvailable = false;

  /// MethodChannel 与原生通信
  static const _channel = MethodChannel('com.steambun.steam_bun_timer/voice');

  bool get isEnabled => _isEnabled;
  bool get isModelAvailable => _modelAvailable;

  /// 设置播报中标志 — 由 ReminderManager 调用
  void setAnnouncing(bool value) => _isAnnouncing = value;

  /// 初始化 sherpa-onnx KWS 引擎
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // 复制模型文件到可访问目录
      final modelDir = await _prepareModelFiles();
      if (modelDir == null) {
        debugPrint('[KWS] Failed to prepare model files');
        return false;
      }

      // 配置 KWS - 使用 transducer 模型
      final config = KeywordSpotterConfig(
        feat: FeatureConfig(
          sampleRate: _sampleRate,
          featureDim: 80,
        ),
        model: OnlineModelConfig(
          transducer: OnlineTransducerModelConfig(
            encoder: '$modelDir/encoder-epoch-99-avg-1-chunk-16-left-64.onnx',
            decoder: '$modelDir/decoder-epoch-99-avg-1-chunk-16-left-64.onnx',
            joiner: '$modelDir/joiner-epoch-99-avg-1-chunk-16-left-64.onnx',
          ),
          tokens: '$modelDir/tokens.txt',
          numThreads: 2,
          debug: false,
          provider: 'cpu',
        ),
        keywordsFile: '$modelDir/keywords.txt',
        numTrailingBlanks: 1,
        keywordsScore: 1.0,
        keywordsThreshold: 0.25,
        keywordsBufSize: 100,
      );

      _spotter = KeywordSpotter(config);
      _stream = _spotter!.createStream();

      // 设置 MethodChannel 回调
      _channel.setMethodCallHandler(_handleMethodCall);

      _isInitialized = true;
      _modelAvailable = true;
      debugPrint('[KWS] Initialized successfully');
      return true;
    } catch (e, stack) {
      debugPrint('[KWS] Initialization failed: $e');
      debugPrint(stack);
      return false;
    }
  }

  /// 处理 MethodChannel 调用
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onAudioData':
        // 收到音频数据
        final bytes = call.arguments as Uint8List;
        _processAudioData(bytes);
        break;
      case 'onError':
        // 录音错误
        debugPrint('[KWS] Recording error: ${call.arguments}');
        _isEnabled = false;
        await _vibrateTwice();
        onRecognitionFailed?.call();
        break;
    }
  }

  /// 准备模型文件（从 assets 复制到应用目录）
  Future<String?> _prepareModelFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${appDir.path}/kws_model');
      await modelDir.create(recursive: true);

      // 需要复制的文件列表
      final files = [
        'encoder-epoch-99-avg-1-chunk-16-left-64.onnx',
        'decoder-epoch-99-avg-1-chunk-16-left-64.onnx',
        'joiner-epoch-99-avg-1-chunk-16-left-64.onnx',
        'tokens.txt',
        'keywords.txt',
      ];

      for (final file in files) {
        final targetPath = '${modelDir.path}/$file';
        if (!File(targetPath).existsSync()) {
          try {
            final data = await rootBundle.load('assets/models/kws/$file');
            final bytes = data.buffer.asUint8List();
            await File(targetPath).writeAsBytes(bytes);
            debugPrint('[KWS] Copied $file to $targetPath');
          } catch (e) {
            debugPrint('[KWS] Failed to copy $file: $e');
            if (file.endsWith('.onnx')) {
              return null;
            }
          }
        }
      }

      return modelDir.path;
    } catch (e) {
      debugPrint('[KWS] Prepare model files failed: $e');
      return null;
    }
  }

  /// 启用语音唤醒（KWS 监听开始）
  Future<void> enable() async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) {
        await _vibrateTwice();
        onRecognitionFailed?.call();
        return;
      }
    }

    try {
      // 调用原生开始录音
      final started = await _channel.invokeMethod<bool>('startAudioStream', {
        'sampleRate': _sampleRate,
      });
      
      if (started == true) {
        _isEnabled = true;
        debugPrint('[KWS] Listening started');
      } else {
        await _vibrateTwice();
        onRecognitionFailed?.call();
      }
    } catch (e) {
      debugPrint('[KWS] Enable failed: $e');
      await _vibrateTwice();
      onRecognitionFailed?.call();
    }
  }

  /// 禁用语音唤醒 — 释放 ONNX 模型（数十 MB），避免常驻内存
  Future<void> disable() async {
    _isEnabled = false;

    try {
      await _channel.invokeMethod('stopAudioStream');
    } catch (_) {}

    // 释放模型资源 — reset 只清状态不释放内存，free 才真正回收
    _stream?.free();
    _spotter?.free();
    _stream = null;
    _spotter = null;
    _isInitialized = false;
    _floatBufferCache = null;

    // 清除 MethodChannel handler — 防止 stopAudioStream 后仍接收 onAudioData
    _channel.setMethodCallHandler(null);

    debugPrint('[KWS] Listening stopped, model released');
  }

  /// 处理音频数据（PCM 16-bit）
  void _processAudioData(Uint8List data) {
    if (!_isEnabled || _isAnnouncing) return;
    if (_spotter == null || _stream == null) return;

    try {
      // 将 PCM 16-bit 数据转换为 float 样本 (-1.0 ~ 1.0)
      final buffer = Int16List.view(data.buffer);
      // 复用预分配的缓冲区，避免高频内存分配
      final floatBuffer = (_floatBufferCache?.length == buffer.length)
          ? _floatBufferCache!
          : Float32List(buffer.length);
      _floatBufferCache = floatBuffer;
      for (int i = 0; i < buffer.length; i++) {
        floatBuffer[i] = buffer[i] / 32768.0;
      }

      // 输入到识别器
      _stream!.acceptWaveform(samples: floatBuffer, sampleRate: _sampleRate);

      // 解码并检查是否检测到关键词
      while (_spotter!.isReady(_stream!)) {
        _spotter!.decode(_stream!);
      }

      // 获取结果
      final result = _spotter!.getResult(_stream!);
      if (result != null && result.keyword.isNotEmpty) {
        _handleKeywordDetected(result.keyword);
      }
    } catch (e) {
      debugPrint('[KWS] Process audio error: $e');
    }
  }

  /// 处理检测到的关键词
  void _handleKeywordDetected(String keyword) {
    if (_isAnnouncing) return;

    debugPrint('[KWS] Detected: $keyword');

    // 匹配指令 - 根据模型中的关键词格式 @后面的中文
    final cmd = _matchCommand(keyword);
    if (cmd != null) {
      onCommand?.call(cmd);
    } else {
      // 尝试快捷启动词 — 说出品种名直接开锅
      final recipeId = matchQuickStart(keyword);
      if (recipeId != null) {
        onQuickStart?.call(recipeId);
      } else {
        // 未识别的关键词，震动提示
        _vibrateTwice();
        onRecognitionFailed?.call();
      }
    }

    // 重置流以准备下一次识别
    _spotter?.reset(_stream!);
  }

  /// 匹配关键词到指令
  VoiceCommand? _matchCommand(String keyword) {
    // 从关键词中提取 @ 后面的中文部分
    final match = RegExp(r'@(.+)').firstMatch(keyword);
    final text = match?.group(1) ?? keyword;
    final lower = text.toLowerCase().trim();

    // 基础控制词
    if (lower.contains('烧水')) {
      return VoiceCommand.startBoiling;
    }
    if (lower.contains('上锅')) {
      return VoiceCommand.startSteaming;
    }
    if (lower.contains('好了')) {
      return VoiceCommand.done;
    }
    if (lower.contains('两分钟') || lower.contains('2分钟') || lower.contains('二分钟')) {
      return VoiceCommand.addTwoMinutes;
    }

    return null;
  }

  /// 匹配快捷启动词 - 返回对应的配方ID
  String? matchQuickStart(String keyword) {
    final match = RegExp(r'@(.+)').firstMatch(keyword);
    final text = match?.group(1) ?? keyword;
    final lower = text.toLowerCase().trim();

    if (lower.contains('白馒头')) return 'white_bun';
    if (lower.contains('甜馒头')) return 'sweet_bun';
    if (lower.contains('小馒头')) return 'small_bun';
    if (lower.contains('包子')) return 'baozi';
    // 「白饼子」「红糖饼子」必须在「饼子」之前匹配
    if (lower.contains('白饼子')) return 'white_flatbread';
    if (lower.contains('红糖饼子')) return 'brown_sugar_flatbread';
    if (lower.contains('饼子')) return 'white_flatbread';

    return null;
  }

  /// 识别失败时震动两下 — §第四层 优雅降级
  Future<void> _vibrateTwice() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 200);
        await Future.delayed(const Duration(milliseconds: 300));
        await Vibration.vibrate(duration: 200);
      }
    } catch (_) {}
  }

  /// 释放资源 — 委托给 disable()，确保模型真正释放
  Future<void> dispose() async {
    await disable();
  }
}

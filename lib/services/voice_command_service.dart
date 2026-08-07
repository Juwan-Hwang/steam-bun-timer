/// V2 语音指令服务 — §第四层 语音指令
/// 四川话 KWS（关键词识别）框架
/// sherpa-onnx 集成需在 platform 层实现，此处定义抽象接口和 Dart 层框架
/// 识别失败 → 震动两下提示没听清 → 优雅降级
library;

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// 语音指令集 — §第四层 极简指令集
enum VoiceCommand {
  startBoiling,    // 「开始烧水」
  startSteaming,   // 「开始蒸」
  done,            // 「好了」
  addTwoMinutes,   // 「加两分钟」
}

extension VoiceCommandText on VoiceCommand {
  String get displayText {
    switch (this) {
      case VoiceCommand.startBoiling: return '开始烧水';
      case VoiceCommand.startSteaming: return '开始蒸';
      case VoiceCommand.done: return '好了';
      case VoiceCommand.addTwoMinutes: return '加两分钟';
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

class VoiceCommandService {
  VoiceCommandService._();
  static final instance = VoiceCommandService._();

  static const _channel = MethodChannel('com.steambun.steam_bun_timer/voice');

  VoiceCommandCallback? onCommand;
  VoidCallback? onRecognitionFailed;

  bool _isInitialized = false;
  bool _isEnabled = false;

  /// 播报中标志 — 为 true 时忽略语音识别结果，防止自触发（I2 修复）
  bool _isAnnouncing = false;

  bool get isEnabled => _isEnabled;

  /// 设置播报中标志 — 由 ReminderManager 调用
  void setAnnouncing(bool value) => _isAnnouncing = value;

  /// 初始化 sherpa-onnx KWS 引擎
  /// 需在 platform 层加载模型文件
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      _channel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'onCommand':
            if (_isAnnouncing) return; // 播报中忽略，防止自触发
            final cmdIndex = call.arguments as int;
            final cmd = VoiceCommand.values[cmdIndex];
            onCommand?.call(cmd);
          case 'onListeningStarted':
            _isEnabled = true;
          case 'onRecognitionFailed':
            _isEnabled = false;
            await _vibrateTwice();
            onRecognitionFailed?.call();
        }
      });
      final result = await _channel.invokeMethod<bool>('initialize');
      _isInitialized = result ?? false;
      return _isInitialized;
    } catch (_) {
      return false;
    }
  }

  /// 启用语音唤醒（KWS 监听开始）
  Future<void> enable() async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return;
    }
    try {
      final started = await _channel.invokeMethod<bool>('startListening') ?? false;
      if (started) {
        _isEnabled = true;
      }
      // started == false → 权限请求中，等待 onListeningStarted / onRecognitionFailed 回调
    } catch (_) {}
  }

  /// 禁用语音唤醒
  Future<void> disable() async {
    try {
      await _channel.invokeMethod('stopListening');
      _isEnabled = false;
    } catch (_) {}
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
}

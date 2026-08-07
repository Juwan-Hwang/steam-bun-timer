/// 触发源抽象 — §7.3 蓝牙触发 + §第二层/第三层 音量键
/// 蓝牙自拍遥控是 BLE HID 设备，复用系统按键监听路径
library;

import 'foreground_task_handler.dart';

enum TriggerSourceType { volumeKey, bluetoothButton, voice }

class TriggerEvent {
  final TriggerSourceType source;
  final DateTime timestamp;
  const TriggerEvent({required this.source, required this.timestamp});
}

abstract class TriggerSource {
  void start();
  void stop();
  void Function(TriggerEvent)? onTrigger;
}

/// 音量键 + 蓝牙遥控触发源
/// 音量上键和下键都视为「确认下一步 / 停止响铃」
class HardwareKeyTriggerSource implements TriggerSource {
  HardwareKeyTriggerSource._();
  static final instance = HardwareKeyTriggerSource._();

  @override
  void Function(TriggerEvent)? onTrigger;
  bool _isActive = false;

  @override
  void start() {
    if (_isActive) return;
    _isActive = true;
    ForegroundTaskHandler.instance.onKeyEvent = (keyCode) {
      // Android: 24=VOLUME_UP, 25=VOLUME_DOWN, 66=ENTER(蓝牙遥控)
      if (keyCode == 24 || keyCode == 25 || keyCode == 66) {
        final source = keyCode == 66
            ? TriggerSourceType.bluetoothButton
            : TriggerSourceType.volumeKey;
        onTrigger?.call(TriggerEvent(source: source, timestamp: DateTime.now()));
      }
    };
  }

  @override
  void stop() {
    _isActive = false;
    ForegroundTaskHandler.instance.onKeyEvent = null;
  }
}

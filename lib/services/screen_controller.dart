/// 屏幕控制器 — §配套细节
/// 屏幕常亮 / 自动降低亮度 / 防烧屏
/// P3-1: 自动降低亮度真正调用 WindowManager，不再只存布尔
library;

import 'package:wakelock_plus/wakelock_plus.dart';
import 'foreground_task_handler.dart';

class ScreenController {
  ScreenController._();
  static final instance = ScreenController._();

  bool _alwaysOn = true;
  bool _autoDim = true;
  bool _burnInProtection = true;

  bool get alwaysOn => _alwaysOn;
  bool get autoDim => _autoDim;
  bool get burnInProtection => _burnInProtection;

  /// 设置屏幕常亮
  Future<void> setAlwaysOn(bool enabled) async {
    _alwaysOn = enabled;
    try {
      if (enabled) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (_) {}
  }

  /// 启动屏幕常亮（App 启动时调用）
  Future<void> enableAlwaysOn() async {
    if (_alwaysOn) {
      try {
        await WakelockPlus.enable();
      } catch (_) {}
    }
  }

  /// P3-1: 设置自动降低亮度 — 真正调用 WindowManager
  /// 开启时亮度降到 0.15，关闭时恢复系统亮度
  void setAutoDim(bool enabled) {
    _autoDim = enabled;
    if (enabled) {
      // 降到 15% 亮度
      ForegroundTaskHandler.instance.setBrightness(0.15);
    } else {
      // 恢复系统亮度
      ForegroundTaskHandler.instance.setBrightness(-1.0);
    }
  }

  /// 设置防烧屏
  void setBurnInProtection(bool enabled) {
    _burnInProtection = enabled;
  }

  /// 释放 wakelock — App 销毁时调用
  Future<void> dispose() async {
    try {
      await WakelockPlus.disable();
    } catch (_) {}
  }
}

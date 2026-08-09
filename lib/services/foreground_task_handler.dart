/// 前台服务 + 音量键 / 蓝牙按键 MethodChannel
/// §5.1 后台保活 + §第二层/第三层 音量键 & 蓝牙遥控
library;

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// 前台服务回调类型
typedef KeyCallback = void Function(int keyCode);

class ForegroundTaskHandler {
  ForegroundTaskHandler._();
  static final instance = ForegroundTaskHandler._();

  static const _channel = MethodChannel('com.steambun.steam_bun_timer/foreground');

  KeyCallback? onKeyEvent;

  /// 初始化 MethodChannel 监听
  void init() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onKeyEvent') {
        final keyCode = call.arguments as int;
        onKeyEvent?.call(keyCode);
      }
    });
  }

  /// 清理 MethodChannel 监听 — App 销毁时调用
  void dispose() {
    onKeyEvent = null;
    _channel.setMethodCallHandler(null);
  }

  /// 启动前台服务
  /// §5.1: 前台服务保活计时
  Future<void> startForegroundService({
    required String title,
    required String content,
  }) async {
    try {
      await _channel.invokeMethod('startForeground', {
        'title': title,
        'content': content,
      });
    } catch (_) {
      // 非 Android 平台或服务未就绪，静默降级
    }
  }

  /// 更新前台服务通知
  Future<void> updateNotification({required String content}) async {
    try {
      await _channel.invokeMethod('updateNotification', {'content': content});
    } catch (_) {}
  }

  /// 停止前台服务
  Future<void> stopForegroundService() async {
    try {
      await _channel.invokeMethod('stopForeground');
    } catch (_) {}
  }

  /// 设置精确闹钟 — §5.1 AlarmManager 兜底
  /// 到点即使进程被杀也能唤醒
  Future<void> scheduleExactAlarm({
    required int id,
    required DateTime triggerAt,
    required String title,
    required String body,
  }) async {
    try {
      await _channel.invokeMethod('scheduleAlarm', {
        'id': id,
        'triggerAtMillis': triggerAt.millisecondsSinceEpoch,
        'title': title,
        'body': body,
      });
    } catch (_) {}
  }

  /// 取消精确闹钟
  Future<void> cancelExactAlarm(int id) async {
    try {
      await _channel.invokeMethod('cancelAlarm', {'id': id});
    } catch (_) {}
  }

  /// 检查精确闹钟权限 — §5.1 Android 13+
  Future<bool> canScheduleExactAlarms() async {
    try {
      final result = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// 请求精确闹钟权限 — 跳转系统设置
  Future<void> requestExactAlarmPermission() async {
    try {
      await _channel.invokeMethod('requestExactAlarmPermission');
    } catch (_) {}
  }

  /// 检查通知权限 — §5.1 Android 13+
  Future<bool> hasNotificationPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasNotificationPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// 请求通知权限 — 🟡5: 使用 permission_handler 正确请求运行时权限
  /// 原生侧仅跳转设置页就无条件返回 true，Flutter 侧误判已授权
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      if (status.isGranted) return true;
      // 永久拒绝 → 降级到原生设置页跳转
      if (status.isPermanentlyDenied) {
        try {
          await _channel.invokeMethod('requestNotificationPermission');
        } catch (_) {}
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 检查电池优化白名单
  Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final result = await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// 请求忽略电池优化
  Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (_) {}
  }

  /// P3-1: 设置屏幕亮度 — 真正调用 WindowManager
  /// brightness: 0.0~1.0 自定义亮度，-1 恢复系统亮度
  Future<void> setBrightness(double brightness) async {
    try {
      await _channel.invokeMethod('setBrightness', {'brightness': brightness});
    } catch (_) {}
  }
}

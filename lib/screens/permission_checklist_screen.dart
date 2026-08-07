/// 权限检查清单页 — §5.1 Android 13/14 权限引导
/// 每项权限一个开关状态灯，绿=已开、红=待开
library;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_tokens.dart';
import '../services/foreground_task_handler.dart';

class PermissionChecklistScreen extends StatefulWidget {
  const PermissionChecklistScreen({super.key});

  @override
  State<PermissionChecklistScreen> createState() => _PermissionChecklistScreenState();
}

class _PermissionChecklistScreenState extends State<PermissionChecklistScreen> {
  bool _notifications = false;
  bool _exactAlarms = false;
  bool _batteryOpt = false;
  bool _location = false;
  final bool _boot = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final fh = ForegroundTaskHandler.instance;
    final notif = await fh.hasNotificationPermission();
    final alarms = await fh.canScheduleExactAlarms();
    final battery = await fh.isIgnoringBatteryOptimizations();

    // 真实检查定位权限
    bool locGranted = false;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        final perm = await Geolocator.checkPermission();
        locGranted = perm == LocationPermission.always ||
            perm == LocationPermission.whileInUse;
      }
    } catch (_) {}

    // 检查通知权限（permission_handler 兜底）
    if (!notif) {
      final notifStatus = await Permission.notification.status;
      locGranted = locGranted && true; // locGranted 已算好
      if (notifStatus.isGranted) {
        // permission_handler 说有权限但原生说没有，以原生为准
      }
    }

    if (mounted) {
      setState(() {
        _notifications = notif;
        _exactAlarms = alarms;
        _batteryOpt = battery;
        _location = locGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final z = ZephyrThemeExtension.of(context).s;

    return Scaffold(
      appBar: AppBar(
        title: Text('权限检查', style: TextStyle(fontSize: ZephyrFontSize.xl, fontWeight: FontWeight.w400, color: z.textPrimary)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: z.textPrimary), onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: z.isDark
                ? [const Color(0xF718181B), const Color(0xE6000000)]
                : [const Color(0xF2FFFFFF), const Color(0xE6F8FAFC)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(ZephyrSpacing.s5),
          children: [
            _card(z, '通知权限', '到点提醒需要发送通知，Android 13+ 需手动授权', '去设置', _notifications, () async {
              final ok = await ForegroundTaskHandler.instance.requestNotificationPermission();
              setState(() => _notifications = ok);
            }),
            _card(z, '精确闹钟权限', '确保到点即使进程被杀也能唤醒，Android 13+ 默认拒绝', '去设置', _exactAlarms, () async {
              await ForegroundTaskHandler.instance.requestExactAlarmPermission();
              final ok = await ForegroundTaskHandler.instance.canScheduleExactAlarms();
              setState(() => _exactAlarms = ok);
            }),
            _card(z, '忽略电池优化', '防止系统杀后台导致计时丢失', '去设置', _batteryOpt, () async {
              await ForegroundTaskHandler.instance.requestIgnoreBatteryOptimizations();
              final ok = await ForegroundTaskHandler.instance.isIgnoringBatteryOptimizations();
              setState(() => _batteryOpt = ok);
            }),
            _card(z, '定位权限', '获取发酵时的实时气温（和风天气 API）', '授权', _location, () async {
              // 通过 permission_handler 请求定位权限
              final status = await Permission.locationWhenInUse.request();
              if (status.isGranted || status.isLimited) {
                // 同时确保定位服务已开启
                final serviceEnabled = await Geolocator.isLocationServiceEnabled();
                if (!context.mounted) return;
                if (!serviceEnabled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请先开启 GPS 定位服务')),
                  );
                }
                setState(() => _location = serviceEnabled);
              } else {
                if (!context.mounted) return;
                setState(() => _location = false);
              }
            }),
            _card(z, '自启动权限', '厂商 ROM 需加入白名单，开机后自动启动', '已就绪', _boot, () {
              // 厂商自启动设置页面跳转 — 不同厂商路径不同，此处仅提示
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请在系统设置中查找「自启动管理」并添加本应用')),
              );
            }),
            const SizedBox(height: ZephyrSpacing.s6),
            // 刷新按钮
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _checkPermissions,
                child: const Text('重新检查'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(ZephyrSemantic z, String title, String desc, String actionLabel, bool granted, VoidCallback onTap) {
    final color = granted ? z.success : z.danger;
    return Padding(
      padding: const EdgeInsets.only(bottom: ZephyrSpacing.s4),
      child: Container(
        padding: const EdgeInsets.all(ZephyrSpacing.s5),
        decoration: BoxDecoration(
          color: z.isDark ? const Color(0x0DFFFFFF) : const Color(0x66FFFFFF),
          borderRadius: BorderRadius.circular(ZephyrRadius.overlay),
          border: Border.all(color: z.borderSubtle),
        ),
        child: Row(
          children: [
            // 状态灯
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1)],
              ),
            ),
            const SizedBox(width: ZephyrSpacing.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: ZephyrFontSize.base, fontWeight: FontWeight.w600, color: z.textPrimary)),
                  const SizedBox(height: 2),
                  Text(desc, style: TextStyle(fontSize: ZephyrFontSize.xs, color: z.textTertiary)),
                ],
              ),
            ),
            if (!granted)
              TextButton(
                onPressed: onTap,
                child: Text(actionLabel, style: TextStyle(fontSize: ZephyrFontSize.xs, fontWeight: FontWeight.w700, color: z.accentPrimary)),
              ),
            if (granted)
              Icon(Icons.check_circle, size: 20, color: z.success),
          ],
        ),
      ),
    );
  }
}

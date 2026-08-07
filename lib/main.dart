/// 蒸馒头计时器 — 入口
/// 妈妈的厨房帮手 — V1+V2 完整实现
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_tokens.dart';
import 'screens/dashboard_screen.dart';
import 'services/screen_controller.dart';
import 'services/foreground_task_handler.dart';
import 'providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 强制竖屏
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 屏幕常亮 — §配套细节
  await ScreenController.instance.enableAlwaysOn();

  // 初始化前台服务 MethodChannel — §5.1
  ForegroundTaskHandler.instance.init();

  runApp(const ProviderScope(child: SteamBunTimerApp()));
}

class SteamBunTimerApp extends ConsumerStatefulWidget {
  const SteamBunTimerApp({super.key});

  @override
  ConsumerState<SteamBunTimerApp> createState() => _SteamBunTimerAppState();
}

class _SteamBunTimerAppState extends ConsumerState<SteamBunTimerApp> {
  @override
  void initState() {
    super.initState();
    _recoverBatches();
  }

  /// 崩溃恢复 — §5.1 App 重启后按时间戳重建所有倒计时
  Future<void> _recoverBatches() async {
    await ref.read(activeBatchesProvider.notifier).restoreFromPersistence();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '蒸馒头计时器',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(accent: AccentTheme.purple),
      home: const DashboardScreen(),
    );
  }
}

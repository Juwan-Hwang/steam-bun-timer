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
import 'services/voice_command_service.dart';
import 'services/announcement_player.dart';
import 'services/reminder_manager.dart';
import 'services/finish_feedback.dart';
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
  bool _systemUIApplied = false;

  @override
  void initState() {
    super.initState();
    _recoverBatches();
  }

  @override
  void dispose() {
    // 兜底：App 被销毁时释放所有原生资源
    VoiceCommandService.instance.dispose();
    AnnouncementPlayer.instance.dispose();
    ReminderManager.instance.dispose();
    FinishFeedback.dispose();
    super.dispose();
  }

  /// 崩溃恢复 — §5.1 App 重启后按时间戳重建所有倒计时
  Future<void> _recoverBatches() async {
    await ref.read(activeBatchesProvider.notifier).restoreFromPersistence();
  }

  /// 根据主题设置状态栏样式 — 仅在 darkMode 变化时调用，避免每次 build 都触发平台通道
  void _applySystemUI(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDark ? Colors.transparent : Colors.white.withOpacity(0.9),
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark ? Colors.transparent : Colors.white.withOpacity(0.9),
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = settings.darkMode;

    // 仅在 darkMode 变化时更新系统 UI，而非每次 build 都调用
    ref.listen(settingsProvider, (prev, next) {
      if (prev?.darkMode != next.darkMode) {
        _applySystemUI(next.darkMode);
      }
    });

    // 首次 build 设置初始样式
    if (!_systemUIApplied) {
      _systemUIApplied = true;
      _applySystemUI(isDark);
    }

    return MaterialApp(
      title: '蒸馒头计时器',
      debugShowCheckedModeBanner: false,
      theme: isDark ? AppTheme.dark(accent: AccentTheme.purple) : AppTheme.light(accent: AccentTheme.purple),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const DashboardScreen(),
    );
  }
}

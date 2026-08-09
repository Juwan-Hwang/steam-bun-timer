/// 设置页面 — V1+V2 全设置项连接
/// P3-1: 充电保护从假开关改为系统设置导航
/// P-天气: 天气 API 详细教学 + 测试按钮 + 定位权限引导
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_tokens.dart';
import '../providers/app_providers.dart';
import '../services/weather_service.dart';
import '../services/foreground_task_handler.dart';
import 'permission_checklist_screen.dart';
import 'data_export_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final z = ZephyrThemeExtension.of(context).s;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: z.isDark ? const Color(0xF718181B) : const Color(0xF2FFFFFF),
        elevation: 0,
        systemOverlayStyle: z.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        title: Text('设置', style: TextStyle(fontSize: ZephyrFontSize.xl, fontWeight: FontWeight.w400, color: z.textPrimary)),
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
            _section(z, '屏幕与保活'),
            _switch(z, '屏幕常亮', '做馒头期间屏幕不锁屏', settings.screenAlwaysOn,
                () => ref.read(settingsProvider.notifier).toggleScreenAlwaysOn()),
            _switch(z, '自动降低亮度', '常亮时自动降到 15% 亮度防过热', settings.autoDimBrightness,
                () => ref.read(settingsProvider.notifier).toggleAutoDim()),
            _switch(z, '防烧屏', '倒计时数字每分钟微移几个像素', settings.burnInProtection,
                () => ref.read(settingsProvider.notifier).toggleBurnInProtection()),

            const SizedBox(height: ZephyrSpacing.s6),
            _section(z, '提醒'),
            _switch(z, '焖制提醒', '关火后 5 分钟轻提示揭锅', settings.simmeringReminder,
                () => ref.read(settingsProvider.notifier).toggleSimmeringReminder()),

            const SizedBox(height: ZephyrSpacing.s6),
            _section(z, '电池'),
            // P3-1: 充电保护从假开关改为系统设置导航
            _nav(z, '充电保护', '部分机型自带充电上限设置，点击跳转系统电池设置', Icons.battery_charging_full, () {
              ForegroundTaskHandler.instance.requestIgnoreBatteryOptimizations();
            }),

            const SizedBox(height: ZephyrSpacing.s6),
            _section(z, '外观'),
            _switch(z, '深色模式', '切换深色/浅色主题', settings.darkMode,
                () => ref.read(settingsProvider.notifier).toggleDarkMode()),

            const SizedBox(height: ZephyrSpacing.s6),
            _section(z, 'V2 免触增强'),
            _switch(z, '语音指令', '中文关键词识别（开始烧水/好了/加两分钟）', settings.voiceEnabled,
                () => ref.read(settingsProvider.notifier).toggleVoiceEnabled()),

            const SizedBox(height: ZephyrSpacing.s6),
            _section(z, '天气'),
            _nav(z, '和风天气 API Key', '配置后自动采集气温数据', Icons.cloud_outlined, () {
              _showWeatherConfigSheet(context, z, ref);
            }),

            const SizedBox(height: ZephyrSpacing.s6),
            _section(z, '系统权限'),
            _nav(z, '权限检查清单', '通知、精确闹钟、电池优化、定位等', Icons.checklist, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PermissionChecklistScreen()));
            }),

            const SizedBox(height: ZephyrSpacing.s6),
            _section(z, '数据'),
            _nav(z, '导出数据 CSV', '导出所有批次记录供分析', Icons.download, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DataExportScreen()));
            }),

            const SizedBox(height: ZephyrSpacing.s6),
            _section(z, '关于'),
            _info(z, '版本', '1.2.0 (P0-P3 审计修复)'),
            _info(z, '技术栈', 'Flutter 3.x + Drift + Riverpod'),
          ],
        ),
      ),
    );
  }

  Widget _section(ZephyrSemantic z, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: ZephyrSpacing.s3, bottom: ZephyrSpacing.s3),
      child: Text(title, style: TextStyle(fontSize: ZephyrFontSize.xxs, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: z.textMuted)),
    );
  }

  Widget _switch(ZephyrSemantic z, String title, String subtitle, bool value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ZephyrSpacing.s3),
      child: Container(
        padding: const EdgeInsets.all(ZephyrSpacing.s5),
        decoration: BoxDecoration(
          color: z.isDark ? const Color(0x0DFFFFFF) : const Color(0x66FFFFFF),
          borderRadius: BorderRadius.circular(ZephyrRadius.overlay),
          border: Border.all(color: z.borderSubtle),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: ZephyrFontSize.base, fontWeight: FontWeight.w600, color: z.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: ZephyrFontSize.xs, color: z.textTertiary)),
                ],
              ),
            ),
            Switch(value: value, onChanged: (_) => onTap()),
          ],
        ),
      ),
    );
  }

  Widget _nav(ZephyrSemantic z, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ZephyrSpacing.s3),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(ZephyrSpacing.s5),
          decoration: BoxDecoration(
            color: z.isDark ? const Color(0x0DFFFFFF) : const Color(0x66FFFFFF),
            borderRadius: BorderRadius.circular(ZephyrRadius.overlay),
            border: Border.all(color: z.borderSubtle),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: z.accentPrimary),
              const SizedBox(width: ZephyrSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: ZephyrFontSize.base, fontWeight: FontWeight.w600, color: z.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: ZephyrFontSize.xs, color: z.textTertiary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: z.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(ZephyrSemantic z, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ZephyrSpacing.s3),
      child: Container(
        padding: const EdgeInsets.all(ZephyrSpacing.s5),
        decoration: BoxDecoration(
          color: z.isDark ? const Color(0x0DFFFFFF) : const Color(0x66FFFFFF),
          borderRadius: BorderRadius.circular(ZephyrRadius.overlay),
          border: Border.all(color: z.borderSubtle),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: ZephyrFontSize.base, fontWeight: FontWeight.w600, color: z.textPrimary)),
            Text(value, style: TextStyle(fontSize: ZephyrFontSize.sm, color: z.textTertiary)),
          ],
        ),
      ),
    );
  }

  /// P-天气: 和风天气 API 配置面板 — 教学 + API Key/Host 双输入 + 测试
  void _showWeatherConfigSheet(BuildContext context, ZephyrSemantic z, WidgetRef ref) {
    final keyController = TextEditingController();
    final hostController = TextEditingController();
    bool isTesting = false;
    String? testMessage;
    bool sheetClosed = false;

    WeatherService.instance.getApiKey().then((key) {
      if (!sheetClosed) keyController.text = key ?? '';
    });
    WeatherService.instance.getApiHost().then((host) {
      if (!sheetClosed) hostController.text = host ?? '';
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: z.bgElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(ZephyrRadius.overlay))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: ZephyrSpacing.s5, right: ZephyrSpacing.s5, top: ZephyrSpacing.s5,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + ZephyrSpacing.s5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Row(
                children: [
                  Icon(Icons.cloud_outlined, size: 24, color: z.accentPrimary),
                  const SizedBox(width: 8),
                  Text('和风天气 API 配置', style: TextStyle(fontSize: ZephyrFontSize.xl, fontWeight: FontWeight.w600, color: z.textPrimary)),
                ],
              ),
              const SizedBox(height: ZephyrSpacing.s4),

              // 教学步骤
              Container(
                padding: const EdgeInsets.all(ZephyrSpacing.s4),
                decoration: BoxDecoration(
                  color: z.bgMuted,
                  borderRadius: BorderRadius.circular(ZephyrRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('获取步骤', style: TextStyle(fontSize: ZephyrFontSize.sm, fontWeight: FontWeight.w700, color: z.textSecondary)),
                    const SizedBox(height: 8),
                    _stepRow(z, '1', 'console.qweather.com 注册 → 创建项目（免费开发版）'),
                    _stepRow(z, '2', '项目里「添加凭据」→ 选 API KEY → 复制 Key'),
                    _stepRow(z, '3', '控制台「设置」页复制 API Host（独立域名）'),
                    _stepRow(z, '4', '两个值都粘贴到下方，点击测试'),
                    const SizedBox(height: 8),
                    Text('免费版每天 1000 次调用，天气数据不产生费用', style: TextStyle(fontSize: 10, color: z.textTertiary)),
                  ],
                ),
              ),
              const SizedBox(height: ZephyrSpacing.s4),

              // API Key 输入框
              Text('API Key', style: TextStyle(fontSize: ZephyrFontSize.xs, fontWeight: FontWeight.w700, color: z.textSecondary)),
              const SizedBox(height: 4),
              TextField(
                controller: keyController,
                decoration: InputDecoration(
                  hintText: '32 位字符，如 ABCD1234EFGH...',
                  hintStyle: TextStyle(color: z.textTertiary, fontSize: 13),
                  filled: true,
                  fillColor: z.bgMuted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ZephyrRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: z.textPrimary, fontSize: 14),
              ),
              const SizedBox(height: ZephyrSpacing.s3),

              // API Host 输入框
              Text('API Host', style: TextStyle(fontSize: ZephyrFontSize.xs, fontWeight: FontWeight.w700, color: z.textSecondary)),
              const SizedBox(height: 4),
              TextField(
                controller: hostController,
                decoration: InputDecoration(
                  hintText: '如 abc123xyz.def.qweatherapi.com',
                  hintStyle: TextStyle(color: z.textTertiary, fontSize: 13),
                  filled: true,
                  fillColor: z.bgMuted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ZephyrRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: z.textPrimary, fontSize: 14),
              ),
              const SizedBox(height: ZephyrSpacing.s3),

              // 测试结果
              if (testMessage != null)
                Container(
                  padding: const EdgeInsets.all(ZephyrSpacing.s3),
                  decoration: BoxDecoration(
                    color: testMessage!.startsWith('连接成功')
                        ? z.success.withValues(alpha: 0.08)
                        : z.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(ZephyrRadius.md),
                  ),
                  child: Text(testMessage!, style: TextStyle(fontSize: 12, color: testMessage!.startsWith('连接成功') ? z.success : z.danger)),
                ),

              // 按钮
              const SizedBox(height: ZephyrSpacing.s4),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 测试按钮
                  ElevatedButton(
                    onPressed: isTesting ? null : () async {
                      setState(() { isTesting = true; testMessage = null; });
                      await WeatherService.instance.setApiKey(keyController.text.trim());
                      await WeatherService.instance.setApiHost(hostController.text.trim());
                      final result = await WeatherService.instance.testApiKey();
                      setState(() {
                        isTesting = false;
                        testMessage = result.message;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: z.bgMuted,
                      foregroundColor: z.textPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ZephyrRadius.md)),
                    ),
                    child: isTesting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('测试'),
                  ),
                  const SizedBox(width: 8),
                  // 保存按钮
                  ElevatedButton(
                    onPressed: () async {
                      await WeatherService.instance.setApiKey(keyController.text.trim());
                      await WeatherService.instance.setApiHost(hostController.text.trim());
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: z.accentPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ZephyrRadius.md)),
                    ),
                    child: const Text('保存', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      sheetClosed = true;
      keyController.dispose();
      hostController.dispose();
    });
  }

  Widget _stepRow(ZephyrSemantic z, String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(color: z.accentPrimary.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Center(child: Text(num, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: z.accentPrimary))),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: z.textSecondary))),
        ],
      ),
    );
  }
}

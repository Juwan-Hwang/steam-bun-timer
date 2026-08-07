/// 设置页面 — V1+V2 全设置项连接
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_tokens.dart';
import '../providers/app_providers.dart';
import '../services/weather_service.dart';
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
            _switch(z, '自动降低亮度', '常亮时自动降低亮度防过热', settings.autoDimBrightness,
                () => ref.read(settingsProvider.notifier).toggleAutoDim()),
            _switch(z, '防烧屏', '倒计时数字每分钟微移几个像素', settings.burnInProtection,
                () => ref.read(settingsProvider.notifier).toggleBurnInProtection()),

            const SizedBox(height: ZephyrSpacing.s6),
            _section(z, '提醒'),
            _switch(z, '焖制提醒', '关火后 5 分钟轻提示揭锅', settings.simmeringReminder,
                () => ref.read(settingsProvider.notifier).toggleSimmeringReminder()),

            const SizedBox(height: ZephyrSpacing.s6),
            _section(z, '电池'),
            _switch(z, '充电保护', '充电上限 80%（部分机型自带）', settings.chargingProtection,
                () => ref.read(settingsProvider.notifier).toggleChargingProtection()),

            const SizedBox(height: ZephyrSpacing.s6),
            _section(z, 'V2 免触增强'),
            _switch(z, '语音指令', '四川话关键词识别（开始烧水/好了/加两分钟）', settings.voiceEnabled,
                () => ref.read(settingsProvider.notifier).toggleVoiceEnabled()),

            const SizedBox(height: ZephyrSpacing.s6),
            _section(z, '天气'),
            _nav(z, '和风天气 API Key', '配置后自动采集气温数据', Icons.cloud_outlined, () {
              _showApiKeyDialog(context, z, ref);
            }),

            const SizedBox(height: ZephyrSpacing.s6),
            _section(z, '系统权限'),
            _nav(z, '权限检查清单', '通知、精确闹钟、电池优化等', Icons.checklist, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PermissionChecklistScreen()));
            }),

            const SizedBox(height: ZephyrSpacing.s6),
            _section(z, '数据'),
            _nav(z, '导出数据 CSV', '导出所有批次记录供分析', Icons.download, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DataExportScreen()));
            }),

            const SizedBox(height: ZephyrSpacing.s6),
            _section(z, '关于'),
            _info(z, '版本', '1.1.0 (V1+V2 审计修复)'),
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

  /// 和风天气 API Key 配置对话框
  void _showApiKeyDialog(BuildContext context, ZephyrSemantic z, WidgetRef ref) {
    final controller = TextEditingController();
    WeatherService.instance.getApiKey().then((key) {
      controller.text = key ?? '';
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: z.bgElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ZephyrRadius.overlay)),
        title: Text('和风天气 API Key', style: TextStyle(color: z.textPrimary, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('在 dev.qweather.com 注册后获取 API Key，配置后发酵时自动采集气温。',
                style: TextStyle(fontSize: 12, color: z.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '输入 API Key',
                hintStyle: TextStyle(color: z.textTertiary, fontSize: 14),
                filled: true,
                fillColor: z.bgMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ZephyrRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: z.textPrimary, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              await WeatherService.instance.setApiKey(controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text('保存', style: TextStyle(color: z.accentPrimary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

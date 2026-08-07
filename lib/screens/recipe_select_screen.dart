/// 模板选择页面 — §1.1 + V2 习惯默认值提示
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_tokens.dart';
import '../models/recipe.dart';
import '../providers/app_providers.dart';
import 'dashboard_screen.dart';

class RecipeSelectScreen extends ConsumerStatefulWidget {
  const RecipeSelectScreen({super.key});

  @override
  ConsumerState<RecipeSelectScreen> createState() => _RecipeSelectScreenState();
}

class _RecipeSelectScreenState extends ConsumerState<RecipeSelectScreen> {
  /// 习惯默认值缓存 — V2 §3.2
  final Map<String, int?> _habitDefaults = {};

  @override
  void initState() {
    super.initState();
    _loadHabitDefaults();
  }

  Future<void> _loadHabitDefaults() async {
    for (final r in Recipe.presets) {
      final temp = 25.0; // TODO: 获取实时气温
      final habit = await ref.read(activeBatchesProvider.notifier).getHabitDefaultMinutes(r.id, temp);
      _habitDefaults[r.id] = habit;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final z = ZephyrThemeExtension.of(context).s;

    return Scaffold(
      appBar: AppBar(
        title: Text('选择品种', style: TextStyle(fontSize: ZephyrFontSize.xl, fontWeight: FontWeight.w400, color: z.textPrimary)),
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
            // V2: 习惯默认值提示
            if (_habitDefaults.values.any((v) => v != null))
              _habitHintBanner(z),
            for (final recipe in Recipe.presets)
              _recipeCard(z, recipe),
          ],
        ),
      ),
    );
  }

  Widget _habitHintBanner(ZephyrSemantic z) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ZephyrSpacing.s4),
      child: Container(
        padding: const EdgeInsets.all(ZephyrSpacing.s4),
        decoration: BoxDecoration(
          color: z.accentPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(ZephyrRadius.md),
          border: Border.all(color: z.accentPrimary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, size: 18, color: z.accentPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '根据最近使用习惯，已为你调整推荐时长',
                style: TextStyle(fontSize: ZephyrFontSize.xs, color: z.accentPrimary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recipeCard(ZephyrSemantic z, Recipe recipe) {
    final habitMinutes = _habitDefaults[recipe.id];
    final defaultMinutes = habitMinutes ?? recipe.steps.firstWhere((s) => s.type == StepType.fermentation, orElse: () => recipe.steps.first).defaultDurationMinutes ?? 0;
    final hasHabit = habitMinutes != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: ZephyrSpacing.s4),
      child: GestureDetector(
        onTap: () => _start(context, recipe),
        child: Container(
          padding: const EdgeInsets.all(ZephyrSpacing.s5),
          decoration: BoxDecoration(
            color: z.isDark ? const Color(0x0DFFFFFF) : const Color(0x66FFFFFF),
            borderRadius: BorderRadius.circular(ZephyrRadius.overlay),
            border: Border.all(color: z.borderSubtle),
            boxShadow: z.shadowSm,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: z.accentPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ZephyrRadius.md),
                  border: Border.all(color: z.accentPrimary.withValues(alpha: 0.2)),
                ),
                child: Center(child: Icon(_icon(recipe.id), size: 28, color: z.accentPrimary)),
              ),
              const SizedBox(width: ZephyrSpacing.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.name, style: TextStyle(fontSize: ZephyrFontSize.lg, fontWeight: FontWeight.w600, color: z.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      hasHabit ? '习惯: 发酵 $defaultMinutes 分钟' : '默认: 发酵 $defaultMinutes 分钟',
                      style: TextStyle(fontSize: ZephyrFontSize.xs, color: hasHabit ? z.accentPrimary : z.textTertiary),
                    ),
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

  IconData _icon(String id) {
    switch (id) {
      case 'white_bun':
      case 'sweet_bun':
      case 'small_bun':
        return Icons.breakfast_dining;
      case 'flatbread':
        return Icons.lunch_dining;
      default:
        return Icons.restaurant;
    }
  }

  void _start(BuildContext context, Recipe recipe) {
    final habitMinutes = _habitDefaults[recipe.id];
    ref.read(activeBatchesProvider.notifier).startBatch(recipe, fermentationMinutes: habitMinutes);
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (_) => false);
  }
}

/// 模板选择页面 — §1.1 + V2 习惯默认值提示
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_tokens.dart';
import '../models/recipe.dart';
import '../models/batch.dart';
import '../providers/app_providers.dart';
import '../services/weather_service.dart';
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
    // P2-2: 获取真实气温而非硬编码 25°C
    final weather = await WeatherService.instance.fetchCurrentWeather();
    final temp = weather?.temperature;
    for (final r in Recipe.presets) {
      final habit = await ref.read(activeBatchesProvider.notifier).getHabitDefaultMinutes(r.id, temp);
      _habitDefaults[r.id] = habit;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final z = ZephyrThemeExtension.of(context).s;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: z.isDark ? const Color(0xF718181B) : const Color(0xF2FFFFFF),
        elevation: 0,
        systemOverlayStyle: z.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
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
    final isGeneric = recipe.id == 'generic_timer';
    final defaultMinutes = habitMinutes ?? recipe.steps.firstWhere((s) => s.type == StepType.fermentation, orElse: () => recipe.steps.first).defaultDurationMinutes ?? 0;
    final hasHabit = habitMinutes != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: ZephyrSpacing.s4),
      child: GestureDetector(
        onTap: () => isGeneric ? _showGenericTimerDialog(z) : _start(context, recipe),
        onHorizontalDragEnd: (details) {
          // 左滑或右滑都可以弹出状态选择（任意水平滑动）
          if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 100 && !isGeneric) {
            _showStartStatePicker(z, recipe);
          }
        },
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
                      isGeneric
                          ? '自定义事项 · 可编辑名称和时间'
                          : (hasHabit ? '习惯: 发酵 $defaultMinutes 分钟' : '默认: 发酵 $defaultMinutes 分钟 · 左右滑选状态'),
                      style: TextStyle(fontSize: ZephyrFontSize.xs, color: isGeneric ? z.accentPrimary : (hasHabit ? z.accentPrimary : z.textTertiary)),
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
      case 'baozi':
        return Icons.breakfast_dining;
      case 'white_flatbread':
      case 'brown_sugar_flatbread':
      case 'flatbread':
        return Icons.lunch_dining;
      case 'generic_timer':
        return Icons.timer_outlined;
      default:
        return Icons.restaurant;
    }
  }

  void _start(BuildContext context, Recipe recipe) {
    final habitMinutes = _habitDefaults[recipe.id];
    ref.read(activeBatchesProvider.notifier).startBatch(recipe, fermentationMinutes: habitMinutes);
    // pop 回已有的 DashboardScreen — 它 watch activeBatchesProvider，会自动刷新
    // 不用 pushAndRemoveUntil 创建新 DashboardScreen，否则旧 dispose 会清空新设置的回调
    Navigator.pop(context);
  }

  /// 右滑选择起始状态 — 从任意工序开始，而非只能从发酵开始
  void _showStartStatePicker(ZephyrSemantic z, Recipe recipe) {
    final steps = recipe.steps;
    showModalBottomSheet(
      context: context,
      backgroundColor: z.bgElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(ZephyrRadius.overlay))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ZephyrSpacing.s5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('选择起始状态', style: TextStyle(fontSize: ZephyrFontSize.lg, fontWeight: FontWeight.w600, color: z.textPrimary)),
              const SizedBox(height: 4),
              Text('从当前状态开始计时', style: TextStyle(fontSize: ZephyrFontSize.xs, color: z.textTertiary)),
              const SizedBox(height: ZephyrSpacing.s4),
              ...steps.map((step) {
                final isParallel = step.isParallel;
                final duration = step.defaultDurationMinutes;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: z.accentPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(ZephyrRadius.md),
                    ),
                    child: Center(child: Icon(
                      _stepIcon(step.type),
                      size: 20,
                      color: z.accentPrimary,
                    )),
                  ),
                  title: Text(step.label, style: TextStyle(fontSize: ZephyrFontSize.base, fontWeight: FontWeight.w600, color: z.textPrimary)),
                  subtitle: Text(
                    isParallel ? '并行 · ${duration}分钟' : (duration != null ? '$duration分钟' : '确认步骤'),
                    style: TextStyle(fontSize: ZephyrFontSize.xs, color: z.textTertiary),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: z.textTertiary),
                  onTap: () {
                    Navigator.pop(ctx);
                    _startFromState(context, recipe, step);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  IconData _stepIcon(StepType type) {
    switch (type) {
      case StepType.fermentation:
        return Icons.timer;
      case StepType.boiling:
        return Icons.water_drop;
      case StepType.steaming:
        return Icons.soup_kitchen;
      case StepType.simmering:
        return Icons.local_fire_department;
      case StepType.uncover:
        return Icons.check_circle;
      case StepType.flipping:
        return Icons.flip;
      case StepType.plateOut:
        return Icons.restaurant;
    }
  }

  /// 从指定状态开始 — 跳过前面所有步骤
  void _startFromState(BuildContext context, Recipe recipe, StepNode startStep) {
    final habitMinutes = _habitDefaults[recipe.id];
    // 先正常启动批次
    final batch = ref.read(activeBatchesProvider.notifier).startBatch(recipe, fermentationMinutes: habitMinutes);
    if (batch == null) return;

    // 找到起始步骤的索引
    final startIndex = recipe.steps.indexWhere((s) => s.type == startStep.type);
    if (startIndex <= 0) {
      // 从第一步开始，无需调整
      Navigator.pop(context);
      return;
    }

    // 使用公共方法设置起始状态
    ref.read(activeBatchesProvider.notifier).startFromStepIndex(batch.id, startIndex);

    Navigator.pop(context);
  }

  /// 通用倒计时对话框 — 可编辑名称和时间
  void _showGenericTimerDialog(ZephyrSemantic z) {
    final nameCtrl = TextEditingController();
    final minutesCtrl = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: z.bgElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ZephyrRadius.overlay)),
        title: Text('通用倒计时', style: TextStyle(color: z.textPrimary, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                hintText: '事项名称（可选）',
                hintStyle: TextStyle(color: z.textTertiary, fontSize: 14),
                filled: true,
                fillColor: z.bgMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ZephyrRadius.md),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: z.textPrimary, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: minutesCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '分钟',
                hintStyle: TextStyle(color: z.textTertiary, fontSize: 14),
                filled: true,
                fillColor: z.bgMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ZephyrRadius.md),
                  borderSide: BorderSide.none,
                ),
                suffixText: '分钟',
                suffixStyle: TextStyle(color: z.textTertiary, fontSize: 14),
              ),
              style: TextStyle(color: z.textPrimary, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('取消', style: TextStyle(color: z.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final minutes = int.tryParse(minutesCtrl.text.trim()) ?? 10;
              final name = nameCtrl.text.trim();
              Navigator.pop(ctx);
              // 启动通用倒计时，带自定义名称
              ref.read(activeBatchesProvider.notifier)
                  .startBatch(Recipe.genericTimer, fermentationMinutes: minutes);
              // 设置位置标签为事项名称
              if (name.isNotEmpty) {
                final batches = ref.read(activeBatchesProvider);
                if (batches.isNotEmpty) {
                  final lastBatch = batches.last;
                  ref.read(activeBatchesProvider.notifier)
                      .setPositionLabel(lastBatch.id, name);
                }
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: z.accentPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('开始'),
          ),
        ],
      ),
    ).whenComplete(() {
      nameCtrl.dispose();
      minutesCtrl.dispose();
    });
  }
}

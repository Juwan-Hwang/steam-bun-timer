/// 主屏看板 — §1.4
/// V1+V2：卡片排序/全屏提醒覆盖层/音量键确认/语音指令/并行显示
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_tokens.dart';
import '../providers/app_providers.dart';
import '../models/batch.dart';
import '../models/recipe.dart';
import '../services/reminder_manager.dart';
import '../services/trigger_source.dart';
import '../services/voice_command_service.dart';
import '../services/finish_feedback.dart';
import '../widgets/batch_card.dart';
import '../widgets/completion_celebration.dart';
import 'recipe_select_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _setupTriggerSources();
  }

  @override
  void dispose() {
    // 清除单例回调 — 防止旧 State 销毁后回调悬空
    HardwareKeyTriggerSource.instance.stop();
    final voice = VoiceCommandService.instance;
    voice.onCommand = null;
    voice.onQuickStart = null;
    voice.onRecognitionFailed = null;
    super.dispose();
  }

  /// 设置音量键/蓝牙/语音触发源
  void _setupTriggerSources() {
    final trigger = HardwareKeyTriggerSource.instance;
    trigger.onTrigger = (event) {
      _handleTrigger();
    };
    trigger.start();

    // V2: 语音指令
    final voice = VoiceCommandService.instance;
    voice.onCommand = (cmd) {
      _handleVoiceCommand(cmd);
    };
    // V2: 语音快捷启动 — 说出品种名直接开锅
    voice.onQuickStart = (recipeId) {
      _handleQuickStart(recipeId);
    };
    // 初始化语音引擎 — 仅在设置中已开启时加载模型，避免数十 MB 常驻内存
    final settings = ref.read(settingsProvider);
    if (settings.voiceEnabled) {
      VoiceCommandService.instance.initialize();
    }
  }

  /// 触发源回调 — 仅关闭提醒，不自动确认下一步
  ///
  /// 用户反馈：提醒关闭后应先回到看板，让用户手动点按钮确认
  /// 多锅场景下自动确认会导致关不掉提醒、反复出现
  void _handleTrigger() {
    // 清除全屏提醒覆盖层
    ref.read(activeReminderProvider.notifier).state = null;
    // 标记冷却 — 30 秒内不重新触发提醒
    ref.read(activeBatchesProvider.notifier).markReminderDismissed();
    // 仅停止提醒（声音/振动/闹钟），不自动确认任何步骤
    ReminderManager.instance.stop();
  }

  /// 语音指令处理 — V2
  void _handleVoiceCommand(VoiceCommand cmd) {
    final batches = ref.read(activeBatchesProvider);
    if (batches.isEmpty) return;
    final sorted = _sortByUrgency(batches);
    final target = sorted.first;

    switch (cmd) {
      case VoiceCommand.startBoiling:
        // 确认烧水节点 — 优先并行步骤
        final parallel = target.parallelStep;
        if (parallel != null && parallel.status == StepStatus.awaitingConfirmation) {
          ref.read(activeBatchesProvider.notifier).confirmParallelStep(target.id);
        } else {
          final step = target.currentStep;
          if (step?.node.type == StepType.boiling) {
            ref.read(activeBatchesProvider.notifier).confirmCurrentStep(target.id);
          }
        }
      case VoiceCommand.startSteaming:
        final step = target.currentStep;
        if (step?.node.type == StepType.steaming) {
          ref.read(activeBatchesProvider.notifier).confirmCurrentStep(target.id);
        }
      case VoiceCommand.done:
        // 语音「好了」— 根据上下文确认
        // 🔴1 修复：当前步骤与并行步骤互斥确认，防止同时推进
        final step = target.currentStep;
        if (step == null) return;

        // 优先处理并行步骤 — 烧水完成/等待确认时「好了」=确认烧水
        final parallel = target.parallelStep;
        if (parallel != null &&
            (parallel.status == StepStatus.awaitingConfirmation ||
             parallel.status == StepStatus.done)) {
          ref.read(activeBatchesProvider.notifier).confirmParallelStep(target.id);
          return;
        }

        // 无并行步骤待确认 → 处理当前步骤
        if (step.status == StepStatus.evaluating) {
          ref.read(activeBatchesProvider.notifier)
              .evaluateFermentation(target.id, FermentationResult.perfect);
        } else if (step.status == StepStatus.awaitingConfirmation || step.status == StepStatus.done) {
          // 语音完成最终工序（揭锅/出锅）同样触发通关庆祝
          if (step.node.type == StepType.uncover || step.node.type == StepType.plateOut) {
            FinishFeedback.celebrate();
            CompletionCelebration.show(
              context,
              title: step.node.type == StepType.plateOut ? '出锅啦！' : '揭锅啦！',
              subtitle: target.recipe.isFlatbread ? '金黄酥脆 · 趁热吃' : '白白胖胖 · 热气腾腾',
            );
          }
          ref.read(activeBatchesProvider.notifier).confirmCurrentStep(target.id);
        }
      case VoiceCommand.addTwoMinutes:
        // 「加两分钟」= 120 秒（adjustDuration 签名为 deltaSeconds）
        ref.read(activeBatchesProvider.notifier).adjustDuration(target.id, 120);
    }
  }

  /// 语音快捷启动 — V2 说出品种名直接开始批次
  Future<void> _handleQuickStart(String recipeId) async {
    try {
      final recipe = Recipe.findById(recipeId);
      if (recipe == null) return;

      // 尝试获取习惯默认值（需异步，温度暂不可得传 null）
      final habitMinutes = await ref
          .read(activeBatchesProvider.notifier)
          .getHabitDefaultMinutes(recipeId, null);

      if (!mounted) return;
      ref
          .read(activeBatchesProvider.notifier)
          .startBatch(recipe, fermentationMinutes: habitMinutes);
    } catch (e) {
      debugPrint('[QuickStart] Failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final batches = ref.watch(activeBatchesProvider);
    final reminder = ref.watch(activeReminderProvider);
    final z = ZephyrThemeExtension.of(context).s;
    final sorted = _sortByUrgency(batches);

    return Scaffold(
      appBar: batches.isEmpty
          ? null
          : AppBar(
              backgroundColor: z.isDark ? const Color(0xF718181B) : const Color(0xF2FFFFFF),
              elevation: 0,
              systemOverlayStyle: z.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
              iconTheme: IconThemeData(color: z.textPrimary),
              actionsIconTheme: IconThemeData(color: z.textPrimary),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings, color: z.textPrimary),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
              ],
            ),
      body: Stack(
        children: [
          // 主看板
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: z.isDark
                    ? [const Color(0xF718181B), const Color(0xE6000000)]
                    : [const Color(0xF2FFFFFF), const Color(0xE6F8FAFC)],
              ),
            ),
            child: SafeArea(
              child: batches.isEmpty
                  ? _emptyState(z)
                  : _batchList(z, sorted),
            ),
          ),
          // 全屏提醒覆盖层 — §5.2
          // 点击屏幕任意位置 → 仅关闭当前提醒，后续仍会间歇提醒
          // 点击「不再提醒」按钮 → 永久关闭该批次该动作的提醒
          if (reminder != null)
            ReminderOverlay(
              reminder: reminder,
              onConfirm: () {
                ref.read(activeReminderProvider.notifier).state = null;
                ref.read(activeBatchesProvider.notifier).markReminderDismissed();
                ReminderManager.instance.stop();
              },
              onDismissPermanently: () {
                ref.read(activeBatchesProvider.notifier)
                    .dismissReminderPermanently(reminder.batchId, reminder.actionText);
              },
            ),
        ],
      ),
      // 提醒覆盖层显示时隐藏 FAB — 避免「开始一锅」按钮遮挡全屏提醒
      floatingActionButton: reminder != null
          ? null
          : (_hasCapacity(batches) ? _startBtn(z) : _fullBadge(z)),
    );
  }

  Widget _emptyState(ZephyrSemantic z) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(shape: BoxShape.circle, color: z.accentGlow),
            child: Icon(Icons.soup_kitchen, size: 80, color: z.accentPrimary),
          ),
          const SizedBox(height: ZephyrSpacing.s6),
          Text('蒸馒头计时器', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: z.textPrimary, letterSpacing: -0.5)),
          const SizedBox(height: ZephyrSpacing.s3),
          Text('点击下方按钮开始一锅', style: TextStyle(fontSize: ZephyrFontSize.sm, color: z.textTertiary)),
        ],
      ),
    );
  }

  Widget _batchList(ZephyrSemantic z, List<Batch> batches) {
    return Consumer(
      builder: (ctx, ref, _) {
        // 每秒刷新倒计时
        ref.watch(tickProvider);
        return ListView.builder(
          padding: const EdgeInsets.all(ZephyrSpacing.s5),
          itemCount: batches.length,
          itemBuilder: (ctx, i) {
            final b = batches[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: ZephyrSpacing.s4),
              child: BatchCard(
                batch: b,
                onConfirm: () => ref.read(activeBatchesProvider.notifier).confirmCurrentStep(b.id),
                onConfirmParallel: () => ref.read(activeBatchesProvider.notifier).confirmParallelStep(b.id),
                onEvaluate: (result) => ref.read(activeBatchesProvider.notifier).evaluateFermentation(b.id, result),
                onAdjustDuration: (delta) => ref.read(activeBatchesProvider.notifier).adjustDuration(b.id, delta),
                onAdjustParallelDuration: (delta) => ref.read(activeBatchesProvider.notifier).adjustParallelDuration(b.id, delta),
                onExtendFermentation: (mins) => ref.read(activeBatchesProvider.notifier).extendFermentation(b.id, mins),
                onSetFermentationMinutes: (mins) => ref.read(activeBatchesProvider.notifier).setFermentationMinutes(b.id, mins),
                onCancel: () => ref.read(activeBatchesProvider.notifier).cancelBatch(b.id),
                onRestart: () => ref.read(activeBatchesProvider.notifier).restartBatch(b.id),
                onDismiss: () => ref.read(activeBatchesProvider.notifier).removeCompletedBatch(b.id),
                onSetPositionLabel: (label) => ref.read(activeBatchesProvider.notifier).setPositionLabel(b.id, label),
              ),
            );
          },
        );
      },
    );
  }

  /// 只要有活跃批次且编号未满，就显示开始按钮
  bool _hasCapacity(List<Batch> batches) {
    final activeCount = batches.where((b) => b.status == BatchStatus.active).length;
    return activeCount < 6;
  }

  /// 编号满时显示提示徽章
  Widget _fullBadge(ZephyrSemantic z) {
    return FloatingActionButton.extended(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('6 锅已满，完成或取消一锅后再开新的'), duration: Duration(seconds: 2)),
        );
      },
      backgroundColor: z.bgMuted,
      foregroundColor: z.textTertiary,
      icon: const Icon(Icons.lock_outline, size: 20),
      label: Text('已满 6 锅', style: TextStyle(fontSize: ZephyrFontSize.sm, fontWeight: FontWeight.w600)),
    );
  }

  Widget _startBtn(ZephyrSemantic z) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const RecipeSelectScreen())),
      backgroundColor: z.accentPrimary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add, size: 24),
      label: Text('开始一锅', style: TextStyle(fontSize: ZephyrFontSize.base, fontWeight: FontWeight.w700)),
      extendedPadding: const EdgeInsets.symmetric(horizontal: ZephyrSpacing.s6, vertical: ZephyrSpacing.s4),
    );
  }

  List<Batch> _sortByUrgency(List<Batch> batches) {
    final sorted = batches.toList();
    sorted.sort((a, b) => _urgencyVal(b).compareTo(_urgencyVal(a)));
    return sorted;
  }

  int _urgencyVal(Batch b) {
    if (b.isCompleted) return 0;
    final s = b.currentStep;
    if (s == null) return 0;
    switch (s.status) {
      case StepStatus.awaitingConfirmation:
      case StepStatus.evaluating:
      case StepStatus.done:
        // done 也需要用户确认推进， urgency 应与 awaitingConfirmation 同级
        return 100;
      case StepStatus.running:
        final r = s.remainingSeconds;
        if (r == null) return 10;
        if (r <= 0) return 100;
        if (r <= 180) return 80;
        return 50 - (r ~/ 60).clamp(0, 40);
      default:
        return 10;
    }
  }
}

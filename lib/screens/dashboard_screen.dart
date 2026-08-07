/// 主屏看板 — §1.4
/// V1+V2：卡片排序/全屏提醒覆盖层/音量键确认/语音指令/并行显示
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_tokens.dart';
import '../providers/app_providers.dart';
import '../models/batch.dart';
import '../models/recipe.dart';
import '../services/reminder_manager.dart';
import '../services/trigger_source.dart';
import '../services/voice_command_service.dart';
import '../widgets/batch_card.dart';
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
    // 初始化语音引擎（如果设置中已开启）
    VoiceCommandService.instance.initialize();
  }

  /// 触发源回调 — 确认当前最紧急的批次
  void _handleTrigger() {
    // 始终先清除全屏提醒覆盖层
    ref.read(activeReminderProvider.notifier).state = null;

    final batches = ref.read(activeBatchesProvider);
    if (batches.isEmpty) {
      ReminderManager.instance.stop();
      return;
    }

    // 如果有活跃提醒，先停止铃声
    if (ReminderManager.instance.isReminding) {
      ReminderManager.instance.stop().then((_) {
        // 停止后确认最紧急批次的当前工序
        final sorted = _sortByUrgency(batches);
        final mostUrgent = sorted.first;
        final step = mostUrgent.currentStep;
        if (step != null && (step.status == StepStatus.awaitingConfirmation ||
            step.status == StepStatus.evaluating)) {
          ref.read(activeBatchesProvider.notifier).confirmCurrentStep(mostUrgent.id);
        }
      });
      return;
    }

    // 没有活跃提醒时，确认当前工序
    final sorted = _sortByUrgency(batches);
    final mostUrgent = sorted.first;
    final step = mostUrgent.currentStep;
    if (step != null && step.node.requiresConfirmation) {
      ref.read(activeBatchesProvider.notifier).confirmCurrentStep(mostUrgent.id);
    }
  }

  /// 语音指令处理 — V2
  void _handleVoiceCommand(VoiceCommand cmd) {
    final batches = ref.read(activeBatchesProvider);
    if (batches.isEmpty) return;
    final sorted = _sortByUrgency(batches);
    final target = sorted.first;

    switch (cmd) {
      case VoiceCommand.startBoiling:
        // 确认烧水节点
        final step = target.currentStep;
        if (step?.node.type == StepType.boiling) {
          ref.read(activeBatchesProvider.notifier).confirmCurrentStep(target.id);
        }
      case VoiceCommand.startSteaming:
        final step = target.currentStep;
        if (step?.node.type == StepType.steaming) {
          ref.read(activeBatchesProvider.notifier).confirmCurrentStep(target.id);
        }
      case VoiceCommand.done:
        ref.read(activeBatchesProvider.notifier).confirmCurrentStep(target.id);
      case VoiceCommand.addTwoMinutes:
        ref.read(activeBatchesProvider.notifier).adjustDuration(target.id, 2);
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
              actions: [
                IconButton(
                  icon: Icon(Icons.settings, color: z.textSecondary),
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
          if (reminder != null)
            ReminderOverlay(
              reminder: reminder,
              onConfirm: () {
                ref.read(activeReminderProvider.notifier).state = null;
                _handleTrigger();
              },
            ),
        ],
      ),
      floatingActionButton: batches.length < 6 ? _startBtn(z) : null,
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
                onEvaluate: (result) => ref.read(activeBatchesProvider.notifier).evaluateFermentation(b.id, result),
                onAdjustDuration: (delta) => ref.read(activeBatchesProvider.notifier).adjustDuration(b.id, delta),
                onExtendFermentation: (mins) => ref.read(activeBatchesProvider.notifier).extendFermentation(b.id, mins),
                onSetFermentationMinutes: (mins) => ref.read(activeBatchesProvider.notifier).setFermentationMinutes(b.id, mins),
                onCancel: () => ref.read(activeBatchesProvider.notifier).cancelBatch(b.id),
                onRestart: () => ref.read(activeBatchesProvider.notifier).restartBatch(b.id),
                onSetPositionLabel: (label) => ref.read(activeBatchesProvider.notifier).setPositionLabel(b.id, label),
              ),
            );
          },
        );
      },
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

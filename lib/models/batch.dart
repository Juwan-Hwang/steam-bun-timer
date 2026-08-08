/// 批次状态机 — 对应 §6 工序状态机规格
/// 核心数据约束 §4.1：记录时间戳而非计时读数
library;

import 'recipe.dart';

/// 批次状态
enum BatchStatus { active, completed, cancelled }

/// 工序运行时状态
enum StepStatus {
  pending,
  running,
  awaitingConfirmation,
  evaluating,
  extending,
  done,
  /// 焖制静默中 — 后台 5 分钟计时
  simmering,
}

/// 单个工序的运行时状态
class StepRuntime {
  final StepNode node;
  StepStatus status;

  /// 计划开始/结束时间戳
  DateTime? plannedStart;
  DateTime? plannedEnd;

  /// 实际开始/确认时间戳（§4.1 核心约束）
  DateTime? actualStart;
  DateTime? actualConfirm;

  /// 续时累计分钟数
  int extendedMinutes = 0;

  /// 续时记录日志（每次续时的分钟数列表）
  final List<int> extensionsLog = [];

  /// 提醒发出时间戳
  DateTime? reminderSentAt;

  /// 低置信度标记（§4.1 兜底）
  bool lowConfidence = false;

  /// 是否正在并行运行（如烧水与发酵尾部并行）
  bool isParallelRunning = false;

  StepRuntime({required this.node, this.status = StepStatus.pending});

  /// 剩余秒数，null = 无倒计时
  int? get remainingSeconds {
    if (plannedEnd == null) return null;
    final diff = plannedEnd!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  /// 实际完成时长（分钟），由时间戳相减
  int? get actualDurationMinutes {
    if (actualStart == null || actualConfirm == null) return null;
    return actualConfirm!.difference(actualStart!).inMinutes;
  }
}

/// 批次 — 一锅从开始到结束的完整记录
class Batch {
  final String id;
  int displayNumber;
  final Recipe recipe;
  final List<StepRuntime> steps;
  BatchStatus status;

  DateTime? startedAt;
  DateTime? completedAt;
  FermentationResult? fermentationResult;
  double? temperature;
  int? humidity;
  int adjustmentMinutes = 0;
  String? positionLabel;
  int currentStepIndex = 0;

  /// 并行工序的运行时引用（如烧水与发酵并行期间）
  StepRuntime? parallelStep;

  /// 焖制静默计时结束时间
  DateTime? simmeringEnd;

  /// 天气获取重试时间戳 — 温度为 null 时每 60 秒重试
  DateTime? weatherRetryAt;

  Batch({
    required this.id,
    required this.displayNumber,
    required this.recipe,
    required this.steps,
    this.status = BatchStatus.active,
    this.startedAt,
    this.completedAt,
    this.temperature,
    this.positionLabel,
    this.currentStepIndex = 0,
  });

  StepRuntime? get currentStep =>
      currentStepIndex < steps.length ? steps[currentStepIndex] : null;

  bool get isCompleted => status == BatchStatus.completed;
  bool get isCancelled => status == BatchStatus.cancelled;

  /// 获取发酵工序
  StepRuntime? get fermentationStep {
    final i = steps.indexWhere((s) => s.node.type == StepType.fermentation);
    return i >= 0 ? steps[i] : null;
  }

  /// 获取烧水工序
  StepRuntime? get boilingStep {
    final i = steps.indexWhere((s) => s.node.type == StepType.boiling);
    return i >= 0 ? steps[i] : null;
  }

  /// 获取蒸制工序
  StepRuntime? get steamingStep {
    final i = steps.indexWhere((s) => s.node.type == StepType.steaming);
    return i >= 0 ? steps[i] : null;
  }

  /// 获取焖制工序
  StepRuntime? get simmeringStep {
    final i = steps.indexWhere((s) => s.node.type == StepType.simmering);
    return i >= 0 ? steps[i] : null;
  }

  /// 获取揭锅工序
  StepRuntime? get uncoverStep {
    final i = steps.indexWhere((s) => s.node.type == StepType.uncover);
    return i >= 0 ? steps[i] : null;
  }

  /// 工厂方法：从模板创建新批次
  factory Batch.create({
    required String id,
    required int displayNumber,
    required Recipe recipe,
    int? fermentationMinutes,
  }) {
    final steps = recipe.steps.map((n) => StepRuntime(node: n)).toList();
    final batch = Batch(
      id: id,
      displayNumber: displayNumber,
      recipe: recipe,
      steps: steps,
      startedAt: DateTime.now(),
    );

    // 初始化第一个工序
    if (steps.isNotEmpty) {
      final first = steps[0];
      first.status = StepStatus.running;
      first.actualStart = DateTime.now();
      first.plannedStart = DateTime.now();
      final dur = fermentationMinutes ?? first.node.defaultDurationMinutes;
      if (dur != null) {
        first.plannedEnd = DateTime.now().add(Duration(minutes: dur));
      }
    }

    return batch;
  }

  /// 从持久化数据恢复批次 — 完整恢复所有字段
  factory Batch.restore({
    required String id,
    required int displayNumber,
    required Recipe recipe,
    required int currentStepIndex,
    required BatchStatus status,
    required DateTime startedAt,
    DateTime? completedAt,
    double? temperature,
    int? humidity,
    int adjustmentMinutes = 0,
    String? positionLabel,
    FermentationResult? fermentationResult,
    DateTime? simmeringEnd,
    StepRuntime? parallelStep,
    required List<StepRuntime> steps,
  }) {
    final batch = Batch(
      id: id,
      displayNumber: displayNumber,
      recipe: recipe,
      steps: steps,
      status: status,
      startedAt: startedAt,
      completedAt: completedAt,
      temperature: temperature,
      positionLabel: positionLabel,
      currentStepIndex: currentStepIndex,
    );
    batch.humidity = humidity;
    batch.adjustmentMinutes = adjustmentMinutes;
    batch.fermentationResult = fermentationResult;
    batch.simmeringEnd = simmeringEnd;
    batch.parallelStep = parallelStep;
    return batch;
  }
}

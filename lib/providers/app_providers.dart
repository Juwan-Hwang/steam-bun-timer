/// Riverpod 状态管理 — 全局 App 状态
/// V1+V2 完整功能：并行烧水/焖制静默计时/超时间歇提醒/低置信度/习惯默认值/持久化/数据入库
library;

import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart' hide Batch;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../models/batch.dart';
import '../utils/number_pool.dart';
import '../utils/season_util.dart';
import '../data/database.dart';
import '../services/weather_service.dart';
import '../services/habit_default_service.dart';
import '../services/batch_persistence.dart';
import '../services/reminder_manager.dart';
import '../services/foreground_task_handler.dart';
import '../services/screen_controller.dart';
import '../services/voice_command_service.dart';

/// 设置 Provider — 持久化到 SharedPreferences
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class AppSettings {
  final bool screenAlwaysOn;
  final bool autoDimBrightness;
  final bool burnInProtection;
  final bool simmeringReminder;
  final bool chargingProtection;
  final bool voiceEnabled;

  const AppSettings({
    this.screenAlwaysOn = true,
    this.autoDimBrightness = true,
    this.burnInProtection = true,
    this.simmeringReminder = true,
    this.chargingProtection = false,
    this.voiceEnabled = false,
  });

  AppSettings copyWith({
    bool? screenAlwaysOn,
    bool? autoDimBrightness,
    bool? burnInProtection,
    bool? simmeringReminder,
    bool? chargingProtection,
    bool? voiceEnabled,
  }) {
    return AppSettings(
      screenAlwaysOn: screenAlwaysOn ?? this.screenAlwaysOn,
      autoDimBrightness: autoDimBrightness ?? this.autoDimBrightness,
      burnInProtection: burnInProtection ?? this.burnInProtection,
      simmeringReminder: simmeringReminder ?? this.simmeringReminder,
      chargingProtection: chargingProtection ?? this.chargingProtection,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
    );
  }

  /// 从 SharedPreferences 加载
  static Future<AppSettings> fromPrefs(SharedPreferences prefs) async {
    return AppSettings(
      screenAlwaysOn: prefs.getBool('screenAlwaysOn') ?? true,
      autoDimBrightness: prefs.getBool('autoDimBrightness') ?? true,
      burnInProtection: prefs.getBool('burnInProtection') ?? true,
      simmeringReminder: prefs.getBool('simmeringReminder') ?? true,
      chargingProtection: prefs.getBool('chargingProtection') ?? false,
      voiceEnabled: prefs.getBool('voiceEnabled') ?? false,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SharedPreferences? _prefs;

  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    state = await AppSettings.fromPrefs(_prefs!);
    // 同步屏幕控制器状态
    await ScreenController.instance.setAlwaysOn(state.screenAlwaysOn);
    ScreenController.instance.setAutoDim(state.autoDimBrightness);
    ScreenController.instance.setBurnInProtection(state.burnInProtection);
    // 如果语音已开启，启动 KWS
    if (state.voiceEnabled) {
      await VoiceCommandService.instance.enable();
    }
  }

  Future<void> _save(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  void toggleScreenAlwaysOn() {
    state = state.copyWith(screenAlwaysOn: !state.screenAlwaysOn);
    ScreenController.instance.setAlwaysOn(state.screenAlwaysOn);
    _save('screenAlwaysOn', state.screenAlwaysOn);
  }

  void toggleAutoDim() {
    state = state.copyWith(autoDimBrightness: !state.autoDimBrightness);
    ScreenController.instance.setAutoDim(state.autoDimBrightness);
    _save('autoDimBrightness', state.autoDimBrightness);
  }

  void toggleBurnInProtection() {
    state = state.copyWith(burnInProtection: !state.burnInProtection);
    ScreenController.instance.setBurnInProtection(state.burnInProtection);
    _save('burnInProtection', state.burnInProtection);
  }

  void toggleSimmeringReminder() {
    state = state.copyWith(simmeringReminder: !state.simmeringReminder);
    _save('simmeringReminder', state.simmeringReminder);
  }

  void toggleChargingProtection() {
    state = state.copyWith(chargingProtection: !state.chargingProtection);
    _save('chargingProtection', state.chargingProtection);
  }

  void toggleVoiceEnabled() {
    state = state.copyWith(voiceEnabled: !state.voiceEnabled);
    _save('voiceEnabled', state.voiceEnabled);
    if (state.voiceEnabled) {
      VoiceCommandService.instance.enable();
    } else {
      VoiceCommandService.instance.disable();
    }
  }
}

/// 编号池
final numberPoolProvider = Provider<NumberPool>((ref) => NumberPool(maxCount: 6));

/// 数据库
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

/// 活跃批次
final activeBatchesProvider = StateNotifierProvider<ActiveBatchesNotifier, List<Batch>>((ref) {
  return ActiveBatchesNotifier(ref);
});

/// 当前活跃提醒
final activeReminderProvider = StateProvider<ReminderRequest?>((ref) => null);

class ActiveBatchesNotifier extends StateNotifier<List<Batch>> {
  final Ref ref;
  Timer? _checkTimer;

  ActiveBatchesNotifier(this.ref) : super([]) {
    // 每秒检查所有批次状态
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  /// 每秒 tick — 检查超时/并行触发/焖制计时/低置信度
  void _tick() {
    if (state.isEmpty) return;
    bool changed = false;

    for (final batch in state) {
      final step = batch.currentStep;
      if (step == null) continue;

      // 1. 检查并行触发 — 发酵剩 3 分钟时启动烧水
      if (step.node.type == StepType.fermentation &&
          step.status == StepStatus.running &&
          batch.parallelStep == null) {
        final boilingStep = batch.boilingStep;
        if (boilingStep != null) {
          final remain = step.remainingSeconds;
          if (remain != null && remain <= 180) { // 3 分钟
            _triggerParallelBoiling(batch, boilingStep);
            changed = true;
          }
        }
      }

      // 2. 检查发酵倒计时到点 → 进入评价
      if (step.node.type == StepType.fermentation &&
          step.status == StepStatus.running) {
        final remain = step.remainingSeconds;
        if (remain != null && remain <= 0) {
          step.status = StepStatus.evaluating;
          _triggerReminder(batch, '发酵好了');
          changed = true;
        }
      }

      // 3. 检查发酵评价超时 → 5 分钟后低置信度
      if (step.status == StepStatus.evaluating &&
          step.reminderSentAt != null) {
        final sinceReminder = DateTime.now().difference(step.reminderSentAt!).inMinutes;
        if (sinceReminder >= 5) {
          step.lowConfidence = true;
          // 自动转入下阶段（§6 超过 5 min 未确认打低置信度，自动转入下阶段）
          _evaluateFermentationInternal(batch, FermentationResult.perfect);
          changed = true;
        } else if (sinceReminder >= 2) {
          // 2 分钟后每 30 秒间歇提醒
          if (sinceReminder * 60 % 30 == 0) {
            _triggerIntermittentReminder(batch, '发酵好了');
          }
        }
      }

      // 4. 检查动作节点超时 — 2 分钟后每 30 秒间歇提醒
      if (step.status == StepStatus.awaitingConfirmation &&
          step.reminderSentAt != null) {
        final sinceReminder = DateTime.now().difference(step.reminderSentAt!).inSeconds;
        if (sinceReminder >= 120) { // 2 分钟
          if (sinceReminder % 30 == 0) { // 每 30 秒
            _triggerIntermittentReminder(batch, step.node.announcementAction ?? '');
          }
        }
      }

      // 5. 检查焖制静默计时 — 5 分钟后轻提示
      if (step.node.type == StepType.simmering &&
          step.status == StepStatus.simmering &&
          batch.simmeringEnd != null) {
        if (DateTime.now().isAfter(batch.simmeringEnd!)) {
          final settings = ref.read(settingsProvider);
          if (settings.simmeringReminder) {
            _triggerSimmeringHint(batch);
          }
          batch.simmeringEnd = null; // 只提醒一次
          changed = true;
        }
      }

      // 6. 检查并行烧水到点
      final parallel = batch.parallelStep;
      if (parallel != null && parallel.isParallelRunning) {
        final remain = parallel.remainingSeconds;
        if (remain != null && remain <= 0) {
          parallel.isParallelRunning = false;
          parallel.status = StepStatus.done;
          // 烧水完成 → 提醒上锅
          _triggerReminder(batch, '该上锅了');
          changed = true;
        }
      }

      // 7. 更新前台服务通知
      _updateForegroundNotification(batch);
    }

    if (changed) {
      state = List.of(state);
      _persistAll();
    }
  }

  /// 开始一个新批次
  Batch? startBatch(Recipe recipe, {int? fermentationMinutes}) {
    final pool = ref.read(numberPoolProvider);
    final number = pool.acquire();
    if (number == null) return null;

    final batch = Batch.create(
      id: 'batch_${DateTime.now().millisecondsSinceEpoch}',
      displayNumber: number,
      recipe: recipe,
      fermentationMinutes: fermentationMinutes,
    );

    // 异步获取气温 — §4.5
    _fetchWeather(batch.id);

    // 启动前台服务 — §5.1 保活
    _startForegroundIfNeeded();

    state = [...state, batch];
    _persistBatch(batch);
    return batch;
  }

  /// 确认当前工序动作节点
  void confirmCurrentStep(String batchId) {
    final idx = state.indexWhere((b) => b.id == batchId);
    if (idx == -1) return;
    final batch = state[idx];
    final current = batch.currentStep;
    if (current == null) return;

    // 停止提醒
    ReminderManager.instance.stop();

    current.actualConfirm = DateTime.now();
    current.status = StepStatus.done;

    // 提醒→确认间隔在 _saveBatchRecord 中通过 reminderSentAt/actualConfirm 计算

    // 推进到下一步
    _advanceToNext(batch, idx);
    state = List.of(state);
    _persistBatch(batch);
  }

  /// 发酵评价 — §4.3
  void evaluateFermentation(String batchId, FermentationResult result) {
    final idx = state.indexWhere((b) => b.id == batchId);
    if (idx == -1) return;
    final batch = state[idx];

    // 停止提醒
    ReminderManager.instance.stop();

    batch.fermentationResult = result;

    switch (result) {
      case FermentationResult.perfect:
        _evaluateFermentationInternal(batch, result);
      case FermentationResult.notEnough:
        final fStep = batch.fermentationStep!;
        fStep.status = StepStatus.extending;
      case FermentationResult.overFermented:
        _evaluateFermentationInternal(batch, result);
    }

    state = List.of(state);
    _persistBatch(batch);
  }

  void _evaluateFermentationInternal(Batch batch, FermentationResult result) {
    final fStep = batch.fermentationStep!;
    fStep.actualConfirm = DateTime.now();
    fStep.status = StepStatus.done;

    // 评价后不结束卡片，而是进入下一步（§6 关键规格约定）
    // 烧水如果已在并行，进入「该上锅了」awaitingConfirmation
    // 如果烧水未并行（饼子无发酵），直接进入下一步
    final idx = state.indexWhere((b) => b.id == batch.id);
    if (idx >= 0) {
      _advanceToNext(batch, idx);
    }
  }

  /// 续时 — §4.3 追加计时
  void extendFermentation(String batchId, int additionalMinutes) {
    final idx = state.indexWhere((b) => b.id == batchId);
    if (idx == -1) return;
    final batch = state[idx];
    final fStep = batch.fermentationStep!;

    fStep.extendedMinutes += additionalMinutes;
    fStep.extensionsLog.add(additionalMinutes);
    fStep.plannedEnd = DateTime.now().add(Duration(minutes: additionalMinutes));
    fStep.status = StepStatus.running;

    state = List.of(state);
    _persistBatch(batch);
  }

  /// 微调时长 — §3.1
  void adjustDuration(String batchId, int deltaMinutes) {
    final idx = state.indexWhere((b) => b.id == batchId);
    if (idx == -1) return;
    final batch = state[idx];
    final current = batch.currentStep;
    if (current == null || current.plannedEnd == null) return;

    current.plannedEnd = current.plannedEnd!.add(Duration(minutes: deltaMinutes));
    batch.adjustmentMinutes += deltaMinutes;

    // V2: 记录调整行为用于习惯默认值
    final temp = batch.temperature;
    if (current.node.type == StepType.fermentation) {
      final finalMinutes = current.remainingSeconds != null
          ? (current.remainingSeconds! ~/ 60) + deltaMinutes
          : null;
      if (finalMinutes != null) {
        HabitDefaultService.instance.recordAdjustment(
          recipeId: batch.recipe.id,
          temperature: temp,
          adjustmentMinutes: deltaMinutes,
          finalMinutes: finalMinutes,
        );
      }
    }

    state = List.of(state);
    _persistBatch(batch);
  }

  /// 设置发酵时长（滑动条/数字键盘）
  void setFermentationMinutes(String batchId, int minutes) {
    final idx = state.indexWhere((b) => b.id == batchId);
    if (idx == -1) return;
    final batch = state[idx];
    final fStep = batch.fermentationStep;
    if (fStep == null || fStep.status != StepStatus.running) return;

    fStep.plannedEnd = DateTime.now().add(Duration(minutes: minutes));
    fStep.plannedStart = DateTime.now();

    state = List.of(state);
    _persistBatch(batch);
  }

  /// 取消批次 — §4.2 标记为「未完成」
  void cancelBatch(String batchId) {
    final idx = state.indexWhere((b) => b.id == batchId);
    if (idx == -1) return;
    final batch = state[idx];
    batch.status = BatchStatus.cancelled;
    batch.completedAt = DateTime.now();

    // 入库标记为未完成
    _saveBatchRecord(batch);

    ref.read(numberPoolProvider).release(batch.displayNumber);
    ActiveBatchStorage.instance.removeBatch(batchId);
    state = List.from(state)..removeAt(idx);
    _stopForegroundIfIdle();
  }

  /// 完成批次后移除
  void removeCompletedBatch(String batchId) {
    final idx = state.indexWhere((b) => b.id == batchId);
    if (idx == -1) return;
    final batch = state[idx];
    ref.read(numberPoolProvider).release(batch.displayNumber);
    ActiveBatchStorage.instance.removeBatch(batchId);
    state = List.from(state)..removeAt(idx);
    _stopForegroundIfIdle();
  }

  /// 饼子「再来一锅」— §6
  void restartBatch(String batchId) {
    final idx = state.indexWhere((b) => b.id == batchId);
    if (idx == -1) return;
    final oldBatch = state[idx];
    // 完成旧批次
    oldBatch.status = BatchStatus.completed;
    oldBatch.completedAt = DateTime.now();
    _saveBatchRecord(oldBatch);
    ref.read(numberPoolProvider).release(oldBatch.displayNumber);
    ActiveBatchStorage.instance.removeBatch(batchId);

    // 创建新批次（同模板）
    final newBatch = startBatch(oldBatch.recipe);
    state = List.from(state)..removeAt(idx);
    if (newBatch != null) {
      state = [...state, newBatch];
    }
  }

  /// 设置位置标签
  void setPositionLabel(String batchId, String label) {
    final idx = state.indexWhere((b) => b.id == batchId);
    if (idx == -1) return;
    final batch = state[idx];
    batch.positionLabel = label.isEmpty ? null : label;
    state = List.of(state);
    _persistBatch(batch);
  }

  /// 获取习惯默认值 — V2 §3.2
  Future<int?> getHabitDefaultMinutes(String recipeId, double? temperature) {
    return HabitDefaultService.instance.getHabitDefaultMinutes(
      recipeId: recipeId,
      temperature: temperature,
    );
  }

  // ── 内部方法 ──

  void _advanceToNext(Batch batch, int idx) {
    if (batch.currentStepIndex < batch.steps.length - 1) {
      batch.currentStepIndex++;
      final next = batch.currentStep!;

      // 如果该步骤已作为并行步骤启动（如烧水在发酵尾部已并行），
      // 不重置已有时间戳，直接切换为 running 状态
      if (next.actualStart != null &&
          (next.status == StepStatus.awaitingConfirmation ||
           next.isParallelRunning)) {
        // 清理并行标记 — 交接后不再是并行
        next.isParallelRunning = false;
        next.status = StepStatus.running;
        // plannedEnd 已在并行启动时设置，保留不动
        return;
      }

      // 根据工序类型设置初始状态
      switch (next.node.type) {
        case StepType.simmering:
          // 焖制 — 进入静默计时，5 分钟后轻提示
          next.status = StepStatus.simmering;
          next.actualStart = DateTime.now();
          batch.simmeringEnd = DateTime.now().add(
            Duration(minutes: next.node.defaultDurationMinutes ?? 5),
          );
          // 播报「该关火了」
          _triggerReminder(batch, '该关火了');
        case StepType.uncover:
          // 揭锅 — 等待确认
          next.status = StepStatus.awaitingConfirmation;
          next.actualStart = DateTime.now();
        default:
          next.status = StepStatus.running;
          next.actualStart = DateTime.now();
          next.plannedStart = DateTime.now();
          if (next.node.defaultDurationMinutes != null) {
            next.plannedEnd = DateTime.now().add(
              Duration(minutes: next.node.defaultDurationMinutes!),
            );
          }
      }
    } else {
      // 所有工序完成
      batch.status = BatchStatus.completed;
      batch.completedAt = DateTime.now();
      _saveBatchRecord(batch);
      // 无活跃批次时停止前台服务
      _stopForegroundIfIdle();
    }
  }

  /// 触发并行烧水 — §1.3
  void _triggerParallelBoiling(Batch batch, StepRuntime boilingStep) {
    boilingStep.isParallelRunning = true;
    boilingStep.status = StepStatus.awaitingConfirmation;
    boilingStep.actualStart = DateTime.now();
    boilingStep.plannedStart = DateTime.now();
    boilingStep.plannedEnd = DateTime.now().add(
      Duration(minutes: boilingStep.node.defaultDurationMinutes ?? 5),
    );
    boilingStep.reminderSentAt = DateTime.now();
    batch.parallelStep = boilingStep;

    // 播报「该烧水了」
    _triggerReminder(batch, '该烧水了');
  }

  /// 触发提醒 — §5.2
  void _triggerReminder(Batch batch, String actionText) {
    final step = batch.currentStep;
    if (step != null) {
      step.reminderSentAt ??= DateTime.now();
    }

    final req = ReminderRequest(
      batchNumber: batch.displayNumber,
      recipeName: batch.recipe.name,
      recipeId: batch.recipe.id,
      actionText: actionText,
    );

    ref.read(activeReminderProvider.notifier).state = req;
    ReminderManager.instance.start(req);

    // 设置精确闹钟兜底
    ForegroundTaskHandler.instance.scheduleExactAlarm(
      id: batch.displayNumber,
      triggerAt: DateTime.now().add(const Duration(seconds: 5)),
      title: '${batch.displayNumber}号 ${batch.recipe.name}',
      body: actionText,
    );
  }

  /// 间歇提醒 — 每 30 秒
  void _triggerIntermittentReminder(Batch batch, String actionText) {
    final req = ReminderRequest(
      batchNumber: batch.displayNumber,
      recipeName: batch.recipe.name,
      recipeId: batch.recipe.id,
      actionText: actionText,
      level: ReminderLevel.intermittent,
    );
    ReminderManager.instance.start(req);
  }

  /// 焖制轻提示 — 一声非循环
  void _triggerSimmeringHint(Batch batch) {
    final req = ReminderRequest(
      batchNumber: batch.displayNumber,
      recipeName: batch.recipe.name,
      recipeId: batch.recipe.id,
      actionText: '可以揭锅了',
      level: ReminderLevel.simmeringHint,
    );
    ReminderManager.instance.start(req);
  }

  /// 启动前台服务（如果尚未启动）
  void _startForegroundIfNeeded() {
    ForegroundTaskHandler.instance.startForegroundService(
      title: '蒸馒头计时器',
      content: '${state.length + 1} 个批次运行中',
    );
  }

  /// 无活跃批次时停止前台服务
  void _stopForegroundIfIdle() {
    final active = state.where((b) => b.status == BatchStatus.active).toList();
    if (active.isEmpty) {
      ForegroundTaskHandler.instance.stopForegroundService();
    }
  }

  /// 更新前台服务通知
  void _updateForegroundNotification(Batch batch) {
    final step = batch.currentStep;
    if (step == null) return;
    final r = step.remainingSeconds;
    final timeStr = r != null
        ? '${(r ~/ 60).toString().padLeft(2, '0')}:${(r % 60).toString().padLeft(2, '0')}'
        : step.node.label;

    ForegroundTaskHandler.instance.updateNotification(
      content: '${batch.displayNumber}号 ${batch.recipe.name} ${step.node.label} $timeStr',
    );
  }

  /// 异步获取天气 — §4.5
  Future<void> _fetchWeather(String batchId) async {
    final data = await WeatherService.instance.fetchCurrentWeather();
    if (data == null) return;
    final idx = state.indexWhere((b) => b.id == batchId);
    if (idx == -1) return;
    state[idx].temperature = data.temperature;
    state[idx].humidity = data.humidity;
    state = List.of(state);
  }

  /// 批次完成时入库 — §4.2
  Future<void> _saveBatchRecord(Batch batch) async {
    final db = ref.read(databaseProvider);
    final fStep = batch.fermentationStep;
    final bStep = batch.boilingStep;
    final sStep = batch.steamingStep;
    final simStep = batch.simmeringStep;
    final uStep = batch.uncoverStep;

    final fermentActual = fStep?.actualDurationMinutes;

    // 焖制间隔（参考数据）
    final simmeringInterval = (sStep?.actualConfirm != null && uStep?.actualConfirm != null)
        ? uStep!.actualConfirm!.difference(sStep!.actualConfirm!).inMinutes
        : null;

    // 提醒→确认间隔（行为数据）
    final bs = bStep;
    int? boilingDelay;
    if (bs != null && bs.reminderSentAt != null && bs.actualConfirm != null) {
      boilingDelay = bs.actualConfirm!.difference(bs.reminderSentAt!).inSeconds;
    }
    final ss = sStep;
    int? steamingDelay;
    if (ss != null && ss.reminderSentAt != null && ss.actualConfirm != null) {
      steamingDelay = ss.actualConfirm!.difference(ss.reminderSentAt!).inSeconds;
    }

    await db.insertBatchRecord(BatchRecordsCompanion.insert(
      id: batch.id,
      displayNumber: batch.displayNumber,
      recipeId: batch.recipe.id,
      recipeName: batch.recipe.name,
      fermentationStart: Value(fStep?.actualStart),
      fermentationConfirm: Value(fStep?.actualConfirm),
      boilingStart: Value(bStep?.actualStart),
      boilingConfirm: Value(bStep?.actualConfirm),
      steamingStart: Value(sStep?.actualStart),
      steamingConfirm: Value(sStep?.actualConfirm),
      simmeringStart: Value(simStep?.actualStart),
      uncoverConfirm: Value(uStep?.actualConfirm),
      fermentationActualMinutes: Value(fermentActual),
      fermentationResult: Value(batch.fermentationResult?.name),
      lowConfidence: Value(fStep?.lowConfidence ?? false),
      simmeringIntervalMinutes: Value(simmeringInterval),
      temperature: Value(batch.temperature),
      humidity: Value(batch.humidity),
      createdAt: batch.startedAt ?? DateTime.now(),
      season: SeasonUtil.name(SeasonUtil.fromDateTime(batch.startedAt ?? DateTime.now())),
      adjustmentMinutes: Value(batch.adjustmentMinutes),
      status: batch.status == BatchStatus.completed ? 'completed' : 'cancelled',
      positionLabel: Value(batch.positionLabel),
      boilingReminderDelaySeconds: Value(boilingDelay),
      steamingReminderDelaySeconds: Value(steamingDelay),
      extensionsLog: Value(jsonEncode(fStep?.extensionsLog ?? [])),
    ));
  }

  /// 持久化单个批次 — §5.1 崩溃恢复
  Future<void> _persistBatch(Batch batch) async {
    await ActiveBatchStorage.instance.saveBatch(batch);
  }

  /// 持久化所有活跃批次
  Future<void> _persistAll() async {
    for (final b in state) {
      await _persistBatch(b);
    }
  }

  /// 从持久化恢复 — §5.1 App 重启后重建倒计时
  Future<void> restoreFromPersistence() async {
    final batches = await ActiveBatchStorage.instance.loadAllBatches();
    if (batches.isEmpty) return;

    // 恢复编号池 — 为每个批次重新占用编号
    final pool = ref.read(numberPoolProvider);
    for (final batch in batches) {
      if (batch.displayNumber > 0 && pool.isAvailable(batch.displayNumber)) {
        // 恢复原有编号
        pool.acquireSpecific(batch.displayNumber);
      } else {
        // 编号不可用时重新分配
        batch.displayNumber = pool.acquire() ?? 0;
      }
    }

    state = batches;
  }
}

/// 倒计时 tick — 每秒更新 UI
final tickProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (c) => c);
});

/// 崩溃恢复持久化 — §5.1
/// 每个批次的关键时间戳持久化到 SQLite
/// App 重启后按时间戳重建所有倒计时
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database.dart';
import '../models/batch.dart';
import '../models/recipe.dart';

/// 活跃批次持久化表 — 用于崩溃恢复
/// 与 BatchRecords（完成记录）分离
class ActiveBatchStorage {
  ActiveBatchStorage._();
  static final instance = ActiveBatchStorage._();

  final _db = AppDatabase();

  /// 保存/更新活跃批次状态 — 完整序列化所有字段
  Future<void> saveBatch(Batch batch) async {
    final json = jsonEncode(_batchToJson(batch));
    await _db.customStatement(
      'INSERT OR REPLACE INTO active_batch_kv (id, data) VALUES (?, ?)',
      [batch.id, json],
    );
    // 同步 SharedPreferences 标志 — BootReceiver 据此决定是否启动前台服务（R3 修复）
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_active', true);
  }

  /// 删除活跃批次（完成后）
  Future<void> removeBatch(String batchId) async {
    await _db.customStatement(
      'DELETE FROM active_batch_kv WHERE id = ?',
      [batchId],
    );
    // 如果已无活跃批次，清除标志
    final remaining = await loadAllBatches();
    if (remaining.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_active', false);
    }
  }

  /// 加载所有活跃批次（用于崩溃恢复）
  Future<List<Batch>> loadAllBatches() async {
    final rows = await _db.customSelect('SELECT id, data FROM active_batch_kv').get();
    final batches = <Batch>[];
    for (final row in rows) {
      try {
        final id = row.read<String>('id');
        final data = row.read<String>('data');
        final json = jsonDecode(data) as Map<String, dynamic>;
        batches.add(_batchFromJson(id, json));
      } catch (_) {
        // 跳过损坏的记录
      }
    }
    return batches;
  }

  // ── 完整序列化 — 不丢任何字段 ──

  Map<String, dynamic> _batchToJson(Batch batch) {
    return {
      'recipeId': batch.recipe.id,
      'displayNumber': batch.displayNumber,
      'currentStepIndex': batch.currentStepIndex,
      'status': batch.status.name,
      'startedAt': batch.startedAt?.toIso8601String(),
      'completedAt': batch.completedAt?.toIso8601String(),
      'temperature': batch.temperature,
      'humidity': batch.humidity,
      'weatherSource': batch.weatherSource,
      'adjustmentMinutes': batch.adjustmentMinutes,
      'positionLabel': batch.positionLabel,
      'fermentationResult': batch.fermentationResult?.name,
      'simmeringEnd': batch.simmeringEnd?.toIso8601String(),
      'parallelStepType': batch.parallelStep?.node.type.name,
      'parallelStepIsRunning': batch.parallelStep?.isParallelRunning,
      'weatherRetryAt': batch.weatherRetryAt?.toIso8601String(),
      'steps': batch.steps.map(_stepToJson).toList(),
    };
  }

  Batch _batchFromJson(String id, Map<String, dynamic> j) {
    final recipeId = j['recipeId'] as String? ?? 'white_bun';
    // findById 兼容已废弃的 flatbread ID
    final recipe = Recipe.findById(recipeId) ?? Recipe.presets.first;

    final stepsJson = j['steps'] as List<dynamic>;
    final steps = stepsJson.map((s) => _stepFromJson(s as Map<String, dynamic>, recipe)).toList();

    // 恢复并行步骤引用
    StepRuntime? parallelStep;
    final parallelType = j['parallelStepType'] as String?;
    if (parallelType != null) {
      final type = StepType.values.firstWhere(
        (t) => t.name == parallelType,
        orElse: () => StepType.boiling,
      );
      final idx = steps.indexWhere((s) => s.node.type == type);
      if (idx >= 0) {
        parallelStep = steps[idx];
        parallelStep.isParallelRunning = j['parallelStepIsRunning'] as bool? ?? false;
      }
    }

    return Batch.restore(
      id: id,
      displayNumber: j['displayNumber'] as int? ?? 0,
      recipe: recipe,
      currentStepIndex: j['currentStepIndex'] as int? ?? 0,
      status: BatchStatus.values.firstWhere(
        (s) => s.name == j['status'],
        orElse: () => BatchStatus.active,
      ),
      startedAt: _parseDate(j['startedAt']) ?? DateTime.now(),
      completedAt: _parseDate(j['completedAt']),
      temperature: (j['temperature'] as num?)?.toDouble(),
      humidity: j['humidity'] as int?,
      weatherSource: j['weatherSource'] as String?,
      adjustmentMinutes: j['adjustmentMinutes'] as int? ?? 0,
      positionLabel: j['positionLabel'] as String?,
      fermentationResult: _parseFermentationResult(j['fermentationResult']),
      simmeringEnd: _parseDate(j['simmeringEnd']),
      parallelStep: parallelStep,
      weatherRetryAt: _parseDate(j['weatherRetryAt']),
      steps: steps,
    );
  }

  Map<String, dynamic> _stepToJson(StepRuntime s) {
    return {
      'type': s.node.type.name,
      'label': s.node.label,
      'status': s.status.name,
      'plannedStart': s.plannedStart?.toIso8601String(),
      'plannedEnd': s.plannedEnd?.toIso8601String(),
      'actualStart': s.actualStart?.toIso8601String(),
      'actualConfirm': s.actualConfirm?.toIso8601String(),
      'extendedMinutes': s.extendedMinutes,
      'extensionsLog': s.extensionsLog,
      'reminderSentAt': s.reminderSentAt?.toIso8601String(),
      'lowConfidence': s.lowConfidence,
      'isParallelRunning': s.isParallelRunning,
    };
  }

  StepRuntime _stepFromJson(Map<String, dynamic> j, Recipe recipe) {
    final type = StepType.values.firstWhere(
      (t) => t.name == j['type'],
      orElse: () => StepType.fermentation,
    );
    // 从 Recipe 定义中找到对应的 StepNode（保持引用一致性）
    final node = recipe.steps.firstWhere(
      (s) => s.type == type,
      orElse: () => StepNode(type: type, label: j['label'] as String? ?? '', entryCondition: '', uiState: ''),
    );

    final s = StepRuntime(node: node);
    s.status = StepStatus.values.firstWhere(
      (st) => st.name == j['status'],
      orElse: () => StepStatus.pending,
    );
    s.plannedStart = _parseDate(j['plannedStart']);
    s.plannedEnd = _parseDate(j['plannedEnd']);
    s.actualStart = _parseDate(j['actualStart']);
    s.actualConfirm = _parseDate(j['actualConfirm']);
    s.extendedMinutes = j['extendedMinutes'] as int? ?? 0;
    s.extensionsLog.addAll((j['extensionsLog'] as List?)?.cast<int>() ?? []);
    s.reminderSentAt = _parseDate(j['reminderSentAt']);
    s.lowConfidence = j['lowConfidence'] as bool? ?? false;
    s.isParallelRunning = j['isParallelRunning'] as bool? ?? false;
    return s;
  }

  FermentationResult? _parseFermentationResult(dynamic v) {
    if (v == null) return null;
    return FermentationResult.values.firstWhere(
      (r) => r.name == v,
      orElse: () => FermentationResult.perfect,
    );
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v as String);
  }
}

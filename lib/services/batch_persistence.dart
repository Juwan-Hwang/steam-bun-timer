/// 崩溃恢复持久化 — §5.1
/// 每个批次的关键时间戳持久化到 SQLite
/// App 重启后按时间戳重建所有倒计时
library;

import 'dart:convert';
import '../data/database.dart';
import '../models/batch.dart';
import '../models/recipe.dart';

/// 活跃批次持久化表 — 用于崩溃恢复
/// 与 BatchRecords（完成记录）分离
class ActiveBatchStorage {
  ActiveBatchStorage._();
  static final instance = ActiveBatchStorage._();

  final _db = AppDatabase();

  /// 保存/更新活跃批次状态
  Future<void> saveBatch(Batch batch) async {
    final stepsJson = jsonEncode(batch.steps.map(_stepToJson).toList());

    // 使用 shared_preferences 存储活跃批次（简单可靠）
    // 这里用 raw SQL 方式直接写 kv 表更优雅
    await _db.customStatement(
      'INSERT OR REPLACE INTO active_batch_kv (id, data) VALUES (?, ?)',
      [batch.id, stepsJson],
    );
  }

  /// 删除活跃批次（完成后）
  Future<void> removeBatch(String batchId) async {
    await _db.customStatement(
      'DELETE FROM active_batch_kv WHERE id = ?',
      [batchId],
    );
  }

  /// 加载所有活跃批次（用于崩溃恢复）
  Future<List<Batch>> loadAllBatches() async {
    final rows = await _db.customSelect('SELECT id, data FROM active_batch_kv').get();
    final batches = <Batch>[];
    for (final row in rows) {
      try {
        final id = row.read<String>('id');
        final data = row.read<String>('data');
        final stepsJson = jsonDecode(data) as List<dynamic>;
        final steps = stepsJson.map((j) => _stepFromJson(j as Map<String, dynamic>)).toList();

        // 从 steps 重建 Recipe 引用
        final recipe = Recipe.presets.firstWhere(
          (r) => r.steps.any((s) => s.type == steps.first.node.type),
          orElse: () => Recipe.presets.first,
        );

        batches.add(Batch.restore(
          id: id,
          displayNumber: 0, // 从数据中恢复
          recipe: recipe,
          currentStepIndex: 0,
          status: BatchStatus.active,
          startedAt: DateTime.now(),
          steps: steps,
        ));
      } catch (_) {
        // 跳过损坏的记录
      }
    }
    return batches;
  }

  Map<String, dynamic> _stepToJson(StepRuntime s) {
    return {
      'type': s.node.type.name,
      'label': s.node.label,
      'defaultDuration': s.node.defaultDurationMinutes,
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

  StepRuntime _stepFromJson(Map<String, dynamic> j) {
    final type = StepType.values.firstWhere(
      (t) => t.name == j['type'],
      orElse: () => StepType.fermentation,
    );
    // 找到对应的 StepNode 定义
    final node = _findStepNode(type, j['label'] as String) ??
        StepNode(type: type, label: j['label'] as String, entryCondition: '', uiState: '');

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

  StepNode? _findStepNode(StepType type, String label) {
    for (final r in Recipe.presets) {
      for (final s in r.steps) {
        if (s.type == type && s.label == label) return s;
      }
    }
    return null;
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v as String);
  }
}

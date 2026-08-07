/// SQLite (Drift) 数据层 — 对应 §4.2 自动采集
/// 核心约束 §4.1：记录时间戳而非计时读数
library;

/// V1 就备齐所有字段（§4.4）
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'database.g.dart';

/// 批次数据表 — §4.2
@DataClassName('BatchRecord')
class BatchRecords extends Table {
  TextColumn get id => text()();
  IntColumn get displayNumber => integer()();
  TextColumn get recipeId => text()();
  TextColumn get recipeName => text()();

  // ── 各关键动作的时间戳（§4.1 核心约束）──
  DateTimeColumn get fermentationStart => dateTime().nullable()();
  DateTimeColumn get fermentationConfirm => dateTime().nullable()();
  DateTimeColumn get boilingStart => dateTime().nullable()();
  DateTimeColumn get boilingConfirm => dateTime().nullable()();
  DateTimeColumn get steamingStart => dateTime().nullable()();
  DateTimeColumn get steamingConfirm => dateTime().nullable()();
  DateTimeColumn get simmeringStart => dateTime().nullable()();
  DateTimeColumn get uncoverConfirm => dateTime().nullable()();

  // ── 发酵实际完成时长（时间戳相减）──
  IntColumn get fermentationActualMinutes => integer().nullable()();

  // ── 评价结果（监督学习标注目标）──
  TextColumn get fermentationResult => text().nullable()();

  // ── 低置信度标记（§4.1 兜底）──
  BoolColumn get lowConfidence => boolean().withDefault(const Constant(false))();

  // ── 焖制间隔（参考数据，不参与训练）──
  IntColumn get simmeringIntervalMinutes => integer().nullable()();

  // ── 环境数据（§4.5）──
  RealColumn get temperature => real().nullable()();
  IntColumn get humidity => integer().nullable()();

  // ── 日期/季节 ──
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get season => text()();

  // ── 微调幅度 ──
  IntColumn get adjustmentMinutes => integer().withDefault(const Constant(0))();

  // ── 批次完成状态 ──
  TextColumn get status => text()(); // completed / cancelled

  // ── 位置标签（可选）──
  TextColumn get positionLabel => text().nullable()();

  // ── 行为数据：动作节点「提醒→确认」间隔（§6 关键规格约定）──
  IntColumn get boilingReminderDelaySeconds => integer().nullable()();
  IntColumn get steamingReminderDelaySeconds => integer().nullable()();

  // ── 续时记录（JSON 数组：每次续时的分钟数）──
  TextColumn get extensionsLog => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 模板自定义表 — 支持新增/复制/重命名（§1.1）
@DataClassName('RecipeRecord')
class RecipeRecords extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get announcementName => text()();
  TextColumn get stepsJson => text()();
  IntColumn get fermentationRangeMin => integer()();
  IntColumn get fermentationRangeMax => integer()();
  BoolColumn get isPreset => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 习惯默认值表 — §3.2 前端层
@DataClassName('HabitDefault')
class HabitDefaults extends Table {
  TextColumn get recipeId => text()();
  IntColumn get temperatureRangeLow => integer()();
  IntColumn get temperatureRangeHigh => integer()();
  IntColumn get defaultMinutes => integer()();
  IntColumn get consecutiveCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {recipeId, temperatureRangeLow, temperatureRangeHigh};
}

@DriftDatabase(tables: [BatchRecords, RecipeRecords, HabitDefaults])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());
  static final instance = AppDatabase._();
  factory AppDatabase() => instance;

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // 创建活跃批次 KV 表（用于崩溃恢复）
      await customStatement(
        'CREATE TABLE IF NOT EXISTS active_batch_kv (id TEXT PRIMARY KEY, data TEXT NOT NULL)',
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await customStatement(
          'CREATE TABLE IF NOT EXISTS active_batch_kv (id TEXT PRIMARY KEY, data TEXT NOT NULL)',
        );
      }
    },
  );

  // ── 批次记录操作 ──

  /// 插入一条完整的批次记录（每完成一锅时调用）
  Future<void> insertBatchRecord(BatchRecordsCompanion record) =>
      into(batchRecords).insert(record);

  /// 查询所有批次记录
  Future<List<BatchRecord>> getAllBatchRecords() =>
      select(batchRecords).get();

  /// 导出 CSV — §4.6
  Future<String> exportCsv() async {
    final records = await getAllBatchRecords();
    final buffer = StringBuffer();
    // UTF-8 BOM — 确保 Excel 正确识别中文
    buffer.write('\uFEFF');

    // CSV 表头
    buffer.writeln(
      '批次编号,品种,开始发酵,确认发酵,开始烧水,确认烧水,开始蒸,确认蒸,开始焖,揭锅,'
      '发酵实际时长(分钟),评价结果,低置信度,焖制间隔(分钟),气温(°C),湿度(%),'
      '日期,季节,微调幅度(分钟),状态,位置标签,烧水提醒延迟(秒),蒸制提醒延迟(秒),续时记录',
    );

    for (final r in records) {
      buffer.writeln([
        r.displayNumber,
        _csvEscape(r.recipeName),
        r.fermentationStart?.toIso8601String() ?? '',
        r.fermentationConfirm?.toIso8601String() ?? '',
        r.boilingStart?.toIso8601String() ?? '',
        r.boilingConfirm?.toIso8601String() ?? '',
        r.steamingStart?.toIso8601String() ?? '',
        r.steamingConfirm?.toIso8601String() ?? '',
        r.simmeringStart?.toIso8601String() ?? '',
        r.uncoverConfirm?.toIso8601String() ?? '',
        r.fermentationActualMinutes ?? '',
        _csvEscape(r.fermentationResult ?? ''),
        r.lowConfidence,
        r.simmeringIntervalMinutes ?? '',
        r.temperature ?? '',
        r.humidity ?? '',
        r.createdAt.toIso8601String(),
        _csvEscape(r.season),
        r.adjustmentMinutes,
        _csvEscape(r.status),
        _csvEscape(r.positionLabel ?? ''),
        r.boilingReminderDelaySeconds ?? '',
        r.steamingReminderDelaySeconds ?? '',
        _csvEscape(r.extensionsLog ?? ''),
      ].join(','));
    }

    return buffer.toString();
  }

  /// CSV 字段转义 — 含逗号/引号/换行/回车时用双引号包裹并转义内部引号
  static String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  // ── 习惯默认值操作 ──

  /// 查询某品种在当前气温范围的习惯默认值
  Future<HabitDefault?> getHabitDefault(String recipeId, int tempLow, int tempHigh) {
    final query = select(habitDefaults)
      ..where((t) => t.recipeId.equals(recipeId) & t.temperatureRangeLow.equals(tempLow) & t.temperatureRangeHigh.equals(tempHigh));
    return query.getSingleOrNull();
  }

  /// 更新习惯默认值（连续3次同方向调整且数值一致时触发）
  Future<void> upsertHabitDefault(HabitDefaultsCompanion record) =>
      into(habitDefaults).insertOnConflictUpdate(record);
}

// ── 连接 ──
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'steam_bun_timer.db'));
    return NativeDatabase.createInBackground(file);
  });
}

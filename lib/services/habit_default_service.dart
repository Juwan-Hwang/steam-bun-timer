/// V2 习惯默认值服务 — §3.2 前端层
/// 气温 ±3°C 范围内、同方向调整连续 3 次且数值一致时触发
/// 只影响前端起跑线，不碰数据
library;

import '../data/database.dart';
import '../utils/season_util.dart';
import 'package:drift/drift.dart';

class HabitDefaultService {
  HabitDefaultService._();
  static final instance = HabitDefaultService._();

  final _db = AppDatabase();

  /// 记录一次调整行为
  /// recipeId: 品种 ID
  /// temperature: 当前气温
  /// adjustmentMinutes: 微调幅度（正=加长，负=缩短，0=未调）
  /// finalMinutes: 最终设定的发酵分钟数
  Future<void> recordAdjustment({
    required String recipeId,
    required double? temperature,
    required int adjustmentMinutes,
    required int finalMinutes,
  }) async {
    if (temperature == null || adjustmentMinutes == 0) return;

    final (tempLow, tempHigh) = SeasonUtil.tempBucket(temperature);

    // 查询现有记录
    final existing = await _db.getHabitDefault(recipeId, tempLow, tempHigh);

    if (existing == null) {
      // 首次记录
      await _db.upsertHabitDefault(HabitDefaultsCompanion.insert(
        recipeId: recipeId,
        temperatureRangeLow: tempLow,
        temperatureRangeHigh: tempHigh,
        defaultMinutes: finalMinutes,
        consecutiveCount: const Value(1),
        updatedAt: DateTime.now(),
      ));
      return;
    }

    // 检查是否同方向且数值一致
    final isSameDirection = _sameDirection(existing, adjustmentMinutes, finalMinutes);

    if (isSameDirection) {
      final newCount = existing.consecutiveCount + 1;
      if (newCount >= 3) {
        // 连续 3 次满足条件 → 更新习惯默认值
        await _db.upsertHabitDefault(HabitDefaultsCompanion(
          recipeId: Value(recipeId),
          temperatureRangeLow: Value(tempLow),
          temperatureRangeHigh: Value(tempHigh),
          defaultMinutes: Value(finalMinutes),
          consecutiveCount: Value(newCount),
          updatedAt: Value(DateTime.now()),
        ));
      } else {
        await _db.upsertHabitDefault(HabitDefaultsCompanion(
          recipeId: Value(recipeId),
          temperatureRangeLow: Value(tempLow),
          temperatureRangeHigh: Value(tempHigh),
          defaultMinutes: Value(existing.defaultMinutes),
          consecutiveCount: Value(newCount),
          updatedAt: Value(DateTime.now()),
        ));
      }
    } else {
      // 方向不一致或数值不同 → 重置计数
      await _db.upsertHabitDefault(HabitDefaultsCompanion(
        recipeId: Value(recipeId),
        temperatureRangeLow: Value(tempLow),
        temperatureRangeHigh: Value(tempHigh),
        defaultMinutes: Value(finalMinutes),
        consecutiveCount: const Value(1),
        updatedAt: Value(DateTime.now()),
      ));
    }
  }

  /// 查询习惯默认值
  /// 返回 null 表示无习惯值，回退到品种默认值
  Future<int?> getHabitDefaultMinutes({
    required String recipeId,
    required double? temperature,
  }) async {
    if (temperature == null) return null;

    final (tempLow, tempHigh) = SeasonUtil.tempBucket(temperature);
    final habit = await _db.getHabitDefault(recipeId, tempLow, tempHigh);

    // 只有连续 3 次以上才返回习惯值
    if (habit != null && habit.consecutiveCount >= 3) {
      return habit.defaultMinutes;
    }
    return null;
  }

  /// 检查是否同方向调整且数值一致
  bool _sameDirection(HabitDefault existing, int newAdjustment, int newFinalMinutes) {
    // 方向一致 = 之前也在加长（或缩短），这次也是
    // 数值一致 = 最终设定的分钟数相同
    return existing.defaultMinutes == newFinalMinutes;
  }
}

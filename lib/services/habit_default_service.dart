/// V2 习惯默认值服务 — §3.2 前端层
/// 气温 ±3°C 范围内、同方向调整连续 3 次且数值一致时触发
/// 只影响前端起跑线，不碰数据
library;

import '../data/database.dart';
import '../utils/season_util.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HabitDefaultService {
  HabitDefaultService._();
  static final instance = HabitDefaultService._();

  final _db = AppDatabase();

  /// P2-1: 生成习惯方向存储 key
  String _directionKey(String recipeId, int tempLow, int tempHigh) =>
      'habit_dir_${recipeId}_${tempLow}_$tempHigh';

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

    // P2-1: 读取上次调整方向
    final prefs = await SharedPreferences.getInstance();
    final dirKey = _directionKey(recipeId, tempLow, tempHigh);
    final lastDirection = prefs.getInt(dirKey) ?? 0; // 1=加长, -1=缩短
    final currentDirection = adjustmentMinutes > 0 ? 1 : -1;

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
      await prefs.setInt(dirKey, currentDirection);
      return;
    }

    // P2-1: 检查是否同方向且数值一致
    final isSameDirection = _sameDirection(
      lastDirection, currentDirection, existing.defaultMinutes, finalMinutes);

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
    // P2-1: 保存当前方向
    await prefs.setInt(dirKey, currentDirection);
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

  /// P2-1: 检查是否同方向调整且数值一致
  /// §3.2: 「同方向且数值一致连续 3 次」
  /// lastDirection / currentDirection: 1=加长, -1=缩短
  /// lastMinutes / newMinutes: 最终设定的发酵分钟数
  bool _sameDirection(
    int lastDirection, int currentDirection,
    int lastMinutes, int newMinutes,
  ) {
    // 方向必须一致（同为加长或同为缩短）
    if (lastDirection != currentDirection) return false;
    // 数值必须一致（最终分钟数相同）
    if (lastMinutes != newMinutes) return false;
    return true;
  }
}

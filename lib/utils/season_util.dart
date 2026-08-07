/// 季节计算工具 — §4.2 日期/季节字段
library;

enum Season { spring, summer, autumn, winter }

class SeasonUtil {
  SeasonUtil._();

  /// 根据日期判断季节（气象学标准：3-5月春，6-8月夏，9-11月秋，12-2月冬）
  static Season fromDateTime(DateTime dt) {
    final m = dt.month;
    if (m >= 3 && m <= 5) return Season.spring;
    if (m >= 6 && m <= 8) return Season.summer;
    if (m >= 9 && m <= 11) return Season.autumn;
    return Season.winter;
  }

  static String name(Season s) {
    switch (s) {
      case Season.spring: return '春';
      case Season.summer: return '夏';
      case Season.autumn: return '秋';
      case Season.winter: return '冬';
    }
  }

  /// 气温范围桶（每 3°C 一档，用于习惯默认值匹配）
  static (int, int) tempBucket(double temp) {
    final low = (temp ~/ 3) * 3;
    return (low, low + 3);
  }
}

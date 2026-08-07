/// 批次编号管理器 — §1.4 回收复用
/// 编号永远保持在最小空闲号，1-6 之间
class NumberPool {
  final int maxCount;

  /// 当前已占用的编号集合
  final Set<int> _occupied = {};

  NumberPool({this.maxCount = 6});

  /// 分配最小可用编号
  int? acquire() {
    for (int i = 1; i <= maxCount; i++) {
      if (!_occupied.contains(i)) {
        _occupied.add(i);
        return i;
      }
    }
    return null; // 无可用编号
  }

  /// 分配指定编号（用于崩溃恢复）
  bool acquireSpecific(int number) {
    if (number < 1 || number > maxCount) return false;
    if (_occupied.contains(number)) return false;
    _occupied.add(number);
    return true;
  }

  /// 释放编号（回收复用）
  void release(int number) {
    _occupied.remove(number);
  }

  /// 检查编号是否可用
  bool isAvailable(int number) => !_occupied.contains(number);

  /// 当前已占用的编号数量
  int get occupiedCount => _occupied.length;

  /// 是否已满
  bool get isFull => _occupied.length >= maxCount;
}

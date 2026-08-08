/// 位置标签历史存储 — 持久化到 SharedPreferences
/// 用户输入过的位置标签自动保存，下次可选择而非重复输入
library;

import 'package:shared_preferences/shared_preferences.dart';

class PositionLabelStore {
  PositionLabelStore._();
  static final instance = PositionLabelStore._();

  static const _key = 'position_labels';

  /// 加载所有已保存的位置标签（按最近使用排序）
  Future<List<String>> loadLabels() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// 保存一个位置标签（去重，移到末尾表示最近使用）
  Future<void> saveLabel(String label) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final labels = prefs.getStringList(_key) ?? [];
    labels.remove(trimmed);
    labels.add(trimmed);
    // 最多保留 20 个，防止无限增长
    if (labels.length > 20) {
      labels.removeRange(0, labels.length - 20);
    }
    await prefs.setStringList(_key, labels);
  }

  /// 删除一个位置标签
  Future<void> removeLabel(String label) async {
    final prefs = await SharedPreferences.getInstance();
    final labels = prefs.getStringList(_key) ?? [];
    labels.remove(label);
    await prefs.setStringList(_key, labels);
  }
}

/// 数据导出页面 — §4.6 一键导出 CSV
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_tokens.dart';
import '../providers/app_providers.dart';

class DataExportScreen extends ConsumerStatefulWidget {
  const DataExportScreen({super.key});

  @override
  ConsumerState<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends ConsumerState<DataExportScreen> {
  List<dynamic> _records = [];
  bool _loading = true;

  /// 上次导出的文件路径 — 显示在 UI 上方便用户查找
  String? _lastExportPath;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final db = ref.read(databaseProvider);
    final records = await db.getAllBatchRecords();
    setState(() {
      _records = records;
      _loading = false;
    });
  }

  /// 获取用户可见的导出目录 — 优先公共下载目录，兜底 App 外部存储
  Future<Directory> _getExportDir() async {
    // 1. 尝试公共下载目录 — 所有文件管理器可直接看到
    final downloads = Directory('/storage/emulated/0/Download');
    if (await _tryAccess(downloads)) return downloads;

    // 2. 兜底：App 专属外部存储 — 文件管理器在 Android/data/<pkg>/files/ 下可见
    final external = await getExternalStorageDirectory();
    return external ?? await getApplicationDocumentsDirectory();
  }

  /// 测试目录是否可写
  Future<bool> _tryAccess(Directory dir) async {
    try {
      if (!await dir.exists()) await dir.create(recursive: true);
      final probe = File('${dir.path}/.probe');
      await probe.writeAsString('');
      await probe.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _exportCsv() async {
    final db = ref.read(databaseProvider);
    final csv = await db.exportCsv();

    final dir = await _getExportDir();
    final fileName = 'steam_bun_data_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csv);

    setState(() => _lastExportPath = file.path);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已导出 ${_records.length} 条记录'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final z = ZephyrThemeExtension.of(context).s;

    return Scaffold(
      appBar: AppBar(
        title: Text('数据导出', style: TextStyle(fontSize: ZephyrFontSize.xl, fontWeight: FontWeight.w400, color: z.textPrimary)),
        leading: IconButton(icon: Icon(Icons.arrow_back, color: z.textPrimary), onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: z.isDark
                ? [const Color(0xF718181B), const Color(0xE6000000)]
                : [const Color(0xF2FFFFFF), const Color(0xE6F8FAFC)],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(ZephyrSpacing.s5),
                children: [
                  // 统计卡片
                  Container(
                    padding: const EdgeInsets.all(ZephyrSpacing.s5),
                    decoration: BoxDecoration(
                      color: z.accentPrimary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(ZephyrRadius.overlay),
                      border: Border.all(color: z.accentPrimary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.dataset, size: 32, color: z.accentPrimary),
                        const SizedBox(width: ZephyrSpacing.s4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('累计记录', style: TextStyle(fontSize: ZephyrFontSize.xs, color: z.textTertiary)),
                              Text('${_records.length} 条', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w200, color: z.textPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ZephyrSpacing.s6),
                  // 导出按钮
                  SizedBox(
                    width: double.infinity,
                    height: 72,
                    child: ElevatedButton.icon(
                      onPressed: _records.isEmpty ? null : _exportCsv,
                      icon: const Icon(Icons.download, size: 24),
                      label: Text(_records.isEmpty ? '暂无数据' : '导出 CSV', style: const TextStyle(fontSize: ZephyrFontSize.lg, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  // 上次导出路径
                  if (_lastExportPath != null) ...[
                    const SizedBox(height: ZephyrSpacing.s4),
                    Container(
                      padding: const EdgeInsets.all(ZephyrSpacing.s4),
                      decoration: BoxDecoration(
                        color: z.accentPrimary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(ZephyrRadius.md),
                        border: Border.all(color: z.accentPrimary.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.folder_open, size: 18, color: z.accentPrimary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('文件已保存到', style: TextStyle(fontSize: ZephyrFontSize.xs, color: z.textTertiary)),
                                const SizedBox(height: 2),
                                SelectableText(
                                  _lastExportPath!,
                                  style: TextStyle(fontSize: ZephyrFontSize.xs, color: z.accentPrimary, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: ZephyrSpacing.s6),
                  // 说明
                  Container(
                    padding: const EdgeInsets.all(ZephyrSpacing.s4),
                    decoration: BoxDecoration(
                      color: z.bgMuted,
                      borderRadius: BorderRadius.circular(ZephyrRadius.md),
                    ),
                    child: Text(
                      '所有数据存储在本地 SQLite，导出后可在电脑端用 Excel 或 Python 分析。\n'
                      'CSV 文件保存到手机「下载」目录，用文件管理器即可找到。\n'
                      '字段包括：批次编号、品种、各动作时间戳、发酵实际时长、评价结果、低置信度标记、气温等。',
                      style: TextStyle(fontSize: ZephyrFontSize.xs, color: z.textTertiary, height: 1.5),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

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

  Future<void> _exportCsv() async {
    final db = ref.read(databaseProvider);
    final csv = await db.exportCsv();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/steam_bun_data_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已导出 ${_records.length} 条记录')),
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
                  const SizedBox(height: ZephyrSpacing.s6),
                  // 说明
                  Container(
                    padding: const EdgeInsets.all(ZephyrSpacing.s4),
                    decoration: BoxDecoration(
                      color: z.bgMuted,
                      borderRadius: BorderRadius.circular(ZephyrRadius.md),
                    ),
                    child: Text(
                      '所有数据存储在本地 SQLite，导出后可在电脑端用 Excel 或 Python 分析。\n字段包括：批次编号、品种、各动作时间戳、发酵实际时长、评价结果、低置信度标记、气温等。',
                      style: TextStyle(fontSize: ZephyrFontSize.xs, color: z.textTertiary, height: 1.5),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 大号滑动条 — §3.1 大跨度滑动条（带区间分档）
/// 用整只手或手背快速拖动即可一次性调整很大跨度
/// 滑动条只在区间内线性映射，超出区间用 +/− 按钮或数字键盘
library;

import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class TimeSlider extends StatelessWidget {
  /// 当前值（分钟）
  final int value;

  /// 合理区间 (min, max)
  final (int, int) range;

  /// 值变化回调
  final ValueChanged<int> onChanged;

  /// 步进（1 或 5）
  final int step;

  const TimeSlider({
    super.key,
    required this.value,
    required this.range,
    required this.onChanged,
    this.step = 1,
  });

  @override
  Widget build(BuildContext context) {
    final z = ZephyrThemeExtension.of(context).s;
    final (min, max) = range;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ZephyrSpacing.s2),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$min', style: TextStyle(fontSize: 10, color: z.textMuted)),
              Text(
                '$value 分钟',
                style: TextStyle(fontSize: ZephyrFontSize.sm, fontWeight: FontWeight.w700, color: z.accentPrimary),
              ),
              Text('$max', style: TextStyle(fontSize: 10, color: z.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: z.accentPrimary,
              inactiveTrackColor: z.bgMuted,
              thumbColor: z.accentPrimary,
              overlayColor: z.accentGlow,
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: value.toDouble().clamp(min.toDouble(), max.toDouble()),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: ((max - min) ~/ step).clamp(1, 200),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }
}

/// 数字键盘 — §3.1 点击数字唤出数字键盘
/// 防误触：需点时间数字后长按 1 秒才激活
library;

import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class NumberPad extends StatefulWidget {
  /// 初始值
  final int initialValue;

  /// 确认回调
  final ValueChanged<int> onConfirm;

  const NumberPad({
    super.key,
    this.initialValue = 30,
    required this.onConfirm,
  });

  @override
  State<NumberPad> createState() => _NumberPadState();
}

class _NumberPadState extends State<NumberPad> {
  late String _input;

  @override
  void initState() {
    super.initState();
    _input = widget.initialValue.toString();
  }

  void _append(String s) {
    setState(() {
      if (_input == '0') {
        _input = s;
      } else if (_input.length < 3) {
        _input += s;
      }
    });
  }

  void _backspace() {
    setState(() {
      if (_input.length > 1) {
        _input = _input.substring(0, _input.length - 1);
      } else {
        _input = '0';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final zephyr = ZephyrThemeExtension.of(context).s;
    final value = int.tryParse(_input) ?? 0;

    return Container(
      padding: const EdgeInsets.all(ZephyrSpacing.s5),
      decoration: BoxDecoration(
        color: zephyr.bgElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(ZephyrRadius.overlay)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 当前输入显示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _input,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w200,
                  color: zephyr.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '分钟',
                style: TextStyle(fontSize: 14, color: zephyr.textMuted),
              ),
            ],
          ),
          const SizedBox(height: ZephyrSpacing.s5),
          // 数字键盘 3x4
          for (final row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  for (final key in row) ...[
                    Expanded(child: _buildKey(zephyr, key, () => _append(key))),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          // 底排：清空、0、确认
          Row(
            children: [
              Expanded(child: _buildKey(zephyr, '⌫', _backspace, isAction: true)),
              const SizedBox(width: 8),
              Expanded(child: _buildKey(zephyr, '0', () => _append('0'))),
              const SizedBox(width: 8),
              Expanded(
                child: _buildKey(
                  zephyr,
                  '确认',
                  () => widget.onConfirm(value),
                  isConfirm: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(
    ZephyrSemantic zephyr,
    String label,
    VoidCallback onTap, {
    bool isAction = false,
    bool isConfirm = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: isConfirm
              ? zephyr.accentPrimary
              : isAction
                  ? zephyr.bgMuted
                  : zephyr.bgSecondary,
          borderRadius: BorderRadius.circular(ZephyrRadius.md),
          border: Border.all(
            color: isConfirm
                ? zephyr.accentPrimary
                : zephyr.borderSubtle,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isConfirm ? ZephyrFontSize.lg : 28,
              fontWeight: FontWeight.w700,
              color: isConfirm ? Colors.white : zephyr.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 长按 1 秒激活的数字触发器
/// §3.1 防误触：需点时间数字后长按 1 秒才激活数字键盘
class LongPressNumberTrigger extends StatefulWidget {
  final Widget child;
  final VoidCallback onLongPressActivated;

  const LongPressNumberTrigger({
    super.key,
    required this.child,
    required this.onLongPressActivated,
  });

  @override
  State<LongPressNumberTrigger> createState() => _LongPressNumberTriggerState();
}

class _LongPressNumberTriggerState extends State<LongPressNumberTrigger> {
  OverlayEntry? _progressOverlay;

  @override
  void dispose() {
    _hideProgress();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _showProgress(context),
      onLongPressEnd: (_) => _hideProgress(),
      onLongPressCancel: _hideProgress,
      child: widget.child,
    );
  }

  void _showProgress(BuildContext context) {
    _progressOverlay = OverlayEntry(
      builder: (ctx) {
        final zephyr = ZephyrThemeExtension.of(ctx).s;
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(ZephyrSpacing.s5),
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: zephyr.bgMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(seconds: 1),
                    onEnd: () {
                      _hideProgress();
                      widget.onLongPressActivated();
                    },
                    builder: (ctx, v, _) => Container(
                      decoration: BoxDecoration(
                        color: zephyr.accentPrimary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_progressOverlay!);
  }

  void _hideProgress() {
    _progressOverlay?.remove();
    _progressOverlay = null;
  }
}

/// 工序卡片 — §1.4 主屏看板
/// 颜色编码：蓝(发酵中) / 黄(即将到点) / 红(需要操作) / 绿(完成)
/// V1+V2 完整功能：并行双行倒计时/滑动条/数字键盘/长按取消/防烧屏微移/再来一锅/位置标签
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_tokens.dart';
import '../models/batch.dart';
import '../models/recipe.dart';
import '../services/screen_controller.dart';
import 'time_slider.dart';
import 'number_pad.dart';

enum CardUrgency { calm, approaching, urgent, done }

class BatchCard extends StatefulWidget {
  final Batch batch;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final void Function(FermentationResult)? onEvaluate;
  final void Function(int)? onAdjustDuration;
  final void Function(int)? onSetFermentationMinutes;
  final VoidCallback? onRestart; // 饼子「再来一锅」
  final void Function(String)? onSetPositionLabel;

  const BatchCard({
    super.key,
    required this.batch,
    this.onConfirm,
    this.onCancel,
    this.onEvaluate,
    this.onAdjustDuration,
    this.onSetFermentationMinutes,
    this.onRestart,
    this.onSetPositionLabel,
  });

  @override
  State<BatchCard> createState() => _BatchCardState();
}

class _BatchCardState extends State<BatchCard>
    with TickerProviderStateMixin {
  late AnimationController _blinkCtrl;
  late AnimationController _burnInCtrl;
  bool _sliderExpanded = false;

  @override
  void initState() {
    super.initState();
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // 防烧屏微移 — 每分钟一个周期
    _burnInCtrl = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _blinkCtrl.dispose();
    _burnInCtrl.dispose();
    super.dispose();
  }

  CardUrgency get _urgency {
    final b = widget.batch;
    if (b.isCompleted) return CardUrgency.done;
    final s = b.currentStep;
    if (s == null) return CardUrgency.calm;
    switch (s.status) {
      case StepStatus.awaitingConfirmation:
      case StepStatus.evaluating:
        return CardUrgency.urgent;
      case StepStatus.running:
        final r = s.remainingSeconds;
        if (r == null) return CardUrgency.calm;
        if (r <= 0) return CardUrgency.urgent;
        if (r <= 180) return CardUrgency.approaching;
        return CardUrgency.calm;
      default:
        return CardUrgency.calm;
    }
  }

  @override
  Widget build(BuildContext context) {
    final z = ZephyrThemeExtension.of(context).s;
    final u = _urgency;

    if (u == CardUrgency.urgent) {
      _blinkCtrl.repeat(reverse: true);
    } else {
      _blinkCtrl.stop();
    }

    final (bg, border, accent) = _colors(u, z);

    return AnimatedBuilder(
      animation: _blinkCtrl,
      builder: (ctx, child) {
        final alpha = u == CardUrgency.urgent ? 0.4 + 0.6 * _blinkCtrl.value : 1.0;
        return Opacity(opacity: alpha, child: child);
      },
      child: _body(z, u, bg, border, accent),
    );
  }

  Widget _body(ZephyrSemantic z, CardUrgency u, Color bg, Color border, Color accent) {
    final b = widget.batch;
    final s = b.currentStep;

    return GestureDetector(
      onLongPress: _showCancelDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(ZephyrSpacing.s5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(ZephyrRadius.overlay),
          border: Border.all(color: border, width: 1.5),
          boxShadow: u == CardUrgency.urgent ? z.shadowMd : z.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(z, accent),
            const SizedBox(height: ZephyrSpacing.s4),
            _content(z, accent, s),
            if (_shouldShowAction(s)) ...[
              const SizedBox(height: ZephyrSpacing.s3),
              _actionButton(z, accent, s!),
            ],
            if (b.isCompleted && b.recipe.id == 'flatbread') ...[
              const SizedBox(height: ZephyrSpacing.s3),
              _restartButton(z, accent),
            ],
          ],
        ),
      ),
    );
  }

  // ── 头部：编号 + 品种 + 位置标签 ──
  Widget _header(ZephyrSemantic z, Color accent) {
    final b = widget.batch;
    final s = b.currentStep;
    return Row(
      children: [
        _numberBadge(z, accent),
        const SizedBox(width: ZephyrSpacing.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b.recipe.name, style: TextStyle(fontSize: ZephyrFontSize.lg, fontWeight: FontWeight.w600, color: z.textPrimary)),
              if (s != null)
                Text(s.node.label, style: TextStyle(fontSize: ZephyrFontSize.xs, fontWeight: FontWeight.w500, color: z.textSecondary)),
            ],
          ),
        ),
        if (b.positionLabel != null)
          GestureDetector(
            onTap: () => _showPositionPicker(z),
            child: _tag(z, b.positionLabel!, z.bgMuted, z.textTertiary),
          )
        else
          GestureDetector(
            onTap: () => _showPositionPicker(z),
            child: Icon(Icons.add_location_alt_outlined, size: 20, color: z.textTertiary),
          ),
      ],
    );
  }

  Widget _numberBadge(ZephyrSemantic z, Color accent) {
    return AnimatedBuilder(
      animation: _burnInCtrl,
      builder: (ctx, child) {
        // 防烧屏微移
        final dx = (ScreenController.instance.burnInProtection ? 2 * _burnInCtrl.value : 0.0);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(ZephyrRadius.md),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Center(
          child: Text(
            '${widget.batch.displayNumber}号',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: accent),
          ),
        ),
      ),
    );
  }

  Widget _tag(ZephyrSemantic z, String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(ZephyrRadius.full)),
      child: Text(text, style: TextStyle(fontSize: 10, color: fg)),
    );
  }

  // ── 内容区域 ──
  Widget _content(ZephyrSemantic z, Color accent, StepRuntime? s) {
    if (s == null) return const SizedBox(height: ZephyrSpacing.s6);

    // 并行期间显示双行倒计时 — §1.3
    final parallel = widget.batch.parallelStep;
    if (parallel != null && parallel.isParallelRunning && s.node.type == StepType.fermentation) {
      return _parallelDisplay(z, accent, s, parallel);
    }

    switch (s.status) {
      case StepStatus.running:
        return _countdown(z, accent, s);
      case StepStatus.awaitingConfirmation:
        return _awaiting(z, accent, s);
      case StepStatus.evaluating:
        return _eval(z, accent);
      case StepStatus.extending:
        return _extend(z, accent, s);
      case StepStatus.simmering:
        return _simmering(z);
      default:
        return const SizedBox(height: ZephyrSpacing.s6);
    }
  }

  /// 并行双行倒计时 — §1.3
  Widget _parallelDisplay(ZephyrSemantic z, Color accent, StepRuntime fermentation, StepRuntime boiling) {
    return Column(
      children: [
        // 上行：发酵
        _dualLine(z, '发酵', fermentation, z.info),
        const SizedBox(height: 4),
        // 下行：烧水
        _dualLine(z, '烧水', boiling, z.warning),
      ],
    );
  }

  Widget _dualLine(ZephyrSemantic z, String label, StepRuntime s, Color color) {
    final r = s.remainingSeconds ?? 0;
    final mins = (r / 60).floor();
    final secs = r % 60;
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(label, style: TextStyle(fontSize: 12, color: z.textTertiary)),
        ),
        Expanded(
          child: Text(
            '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w200,
              color: r <= 0 ? z.danger : z.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -1,
            ),
          ),
        ),
        Text('剩余', style: TextStyle(fontSize: 10, color: z.textMuted)),
      ],
    );
  }

  /// 倒计时 + 微调 + 滑动条
  Widget _countdown(ZephyrSemantic z, Color accent, StepRuntime s) {
    final r = s.remainingSeconds ?? 0;
    final mins = (r / 60).floor();
    final secs = r % 60;
    final isFermentation = s.node.type == StepType.fermentation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 倒计时数字 — 长按 1 秒唤出数字键盘
        LongPressNumberTrigger(
          onLongPressActivated: () => _showNumberPad(z),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedBuilder(
                animation: _burnInCtrl,
                builder: (ctx, child) {
                  final dx = ScreenController.instance.burnInProtection ? 3 * _burnInCtrl.value : 0.0;
                  final dy = ScreenController.instance.burnInProtection ? 1 * _burnInCtrl.value : 0.0;
                  return Transform.translate(offset: Offset(dx, dy), child: child);
                },
                child: Text(
                  '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w200,
                    color: z.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    letterSpacing: -2,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text('剩余', style: TextStyle(fontSize: 12, color: z.textMuted, fontWeight: FontWeight.w600)),
              const Spacer(),
              _adjustBtn(z, '−', -1),
              const SizedBox(width: 4),
              _adjustBtn(z, '+', 1),
            ],
          ),
        ),
        // 发酵阶段显示滑动条
        if (isFermentation && _sliderExpanded) ...[
          const SizedBox(height: ZephyrSpacing.s3),
          TimeSlider(
            value: r ~/ 60,
            range: widget.batch.recipe.fermentationRange,
            onChanged: (v) => widget.onSetFermentationMinutes?.call(v),
          ),
        ],
        // 展开滑动条按钮
        if (isFermentation)
          TextButton(
            onPressed: () => setState(() => _sliderExpanded = !_sliderExpanded),
            child: Text(
              _sliderExpanded ? '收起滑动条' : '滑动条调整',
              style: TextStyle(fontSize: 12, color: z.accentPrimary, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _awaiting(ZephyrSemantic z, Color accent, StepRuntime s) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ZephyrSpacing.s4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ZephyrRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app, size: 24, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              s.node.uiState,
              style: TextStyle(fontSize: ZephyrFontSize.base, fontWeight: FontWeight.w600, color: accent),
            ),
          ),
        ],
      ),
    );
  }

  /// 评价三选一 — §4.3
  Widget _eval(ZephyrSemantic z, Color accent) {
    return Row(
      children: [
        Expanded(child: _evalBtn(z, '正好', z.success, () => widget.onEvaluate?.call(FermentationResult.perfect))),
        const SizedBox(width: 8),
        Expanded(child: _evalBtn(z, '还不够', z.warning, () => widget.onEvaluate?.call(FermentationResult.notEnough))),
        const SizedBox(width: 8),
        Expanded(child: _evalBtn(z, '发过了', z.danger, () => widget.onEvaluate?.call(FermentationResult.overFermented))),
      ],
    );
  }

  Widget _evalBtn(ZephyrSemantic z, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(ZephyrRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Center(
          child: Text(label, style: TextStyle(fontSize: ZephyrFontSize.lg, fontWeight: FontWeight.w700, color: color)),
        ),
      ),
    );
  }

  /// 续时面板 — §4.3 +1/+5/数字键盘
  Widget _extend(ZephyrSemantic z, Color accent, StepRuntime s) {
    return Column(
      children: [
        Row(
          children: [
            Text('续时中', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: z.textPrimary)),
            const Spacer(),
            _adjustBtn(z, '+1', 1),
            const SizedBox(width: 4),
            _adjustBtn(z, '+5', 5),
          ],
        ),
        if (s.extendedMinutes > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '已续时 ${s.extendedMinutes} 分钟',
              style: TextStyle(fontSize: 12, color: z.textMuted),
            ),
          ),
      ],
    );
  }

  /// 焖制中 — 静默无倒计时
  Widget _simmering(ZephyrSemantic z) {
    return Row(
      children: [
        Icon(Icons.soup_kitchen, size: 32, color: z.textTertiary),
        const SizedBox(width: 8),
        Text('焖制中…', style: TextStyle(fontSize: ZephyrFontSize.xl, fontWeight: FontWeight.w300, color: z.textTertiary)),
      ],
    );
  }

  // ── 操作按钮 ≥72dp ──
  bool _shouldShowAction(StepRuntime? s) {
    if (s == null) return false;
    if (!s.node.requiresConfirmation) return false;
    return s.status == StepStatus.awaitingConfirmation ||
           s.status == StepStatus.running ||
           s.status == StepStatus.simmering;
  }

  Widget _actionButton(ZephyrSemantic z, Color accent, StepRuntime s) {
    final label = _actionLabel(s);
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: ElevatedButton(
        onPressed: widget.onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ZephyrRadius.overlay)),
        ),
        child: Text(label, style: const TextStyle(fontSize: ZephyrFontSize.lg, fontWeight: FontWeight.w700)),
      ),
    );
  }

  String _actionLabel(StepRuntime s) {
    switch (s.node.type) {
      case StepType.fermentation:
        return s.status == StepStatus.evaluating ? '评价' : '确认';
      case StepType.boiling:
        return '已开始烧水';
      case StepType.steaming:
        return '已开始蒸';
      case StepType.simmering:
        return '已关火';
      case StepType.uncover:
        return '揭锅';
      case StepType.flipping:
        return '已翻面';
      case StepType.plateOut:
        return '已出锅';
    }
  }

  /// 饼子「再来一锅」— §6
  Widget _restartButton(ZephyrSemantic z, Color accent) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: ElevatedButton(
        onPressed: widget.onRestart,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent.withValues(alpha: 0.15),
          foregroundColor: accent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ZephyrRadius.overlay)),
          side: BorderSide(color: accent.withValues(alpha: 0.3)),
        ),
        child: const Text('再来一锅', style: TextStyle(fontSize: ZephyrFontSize.lg, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── 微调按钮 ──
  Widget _adjustBtn(ZephyrSemantic z, String label, int delta) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onAdjustDuration?.call(delta);
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: z.bgMuted,
          borderRadius: BorderRadius.circular(ZephyrRadius.control),
          border: Border.all(color: z.borderSubtle),
        ),
        child: Center(
          child: Text(label, style: TextStyle(fontSize: ZephyrFontSize.lg, fontWeight: FontWeight.w700, color: z.textPrimary)),
        ),
      ),
    );
  }

  // ── 长按取消对话框 — §防误触 ──
  void _showCancelDialog() {
    final z = ZephyrThemeExtension.of(context).s;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: z.bgElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ZephyrRadius.overlay)),
        title: Text('取消这一锅？', style: TextStyle(color: z.textPrimary, fontWeight: FontWeight.w600)),
        content: Text('此批次将标记为「未完成」，不参与数据分析。', style: TextStyle(color: z.textSecondary, fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('不了')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onCancel?.call();
            },
            child: Text('确认取消', style: TextStyle(color: z.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── 数字键盘 ──
  void _showNumberPad(ZephyrSemantic z) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NumberPad(
        initialValue: widget.batch.currentStep?.remainingSeconds != null
            ? (widget.batch.currentStep!.remainingSeconds! ~/ 60)
            : 30,
        onConfirm: (minutes) {
          Navigator.pop(ctx);
          widget.onSetFermentationMinutes?.call(minutes);
        },
      ),
    );
  }

  // ── 位置标签选择 ──
  void _showPositionPicker(ZephyrSemantic z) {
    final labels = ['左盆', '右盆', '灶台边', '案板边'];
    showModalBottomSheet(
      context: context,
      backgroundColor: z.bgElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(ZephyrRadius.overlay))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(ZephyrSpacing.s5),
              child: Text('选择位置标签', style: TextStyle(fontSize: ZephyrFontSize.lg, fontWeight: FontWeight.w600, color: z.textPrimary)),
            ),
            for (final label in labels)
              ListTile(
                title: Text(label, style: TextStyle(color: z.textPrimary)),
                onTap: () {
                  widget.onSetPositionLabel?.call(label);
                  Navigator.pop(ctx);
                },
              ),
            ListTile(
              title: Text('清除标签', style: TextStyle(color: z.danger)),
              onTap: () {
                widget.onSetPositionLabel?.call('');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: ZephyrSpacing.s3),
          ],
        ),
      ),
    );
  }

  // ── 颜色 ──
  (Color, Color, Color) _colors(CardUrgency u, ZephyrSemantic z) {
    switch (u) {
      case CardUrgency.calm:
        return (z.isDark ? const Color(0x0DFFFFFF) : const Color(0x66FFFFFF), z.borderSubtle, z.info);
      case CardUrgency.approaching:
        return (z.warning.withValues(alpha: 0.05), z.warning.withValues(alpha: 0.3), z.warning);
      case CardUrgency.urgent:
        return (z.danger.withValues(alpha: 0.08), z.danger.withValues(alpha: 0.4), z.danger);
      case CardUrgency.done:
        return (z.success.withValues(alpha: 0.05), z.success.withValues(alpha: 0.25), z.success);
    }
  }
}

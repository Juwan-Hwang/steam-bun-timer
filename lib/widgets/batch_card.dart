/// 工序卡片 — §1.4 主屏看板
/// 颜色编码：蓝(发酵中) / 黄(即将到点) / 红(需要操作) / 金(完成·成就色)
/// V1+V2 完整功能：并行双行倒计时/滑动条/数字键盘/长按取消/防烧屏微移/再来一锅/位置标签
/// V3: 最终工序（揭锅/出锅）金色收官按钮 + 通关庆祝（动效+音效+震动）
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_tokens.dart';
import '../models/batch.dart';
import '../models/recipe.dart';
import '../services/screen_controller.dart';
import '../services/position_label_store.dart';
import '../services/finish_feedback.dart';
import 'completion_celebration.dart';
import 'time_slider.dart';
import 'number_pad.dart';

enum CardUrgency { calm, approaching, urgent, done }

class BatchCard extends StatefulWidget {
  final Batch batch;
  final VoidCallback? onConfirm;
  final VoidCallback? onConfirmParallel; // P0-3: 并行烧水步骤确认
  final VoidCallback? onCancel;
  final void Function(FermentationResult)? onEvaluate;
  final void Function(int)? onAdjustDuration;
  final void Function(int)? onExtendFermentation;
  final void Function(int)? onSetFermentationMinutes;
  final VoidCallback? onRestart; // 饼子「再来一锅」
  final VoidCallback? onDismiss;  // 完成后从看板移除
  final void Function(String)? onSetPositionLabel;
  final void Function(int)? onAdjustParallelDuration; // 并行烧水微调

  const BatchCard({
    super.key,
    required this.batch,
    this.onConfirm,
    this.onConfirmParallel,
    this.onCancel,
    this.onEvaluate,
    this.onAdjustDuration,
    this.onExtendFermentation,
    this.onSetFermentationMinutes,
    this.onRestart,
    this.onDismiss,
    this.onSetPositionLabel,
    this.onAdjustParallelDuration,
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
    // 防烧屏微移 — 每分钟一个周期（仅在开启时运行，避免 60fps 空转）
    _burnInCtrl = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 1),
    );
    if (ScreenController.instance.burnInProtection) {
      _burnInCtrl.repeat();
    }
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
      case StepStatus.done:
        // 🟢8 修复：done 与 awaitingConfirmation 同级 urgent
        // _sortByUrgency 已将 done 置顶（urgency=100），卡片视觉需保持一致
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
  void didUpdateWidget(covariant BatchCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // urgency 变化时调整闪烁动画 — 不在 build() 中操作 Controller
    final u = _urgency;
    if (u == CardUrgency.urgent) {
      if (!_blinkCtrl.isAnimating) _blinkCtrl.repeat(reverse: true);
    } else {
      if (_blinkCtrl.isAnimating) _blinkCtrl.stop();
    }
    // 防烧屏开关变化时启停微移动画 — 避免关闭后仍 60fps 空转
    if (ScreenController.instance.burnInProtection) {
      if (!_burnInCtrl.isAnimating) _burnInCtrl.repeat();
    } else {
      if (_burnInCtrl.isAnimating) _burnInCtrl.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final z = ZephyrThemeExtension.of(context).s;
    final u = _urgency;

    // didUpdateWidget 已处理动画启停；首次 build 也需检查
    if (u == CardUrgency.urgent && !_blinkCtrl.isAnimating) {
      _blinkCtrl.repeat(reverse: true);
    } else if (u != CardUrgency.urgent && _blinkCtrl.isAnimating) {
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
            b.isCompleted ? _completedContent(z) : _content(z, accent, s),
            if (_shouldShowAction(s)) ...[
              const SizedBox(height: ZephyrSpacing.s3),
              _actionButton(z, accent, s!),
            ],
            // P0-3: 并行烧水步骤需要确认时显示按钮
            if (_shouldShowParallelAction()) ...[
              const SizedBox(height: ZephyrSpacing.s3),
              _parallelActionButton(z),
            ],
            if (b.isCompleted && b.recipe.isFlatbread) ...[
              const SizedBox(height: ZephyrSpacing.s3),
              _restartButton(z, accent),
            ],
            if (b.isCompleted) ...[
              const SizedBox(height: ZephyrSpacing.s3),
              _dismissButton(z),
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
                // 状态标签字号放大 — 方便看到当前状态
                Text(s.node.label, style: TextStyle(fontSize: ZephyrFontSize.sm, fontWeight: FontWeight.w600, color: z.textSecondary)),
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
    // 仅在发酵 running 时显示并行倒计时；evaluating 时显示评价按钮，不遮盖
    final parallel = widget.batch.parallelStep;
    if (parallel != null && parallel.isParallelRunning &&
        s.node.type == StepType.fermentation && s.status == StepStatus.running) {
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
  /// 双行均带 ±微调按钮：发酵行调发酵时间，烧水行调烧水时间
  Widget _parallelDisplay(ZephyrSemantic z, Color accent, StepRuntime fermentation, StepRuntime boiling) {
    return Column(
      children: [
        // 上行：发酵
        _dualLine(z, '发酵', fermentation, z.info, showAdjust: true),
        const SizedBox(height: 4),
        // 下行：烧水
        _dualLine(z, '烧水', boiling, z.warning, showAdjust: true, parallel: true),
      ],
    );
  }

  Widget _dualLine(ZephyrSemantic z, String label, StepRuntime s, Color color, {bool showAdjust = false, bool parallel = false}) {
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
        if (showAdjust) ...[
          _adjustBtn(z, '−', -60, parallel: parallel),
          const SizedBox(width: 4),
          _adjustBtn(z, '+', 60, parallel: parallel),
        ] else
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('剩余', style: TextStyle(fontSize: 12, color: z.textMuted, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              // 调节按钮：顶部对齐
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 第一排：分钟调节
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _adjustBtn(z, '−', -60),
                        const SizedBox(width: 4),
                        _adjustBtn(z, '+', 60),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 第二排：30秒调节
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _adjustBtn(z, '−30s', -30),
                        const SizedBox(width: 4),
                        _adjustBtn(z, '+30s', 30),
                      ],
                    ),
                  ],
                ),
              ),
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
    // 用户友好文案 — 不显示内部设计规格 uiState
    final friendlyText = _awaitingText(s);
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
              friendlyText,
              style: TextStyle(fontSize: ZephyrFontSize.lg, fontWeight: FontWeight.w600, color: accent),
            ),
          ),
        ],
      ),
    );
  }

  /// awaitingConfirmation 状态的用户友好文案
  String _awaitingText(StepRuntime s) {
    switch (s.node.type) {
      case StepType.boiling:
        return '等待开始烧水';
      case StepType.steaming:
        return '等待上锅蒸制';
      case StepType.uncover:
        return '可以揭锅了';
      case StepType.flipping:
        return '等待翻面';
      case StepType.plateOut:
        return '等待出锅';
      default:
        return '等待确认';
    }
  }

  /// 评价三选一 — §4.3
  /// 评价阶段若并行烧水仍在运行，下方显示烧水倒计时 + 微调按钮
  Widget _eval(ZephyrSemantic z, Color accent) {
    final parallel = widget.batch.parallelStep;
    final showBoiling = parallel != null && parallel.status == StepStatus.running;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 提示文案 — 让用户知道发酵已好、需要评价
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '发酵好了，请评价',
            style: TextStyle(fontSize: ZephyrFontSize.lg, fontWeight: FontWeight.w600, color: accent),
          ),
        ),
        Row(
          children: [
            Expanded(child: _evalBtn(z, '正好', z.success, () => widget.onEvaluate?.call(FermentationResult.perfect))),
            const SizedBox(width: 8),
            Expanded(child: _evalBtn(z, '还不够', z.warning, () => widget.onEvaluate?.call(FermentationResult.notEnough))),
            const SizedBox(width: 8),
            Expanded(child: _evalBtn(z, '发过了', z.danger, () => widget.onEvaluate?.call(FermentationResult.overFermented))),
          ],
        ),
        // 评价阶段仍显示并行烧水倒计时 + 微调按钮
        if (showBoiling) ...[
          const SizedBox(height: ZephyrSpacing.s3),
          _boilingMiniCountdown(z),
        ],
      ],
    );
  }

  /// 评价阶段的紧凑烧水倒计时 — 带微调按钮
  Widget _boilingMiniCountdown(ZephyrSemantic z) {
    final parallel = widget.batch.parallelStep!;
    final r = parallel.remainingSeconds ?? 0;
    final mins = (r / 60).floor();
    final secs = r % 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: z.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ZephyrRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.water_drop, size: 18, color: z.warning),
          const SizedBox(width: 8),
          Text('烧水', style: TextStyle(fontSize: 13, color: z.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: r <= 0 ? z.danger : z.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
                letterSpacing: -1,
              ),
            ),
          ),
          _adjustBtn(z, '−', -60, parallel: true),
          const SizedBox(width: 4),
          _adjustBtn(z, '+', 60, parallel: true),
        ],
      ),
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
            _extendBtn(z, '+1', 1),
            const SizedBox(width: 4),
            _extendBtn(z, '+5', 5),
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

  /// 续时按钮 — 调用 onExtendFermentation 而非 onAdjustDuration
  Widget _extendBtn(ZephyrSemantic z, String label, int minutes) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onExtendFermentation?.call(minutes);
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: z.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(ZephyrRadius.control),
          border: Border.all(color: z.warning.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(label, style: TextStyle(fontSize: ZephyrFontSize.lg, fontWeight: FontWeight.w700, color: z.warning)),
        ),
      ),
    );
  }

  /// 焖制中 — 静默无倒计时
  Widget _simmering(ZephyrSemantic z) {
    return Row(
      children: [
        Icon(Icons.soup_kitchen, size: 32, color: z.textTertiary),
        const SizedBox(width: 8),
        Text('焖制中…', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: z.textTertiary)),
      ],
    );
  }

  /// 完成态内容 — 「已盖章的工单」而非绿色大按钮：
  /// 倾斜的金色圆章(✓) + 完成文案 + 实际用时
  Widget _completedContent(ZephyrSemantic z) {
    final b = widget.batch;
    final gold = _gold(z);
    String? durationText;
    if (b.startedAt != null && b.completedAt != null) {
      final mins = b.completedAt!.difference(b.startedAt!).inMinutes;
      durationText = mins >= 60
          ? '用时 ${mins ~/ 60} 小时 ${mins % 60} 分钟'
          : '用时 $mins 分钟';
    }
    return Row(
      children: [
        // 印章 — 双层圆环 + 轻微倾斜，像盖在工单上的戳
        Transform.rotate(
          angle: -0.12,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withValues(alpha: 0.10),
              border: Border.all(color: gold, width: 2.5),
            ),
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gold.withValues(alpha: 0.5), width: 1),
              ),
              child: Center(
                child: Icon(Icons.check_rounded, color: gold, size: 30),
              ),
            ),
          ),
        ),
        const SizedBox(width: ZephyrSpacing.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '这锅完成啦！',
                style: TextStyle(fontSize: ZephyrFontSize.xl, fontWeight: FontWeight.w800, color: gold),
              ),
              if (durationText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(durationText, style: TextStyle(fontSize: ZephyrFontSize.sm, color: z.textSecondary)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 操作按钮 ≥72dp ──
  bool _shouldShowAction(StepRuntime? s) {
    if (s == null) return false;
    // R4: 当前步骤就是并行步骤时，不显示主按钮 — 只显示并行按钮
    final parallel = widget.batch.parallelStep;
    if (parallel != null && parallel.node.type == s.node.type) return false;
    // 仅在需要用户操作时显示按钮：
    //   awaitingConfirmation → 首次确认（开始倒计时）
    //   done → 完成确认（推进下一步）
    // running / simmering / evaluating / extending → 不显示
    return s.status == StepStatus.awaitingConfirmation ||
           s.status == StepStatus.done;
  }

  /// P0-3: 并行烧水步骤是否需要显示确认按钮
  bool _shouldShowParallelAction() {
    final parallel = widget.batch.parallelStep;
    if (parallel == null) return false;
    return parallel.status == StepStatus.awaitingConfirmation ||
           parallel.status == StepStatus.done;
  }

  /// P0-3: 并行烧水确认按钮
  /// 烧水比发酵快时：点击「我开始蒸了」直接开始蒸制倒计时，无需等待发酵完成
  Widget _parallelActionButton(ZephyrSemantic z) {
    final parallel = widget.batch.parallelStep!;
    final isBoilingDone = parallel.status == StepStatus.done;
    final label = isBoilingDone ? '我开始蒸了' : '我开始烧水了';
    final color = isBoilingDone ? z.danger : z.warning;
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: ElevatedButton(
        onPressed: widget.onConfirmParallel,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ZephyrRadius.overlay)),
        ),
        child: Text(label, style: const TextStyle(fontSize: ZephyrFontSize.lg, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _actionButton(ZephyrSemantic z, Color accent, StepRuntime s) {
    final label = _actionLabel(s);
    // 最终工序（揭锅/出锅）→ 金色收官按钮，按下触发通关庆祝
    final isFinal = widget.batch.currentStepIndex == widget.batch.steps.length - 1;
    if (isFinal) {
      return _FinalActionButton(label: label, onTap: () => _handleFinalTap(s));
    }
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

  /// 最终工序确认 — 游戏化「完美通关」三段反馈：
  ///   1. 立即 heavyImpact 触感（手感）
  ///   2. 鼓点震动 + 出锅音效（FinishFeedback）
  ///   3. 全屏印章庆祝动效（CompletionCelebration）
  /// 动画完毕后自动收起卡片（调用 onDismiss）
  void _handleFinalTap(StepRuntime s) {
    HapticFeedback.heavyImpact();
    // 通用倒计时 — 简单完成提示，不触发揭锅/出锅庆祝动画
    if (widget.batch.recipe.id == 'generic_timer') {
      widget.onConfirm?.call();
      widget.onDismiss?.call();
      return;
    }
    FinishFeedback.celebrate();
    CompletionCelebration.show(
      context,
      title: s.node.type == StepType.plateOut ? '出锅啦！' : '揭锅啦！',
      subtitle: widget.batch.recipe.isFlatbread ? '金黄酥脆 · 趁热吃' : '白白胖胖 · 热气腾腾',
      onDone: () {
        // 动画完毕 + 状态已推进 → 自动收起卡片
        widget.onDismiss?.call();
      },
    );
    widget.onConfirm?.call();
  }

  String _actionLabel(StepRuntime s) {
    // 通用倒计时 — 按钮文案适配
    if (widget.batch.recipe.id == 'generic_timer') {
      return '完成';
    }
    switch (s.node.type) {
      case StepType.fermentation:
        return s.status == StepStatus.evaluating ? '评价' : '确认';
      case StepType.boiling:
        return '我开始烧水了';
      case StepType.steaming:
        // awaitingConfirmation → 首次确认「已开始蒸」
        // done → 倒计时结束「已关火」
        return s.status == StepStatus.done ? '我关火了' : '我开始蒸了';
      case StepType.simmering:
        return '揭锅';
      case StepType.uncover:
        return '揭锅';
      case StepType.flipping:
        return '我翻面了';
      case StepType.plateOut:
        return '我出锅了';
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

  /// 完成后从看板移除
  Widget _dismissButton(ZephyrSemantic z) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: widget.onDismiss,
        style: OutlinedButton.styleFrom(
          foregroundColor: z.textTertiary,
          side: BorderSide(color: z.borderSubtle),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ZephyrRadius.overlay)),
        ),
        child: Text('收起', style: TextStyle(fontSize: ZephyrFontSize.base, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ── 微调按钮 ──
  /// parallel=true 时调用 onAdjustParallelDuration（调烧水），否则调 onAdjustDuration（调当前步骤）
  Widget _adjustBtn(ZephyrSemantic z, String label, int delta, {bool parallel = false}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (parallel) {
          widget.onAdjustParallelDuration?.call(delta);
        } else {
          widget.onAdjustDuration?.call(delta);
        }
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
          child: Text(label, style: TextStyle(fontSize: ZephyrFontSize.sm, fontWeight: FontWeight.w700, color: z.textPrimary)),
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
        content: Text('此批次将标记为「未完成」。', style: TextStyle(color: z.textSecondary, fontSize: 14)),
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

  // ── 位置标签 — 用户自定义输入 + 历史选择 ──
  void _showPositionPicker(ZephyrSemantic z) async {
    // 预加载历史标签
    final savedLabels = await PositionLabelStore.instance.loadLabels();
    final controller = TextEditingController(text: widget.batch.positionLabel ?? '');

    if (!mounted) {
      controller.dispose();
      return;
    }

    try {
      await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: z.bgElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(ZephyrRadius.overlay))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: ZephyrSpacing.s5, right: ZephyrSpacing.s5, top: ZephyrSpacing.s5,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + ZephyrSpacing.s5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('位置标签', style: TextStyle(fontSize: ZephyrFontSize.lg, fontWeight: FontWeight.w600, color: z.textPrimary)),
              const SizedBox(height: 4),
              Text('选择历史标签或输入新标签', style: TextStyle(fontSize: ZephyrFontSize.xs, color: z.textTertiary)),
              // 历史标签快选
              if (savedLabels.isNotEmpty) ...[
                const SizedBox(height: ZephyrSpacing.s3),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: savedLabels.map((label) {
                    final isSelected = label == widget.batch.positionLabel;
                    return GestureDetector(
                      onTap: () {
                        widget.onSetPositionLabel?.call(label);
                        Navigator.pop(ctx);
                      },
                      onLongPress: () {
                        // 长按删除历史标签
                        PositionLabelStore.instance.removeLabel(label);
                        Navigator.pop(ctx);
                        _showPositionPicker(z); // 刷新列表
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? z.accentPrimary.withValues(alpha: 0.15) : z.bgMuted,
                          borderRadius: BorderRadius.circular(ZephyrRadius.full),
                          border: Border.all(
                            color: isSelected ? z.accentPrimary.withValues(alpha: 0.3) : z.borderSubtle,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? z.accentPrimary : z.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 4),
                Text('长按可删除历史标签', style: TextStyle(fontSize: 10, color: z.textMuted)),
              ],
              const SizedBox(height: ZephyrSpacing.s3),
              TextField(
                controller: controller,
                autofocus: savedLabels.isEmpty,
                decoration: InputDecoration(
                  hintText: '输入新位置标签…',
                  hintStyle: TextStyle(color: z.textTertiary, fontSize: 14),
                  filled: true,
                  fillColor: z.bgMuted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ZephyrRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(color: z.textPrimary, fontSize: 16),
              ),
              const SizedBox(height: ZephyrSpacing.s3),
              Row(
                children: [
                  if (widget.batch.positionLabel != null)
                    TextButton(
                      onPressed: () {
                        widget.onSetPositionLabel?.call('');
                        Navigator.pop(ctx);
                      },
                      child: Text('清除', style: TextStyle(color: z.danger)),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    // 🟢7: 空文本点「确定」也生效 — 传入 trim 后的文本（空=清除标签）
                    onPressed: () {
                      widget.onSetPositionLabel?.call(controller.text.trim());
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: z.accentPrimary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('确定'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    } finally {
      // 🟢7: bottom sheet 关闭后释放 controller，异常路径也不泄漏
      controller.dispose();
    }
  }
  /// 收官金 — 完成态与最终按钮的成就色（替代原 success 绿，避免「大绿按钮」观感）
  Color _gold(ZephyrSemantic z) =>
      z.isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);

  (Color, Color, Color) _colors(CardUrgency u, ZephyrSemantic z) {
    switch (u) {
      case CardUrgency.calm:
        return (z.isDark ? const Color(0x0DFFFFFF) : const Color(0x66FFFFFF), z.borderSubtle, z.info);
      case CardUrgency.approaching:
        return (z.warning.withValues(alpha: 0.05), z.warning.withValues(alpha: 0.3), z.warning);
      case CardUrgency.urgent:
        return (z.danger.withValues(alpha: 0.08), z.danger.withValues(alpha: 0.4), z.danger);
      case CardUrgency.done:
        // 金色成就态 — 极低透明度的底色与描边，区别于任何可操作按钮
        final gold = _gold(z);
        return (gold.withValues(alpha: 0.04), gold.withValues(alpha: 0.25), gold);
    }
  }
}

/// 最终工序「收官」按钮 — 游戏化设计：
/// 待机时金色渐变 + 流光周期性扫过（吸引点击，像终点线前的宝箱），
/// 按下时压缩 0.93、松手 elastic 回弹（手感 juice）
class _FinalActionButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;

  const _FinalActionButton({required this.label, this.onTap});

  @override
  State<_FinalActionButton> createState() => _FinalActionButtonState();
}

class _FinalActionButtonState extends State<_FinalActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;
  Timer? _shimmerTimer;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    // 流光每 2.4 秒扫过一次，间隔 5.6 秒间歇 → 降低 70% 无意义帧重建
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _shimmer.forward(from: 0.0);
    _shimmerTimer = Timer.periodic(const Duration(milliseconds: 8000), (_) {
      if (mounted) _shimmer.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _shimmerTimer?.cancel();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: _pressed
            ? const Duration(milliseconds: 110)
            : const Duration(milliseconds: 600),
        curve: _pressed ? Curves.easeOut : Curves.elasticOut,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ZephyrRadius.overlay),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFBBF24), Color(0xFFF59E0B), Color(0xFFD97706)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ZephyrRadius.overlay),
            child: LayoutBuilder(
              builder: (ctx, cons) {
                return Stack(
                  children: [
                    // 流光 — 斜切白色高光从左向右扫过
                    AnimatedBuilder(
                      animation: _shimmer,
                      builder: (_, child) {
                        final t = _shimmer.value;
                        final x = -80 + (cons.maxWidth + 160) * t;
                        return Positioned(
                          left: x,
                          top: -20,
                          bottom: -20,
                          width: 64,
                          child: Transform.rotate(
                            angle: 0.35,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0),
                                    Colors.white.withValues(alpha: 0.38),
                                    Colors.white.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // 文案
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 20, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            widget.label,
                            style: const TextStyle(
                              fontSize: ZephyrFontSize.lg,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

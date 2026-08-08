/// 出锅庆祝覆盖层 — 游戏化「完美通关」时刻
/// 编排: 金色闪光(0~35%) → 冲击波圆环(0~45%) → 印章 elastic 砸落(6%~75%)
///       + 蒸汽金粒子向上飘散(8%~93%) → 整体淡出(85%~100%)
/// 总时长 1.9 秒，不拦截触摸，播完自动移除
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

class CompletionCelebration {
  CompletionCelebration._();

  /// 在屏幕上方播放一次出锅庆祝
  static void show(BuildContext context, {required String title, String? subtitle}) {
    // 系统开启「减弱动态效果」时跳过演出 — 音效与震动仍由 FinishFeedback 提供
    if (MediaQuery.of(context).disableAnimations) return;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CelebrationOverlay(
        title: title,
        subtitle: subtitle,
        onDone: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _CelebrationOverlay extends StatefulWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onDone;

  const _CelebrationOverlay({
    required this.title,
    this.subtitle,
    required this.onDone,
  });

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  static const _gold = Color(0xFFF59E0B);
  static const _goldDeep = Color(0xFFD97706);
  static const _goldLight = Color(0xFFFFE9B8);

  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onDone();
      })
      ..forward();

    // 固定种子的粒子群 — 每次播放形态一致，避免纯随机带来的廉价感
    _particles = List.generate(20, (i) {
      final r = math.Random(i * 97 + 13);
      return _Particle(
        angle: r.nextDouble() * 2 * math.pi,
        distance: 110 + r.nextDouble() * 160,
        size: 3 + r.nextDouble() * 5,
        delay: r.nextDouble() * 0.25,
        wobble: 8 + r.nextDouble() * 14,
        phase: r.nextDouble() * 2 * math.pi,
        light: r.nextBool(),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// 闪光包络: 快速升起 → 缓慢回落（0~35%）
  double get _flash {
    final t = _ctrl.value;
    if (t > 0.35) return 0;
    final p = t / 0.35;
    return p < 0.3 ? p / 0.3 : 1 - (p - 0.3) / 0.7;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, _) {
        final t = _ctrl.value;
        final ringT = (t / 0.45).clamp(0.0, 1.0);
        final stampIn = ((t - 0.06) / 0.12).clamp(0.0, 1.0);
        final stampScaleT =
            const Interval(0.06, 0.75, curve: Curves.elasticOut).transform(t);
        final stampScale = 2.4 - 1.4 * stampScaleT;
        final fade = t < 0.85 ? 1.0 : 1 - (t - 0.85) / 0.15;

        return IgnorePointer(
          child: Opacity(
            opacity: fade,
            child: Stack(
              children: [
                // 金色闪光 — 径向渐变相衬「热气扑面」
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.22 * _flash,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [_goldLight, Colors.transparent],
                          radius: 0.9,
                        ),
                      ),
                    ),
                  ),
                ),
                // 冲击波圆环
                if (ringT < 1)
                  Center(
                    child: Transform.scale(
                      scale: 0.25 + 2.6 * Curves.easeOut.transform(ringT),
                      child: Opacity(
                        opacity: 1 - ringT,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _gold, width: 6),
                          ),
                        ),
                      ),
                    ),
                  ),
                // 蒸汽金粒子
                Positioned.fill(
                  child: CustomPaint(painter: _ParticlePainter(_particles, t)),
                ),
                // 印章砸落
                Center(
                  child: Opacity(
                    opacity: stampIn,
                    child: Transform.scale(
                      scale: stampScale,
                      child: Transform.rotate(
                        angle: -0.10,
                        child: _stamp(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 通关印章 — 白底金边，微微倾斜，像盖在工单上的戳
  Widget _stamp() {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _goldDeep, width: 4),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.55),
              blurRadius: 40,
              spreadRadius: 6,
            ),
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: _goldDeep,
                letterSpacing: 2,
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                widget.subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _gold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final double delay;
  final double wobble; // 蒸汽横向卷曲幅度
  final double phase;  // 卷曲相位
  final bool light;

  const _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
    required this.wobble,
    required this.phase,
    required this.light,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;

  _ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (final p in particles) {
      final local = ((t - 0.08 - p.delay) / 0.85).clamp(0.0, 1.0);
      if (local <= 0 || local >= 1) continue;
      final eased = Curves.easeOut.transform(local);
      // 蒸汽卷曲 — 上升过程中正弦摆动，像热气打着旋儿散开
      final curl = math.sin(local * math.pi * 2.2 + p.phase) * p.wobble * local;
      final offset = center +
          Offset(math.cos(p.angle), math.sin(p.angle)) * p.distance * eased +
          Offset(curl, -60 * eased); // 蒸汽向上飘
      final paint = Paint()
        ..color = (p.light ? const Color(0xFFFFE9B8) : const Color(0xFFF59E0B))
            .withValues(alpha: 1 - local);
      canvas.drawCircle(offset, p.size * (1 - 0.4 * local), paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

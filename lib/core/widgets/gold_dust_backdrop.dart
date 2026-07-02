// lib/core/widgets/gold_dust_backdrop.dart
// 金尘粒子背景, 移植自 web-prototype 的 Canvas 星空效果.
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../mystic_theme.dart';

class GoldDustBackdrop extends StatefulWidget {
  final Widget child;
  const GoldDustBackdrop({super.key, required this.child});

  @override
  State<GoldDustBackdrop> createState() => _GoldDustBackdropState();
}

class _GoldDustBackdropState extends State<GoldDustBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rand = math.Random(7);
  List<_Dust> _dust = const [];
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  void _ensureDust(Size size) {
    if (size == _lastSize && _dust.isNotEmpty) return;
    _lastSize = size;
    final count = ((size.width * size.height) / 9000).clamp(20, 260).floor();
    _dust = List.generate(count, (_) => _Dust(
          x: _rand.nextDouble(),
          y: _rand.nextDouble(),
          r: _rand.nextDouble() * 1.1 + .2,
          phase: _rand.nextDouble() * 2 * math.pi,
          speed: .5 + _rand.nextDouble() * 1.5,
        ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.1,
                colors: [MysticColors.gold.withOpacity(.14), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: LayoutBuilder(builder: (context, constraints) {
            final size = constraints.biggest;
            _ensureDust(size);
            return AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => CustomPaint(
                painter: _DustPainter(dust: _dust, time: _ctrl.value * 2 * math.pi),
              ),
            );
          }),
        ),
        widget.child,
      ],
    );
  }
}

class _Dust {
  final double x, y, r, phase, speed;
  _Dust({required this.x, required this.y, required this.r, required this.phase, required this.speed});
}

class _DustPainter extends CustomPainter {
  final List<_Dust> dust;
  final double time;
  _DustPainter({required this.dust, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final d in dust) {
      final a = .18 + .35 * (math.sin(d.phase + time * d.speed * .4).abs());
      canvas.drawCircle(
        Offset(d.x * size.width, d.y * size.height),
        d.r,
        Paint()..color = MysticColors.goldBright.withOpacity(a),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter oldDelegate) => oldDelegate.time != time;
}

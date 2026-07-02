// lib/core/widgets/mystic_compass.dart
// 旋转罗盘: 外圈八卦 + 中圈十二地支 + 中心太极, 移植自 web-prototype 的 SVG 版本.
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../mystic_theme.dart';

/// 八卦二进制表 (乾兌離震巽坎艮坤), 1=阳爻(实线) 0=阴爻(断线).
const List<List<int>> _kTrigrams = [
  [1, 1, 1], // 乾
  [0, 1, 1], // 兌
  [1, 0, 1], // 離
  [0, 0, 1], // 震
  [1, 1, 0], // 巽
  [0, 1, 0], // 坎
  [1, 0, 0], // 艮
  [0, 0, 0], // 坤
];

const String _kEarthlyBranches = '子丑寅卯辰巳午未申酉戌亥';

/// 三层旋转罗盘: 外圈八卦缓慢正转, 中圈地支反转, 中心太极静止.
class MysticCompass extends StatefulWidget {
  final double size;
  const MysticCompass({super.key, this.size = 280});

  @override
  State<MysticCompass> createState() => _MysticCompassState();
}

class _MysticCompassState extends State<MysticCompass>
    with TickerProviderStateMixin {
  late final AnimationController _slow;
  late final AnimationController _rev;

  @override
  void initState() {
    super.initState();
    _slow = AnimationController(vsync: this, duration: const Duration(seconds: 120))..repeat();
    _rev = AnimationController(vsync: this, duration: const Duration(seconds: 90))..repeat();
  }

  @override
  void dispose() {
    _slow.dispose();
    _rev.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _slow,
            builder: (_, __) => Transform.rotate(
              angle: _slow.value * 2 * math.pi,
              child: CustomPaint(
                size: Size.square(widget.size),
                painter: _BaguaRingPainter(),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _rev,
            builder: (_, __) => Transform.rotate(
              angle: -_rev.value * 2 * math.pi,
              child: CustomPaint(
                size: Size.square(widget.size),
                painter: _ZodiacRingPainter(),
              ),
            ),
          ),
          CustomPaint(
            size: Size.square(widget.size * 0.28),
            painter: _TaijiPainter(),
          ),
        ],
      ),
    );
  }
}

class _BaguaRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;
    final ringPaint = Paint()
      ..color = MysticColors.gold.withOpacity(.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, r - 2, ringPaint);
    canvas.drawCircle(
      center,
      r - 12,
      Paint()
        ..color = MysticColors.gold.withOpacity(.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .6,
    );

    final barPaint = Paint()..color = MysticColors.gold.withOpacity(.8);
    for (var i = 0; i < 8; i++) {
      final angle = (i * 45 - 90) * math.pi / 180;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle + math.pi / 2);
      // 三爻从外向内排列, 起点在半径 (r-34) 处
      for (var line = 0; line < 3; line++) {
        final y = -(r - 34) + line * 8;
        final solid = _kTrigrams[i][line] == 1;
        if (solid) {
          canvas.drawRect(Rect.fromLTWH(-16, y, 32, 4), barPaint);
        } else {
          canvas.drawRect(Rect.fromLTWH(-16, y, 13, 4), barPaint);
          canvas.drawRect(Rect.fromLTWH(3, y, 13, 4), barPaint);
        }
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ZodiacRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width * .35;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = MysticColors.gold.withOpacity(.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8,
    );
    canvas.drawCircle(
      center,
      r - 6,
      Paint()
        ..color = MysticColors.gold.withOpacity(.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .5,
    );

    for (var i = 0; i < _kEarthlyBranches.length; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * r;
      final tp = TextPainter(
        text: TextSpan(
          text: _kEarthlyBranches[i],
          style: MysticFonts.body(13, color: MysticColors.goldDim),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TaijiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = MysticColors.gold.withOpacity(.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8,
    );

    // 右半圆盘 (直径线在正中, 弧线向右鼓出)
    final rightHalf = Path()
      ..moveTo(center.dx, center.dy - r)
      ..arcToPoint(Offset(center.dx, center.dy + r),
          radius: Radius.circular(r), clockwise: true)
      ..close();

    final topBump = Path()
      ..addOval(Rect.fromCircle(center: Offset(center.dx, center.dy - r / 2), radius: r / 2));
    final bottomBump = Path()
      ..addOval(Rect.fromCircle(center: Offset(center.dx, center.dy + r / 2), radius: r / 2));

    // 金色 S 形: 右半圆 + 顶部凸起 - 底部凹陷
    var goldPath = Path.combine(PathOperation.union, rightHalf, topBump);
    goldPath = Path.combine(PathOperation.difference, goldPath, bottomBump);

    final fullCircle = Path()..addOval(Rect.fromCircle(center: center, radius: r));
    final paperPath = Path.combine(PathOperation.difference, fullCircle, goldPath);

    canvas.drawPath(goldPath, Paint()..color = MysticColors.gold.withOpacity(.85));
    canvas.drawPath(paperPath, Paint()..color = MysticColors.ink3);

    canvas.drawCircle(Offset(center.dx, center.dy - r / 2), r * .15, Paint()..color = MysticColors.ink3);
    canvas.drawCircle(Offset(center.dx, center.dy + r / 2), r * .15,
        Paint()..color = MysticColors.gold.withOpacity(.85));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

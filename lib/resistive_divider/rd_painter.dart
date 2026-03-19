import 'package:flutter/material.dart';
import 'dart:math';
import 'rd_globalvar.dart';

class ResistiveDividerPainterFrame extends StatefulWidget {
  final ResistiveDividerController controller;

  const ResistiveDividerPainterFrame({super.key, required this.controller});

  @override
  State<ResistiveDividerPainterFrame> createState() =>
      _ResistiveDividerPainterFrameState();
}

class _ResistiveDividerPainterFrameState
    extends State<ResistiveDividerPainterFrame>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return CustomPaint(
          painter: ResistiveDividerPainter(
            controller: widget.controller,
            animationValue: _animController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ResistiveDividerPainter extends CustomPainter {
  final ResistiveDividerController controller;
  final double animationValue;

  ResistiveDividerPainter({
    required this.controller,
    required this.animationValue,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    const double armLen = 120.0;

    final p1 = center + const Offset(-armLen, 0);
    final p2 = center + Offset(armLen * cos(-pi / 6), armLen * sin(-pi / 6));
    final p3 = center + Offset(armLen * cos(pi / 6), armLen * sin(pi / 6));

    paint.color = Colors.black;
    _drawResistorArm(canvas, paint, center, p1);
    _drawResistorArm(canvas, paint, center, p2);
    _drawResistorArm(canvas, paint, center, p3);

    _drawText(canvas, "Port 1", p1 - const Offset(20, 0), TextAlign.right);
    _drawText(canvas, "Port 2", p2 + const Offset(20, -10), TextAlign.left);
    _drawText(canvas, "Port 3", p3 + const Offset(20, 10), TextAlign.left);

    _drawSmallText(canvas, "R", (center + p1) / 2 + const Offset(0, -15));
    _drawSmallText(canvas, "R", (center + p2) / 2 + const Offset(5, -15));
    _drawSmallText(canvas, "R", (center + p3) / 2 + const Offset(5, 15));

    final input = controller.inputPort;
    const inColor = Colors.red;
    const outColor = Colors.blue;

    if (input == 1) {
      _drawWave(canvas, p1, center, inColor, 1.0);
      _drawWave(canvas, center, p1, outColor, controller.s11);
      _drawWave(canvas, center, p2, outColor, controller.s21);
      _drawWave(canvas, center, p3, outColor, controller.s31);
    } else if (input == 2) {
      _drawWave(canvas, p2, center, inColor, 1.0);
      _drawWave(canvas, center, p2, outColor, controller.s11);
      _drawWave(canvas, center, p1, outColor, controller.s21);
      _drawWave(canvas, center, p3, outColor, controller.s31);
    } else {
      _drawWave(canvas, p3, center, inColor, 1.0);
      _drawWave(canvas, center, p3, outColor, controller.s11);
      _drawWave(canvas, center, p1, outColor, controller.s21);
      _drawWave(canvas, center, p2, outColor, controller.s31);
    }

    _drawPortDot(canvas, p1, input == 1 ? Colors.red : Colors.blue);
    _drawPortDot(canvas, p2, input == 2 ? Colors.red : Colors.blue);
    _drawPortDot(canvas, p3, input == 3 ? Colors.red : Colors.blue);

    canvas.drawCircle(center, 4.0, Paint()..style = PaintingStyle.fill);
  }

  void _drawResistorArm(Canvas canvas, Paint paint, Offset pStart, Offset pEnd) {
    final totalLen = (pEnd - pStart).distance;
    final angle = (pEnd - pStart).direction;

    canvas.save();
    canvas.translate(pStart.dx, pStart.dy);
    canvas.rotate(angle);

    final path = Path();
    path.moveTo(0, 0);

    final rStart = totalLen / 3;
    final rEnd = totalLen * 2 / 3;
    final rWidth = rEnd - rStart;

    path.lineTo(rStart, 0);

    const zigs = 4;
    final zigW = rWidth / zigs;
    for (int i = 0; i < zigs; i++) {
      final x = rStart + i * zigW;
      path.lineTo(x + zigW / 4, -5);
      path.lineTo(x + zigW * 3 / 4, 5);
      path.lineTo(x + zigW, 0);
    }
    path.lineTo(totalLen, 0);

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawWave(
    Canvas canvas,
    Offset pStart,
    Offset pEnd,
    Color color,
    double signedAmp,
  ) {
    final amp = signedAmp.abs();
    if (amp < 0.05) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final dist = (pEnd - pStart).distance;
    final angle = (pEnd - pStart).direction;
    final cosA = cos(angle);
    final sinA = sin(angle);

    final k = controller.frequency * 0.15;
    final phaseOffset = signedAmp < 0 ? pi : 0.0;

    for (double t = 0; t <= dist; t += 2) {
      final phase = t * k - animationValue * 2 * pi + phaseOffset;
      final currentY = 6.0 * amp * sin(phase);

      final finalX = pStart.dx + t * cosA - currentY * sinA;
      final finalY = pStart.dy + t * sinA + currentY * cosA;

      if (t == 0) {
        path.moveTo(finalX, finalY);
      } else {
        path.lineTo(finalX, finalY);
      }
    }

    canvas.drawPath(path, paint);
    _drawArrow(canvas, pStart, pEnd, color);
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Color color) {
    final angle = atan2(end.dy - start.dy, end.dx - start.dx);
    final arrowX = start.dx + (end.dx - start.dx) * 0.25;
    final arrowY = start.dy + (end.dy - start.dy) * 0.25;

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const arrowSize = 6.0;

    final path = Path();
    path.moveTo(
      arrowX + arrowSize * cos(angle),
      arrowY + arrowSize * sin(angle),
    );
    path.lineTo(
      arrowX + arrowSize * cos(angle + 2.5),
      arrowY + arrowSize * sin(angle + 2.5),
    );
    path.lineTo(
      arrowX + arrowSize * cos(angle - 2.5),
      arrowY + arrowSize * sin(angle - 2.5),
    );
    path.close();

    canvas.drawPath(path, arrowPaint);
  }

  void _drawPortDot(Canvas canvas, Offset center, Color color) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    if (color == Colors.red) {
      canvas.drawCircle(center, 10.0, p..color = color.withOpacity(0.3));
      p.color = Colors.red;
    }
    canvas.drawCircle(center, 5.0, p);
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextAlign align) {
    final span = TextSpan(
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      text: text,
    );
    final tp = TextPainter(
      text: span,
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawSmallText(Canvas canvas, String text, Offset pos) {
    final span = TextSpan(
      style: TextStyle(color: Colors.grey[800], fontSize: 10),
      text: text,
    );
    final tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    canvas.drawRect(
      Rect.fromCenter(
        center: pos,
        width: tp.width + 4,
        height: tp.height + 2,
      ),
      Paint()..color = Colors.white,
    );
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant ResistiveDividerPainter oldDelegate) => true;
}
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'wd_globalvar.dart';

class WilkinsonPainter extends CustomPainter {
  final WilkinsonController controller;
  final double animationValue;

  WilkinsonPainter({required this.controller, required this.animationValue})
      : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2 - 60, size.height / 2);

    double baseWidth = 12.0;
    double wInput = baseWidth;
    double wTop = max(2.0, baseWidth * (50.0 / controller.z02));
    double wBot = max(2.0, baseWidth * (50.0 / controller.z03));

    final paintCopper = Paint()
      ..color = const Color(0xFFB87333)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = wInput;

    final pStart = center + const Offset(-150, 0);
    final pSplit = center + const Offset(-50, 0);
    final pPort2 = center + const Offset(100, -90);
    final pPort3 = center + const Offset(100, 90);

    Path pathIn = Path()
      ..moveTo(pStart.dx, pStart.dy)
      ..lineTo(pSplit.dx, pSplit.dy);

    Path pathTop = Path();
    pathTop.moveTo(pSplit.dx, pSplit.dy);
    pathTop.quadraticBezierTo(
      center.dx,
      -110 + center.dy / 2 + 50,
      pPort2.dx,
      pPort2.dy,
    );

    Path pathBot = Path();
    pathBot.moveTo(pSplit.dx, pSplit.dy);
    pathBot.quadraticBezierTo(
      center.dx,
      110 + center.dy / 2 - 50,
      pPort3.dx,
      pPort3.dy,
    );

    canvas.drawPath(pathIn, paintCopper);
    paintCopper.strokeWidth = wTop;
    canvas.drawPath(pathTop, paintCopper);
    paintCopper.strokeWidth = wBot;
    canvas.drawPath(pathBot, paintCopper);

    _drawResistor(canvas, pPort2, pPort3, controller.rIso, vertical: true);

    _drawOutputLoad(canvas, pPort2, controller.r2, "R2");
    _drawOutputLoad(canvas, pPort3, controller.r3, "R3");

    _drawText(canvas, "Port 1", pStart + const Offset(-45, -10));

    _drawSmallText(
      canvas,
      "Z02=${controller.z02.toStringAsFixed(1)}",
      Offset(center.dx - 10, pPort2.dy + 20),
      isTop: true,
    );

    _drawSmallText(
      canvas,
      "Z03=${controller.z03.toStringAsFixed(1)}",
      Offset(center.dx - 10, pPort3.dy - 30),
      isTop: false,
    );

    _drawText(canvas, "Port 2", pPort2 + const Offset(15, -12));
    _drawText(canvas, "Port 3", pPort3 + const Offset(15, 0));

    double waveFreq = controller.frequency * 0.08;
    double phaseShift = pi / 2 * (controller.frequency / 3.0);

    // 改这里：输入红色，输出蓝色
    _drawPathWave(canvas, pathIn, Colors.red, 1.0, waveFreq, 0);
    _drawPathWave(canvas, pathTop, Colors.blue, controller.s21, waveFreq, phaseShift);
    _drawPathWave(canvas, pathBot, Colors.blue, controller.s31, waveFreq, phaseShift);
  }

  void _drawOutputLoad(Canvas canvas, Offset portPos, double rVal, String label) {
    final paintWire = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    Offset pElbow = portPos + const Offset(40, 0);
    canvas.drawLine(portPos, pElbow, paintWire);

    Offset pResStart = pElbow;
    Offset pResEnd = pElbow + const Offset(0, 30);
    _drawResistorSymbolOnly(canvas, pResStart, pResEnd);

    _drawGround(canvas, pResEnd);

    TextPainter tp = TextPainter(
      text: TextSpan(
        text: "$label\n${rVal.toStringAsFixed(1)}Ω",
        style: const TextStyle(
          color: Colors.teal,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pElbow + const Offset(10, 5));
  }

  void _drawGround(Canvas canvas, Offset pos) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(pos + const Offset(-10, 0), pos + const Offset(10, 0), paint);
    canvas.drawLine(pos + const Offset(-6, 4), pos + const Offset(6, 4), paint);
    canvas.drawLine(pos + const Offset(-2, 8), pos + const Offset(2, 8), paint);
  }

  void _drawResistorSymbolOnly(Canvas canvas, Offset p1, Offset p2) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    Path path = Path();
    path.moveTo(p1.dx, p1.dy);
    int zigs = 4;
    double dist = (p2.dy - p1.dy).abs();
    double step = dist / zigs;
    double width = 4.0;

    for (int i = 1; i < zigs; i++) {
      double x = p1.dx + (i % 2 == 0 ? -width : width);
      double y = p1.dy + i * step;
      path.lineTo(x, y);
    }
    path.lineTo(p2.dx, p2.dy);
    canvas.drawPath(path, paint);
  }

  void _drawResistor(Canvas canvas, Offset p1, Offset p2, double resistance, {bool vertical = false}) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double dy = p2.dy - p1.dy;
    double dx = p2.dx - p1.dx;
    double len = sqrt(dx * dx + dy * dy);

    canvas.save();
    canvas.translate(p1.dx, p1.dy);
    canvas.rotate(atan2(dy, dx));

    Path localPath = Path();
    localPath.moveTo(0, 0);
    int zigs = 6;
    double step = len / zigs;
    double w = 5.0;
    for (int i = 1; i < zigs; i++) {
      localPath.lineTo(i * step, (i % 2 == 0) ? -w : w);
    }
    localPath.lineTo(len, 0);
    canvas.drawPath(localPath, paint);
    canvas.restore();

    TextPainter tp = TextPainter(
      text: TextSpan(
        text: "R=${resistance.toStringAsFixed(1)}Ω",
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(p1.dx + 15, (p1.dy + p2.dy) / 2 - 5));
  }

  void _drawSmallText(Canvas canvas, String text, Offset pos, {required bool isTop}) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 2, pos.dy - 2, tp.width + 4, tp.height + 4),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withOpacity(0.8),
    );
    tp.paint(canvas, pos);
  }

  void _drawText(Canvas canvas, String text, Offset pos) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos);
  }

  void _drawPathWave(Canvas canvas, Path followPath, Color color, double amp, double k, double phaseOffset) {
    if (amp < 0.05) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    PathMetrics pathMetrics = followPath.computeMetrics();
    for (PathMetric metric in pathMetrics) {
      Path wavePath = Path();
      double length = metric.length;

      for (double d = 0; d < length; d += 2.0) {
        Tangent? t = metric.getTangentForOffset(d);
        if (t == null) continue;

        double phase = d * k - animationValue * 2 * pi - phaseOffset;
        double offsetVal = 8.0 * amp * sin(phase);
        double nx = -t.vector.dy;
        double ny = t.vector.dx;
        double x = t.position.dx + nx * offsetVal;
        double y = t.position.dy + ny * offsetVal;

        if (d == 0) {
          wavePath.moveTo(x, y);
        } else {
          wavePath.lineTo(x, y);
        }
      }

      canvas.drawPath(wavePath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WilkinsonPainter oldDelegate) => true;
}
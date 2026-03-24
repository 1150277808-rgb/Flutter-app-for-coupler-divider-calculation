import 'dart:math';
import 'package:flutter/material.dart';
import 'bl_globalvar.dart';

class BranchLineSPlot extends StatelessWidget {
  final BranchLineController controller;

  const BranchLineSPlot({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final s11db = _db20(controller.s1_mag);
        final s21db = _db20(controller.s2_mag);
        final s31db = _db20(controller.s3_mag);
        final s41db = _db20(controller.s4_mag);

        return Card(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "S-Parameters vs Frequency",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Current frequency: ${controller.freqGHz.toStringAsFixed(3)} GHz",
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    _LegendDot(color: Colors.red, text: "S11"),
                    _LegendDot(color: Colors.blue, text: "S21"),
                    _LegendDot(color: Colors.purple, text: "S31"),
                    _LegendDot(color: Colors.green, text: "S41"),
                    _LegendDot(color: Colors.black54, text: "Current f"),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _BlPlotPainter(controller: controller),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    _ValueChip(label: "S11", value: s11db, color: Colors.red),
                    _ValueChip(label: "S21", value: s21db, color: Colors.blue),
                    _ValueChip(label: "S31", value: s31db, color: Colors.purple),
                    _ValueChip(label: "S41", value: s41db, color: Colors.green),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _db20(double x) {
    if (x <= 1e-6) return -120.0;
    return 20.0 * log(x) / ln10;
  }
}

class _BlPlotPainter extends CustomPainter {
  final BranchLineController controller;

  _BlPlotPainter({required this.controller}) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final freqs = controller.sweepFreqGHz;
    final s11 = controller.sweepS11dB;
    final s21 = controller.sweepS21dB;
    final s31 = controller.sweepS31dB;
    final s41 = controller.sweepS41dB;

    if (freqs.length < 2) {
      _drawCenteredText(canvas, size, "No sweep data");
      return;
    }

    const double left = 50;
    const double right = 16;
    const double top = 14;
    const double bottom = 34;

    final Rect plotRect = Rect.fromLTWH(
      left,
      top,
      size.width - left - right,
      size.height - top - bottom,
    );

    final double xMin = freqs.first;
    final double xMax = freqs.last;
    const double yMax = 0.0;
    const double yMin = -40.0;

    final axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.25)
      ..strokeWidth = 1;

    // Border
    canvas.drawRect(plotRect, axisPaint);

    // Horizontal grid and labels
    for (double y = yMin; y <= yMax; y += 10) {
      final py = _mapY(y, yMin, yMax, plotRect);
      canvas.drawLine(
        Offset(plotRect.left, py),
        Offset(plotRect.right, py),
        gridPaint,
      );
      _drawText(
        canvas,
        "${y.toInt()}",
        Offset(plotRect.left - 8, py),
        alignRight: true,
      );
    }

    // Vertical ticks and labels
    const int xTicks = 5;
    for (int i = 0; i <= xTicks; i++) {
      final xVal = xMin + (xMax - xMin) * i / xTicks;
      final px = _mapX(xVal, xMin, xMax, plotRect);

      canvas.drawLine(
        Offset(px, plotRect.top),
        Offset(px, plotRect.bottom),
        gridPaint,
      );

      _drawText(
        canvas,
        xVal.toStringAsFixed(1),
        Offset(px, plotRect.bottom + 14),
        centered: true,
      );
    }

    // Axis titles
    _drawText(
      canvas,
      "Frequency (GHz)",
      Offset(plotRect.center.dx, size.height - 8),
      centered: true,
    );
    _drawText(
      canvas,
      "dB",
      Offset(18, plotRect.top - 2),
    );

    _drawCurve(canvas, plotRect, freqs, s11, xMin, xMax, yMin, yMax, Colors.red);
    _drawCurve(canvas, plotRect, freqs, s21, xMin, xMax, yMin, yMax, Colors.blue);
    _drawCurve(canvas, plotRect, freqs, s31, xMin, xMax, yMin, yMax, Colors.purple);
    _drawCurve(canvas, plotRect, freqs, s41, xMin, xMax, yMin, yMax, Colors.green);

    // Current frequency marker
    final currentX = _mapX(controller.freqGHz, xMin, xMax, plotRect);
    _drawDashedLine(
      canvas,
      Offset(currentX, plotRect.top),
      Offset(currentX, plotRect.bottom),
      Paint()
        ..color = Colors.black54
        ..strokeWidth = 1.2,
    );

    _drawText(
      canvas,
      "${controller.freqGHz.toStringAsFixed(2)} GHz",
      Offset(currentX, plotRect.top - 2),
      centered: true,
      bg: Colors.white,
    );

    // Current points
    _drawCurrentPoint(canvas, plotRect, controller.freqGHz, _db20(controller.s1_mag), xMin, xMax, yMin, yMax, Colors.red);
    _drawCurrentPoint(canvas, plotRect, controller.freqGHz, _db20(controller.s2_mag), xMin, xMax, yMin, yMax, Colors.blue);
    _drawCurrentPoint(canvas, plotRect, controller.freqGHz, _db20(controller.s3_mag), xMin, xMax, yMin, yMax, Colors.purple);
    _drawCurrentPoint(canvas, plotRect, controller.freqGHz, _db20(controller.s4_mag), xMin, xMax, yMin, yMax, Colors.green);
  }

  void _drawCurve(
    Canvas canvas,
    Rect rect,
    List<double> xs,
    List<double> ys,
    double xMin,
    double xMax,
    double yMin,
    double yMax,
    Color color,
  ) {
    if (xs.length < 2 || ys.length < 2) return;

    final path = Path();
    for (int i = 0; i < min(xs.length, ys.length); i++) {
      final x = _mapX(xs[i], xMin, xMax, rect);
      final y = _mapY(ys[i].clamp(yMin, yMax), yMin, yMax, rect);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  void _drawCurrentPoint(
    Canvas canvas,
    Rect rect,
    double fx,
    double ydb,
    double xMin,
    double xMax,
    double yMin,
    double yMax,
    Color color,
  ) {
    final x = _mapX(fx, xMin, xMax, rect);
    final y = _mapY(ydb.clamp(yMin, yMax), yMin, yMax, rect);

    canvas.drawCircle(
      Offset(x, y),
      4.5,
      Paint()..color = color,
    );
  }

  double _mapX(double x, double xMin, double xMax, Rect rect) {
    return rect.left + (x - xMin) / (xMax - xMin) * rect.width;
  }

  double _mapY(double y, double yMin, double yMax, Rect rect) {
    return rect.bottom - (y - yMin) / (yMax - yMin) * rect.height;
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dash = 6;
    const double gap = 4;
    final total = (p2 - p1).distance;
    final dx = (p2.dx - p1.dx) / total;
    final dy = (p2.dy - p1.dy) / total;

    double dist = 0;
    while (dist < total) {
      final start = Offset(p1.dx + dx * dist, p1.dy + dy * dist);
      final endDist = min(dist + dash, total);
      final end = Offset(p1.dx + dx * endDist, p1.dy + dy * endDist);
      canvas.drawLine(start, end, paint);
      dist += dash + gap;
    }
  }

  void _drawCenteredText(Canvas canvas, Size size, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.black54),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    bool centered = false,
    bool alignRight = false,
    Color? bg,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 11,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    Offset drawPos = pos;
    if (centered) drawPos = pos - Offset(tp.width / 2, tp.height / 2);
    if (alignRight) drawPos = pos - Offset(tp.width, tp.height / 2);

    if (bg != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            drawPos.dx - 3,
            drawPos.dy - 1,
            tp.width + 6,
            tp.height + 2,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = bg,
      );
    }

    tp.paint(canvas, drawPos);
  }

  double _db20(double x) {
    if (x <= 1e-6) return -120.0;
    return 20.0 * log(x) / ln10;
  }

  @override
  bool shouldRepaint(covariant _BlPlotPainter oldDelegate) => true;
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendDot({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _ValueChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ValueChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        '$label = ${value.toStringAsFixed(2)} dB',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
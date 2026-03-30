import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'wd_globalvar.dart';

class WilkinsonSPlot extends StatelessWidget {
  final WilkinsonController controller;

  const WilkinsonSPlot({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("S-Parameters vs Frequency", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                return Text("Current frequency: ${controller.frequency.toStringAsFixed(2)} GHz", style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600));
              },
            ),
            const SizedBox(height: 10),
            const Wrap(spacing: 14, children: [
              _LegendDot(color: Colors.red, text: "S11"),
              _LegendDot(color: Colors.blue, text: "S21"),
              _LegendDot(color: Colors.purple, text: "S31"),
              _LegendDot(color: Colors.green, text: "S23"),
            ]),
            const SizedBox(height: 8),
            const Text("Note: When curves overlap, only one line may be visible.", style: TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            SizedBox(height: 300, width: double.infinity, child: _WdSParameterPlot(controller: controller)),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 11, height: 11, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _WdSParameterPlot extends StatelessWidget {
  final WilkinsonController controller;

  const _WdSParameterPlot({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _WdSParameterPlotPainter(
            samples: controller.sweepSamples(),
            currentFrequency: controller.frequency,
            minF: controller.sweepMinFreq,
            maxF: controller.sweepMaxFreq,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _WdSParameterPlotPainter extends CustomPainter {
  final List<WdSample> samples;
  final double currentFrequency;
  final double minF;
  final double maxF;

  _WdSParameterPlotPainter({
    required this.samples,
    required this.currentFrequency,
    required this.minF,
    required this.maxF,
  });

  double _toDb(double mag) {
    if (mag <= 0.0001) return -40.0;
    final db = 20 * math.log(mag) / math.ln10;
    return db.clamp(-40.0, 0.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFFDFDFD);
    final border = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, bg);
    canvas.drawRRect(rect, border);

    const leftPad = 42.0;
    const rightPad = 14.0;
    const topPad = 16.0;
    const bottomPad = 28.0;

    final plot = Rect.fromLTWH(
      leftPad,
      topPad,
      size.width - leftPad - rightPad,
      size.height - topPad - bottomPad,
    );

    final gridPaint = Paint()
      ..color = const Color(0xFFEAEAEA)
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 1.2;

    const minDb = -40.0;
    const maxDb = 0.0;

    double xOf(double f) => plot.left + (f - minF) / (maxF - minF) * plot.width;
    double yOf(double db) => plot.bottom - (db - minDb) / (maxDb - minDb) * plot.height;

    for (double db = -40; db <= 0; db += 10) {
      final y = yOf(db);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      _paintText(canvas, "${db.toInt()} dB", Offset(4, y - 7), const TextStyle(fontSize: 10, color: Colors.black54));
    }

    final fStep = (maxF - minF) / 4;
    for (int i = 0; i <= 4; i++) {
      final f = minF + i * fStep;
      final x = xOf(f);
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), gridPaint);
      _paintText(canvas, f.toStringAsFixed(1), Offset(x - 10, plot.bottom + 6), const TextStyle(fontSize: 10, color: Colors.black54));
    }

    canvas.drawLine(Offset(plot.left, plot.top), Offset(plot.left, plot.bottom), axisPaint);
    canvas.drawLine(Offset(plot.left, plot.bottom), Offset(plot.right, plot.bottom), axisPaint);

    _paintText(canvas, "Freq (GHz)", Offset(plot.center.dx - 24, size.height - 18), const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500));

    _drawCurve(canvas, plot, samples, (s) => _toDb(s.s11), Colors.red, xOf, yOf);
    _drawCurve(canvas, plot, samples, (s) => _toDb(s.s21), Colors.blue, xOf, yOf);
    _drawCurve(canvas, plot, samples, (s) => _toDb(s.s31), Colors.purple, xOf, yOf);
    _drawCurve(canvas, plot, samples, (s) => _toDb(s.s23), Colors.green, xOf, yOf);

    final currentX = xOf(currentFrequency);
    final dashPaint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 1;

    for (double y = plot.top; y < plot.bottom; y += 6) {
      canvas.drawLine(Offset(currentX, y), Offset(currentX, math.min(y + 3, plot.bottom)), dashPaint);
    }

    final cur = samples.reduce((a, b) => (a.frequency - currentFrequency).abs() < (b.frequency - currentFrequency).abs() ? a : b);

    _drawMarker(canvas, Offset(currentX, yOf(_toDb(cur.s11))), Colors.red);
    _drawMarker(canvas, Offset(currentX, yOf(_toDb(cur.s21))), Colors.blue);
    _drawMarker(canvas, Offset(currentX, yOf(_toDb(cur.s31))), Colors.purple);
    _drawMarker(canvas, Offset(currentX, yOf(_toDb(cur.s23))), Colors.green);
  }

  void _drawCurve(Canvas canvas, Rect plot, List<WdSample> data, double Function(WdSample) valueOf, Color color, double Function(double) xOf, double Function(double) yOf) {
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = xOf(data[i].frequency);
      final y = yOf(valueOf(data[i]));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.clipRect(plot);
    canvas.drawPath(path, p);
    canvas.restore();
  }

  void _drawMarker(Canvas canvas, Offset center, Color color) {
    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, 4.2, fill);
    canvas.drawCircle(center, 4.2, stroke);
  }

  void _paintText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _WdSParameterPlotPainter oldDelegate) {
    return oldDelegate.currentFrequency != currentFrequency || oldDelegate.samples != samples;
  }
}

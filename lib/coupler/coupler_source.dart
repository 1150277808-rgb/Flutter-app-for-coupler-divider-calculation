import 'package:flutter/material.dart';
import 'dart:math';
import 'coupler_globalvar.dart';

class SourceWave extends StatelessWidget {
  final SourceController controller;
  const SourceWave({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class SourceMotion extends StatefulWidget {
  final SourceController controller;
  const SourceMotion({super.key, required this.controller});

  @override
  State<SourceMotion> createState() => _SourceMotionState();
}

class _SourceMotionState extends State<SourceMotion> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
          ..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 420.0;

        return SizedBox(
          height: h,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 15,
                  runSpacing: 8,
                  children: [
                    _buildLegend(Colors.red, "Excited Input"),
                    _buildLegend(Colors.blue, "Outgoing Wave"),
                    _buildLegend(Colors.grey, "Near Zero Output"),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_animController, widget.controller]),
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _RingCouplerPainter(
                        controller: widget.controller,
                        animValue: _animController.value,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}

class _RingCouplerPainter extends CustomPainter {
  final SourceController controller;
  final double animValue;

  _RingCouplerPainter({required this.controller, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const radius = 80.0;

    final p2_ring = _getPoint(cx, cy, radius, -90);
    final p2_end = Offset(cx, cy - radius - 50);
    final p4_ring = _getPoint(cx, cy, radius, 90);
    final p4_end = Offset(cx, cy + radius + 50);
    final p1_ring = _getPoint(cx, cy, radius, -150);
    final p1_end = _getPoint(cx, cy, radius + 50, -150);
    final p3_ring = _getPoint(cx, cy, radius, 150);
    final p3_end = _getPoint(cx, cy, radius + 50, 150);

    final paintStruct = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(Offset(cx, cy), radius, paintStruct);

    _drawText(canvas, "√2 Z₀", cx, cy, color: Colors.black54);
    _drawText(canvas, "Z₀", p2_end.dx + 10, p2_end.dy + 20, color: Colors.black54);

    canvas.drawLine(p1_ring, p1_end, paintStruct);
    canvas.drawLine(p2_ring, p2_end, paintStruct);
    canvas.drawLine(p3_ring, p3_end, paintStruct);
    canvas.drawLine(p4_ring, p4_end, paintStruct);

    _drawLabel(canvas, "Port 2", p2_end.dx, p2_end.dy - 15, isActive: controller.isPortExcited(2));
    _drawLabel(canvas, "Port 4", p4_end.dx, p4_end.dy + 15, isActive: controller.isPortExcited(4));
    _drawLabel(canvas, "Port 1", p1_end.dx - 30, p1_end.dy, isActive: controller.isPortExcited(1));
    _drawLabel(canvas, "Port 3", p3_end.dx - 30, p3_end.dy, isActive: controller.isPortExcited(3));

    final animPhase = -animValue * 2 * pi;

    _drawPort(canvas, 1, p1_end, p1_ring, animPhase);
    _drawPort(canvas, 2, p2_end, p2_ring, animPhase);
    _drawPort(canvas, 3, p3_end, p3_ring, animPhase);
    _drawPort(canvas, 4, p4_end, p4_ring, animPhase);
  }

  void _drawPort(Canvas canvas, int port, Offset outer, Offset inner, double animPhase) {
    final isInput = controller.isPortExcited(port);
    final inputAmp = controller.getInputAmplitude(port);
    final inputPhase = controller.getInputPhaseDeg(port) * pi / 180.0;

    final outAmp = controller.getOutputAmplitude(port);
    final outPhase = controller.getOutputPhaseRad(port);

    if (isInput && inputAmp > 0.01) {
      _drawWave(
        canvas,
        outer,
        inner,
        mag: inputAmp,
        phase: animPhase + inputPhase,
        color: Colors.red,
      );
    }

    if (outAmp > 0.01) {
      _drawWave(
        canvas,
        inner,
        outer,
        mag: outAmp,
        phase: animPhase + outPhase,
        color: outAmp < 0.05 ? Colors.grey : Colors.blue,
      );
    }

    _drawPortDot(
      canvas,
      outer,
      isInput ? Colors.red : (outAmp < 0.05 ? Colors.grey : Colors.blue),
    );
  }

  void _drawWave(
    Canvas canvas,
    Offset start,
    Offset end, {
    required double mag,
    required double phase,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final dist = (end - start).distance;
    final angle = (end - start).direction;
    final wavelength = 300.0 / (controller.freqGHz * 10);

    final path = Path();
    for (double t = 0; t <= dist; t += 2) {
      final y = 8 * mag * sin((t / wavelength) * 2 * pi + phase);
      final finalX = start.dx + t * cos(angle) - y * sin(angle);
      final finalY = start.dy + t * sin(angle) + y * cos(angle);
      if (t == 0) {
        path.moveTo(finalX, finalY);
      } else {
        path.lineTo(finalX, finalY);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawPortDot(Canvas canvas, Offset center, Color color) {
    final p = Paint()..style = PaintingStyle.fill;
    if (color == Colors.red) {
      p.color = color.withOpacity(0.25);
      canvas.drawCircle(center, 10, p);
      p.color = Colors.red;
    } else {
      p.color = color;
    }
    canvas.drawCircle(center, 5, p);
  }

  Offset _getPoint(double cx, double cy, double r, double deg) {
    final rad = deg * pi / 180;
    return Offset(cx + r * cos(rad), cy + r * sin(rad));
  }

  void _drawText(Canvas canvas, String text, double x, double y, {Color color = Colors.black}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 12)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _drawLabel(Canvas canvas, String text, double x, double y, {bool isActive = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isActive ? Colors.red : Colors.black87,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
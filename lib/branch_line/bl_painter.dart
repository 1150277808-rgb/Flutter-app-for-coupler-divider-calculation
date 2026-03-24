import 'dart:math';
import 'package:flutter/material.dart';
import 'bl_globalvar.dart';

class BranchLinePainterFrame extends StatefulWidget {
  final BranchLineController controller;

  const BranchLinePainterFrame({super.key, required this.controller});

  @override
  State<BranchLinePainterFrame> createState() => _BranchLinePainterFrameState();
}

class _BranchLinePainterFrameState extends State<BranchLinePainterFrame>
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
          painter: BranchLinePainter(
            controller: widget.controller,
            animationValue: _animController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class BranchLinePainter extends CustomPainter {
  final BranchLineController controller;
  final double animationValue;

  BranchLinePainter({
    required this.controller,
    required this.animationValue,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..color = Colors.black;

    const double boxW = 360.0;
    const double boxH = 180.0;
    final double left = (size.width - boxW) / 2;
    final double top = (size.height - boxH) / 2;

    final Map<int, Offset> node = {
      1: Offset(left, top),
      2: Offset(left + boxW, top),
      3: Offset(left + boxW, top + boxH),
      4: Offset(left, top + boxH),
    };

    const double stubLen = 50.0;
    final Map<int, Offset> portPos = {
      1: node[1]! - const Offset(stubLen, 0),
      2: node[2]! + const Offset(stubLen, 0),
      3: node[3]! + const Offset(stubLen, 0),
      4: node[4]! - const Offset(stubLen, 0),
    };

    // Static structure
    canvas.drawLine(node[1]!, node[2]!, linePaint);
    canvas.drawLine(node[2]!, node[3]!, linePaint);
    canvas.drawLine(node[3]!, node[4]!, linePaint);
    canvas.drawLine(node[4]!, node[1]!, linePaint);

    canvas.drawLine(portPos[1]!, node[1]!, linePaint);
    canvas.drawLine(node[2]!, portPos[2]!, linePaint);
    canvas.drawLine(node[3]!, portPos[3]!, linePaint);
    canvas.drawLine(node[4]!, portPos[4]!, linePaint);

    // Labels
    _drawText(canvas, "Port 1", portPos[1]! - const Offset(10, 0), TextAlign.right);
    _drawText(canvas, "Port 2", portPos[2]! + const Offset(10, 0), TextAlign.left);
    _drawText(canvas, "Port 4", portPos[4]! - const Offset(10, 0), TextAlign.right);
    _drawText(canvas, "Port 3", portPos[3]! + const Offset(10, 0), TextAlign.left);

    _drawSmallText(canvas, "λ/4, Z₀/√2", (node[1]! + node[2]!) / 2 + const Offset(0, -20));
    _drawSmallText(canvas, "λ/4, Z₀/√2", (node[4]! + node[3]!) / 2 + const Offset(0, 10));
    _drawSmallText(canvas, "λ/4, Z₀", (node[1]! + node[4]!) / 2 + const Offset(10, 0));
    _drawSmallText(canvas, "λ/4, Z₀", (node[2]! + node[3]!) / 2 + const Offset(-10, 0));

    final int input = controller.inputPort;
    final int through = _throughPort(input);
    final int coupled = _coupledPort(input);
    final int isolated = _isolatedPort(input);

    final double visualK = 0.10 + controller.frequency * 0.015;

    // 1) Input excitation stub
    _drawPathWave(
      canvas,
      _buildPath([portPos[input]!, node[input]!]),
      Colors.red,
      1.0,
      visualK,
      0.0,
    );

    // 2) Internal ring waves: draw each edge ONCE only (no duplicate overlay)
    final double internalAmp =
        (((controller.s2_mag + controller.s3_mag) / 2).clamp(0.0, 1.0)) * 0.95;

    final int rot = input - 1;

    _drawPathWave(
      canvas,
      _buildPath([node[1]!, node[2]!]),
      Colors.blue.withOpacity(0.85),
      internalAmp,
      visualK,
      _segmentPhase(0, rot),
    );
    _drawPathWave(
      canvas,
      _buildPath([node[2]!, node[3]!]),
      Colors.blue.withOpacity(0.85),
      internalAmp,
      visualK,
      _segmentPhase(1, rot),
    );
    _drawPathWave(
      canvas,
      _buildPath([node[4]!, node[3]!]),
      Colors.blue.withOpacity(0.85),
      internalAmp,
      visualK,
      _segmentPhase(2, rot),
    );
    _drawPathWave(
      canvas,
      _buildPath([node[1]!, node[4]!]),
      Colors.blue.withOpacity(0.85),
      internalAmp,
      visualK,
      _segmentPhase(3, rot),
    );

    // 3) Output stubs with actual S-parameter amplitudes
    _drawPathWave(
      canvas,
      _buildPath([node[through]!, portPos[through]!]),
      Colors.blue,
      controller.s2_mag,
      visualK,
      controller.s2_phase,
    );

    _drawPathWave(
      canvas,
      _buildPath([node[coupled]!, portPos[coupled]!]),
      Colors.blue.withOpacity(0.70),
      controller.s3_mag,
      visualK,
      controller.s3_phase,
    );

    _drawPathWave(
      canvas,
      _buildPath([node[isolated]!, portPos[isolated]!]),
      Colors.grey.withOpacity(0.75),
      controller.s4_mag,
      visualK,
      controller.s4_phase,
    );

    // Optional reflection at input stub
    if (controller.s1_mag > 0.05) {
      _drawPathWave(
        canvas,
        _buildPath([node[input]!, portPos[input]!]),
        Colors.red.withOpacity(0.55),
        controller.s1_mag,
        visualK,
        controller.s1_phase,
      );
    }

    // Port dots
    _drawPortDot(canvas, portPos[1]!, _getPortColor(1, input));
    _drawPortDot(canvas, portPos[2]!, _getPortColor(2, input));
    _drawPortDot(canvas, portPos[3]!, _getPortColor(3, input));
    _drawPortDot(canvas, portPos[4]!, _getPortColor(4, input));

    // Junction dots
    _drawJunctionDot(canvas, node[1]!);
    _drawJunctionDot(canvas, node[2]!);
    _drawJunctionDot(canvas, node[3]!);
    _drawJunctionDot(canvas, node[4]!);
  }

  int _throughPort(int input) {
    switch (input) {
      case 1:
        return 2;
      case 2:
        return 1;
      case 3:
        return 4;
      case 4:
        return 3;
      default:
        return 2;
    }
  }

  int _coupledPort(int input) {
    switch (input) {
      case 1:
        return 3;
      case 2:
        return 4;
      case 3:
        return 1;
      case 4:
        return 2;
      default:
        return 3;
    }
  }

  int _isolatedPort(int input) {
    switch (input) {
      case 1:
        return 4;
      case 2:
        return 3;
      case 3:
        return 2;
      case 4:
        return 1;
      default:
        return 4;
    }
  }

  double _segmentPhase(int segmentIndex, int rotation) {
    return (segmentIndex - rotation) * pi / 2.0;
  }

  Path _buildPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    return path;
  }

  Color _getPortColor(int currentPort, int inputPort) {
    if (currentPort == inputPort) return Colors.red;

    final isolatedPort = _isolatedPort(inputPort);
    if (currentPort == isolatedPort) return Colors.grey;

    return Colors.blue;
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

  void _drawJunctionDot(Canvas canvas, Offset center) {
    final p = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.0, p);
  }

  void _drawPathWave(
    Canvas canvas,
    Path followPath,
    Color color,
    double amplitude,
    double k,
    double phaseOffset,
  ) {
    if (amplitude <= 0.03) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final metrics = followPath.computeMetrics();

    for (final metric in metrics) {
      final wavePath = Path();
      final length = metric.length;

      for (double d = 0; d <= length; d += 2.0) {
        final tangent = metric.getTangentForOffset(d);
        if (tangent == null) continue;

        final vec = tangent.vector;
        final norm = vec.distance == 0 ? 1.0 : vec.distance;
        final nx = -vec.dy / norm;
        final ny = vec.dx / norm;

        final phase = d * k - animationValue * 2 * pi - phaseOffset;
        final offsetVal = 5.0 * amplitude * sin(phase);

        final x = tangent.position.dx + nx * offsetVal;
        final y = tangent.position.dy + ny * offsetVal;

        if (d == 0) {
          wavePath.moveTo(x, y);
        } else {
          wavePath.lineTo(x, y);
        }
      }

      canvas.drawPath(wavePath, paint);
    }
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextAlign align) {
    final span = TextSpan(
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      text: text,
    );

    final tp = TextPainter(
      text: span,
      textAlign: align,
      textDirection: TextDirection.ltr,
    );

    tp.layout();
    Offset drawPos = pos - Offset(0, tp.height / 2);
    if (align == TextAlign.right) {
      drawPos = drawPos - Offset(tp.width, 0);
    }
    tp.paint(canvas, drawPos);
  }

  void _drawSmallText(Canvas canvas, String text, Offset pos) {
    final span = TextSpan(
      style: TextStyle(
        color: Colors.grey[800],
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      text: text,
    );

    final tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    tp.layout();

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: pos,
        width: tp.width + 4,
        height: tp.height + 2,
      ),
      bgPaint,
    );

    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant BranchLinePainter oldDelegate) => true;
}
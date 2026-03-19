import 'package:flutter/material.dart';
import 'dart:math' as math;
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

    final Offset p1 = Offset(left, top);
    final Offset p2 = Offset(left + boxW, top);
    final Offset p3 = Offset(left + boxW, top + boxH);
    final Offset p4 = Offset(left, top + boxH);

    const double stubLen = 50.0;
    final Offset port1Pos = p1 - const Offset(stubLen, 0);
    final Offset port2Pos = p2 + const Offset(stubLen, 0);
    final Offset port3Pos = p3 + const Offset(stubLen, 0);
    final Offset port4Pos = p4 - const Offset(stubLen, 0);

    // Main structure
    canvas.drawLine(p1, p2, linePaint);
    canvas.drawLine(p2, p3, linePaint);
    canvas.drawLine(p3, p4, linePaint);
    canvas.drawLine(p4, p1, linePaint);

    canvas.drawLine(port1Pos, p1, linePaint);
    canvas.drawLine(p2, port2Pos, linePaint);
    canvas.drawLine(p3, port3Pos, linePaint);
    canvas.drawLine(p4, port4Pos, linePaint);

    // Labels
    _drawText(canvas, "Port 1", port1Pos - const Offset(10, 0), TextAlign.right);
    _drawText(canvas, "Port 2", port2Pos + const Offset(10, 0), TextAlign.left);
    _drawText(canvas, "Port 3", port3Pos + const Offset(10, 0), TextAlign.left);
    _drawText(canvas, "Port 4", port4Pos - const Offset(10, 0), TextAlign.right);

    _drawSmallText(canvas, "λ/4, Zh=${controller.zh.toStringAsFixed(2)}Ω", (p1 + p2) / 2 + const Offset(0, -20));
    _drawSmallText(canvas, "λ/4, Zh=${controller.zh.toStringAsFixed(2)}Ω", (p4 + p3) / 2 + const Offset(0, 10));
    _drawSmallText(canvas, "λ/4, Zv=${controller.zv.toStringAsFixed(2)}Ω", (p1 + p4) / 2 + const Offset(14, 0));
    _drawSmallText(canvas, "λ/4, Zv=${controller.zv.toStringAsFixed(2)}Ω", (p2 + p3) / 2 + const Offset(-14, 0));

    final input = controller.inputPort;

    final Complex sRef = _responseAt(outputPort: input, inputPort: input);

    int throughPort;
    int coupledPort;
    int isolatedPort;

    if (input == 1) {
      throughPort = 2;
      coupledPort = 3;
      isolatedPort = 4;
    } else if (input == 2) {
      throughPort = 1;
      coupledPort = 4;
      isolatedPort = 3;
    } else if (input == 3) {
      throughPort = 4;
      coupledPort = 1;
      isolatedPort = 2;
    } else {
      throughPort = 3;
      coupledPort = 2;
      isolatedPort = 1;
    }

    final Complex sThrough = _responseAt(outputPort: throughPort, inputPort: input);
    final Complex sCoupled = _responseAt(outputPort: coupledPort, inputPort: input);
    final Complex sIso = _responseAt(outputPort: isolatedPort, inputPort: input);

    // Input wave
    _drawIncomingWave(
      canvas,
      _portPoint(input, port1Pos, port2Pos, port3Pos, port4Pos),
      _nodePoint(input, p1, p2, p3, p4),
      Colors.red,
      1.0,
    );

    // Reflection wave
    _drawOutgoingWave(
      canvas,
      _nodePoint(input, p1, p2, p3, p4),
      _portPoint(input, port1Pos, port2Pos, port3Pos, port4Pos),
      Colors.blue,
      sRef.abs(),
      _phaseOf(sRef),
    );

    // Internal branch waves (重点：把 2-3 这条也画出来)
    _drawInternalBranchWaves(
      canvas: canvas,
      inputPort: input,
      p1: p1,
      p2: p2,
      p3: p3,
      p4: p4,
      throughAmp: sThrough.abs(),
      coupledAmp: sCoupled.abs(),
      throughPhase: _phaseOf(sThrough),
      coupledPhase: _phaseOf(sCoupled),
    );

    // Output feed waves
    _drawOutgoingWave(
      canvas,
      _nodePoint(throughPort, p1, p2, p3, p4),
      _portPoint(throughPort, port1Pos, port2Pos, port3Pos, port4Pos),
      Colors.blue,
      sThrough.abs(),
      _phaseOf(sThrough),
    );

    _drawOutgoingWave(
      canvas,
      _nodePoint(coupledPort, p1, p2, p3, p4),
      _portPoint(coupledPort, port1Pos, port2Pos, port3Pos, port4Pos),
      Colors.blue.withOpacity(0.80),
      sCoupled.abs(),
      _phaseOf(sCoupled),
    );

    _drawOutgoingWave(
      canvas,
      _nodePoint(isolatedPort, p1, p2, p3, p4),
      _portPoint(isolatedPort, port1Pos, port2Pos, port3Pos, port4Pos),
      Colors.grey,
      sIso.abs(),
      _phaseOf(sIso),
    );

    // Port dots
    _drawPortDot(canvas, port1Pos, _getPortColor(1, input, isolatedPort));
    _drawPortDot(canvas, port2Pos, _getPortColor(2, input, isolatedPort));
    _drawPortDot(canvas, port3Pos, _getPortColor(3, input, isolatedPort));
    _drawPortDot(canvas, port4Pos, _getPortColor(4, input, isolatedPort));

    _drawJunctionDot(canvas, p1);
    _drawJunctionDot(canvas, p2);
    _drawJunctionDot(canvas, p3);
    _drawJunctionDot(canvas, p4);
  }

  void _drawInternalBranchWaves({
    required Canvas canvas,
    required int inputPort,
    required Offset p1,
    required Offset p2,
    required Offset p3,
    required Offset p4,
    required double throughAmp,
    required double coupledAmp,
    required double throughPhase,
    required double coupledPhase,
  }) {
    final double aMain = math.max(throughAmp, 0.22);
    final double aCoupled = math.max(coupledAmp * 0.85, 0.18);

    final Color mainColor = Colors.blue;
    final Color auxColor = Colors.blue.withOpacity(0.75);

    if (inputPort == 1) {
      _drawSignalWave(canvas, p1, p2, mainColor, aMain, phaseShift: throughPhase);
      _drawSignalWave(canvas, p1, p4, auxColor, aCoupled, phaseShift: coupledPhase + 0.4);
      _drawSignalWave(canvas, p4, p3, auxColor, aCoupled, phaseShift: coupledPhase + 0.8);
      _drawSignalWave(canvas, p2, p3, auxColor, aCoupled, phaseShift: coupledPhase + 1.2);
    } else if (inputPort == 2) {
      _drawSignalWave(canvas, p2, p1, mainColor, aMain, phaseShift: throughPhase);
      _drawSignalWave(canvas, p2, p3, auxColor, aCoupled, phaseShift: coupledPhase + 0.4);
      _drawSignalWave(canvas, p3, p4, auxColor, aCoupled, phaseShift: coupledPhase + 0.8);
      _drawSignalWave(canvas, p1, p4, auxColor, aCoupled, phaseShift: coupledPhase + 1.2);
    } else if (inputPort == 3) {
      _drawSignalWave(canvas, p3, p4, mainColor, aMain, phaseShift: throughPhase);
      _drawSignalWave(canvas, p3, p2, auxColor, aCoupled, phaseShift: coupledPhase + 0.4);
      _drawSignalWave(canvas, p2, p1, auxColor, aCoupled, phaseShift: coupledPhase + 0.8);
      _drawSignalWave(canvas, p4, p1, auxColor, aCoupled, phaseShift: coupledPhase + 1.2);
    } else {
      _drawSignalWave(canvas, p4, p3, mainColor, aMain, phaseShift: throughPhase);
      _drawSignalWave(canvas, p4, p1, auxColor, aCoupled, phaseShift: coupledPhase + 0.4);
      _drawSignalWave(canvas, p1, p2, auxColor, aCoupled, phaseShift: coupledPhase + 0.8);
      _drawSignalWave(canvas, p3, p2, auxColor, aCoupled, phaseShift: coupledPhase + 1.2);
    }
  }

  Complex _responseAt({required int outputPort, required int inputPort}) {
    final s11 = controller.s11;
    final s21 = controller.s21;
    final s31 = controller.s31;
    final s41 = controller.s41;

    final matrix = [
      [s11, s21, s31, s41],
      [s21, s11, s41, s31],
      [s31, s41, s11, s21],
      [s41, s31, s21, s11],
    ];

    return matrix[outputPort - 1][inputPort - 1];
  }

  Offset _portPoint(int port, Offset p1, Offset p2, Offset p3, Offset p4) {
    switch (port) {
      case 1:
        return p1;
      case 2:
        return p2;
      case 3:
        return p3;
      default:
        return p4;
    }
  }

  Offset _nodePoint(int port, Offset p1, Offset p2, Offset p3, Offset p4) {
    switch (port) {
      case 1:
        return p1;
      case 2:
        return p2;
      case 3:
        return p3;
      default:
        return p4;
    }
  }

  Color _getPortColor(int currentPort, int inputPort, int isolatedPort) {
    if (currentPort == inputPort) return Colors.red;
    if (currentPort == isolatedPort) return Colors.grey;
    return Colors.blue;
  }

  double _phaseOf(Complex c) {
    return math.atan2(c.im, c.re);
  }

  void _drawPortDot(Canvas canvas, Offset center, Color color) {
    final p = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    if (color == Colors.red) {
      canvas.drawCircle(center, 10.0, p..color = color.withOpacity(0.25));
      p.color = color;
    }
    canvas.drawCircle(center, 5.0, p);
  }

  void _drawJunctionDot(Canvas canvas, Offset center) {
    final p = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.0, p);
  }

  void _drawIncomingWave(
    Canvas canvas,
    Offset pStart,
    Offset pEnd,
    Color color,
    double amplitude,
  ) {
    _drawSignalWave(
      canvas,
      pStart,
      pEnd,
      color,
      amplitude,
      phaseShift: 0.0,
      drawArrow: true,
    );
  }

  void _drawOutgoingWave(
    Canvas canvas,
    Offset pStart,
    Offset pEnd,
    Color color,
    double amplitude,
    double phaseShift,
  ) {
    _drawSignalWave(
      canvas,
      pStart,
      pEnd,
      color,
      amplitude,
      phaseShift: phaseShift,
      drawArrow: true,
    );
  }

  void _drawSignalWave(
    Canvas canvas,
    Offset pStart,
    Offset pEnd,
    Color color,
    double amplitude, {
    double phaseShift = 0.0,
    bool drawArrow = false,
  }) {
    if (amplitude <= 0.03) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final dist = (pEnd - pStart).distance;
    final angle = (pEnd - pStart).direction;
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);

    final spatialK = controller.frequency * 0.15;

    for (double t = 0; t <= dist; t += 2) {
      final phase = t * spatialK - animationValue * 2 * math.pi + phaseShift;
      final currentY = 5.0 * amplitude * math.sin(phase);

      final finalX = pStart.dx + t * cosA - currentY * sinA;
      final finalY = pStart.dy + t * sinA + currentY * cosA;

      if (t == 0) {
        path.moveTo(finalX, finalY);
      } else {
        path.lineTo(finalX, finalY);
      }
    }

    canvas.drawPath(path, paint);

    if (drawArrow) {
      _drawArrow(canvas, pStart, pEnd, color);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Color color) {
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final arrowX = start.dx + (end.dx - start.dx) * 0.72;
    final arrowY = start.dy + (end.dy - start.dy) * 0.72;

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const arrowSize = 6.0;

    final path = Path();
    path.moveTo(
      arrowX + arrowSize * math.cos(angle),
      arrowY + arrowSize * math.sin(angle),
    );
    path.lineTo(
      arrowX + arrowSize * math.cos(angle + 2.5),
      arrowY + arrowSize * math.sin(angle + 2.5),
    );
    path.lineTo(
      arrowX + arrowSize * math.cos(angle - 2.5),
      arrowY + arrowSize * math.sin(angle - 2.5),
    );
    path.close();

    canvas.drawPath(path, arrowPaint);
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
    var drawPos = pos - Offset(0, tp.height / 2);
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
      ..color = Colors.white.withOpacity(0.88)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: pos,
        width: tp.width + 6,
        height: tp.height + 2,
      ),
      bgPaint,
    );
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant BranchLinePainter oldDelegate) => true;
}
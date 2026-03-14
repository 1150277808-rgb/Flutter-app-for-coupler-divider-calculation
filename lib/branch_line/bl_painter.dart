import 'package:flutter/material.dart';
import 'dart:math';
import 'bl_globalvar.dart';

// --- 1. 动画外壳组件 (修复 bl_main 报错的关键) ---
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
    // 定义动画控制器，2秒循环一次，让波形动起来
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
    // 使用 AnimatedBuilder 监听动画进度
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return CustomPaint(
          // 调用下面的核心绘制逻辑
          painter: BranchLinePainter(
            controller: widget.controller,
            animationValue: _animController.value,
          ),
          size: Size.infinite, // 填满剩余空间
        );
      },
    );
  }
}

// --- 2. 核心绘制逻辑 (您原本的代码) ---
class BranchLinePainter extends CustomPainter {
  final BranchLineController controller;
  final double animationValue; // 0.0 ~ 1.0

  BranchLinePainter({required this.controller, required this.animationValue})
      : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // --- 布局计算 ---
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

    // --- 绘制静态结构 ---
    paint.color = Colors.black;
    paint.strokeWidth = 4.0;
    
    canvas.drawLine(p1, p2, paint);
    canvas.drawLine(p2, p3, paint);
    canvas.drawLine(p3, p4, paint);
    canvas.drawLine(p4, p1, paint);

    canvas.drawLine(port1Pos, p1, paint); 
    canvas.drawLine(p2, port2Pos, paint); 
    canvas.drawLine(p3, port3Pos, paint); 
    canvas.drawLine(p4, port4Pos, paint); 

    // --- 绘制标签 ---
    _drawText(canvas, "Port 1", port1Pos - const Offset(10, 0), TextAlign.right);
    _drawText(canvas, "Port 2", port2Pos + const Offset(10, 0), TextAlign.left);
    _drawText(canvas, "Port 4", port4Pos - const Offset(10, 0), TextAlign.right);
    _drawText(canvas, "Port 3", port3Pos + const Offset(10, 0), TextAlign.left);

    _drawSmallText(canvas, "λ/4, Z₀/√2", (p1 + p2) / 2 + const Offset(0, -20)); 
    _drawSmallText(canvas, "λ/4, Z₀/√2", (p4 + p3) / 2 + const Offset(0, 10));
    _drawSmallText(canvas, "λ/4, Z₀", (p1 + p4) / 2 + const Offset(10, 0));    
    _drawSmallText(canvas, "λ/4, Z₀", (p2 + p3) / 2 + const Offset(-10, 0));   

    // --- 动态波形绘制 ---
    
    // // 获取当前频率 (从 controller 获取)
    // double currentFreq = controller.frequency; 
    
    // // 计算视觉振幅系数
    // // 模拟带宽特性：偏离 3GHz 越远，波形越弱
    // double outputAmp = exp(-pow(currentFreq - 3.0, 2) / 2.0);

    // --- 动态波形绘制 ---
    // 直接使用 Step4 计算结果（由 blController.updateResults 写入）
    final double throughAmp  = controller.s2_mag; // |S21|
    final double coupledAmp  = controller.s3_mag; // |S31|
    final double isoAmp      = controller.s4_mag; // |S41|
    // if (throughAmp < 0.05) outputAmp = 0.0;

    const double inputAmp = 1.0;
    int input = controller.inputPort;
    Color inputColor = Colors.red;   
    Color outputColor = Colors.blue; 
    // Color outputDim = Colors.blue.withOpacity(0.6 * (outputAmp > 0 ? 1 : 0));

    if (input == 1) {
      _drawSignalWave(canvas, port1Pos, p1, inputColor, 1.0);

      // Through -> Port2
      _drawSignalWave(canvas, p1, p2, outputColor, throughAmp);
      _drawSignalWave(canvas, p2, port2Pos, outputColor, throughAmp);

      // Coupled -> Port3（走内部三段）
      final Color coupledColor = Colors.blue.withOpacity(0.6);
      _drawSignalWave(canvas, p1, p4, coupledColor, coupledAmp);
      _drawSignalWave(canvas, p4, p3, coupledColor, coupledAmp, offsetPhase: 0.25);
      _drawSignalWave(canvas, p3, port3Pos, coupledColor, coupledAmp, offsetPhase: 0.5);

      // Isolation -> Port4（这段以前你没画；现在按 |S41| 画，理想中心频率会自动“画不出来”）
      _drawSignalWave(canvas, p4, port4Pos, Colors.grey.withOpacity(0.6), isoAmp);
    }

    // if (input == 1) {
    //   _drawSignalWave(canvas, port1Pos, p1, inputColor, inputAmp);
    //   _drawSignalWave(canvas, p1, p2, outputColor, outputAmp); 
    //   _drawSignalWave(canvas, p2, port2Pos, outputColor, outputAmp);
    //   _drawSignalWave(canvas, p1, p4, outputDim, outputAmp); 
    //   _drawSignalWave(canvas, p4, p3, outputDim, outputAmp, offsetPhase: 0.25); 
    //   _drawSignalWave(canvas, p3, port3Pos, outputDim, outputAmp, offsetPhase: 0.5); 
    // } else if (input == 2) {
    //   _drawSignalWave(canvas, port2Pos, p2, inputColor, inputAmp);
    //   _drawSignalWave(canvas, p2, p1, outputColor, outputAmp);
    //   _drawSignalWave(canvas, p1, port1Pos, outputColor, outputAmp);
    //   _drawSignalWave(canvas, p2, p3, outputDim, outputAmp);
    //   _drawSignalWave(canvas, p3, p4, outputDim, outputAmp, offsetPhase: 0.25);
    //   _drawSignalWave(canvas, p4, port4Pos, outputDim, outputAmp, offsetPhase: 0.5);
    // } else if (input == 3) {
    //   _drawSignalWave(canvas, port3Pos, p3, inputColor, inputAmp);
    //   _drawSignalWave(canvas, p3, p4, outputColor, outputAmp);
    //   _drawSignalWave(canvas, p4, port4Pos, outputColor, outputAmp);
    //   _drawSignalWave(canvas, p3, p2, outputDim, outputAmp);
    //   _drawSignalWave(canvas, p2, p1, outputDim, outputAmp, offsetPhase: 0.25);
    //   _drawSignalWave(canvas, p1, port1Pos, outputDim, outputAmp, offsetPhase: 0.5);
    // } else { // Port 4
    //   _drawSignalWave(canvas, port4Pos, p4, inputColor, inputAmp);
    //   _drawSignalWave(canvas, p4, p3, outputColor, outputAmp);
    //   _drawSignalWave(canvas, p3, port3Pos, outputColor, outputAmp);
    //   _drawSignalWave(canvas, p4, p1, outputDim, outputAmp);
    //   _drawSignalWave(canvas, p1, p2, outputDim, outputAmp, offsetPhase: 0.25);
    //   _drawSignalWave(canvas, p2, port2Pos, outputDim, outputAmp, offsetPhase: 0.5);
    // }

    // --- 绘制端口点 ---
    _drawPortDot(canvas, port1Pos, _getPortColor(1, input));
    _drawPortDot(canvas, port2Pos, _getPortColor(2, input));
    _drawPortDot(canvas, port3Pos, _getPortColor(3, input));
    _drawPortDot(canvas, port4Pos, _getPortColor(4, input));

    // --- 连接节点 ---
    _drawJunctionDot(canvas, p1);
    _drawJunctionDot(canvas, p2);
    _drawJunctionDot(canvas, p3);
    _drawJunctionDot(canvas, p4);
  }

  Color _getPortColor(int currentPort, int inputPort) {
    if (currentPort == inputPort) return Colors.red; 
    if (inputPort == 1 && currentPort == 4) return Colors.grey;
    if (inputPort == 2 && currentPort == 3) return Colors.grey;
    if (inputPort == 3 && currentPort == 2) return Colors.grey;
    if (inputPort == 4 && currentPort == 1) return Colors.grey;
    return Colors.blue; 
  }

  void _drawPortDot(Canvas canvas, Offset center, Color color) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    if (color == Colors.red) {
      canvas.drawCircle(center, 10.0, p..color = color.withOpacity(0.3));
      p.color = Colors.red;
    }
    canvas.drawCircle(center, 5.0, p);
  }

  void _drawJunctionDot(Canvas canvas, Offset center) {
    final p = Paint()..color = Colors.black..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.0, p);
  }

  void _drawSignalWave(Canvas canvas, Offset pStart, Offset pEnd, Color color, double amplitude, {double offsetPhase = 0.0}) {
    if (amplitude <= 0.05) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Path path = Path();
    double dist = (pEnd - pStart).distance;
    double angle = (pEnd - pStart).direction;
    double cosA = cos(angle);
    double sinA = sin(angle);

    for (double t = 0; t <= dist; t += 2) {
      double phase = t * 0.15 - animationValue * 2 * pi + offsetPhase * pi; 
      double currentY = 5.0 * amplitude * sin(phase); 

      double dx = t;
      double dy = currentY;
      
      double finalX = pStart.dx + dx * cosA - dy * sinA;
      double finalY = pStart.dy + dx * sinA + dy * cosA;

      if (t == 0) path.moveTo(finalX, finalY);
      else path.lineTo(finalX, finalY);
    }
    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextAlign align) {
    TextSpan span = TextSpan(style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14), text: text);
    TextPainter tp = TextPainter(text: span, textAlign: align, textDirection: TextDirection.ltr);
    tp.layout();
    Offset drawPos = pos - Offset(0, tp.height / 2);
    if (align == TextAlign.right) drawPos = drawPos - Offset(tp.width, 0);
    tp.paint(canvas, drawPos);
  }

  void _drawSmallText(Canvas canvas, String text, Offset pos) {
    TextSpan span = TextSpan(style: TextStyle(color: Colors.grey[800], fontSize: 11, fontWeight: FontWeight.w500), text: text);
    TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout();
    final bgPaint = Paint()..color = Colors.white.withOpacity(0.8)..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: pos, width: tp.width + 4, height: tp.height + 2), bgPaint);
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant BranchLinePainter oldDelegate) {
    return true;
  }
}
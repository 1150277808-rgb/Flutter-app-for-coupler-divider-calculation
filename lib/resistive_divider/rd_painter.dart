import 'package:flutter/material.dart';
import 'dart:math';
import 'rd_globalvar.dart';

// 动画驱动壳
class ResistiveDividerPainterFrame extends StatefulWidget {
  final ResistiveDividerController controller;

  const ResistiveDividerPainterFrame({super.key, required this.controller});

  @override
  State<ResistiveDividerPainterFrame> createState() => _ResistiveDividerPainterFrameState();
}

class _ResistiveDividerPainterFrameState extends State<ResistiveDividerPainterFrame>
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

// 核心绘制逻辑
class ResistiveDividerPainter extends CustomPainter {
  final ResistiveDividerController controller;
  final double animationValue;

  ResistiveDividerPainter({required this.controller, required this.animationValue})
      : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final double armLen = 120.0; // Y字臂长

    // 计算三个端点 (Y字形，夹角120度)
    // Port 1: 左边 (180度)
    // Port 2: 右上 (-30度) -> 330度
    // Port 3: 右下 (30度)
    final p1 = center + Offset(-armLen, 0);
    final p2 = center + Offset(armLen * cos(-pi / 6), armLen * sin(-pi / 6));
    final p3 = center + Offset(armLen * cos(pi / 6), armLen * sin(pi / 6));

    // 绘制连接线（黑色导线）
    paint.color = Colors.black;
    
    // 画电阻符号 (在每条臂的中间段)
    _drawResistorArm(canvas, paint, center, p1);
    _drawResistorArm(canvas, paint, center, p2);
    _drawResistorArm(canvas, paint, center, p3);

    // 绘制文字标签
    _drawText(canvas, "Port 1", p1 - const Offset(20, 0), TextAlign.right);
    _drawText(canvas, "Port 2", p2 + const Offset(20, -10), TextAlign.left);
    _drawText(canvas, "Port 3", p3 + const Offset(20, 10), TextAlign.left);

    _drawSmallText(canvas, "Z₀/3", (center + p1) / 2 + const Offset(0, -15));
    _drawSmallText(canvas, "Z₀/3", (center + p2) / 2 + const Offset(5, -15));
    _drawSmallText(canvas, "Z₀/3", (center + p3) / 2 + const Offset(5, 15));

    // --- 绘制波形 ---
    // Resistive Divider 特点：S21 = 0.5, S31 = 0.5
    // 无论从哪个口进，另外两个口各分一半电压 (Amplitude = 0.5)
    // 输入口反射 S11 = 0 (Amplitude = 0)
    
    int input = controller.inputPort;
    Color inColor = Colors.red;
    Color outColor = Colors.blue;

    if (input == 1) {
      _drawWave(canvas, p1, center, inColor, 1.0); // Input: Port1 -> Center
      _drawWave(canvas, center, p2, outColor, 0.5); // Output: Center -> Port2
      _drawWave(canvas, center, p3, outColor, 0.5); // Output: Center -> Port3
    } else if (input == 2) {
      _drawWave(canvas, p2, center, inColor, 1.0);
      _drawWave(canvas, center, p1, outColor, 0.5);
      _drawWave(canvas, center, p3, outColor, 0.5);
    } else {
      _drawWave(canvas, p3, center, inColor, 1.0);
      _drawWave(canvas, center, p1, outColor, 0.5);
      _drawWave(canvas, center, p2, outColor, 0.5);
    }

    // 绘制端口圆点
    _drawPortDot(canvas, p1, input == 1 ? Colors.red : Colors.blue);
    _drawPortDot(canvas, p2, input == 2 ? Colors.red : Colors.blue);
    _drawPortDot(canvas, p3, input == 3 ? Colors.red : Colors.blue);
    
    // 中心点
    canvas.drawCircle(center, 4.0, Paint()..style = PaintingStyle.fill);
  }

  // 辅助：画带锯齿电阻的线
  void _drawResistorArm(Canvas canvas, Paint paint, Offset pStart, Offset pEnd) {
    double totalLen = (pEnd - pStart).distance;
    double angle = (pEnd - pStart).direction;
    
    // 变换坐标系：让 pStart 为原点，X轴指向 pEnd
    canvas.save();
    canvas.translate(pStart.dx, pStart.dy);
    canvas.rotate(angle);

    Path path = Path();
    path.moveTo(0, 0);
    
    // 电阻在中间 1/3 处
    double rStart = totalLen / 3;
    double rEnd = totalLen * 2 / 3;
    double rWidth = rEnd - rStart;
    
    path.lineTo(rStart, 0);
    // 画锯齿 (简单的三角波)
    int zigs = 4;
    double zigW = rWidth / zigs;
    for (int i = 0; i < zigs; i++) {
      double x = rStart + i * zigW;
      path.lineTo(x + zigW / 4, -5);
      path.lineTo(x + zigW * 3 / 4, 5);
      path.lineTo(x + zigW, 0);
    }
    path.lineTo(totalLen, 0);

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawWave(Canvas canvas, Offset pStart, Offset pEnd, Color color, double amp) {
    if (amp < 0.05) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Path path = Path();
    double dist = (pEnd - pStart).distance;
    double angle = (pEnd - pStart).direction;
    double cosA = cos(angle);
    double sinA = sin(angle);

    // [关键修改 1]：修正波长系数
    // 之前乘以 1 导致频率过高产生混叠(Aliasing)，看起来像倒转
    // 改为 0.15 左右，波形会正常向前流动
    double k = controller.frequency * 0.15; 

    for (double t = 0; t <= dist; t += 2) {
      double phase = t * k - animationValue * 2 * pi; 
      double currentY = 6.0 * amp * sin(phase); 

      double finalX = pStart.dx + t * cosA - currentY * sinA;
      double finalY = pStart.dy + t * sinA + currentY * cosA;

      if (t == 0) path.moveTo(finalX, finalY);
      else path.lineTo(finalX, finalY);
    }
    canvas.drawPath(path, paint);

    // [关键修改 2]：自动画箭头
    // 箭头方向总是从 pStart 指向 pEnd，符合物理流动
    _drawArrow(canvas, pStart, pEnd, color);
  }

  // 新增：画箭头辅助函数
  void _drawArrow(Canvas canvas, Offset start, Offset end, Color color) {
    double angle = atan2(end.dy - start.dy, end.dx - start.dx);
    // 箭头画在靠近起点 1/4 处，避免遮挡中间的电阻
    double arrowX = start.dx + (end.dx - start.dx) * 0.25; 
    double arrowY = start.dy + (end.dy - start.dy) * 0.25;
    
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill; 

    double arrowSize = 6.0;
    
    Path path = Path();
    path.moveTo(arrowX + arrowSize * cos(angle), arrowY + arrowSize * sin(angle));
    path.lineTo(arrowX + arrowSize * cos(angle + 2.5), arrowY + arrowSize * sin(angle + 2.5));
    path.lineTo(arrowX + arrowSize * cos(angle - 2.5), arrowY + arrowSize * sin(angle - 2.5));
    path.close();
    
    canvas.drawPath(path, arrowPaint);
  }

  void _drawPortDot(Canvas canvas, Offset center, Color color) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    if (color == Colors.red) {
      canvas.drawCircle(center, 10.0, p..color = color.withOpacity(0.3));
      p.color = Colors.red;
    }
    canvas.drawCircle(center, 5.0, p);
  }

  void _drawText(Canvas canvas, String text, Offset pos, TextAlign align) {
    TextSpan span = TextSpan(style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold), text: text);
    TextPainter tp = TextPainter(text: span, textAlign: align, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawSmallText(Canvas canvas, String text, Offset pos) {
    TextSpan span = TextSpan(style: TextStyle(color: Colors.grey[800], fontSize: 10), text: text);
    TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout();
    // 加个白底，防止压线
    canvas.drawRect(Rect.fromCenter(center: pos, width: tp.width+4, height: tp.height+2), Paint()..color=Colors.white);
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant ResistiveDividerPainter oldDelegate) => true;
}
import 'dart:math' as math;
import 'dart:ui';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:polarization/polarization_globalvar.dart';
import 'package:polarization/shared/senum/senum.dart';
import 'package:polarization/polarization_symbols.dart';



class Source extends StatelessWidget {
  const Source({
    super.key,
    this.waveKey,
    this.motionKey,
    this.width,
    this.height,
    this.controller,
  });

  final Key? waveKey;
  final Key? motionKey;

  final double? width;
  final double? height;
  final SourceController? controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          SourceWave(
            key: waveKey,
            controller: controller,
          ),
          SourceMotion(
            key: motionKey,
            controller: controller,
          ),
        ],
      ),
    );
  }
}



class SourceWave extends StatefulWidget {
  const SourceWave({
    super.key,
    this.controller,
  });

  final SourceController? controller;

  @override
  State<SourceWave> createState() => _SourceWaveState();
}

class _SourceWaveState extends State<SourceWave> {

  late SourceController controller;

  @override
  void initState() {
    super.initState();

    controller = widget.controller ?? SourceController();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 400,
      child: CustomPaint(
        size: Size(400, 400),
        painter: SourceWavePainter(
          controller: controller,
        ),
      ),
    );
  }
}

class SourceWavePainter extends CustomPainter {
  const SourceWavePainter({
    required this.controller,
  });

  final SourceController controller;

  @override
  void paint(Canvas canvas, Size size) {

    // draw framework
    var paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
    ;
    canvas.drawRect(Rect.fromLTWH(10, 10, 100, 100), paint);
    canvas.drawLine(Offset(10, 60), Offset(110, 60), paint);
    canvas.drawLine(Offset(60, 10), Offset(60, 110), paint);

    canvas.drawRect(Rect.fromLTWH(120, 10, 270, 100), paint);
    canvas.drawLine(Offset(120, 60), Offset(390, 60), paint);
    canvas.drawRect(Rect.fromLTWH(10, 120, 100, 270), paint);
    canvas.drawLine(Offset(60, 120), Offset(60, 390), paint);

    // var tp = TextPainter(
    //   text: TextSpan(
    //     text: maxExy.toString(), 
    //     style: TextStyle(fontFamily: 'sans-serif', fontSize: 10, color: Colors.grey,),
    //   ), 
    //   textAlign: TextAlign.left, 
    //   textDirection: TextDirection.ltr
    // );
    // tp.layout();
    // tp.paint(canvas, Offset(0, 0));

    // tp = TextPainter(
    //   text: TextSpan(
    //     text: (-maxExy).toString(), 
    //     style: TextStyle(fontFamily: 'sans-serif', fontSize: 10, color: Colors.grey,),
    //   ), 
    //   textAlign: TextAlign.left, 
    //   textDirection: TextDirection.ltr
    // );
    // tp.layout();
    // tp.paint(canvas, Offset(110, 110));

    // draw pattern
    paint.color = Colors.indigo;
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.fill;
    
    canvas.drawPoints(PointMode.lines, pts, paint);
    canvas.drawPoints(PointMode.lines, ptsx, paint);
    canvas.drawPoints(PointMode.lines, ptsy, paint);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}



class SourceMotion extends StatefulWidget {
  const SourceMotion({
    super.key,
    this.controller,
  });

  final SourceController? controller;

  @override
  State<SourceMotion> createState() => _SourceMotionState();
}

class _SourceMotionState extends State<SourceMotion> 
  with SingleTickerProviderStateMixin {

  late SourceController controller;
  late AnimationController ac;
  late Animation<int> animation;

  late Duration lastDura;

  @override
  void initState() {
    super.initState();

    controller = widget.controller ?? SourceController();

    ac = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    animation = IntTween(begin: 0, end: maxPts-1).animate(ac);
    ac.repeat();
  }

  @override
  void dispose() {
    ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 400,
      child: CustomPaint(
        size: Size(400, 400),
        painter: SourceMotionPainter(
          controller: controller,
          animation: animation,
        ),
      ),
    );
  }
}

class SourceMotionPainter extends CustomPainter {
  const SourceMotionPainter({
    required this.controller,
    required this.animation,
  }) : super(repaint: animation);

  final SourceController controller;
  final Animation animation;

  @override
  void paint(Canvas canvas, Size size) {

    // int ptid = aniStep;
    int ptid = animation.value;

    var paint = Paint()
      ..color = Colors.amber.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
    ;
    canvas.drawLine(pts[ptid],ptsx[ptid], paint);
    canvas.drawLine(pts[ptid],ptsy[ptid], paint);

    paint.color = Colors.red;
    canvas.drawLine(Offset(60, 60), pts[ptid], paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class SourceController extends ChangeNotifier {
  void update() {
    notifyListeners();
  }
}
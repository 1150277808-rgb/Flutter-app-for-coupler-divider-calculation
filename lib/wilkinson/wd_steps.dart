import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'wd_globalvar.dart';

class WilkinsonSteps extends StatelessWidget {
  final WilkinsonController controller;

  const WilkinsonSteps({super.key, required this.controller});

  double _toDb(double mag) {
    if (mag <= 0.0001) return -40.0;
    return 20 * math.log(mag) / math.ln10;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStepTile(
          title: "Step 1: Equal Power Split (Slide 1)",
          children: [
            const Text("The classic Wilkinson Divider (Equal Split):"),
            const SizedBox(height: 5),
            _buildFormula(r'Z_{line} = \sqrt{2}Z_0'),
            _buildFormula(r'R = 2Z_0'),
            const SizedBox(height: 5),
            const Text(
              "Even-Odd Mode Analysis shows perfect matching and isolation at center frequency.",
            ),
          ],
        ),

        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            String valK2 = controller.kSquared.toStringAsFixed(2);
            String valZ03 = controller.z03.toStringAsFixed(1);
            String valZ02 = controller.z02.toStringAsFixed(1);
            String valR = controller.rIso.toStringAsFixed(1);

            return _buildStepTile(
              title: "Step 2: Unequal Division (Slide 2)",
              children: [
                const Text(
                  "For arbitrary power division ratio:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildFormula(r'K^2 = P_3 / P_2'),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.yellow.withOpacity(0.2),
                  child: Row(
                    children: [
                      const Text("Current Setting: "),
                      Math.tex(
                        "K^2 = $valK2",
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Design Equations:"),

                Row(
                  children: [
                    Expanded(
                      child: Math.tex(
                        r'Z_{03} = Z_0 \sqrt{\frac{1+K^2}{K^3}}',
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const Text(" = "),
                    Text(
                      "$valZ03 Ω",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: Math.tex(
                        r'Z_{02} = Z_0 \sqrt{K(1+K^2)}',
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const Text(" = "),
                    Text(
                      "$valZ02 Ω",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: Math.tex(
                        r'R = Z_0 (K + \frac{1}{K})',
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const Text(" = "),
                    Text(
                      "$valR Ω",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: Math.tex(
                        r'R_2 = Z_0 K',
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const Text(" = "),
                    Text(
                      "${controller.r2.toStringAsFixed(1)} Ω",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: Math.tex(
                        r'R_3 = Z_0 / K',
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const Text(" = "),
                    Text(
                      "${controller.r3.toStringAsFixed(1)} Ω",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),

        _buildStepTile(
          title: "Step 3: S-Matrix Formulation",
          children: [
            const Text("For the ideal symmetric case:"),
            Center(
              child: Math.tex(
                r'[S] = \frac{-j}{\sqrt{2}} \begin{bmatrix} 0 & 1 & 1 \\ 1 & 0 & 0 \\ 1 & 0 & 0 \end{bmatrix}',
                textStyle: const TextStyle(fontSize: 15),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "For unequal split, S21 ≠ S31, but Isolation (S23) remains 0 at design frequency.",
            ),
          ],
        ),

        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final sample = controller.sampleAt(controller.frequency);

            final s11dB = _toDb(sample.s11);
            final s21dB = _toDb(sample.s21);
            final s31dB = _toDb(sample.s31);
            final s23dB = _toDb(sample.s23);

            return _buildStepTile(
              title: "Step 4: Frequency-Dependent S(f) + Plot",
              children: [
                const Text(
                  "To include frequency response, define the electrical length of each quarter-wave branch as:",
                ),
                _buildFormula(r'\theta(f) = \frac{\pi}{2}\frac{f}{f_0}'),
                const SizedBox(height: 6),

                const Text(
                  "Using a simple educational frequency-response model, the S-parameters are written as:",
                ),
                _buildFormula(
                  r'S_{21}(f) = -j\sqrt{\frac{1}{1+K^2}}\sin(\theta(f))',
                ),
                _buildFormula(
                  r'S_{31}(f) = -j\sqrt{\frac{K^2}{1+K^2}}\sin(\theta(f))',
                ),
                _buildFormula(r'S_{11}(f) = \cos(\theta(f))'),
                _buildFormula(r'S_{23}(f) = \cos(\theta(f))'),

                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Text(
                        "Current f = ${controller.frequency.toStringAsFixed(2)} GHz",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "f/f₀ = ${(controller.frequency / controller.designFreq).toStringAsFixed(3)}",
                      ),
                      Text("θ = ${sample.theta.toStringAsFixed(3)} rad"),
                      Text("K² = ${controller.kSquared.toStringAsFixed(2)}"),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                const Text(
                  "Current-frequency result (magnitude in dB):",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildValueChip("S11", s11dB, Colors.red),
                    _buildValueChip("S21", s21dB, Colors.blue),
                    _buildValueChip("S31", s31dB, Colors.purple),
                    _buildValueChip("S23", s23dB, Colors.green),
                  ],
                ),

                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE6E6E6)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 260,
                        child: _WdSParameterPlot(controller: controller),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 14,
                        runSpacing: 8,
                        children: const [
                          _PlotLegendItem(color: Colors.red, text: "S11"),
                          _PlotLegendItem(color: Colors.blue, text: "S21"),
                          _PlotLegendItem(color: Colors.purple, text: "S31"),
                          _PlotLegendItem(color: Colors.green, text: "S23"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            double s11dB = _toDb(controller.s11);
            double s21dB = _toDb(controller.s21);
            double s31dB = _toDb(controller.s31);
            double s23dB = _toDb(controller.s23);

            return ExpansionTile(
              title: const Text(
                "Step 5: Simulation Results",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              initiallyExpanded: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResultRow("S11 (Refl)", s11dB, controller.s11, Colors.red),
                      _buildResultRow("S21 (Port 2)", s21dB, controller.s21, Colors.blue),
                      _buildResultRow("S31 (Port 3)", s31dB, controller.s31, Colors.purple),
                      _buildResultRow("S23 (Iso)", s23dB, controller.s23, Colors.green),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFormula(String tex) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.centerLeft,
      child: Math.tex(tex, textStyle: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildStepTile({required String title, required List<Widget> children}) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
        splashColor: Colors.blue.withOpacity(0.1),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        textColor: Colors.black87,
        iconColor: Colors.indigo,
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.grey.withOpacity(0.02),
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
        collapsedShape: const Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildResultRow(String label, double dbVal, double linVal, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text(
                "${dbVal.toStringAsFixed(1)} dB",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          LinearProgressIndicator(
            value: linVal.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 4,
          )
        ],
      ),
    );
  }

  Widget _buildValueChip(String name, double db, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        "$name = ${db.toStringAsFixed(1)} dB",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
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

  _WdSParameterPlotPainter({
    required this.samples,
    required this.currentFrequency,
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

    const minF = 1.0;
    const maxF = 5.0;
    const minDb = -40.0;
    const maxDb = 0.0;

    double xOf(double f) => plot.left + (f - minF) / (maxF - minF) * plot.width;
    double yOf(double db) => plot.bottom - (db - minDb) / (maxDb - minDb) * plot.height;

    for (double db = -40; db <= 0; db += 10) {
      final y = yOf(db);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      _paintText(
        canvas,
        "${db.toInt()} dB",
        Offset(4, y - 7),
        const TextStyle(fontSize: 10, color: Colors.black54),
      );
    }

    for (double f = 1; f <= 5; f += 1) {
      final x = xOf(f);
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), gridPaint);
      _paintText(
        canvas,
        "${f.toInt()}",
        Offset(x - 6, plot.bottom + 6),
        const TextStyle(fontSize: 10, color: Colors.black54),
      );
    }

    canvas.drawLine(Offset(plot.left, plot.top), Offset(plot.left, plot.bottom), axisPaint);
    canvas.drawLine(Offset(plot.left, plot.bottom), Offset(plot.right, plot.bottom), axisPaint);

    _paintText(
      canvas,
      "Freq (GHz)",
      Offset(plot.center.dx - 24, size.height - 18),
      const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500),
    );

    _drawCurve(
      canvas,
      plot,
      samples,
      (s) => _toDb(s.s11),
      Colors.red,
      xOf,
      yOf,
    );
    _drawCurve(
      canvas,
      plot,
      samples,
      (s) => _toDb(s.s21),
      Colors.blue,
      xOf,
      yOf,
    );
    _drawCurve(
      canvas,
      plot,
      samples,
      (s) => _toDb(s.s31),
      Colors.purple,
      xOf,
      yOf,
    );
    _drawCurve(
      canvas,
      plot,
      samples,
      (s) => _toDb(s.s23),
      Colors.green,
      xOf,
      yOf,
    );

    final currentX = xOf(currentFrequency);
    final dashPaint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 1;

    for (double y = plot.top; y < plot.bottom; y += 6) {
      canvas.drawLine(
        Offset(currentX, y),
        Offset(currentX, math.min(y + 3, plot.bottom)),
        dashPaint,
      );
    }

    final cur = samples.reduce(
      (a, b) => (a.frequency - currentFrequency).abs() < (b.frequency - currentFrequency).abs() ? a : b,
    );

    _drawMarker(canvas, Offset(currentX, yOf(_toDb(cur.s11))), Colors.red);
    _drawMarker(canvas, Offset(currentX, yOf(_toDb(cur.s21))), Colors.blue);
    _drawMarker(canvas, Offset(currentX, yOf(_toDb(cur.s31))), Colors.purple);
    _drawMarker(canvas, Offset(currentX, yOf(_toDb(cur.s23))), Colors.green);
  }

  void _drawCurve(
    Canvas canvas,
    Rect plot,
    List<WdSample> data,
    double Function(WdSample) valueOf,
    Color color,
    double Function(double) xOf,
    double Function(double) yOf,
  ) {
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
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _WdSParameterPlotPainter oldDelegate) {
    return oldDelegate.currentFrequency != currentFrequency ||
        oldDelegate.samples != samples;
  }
}

class _PlotLegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _PlotLegendItem({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
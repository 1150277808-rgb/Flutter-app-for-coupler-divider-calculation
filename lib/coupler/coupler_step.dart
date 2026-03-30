import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math' as math;
import 'coupler_globalvar.dart';

class PolarizationSteps extends StatelessWidget {
  final SourceController controller;

  const PolarizationSteps({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double rad = controller.theta_deg * math.pi / 180.0;
        final double c = math.cos(rad);
        final double s = math.sin(rad);
        final double sq2 = math.sqrt(2);

        final String freq = controller.freqGHz.toStringAsFixed(2);
        final String thetaStr = controller.theta_deg.toStringAsFixed(1);

        final String aeReal = _fmt(c);
        final String beImag = _fmt(sq2 * s);
        final String ceImag = _fmt((c + s) / sq2);
        final String deReal = _fmt(c - s);

        final String aoReal = _fmt(c);
        final String boImag = _fmt(sq2 * s);
        final String coImag = _fmt((s - c) / sq2);
        final String doReal = _fmt(c + s);

        final active = controller.activeInputPorts.isEmpty
            ? "None"
            : controller.activeInputPorts.map((e) => "Port $e").join(", ");

        return Column(
          children: [
            _buildHeader(),
            _buildSParameterPlot(controller),

            _buildMathCard(
              title: "Step 1: Even-Mode Analysis",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "For the even mode (O.C. bisection), multiplying the stub matrix by the line matrix gives:",
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(
                      r'\begin{bmatrix} A & B \\ C & D \end{bmatrix}_e = \begin{bmatrix} 1 & 0 \\ j \frac{1}{\sqrt{2}} & 1 \end{bmatrix} \begin{bmatrix} \cos\theta & j\sqrt{2}\sin\theta \\ j \frac{1}{\sqrt{2}} \sin\theta & \cos\theta \end{bmatrix} = \begin{bmatrix} \cos\theta & j\sqrt{2}\sin\theta \\ j \frac{\cos\theta+\sin\theta}{\sqrt{2}} & \cos\theta-\sin\theta \end{bmatrix}',
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text("At \(f = $freq\\,\\text{GHz}\) (\u03B8 = $thetaStr°), the numerical values are:"),
                  const SizedBox(height: 8),
                  Center(
                    child: Math.tex(
                      r'[M]_e \approx \begin{bmatrix} ' +
                          aeReal +
                          r' & j' +
                          beImag +
                          r' \\ j' +
                          ceImag +
                          r' & ' +
                          deReal +
                          r' \end{bmatrix}',
                      textStyle: const TextStyle(fontSize: 17, color: Colors.indigo),
                    ),
                  ),
                ],
              ),
            ),

            _buildMathCard(
              title: "Step 2: Odd-Mode Analysis",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "For the odd mode (S.C. bisection), the stub admittance is negative:",
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(
                      r'\begin{bmatrix} A & B \\ C & D \end{bmatrix}_o = \begin{bmatrix} 1 & 0 \\ -j \frac{1}{\sqrt{2}} & 1 \end{bmatrix} \begin{bmatrix} \cos\theta & j\sqrt{2}\sin\theta \\ j \frac{1}{\sqrt{2}} \sin\theta & \cos\theta \end{bmatrix} = \begin{bmatrix} \cos\theta & j\sqrt{2}\sin\theta \\ j \frac{\sin\theta-\cos\theta}{\sqrt{2}} & \cos\theta+\sin\theta \end{bmatrix}',
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text("Substituting values for \u03B8 = $thetaStr°:"),
                  const SizedBox(height: 8),
                  Center(
                    child: Math.tex(
                      r'[M]_o \approx \begin{bmatrix} ' +
                          aoReal +
                          r' & j' +
                          boImag +
                          r' \\ j' +
                          coImag +
                          r' & ' +
                          doReal +
                          r' \end{bmatrix}',
                      textStyle: const TextStyle(fontSize: 17, color: Colors.indigo),
                    ),
                  ),
                ],
              ),
            ),

            _buildMathCard(
              title: "Step 3: Final S-Matrix",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "The ideal Scattering Matrix [S] for a Hybrid Ring is:",
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Math.tex(
                      r'[S] = \frac{-j}{\sqrt{2}} \begin{bmatrix} 0 & 1 & 1 & 0 \\ 1 & 0 & 0 & -1 \\ 1 & 0 & 0 & 1 \\ 0 & -1 & 1 & 0 \end{bmatrix}',
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    "For the generalized multi-input case:",
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Math.tex(
                      r'\mathbf{b} = \mathbf{S}\mathbf{a}, \qquad a_i = A_i e^{j\phi_i}',
                      textStyle: const TextStyle(fontSize: 18, color: Colors.teal),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.touch_app, size: 20, color: Colors.amber),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Calculation Status:\nActive inputs: $active",
                            style: TextStyle(fontSize: 13, color: Colors.brown[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    "S-Parameters at Current Frequency (Port 1 excitation):",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildStandardSParameters(controller),
                ],
              ),
            ),

            _buildMathCard(
              title: "Step 4: Current Excitations and Results",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Input vector settings:"),
                  const SizedBox(height: 10),
                  _buildInputRow(1),
                  _buildInputRow(2),
                  _buildInputRow(3),
                  _buildInputRow(4),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text("Computed outgoing waves:"),
                  const SizedBox(height: 10),
                  _buildOutputRow(1),
                  _buildOutputRow(2),
                  _buildOutputRow(3),
                  _buildOutputRow(4),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueGrey.shade100),
                    ),
                    child: Wrap(
                      spacing: 18,
                      runSpacing: 8,
                      children: [
                        Text("Total Pin = ${controller.totalInputPower.toStringAsFixed(4)}"),
                        Text("Total Pout = ${controller.totalOutputPower.toStringAsFixed(4)}"),
                        Text("ΔP = ${controller.powerBalanceError.toStringAsFixed(6)}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        );
      },
    );
  }

  String _fmt(double val) {
    if (val.abs() < 0.0001) return "0.000";
    return val.toStringAsFixed(3);
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: const Text(
        "Calculation Steps (Even-Odd Mode Analysis)",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMathCard({required String title, required Widget content}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(int port) {
    final enabled = controller.isPortExcited(port);
    final amp = controller.getInputAmplitude(port);
    final phase = controller.getInputPhaseDeg(port);
    final power = controller.getInputPower(port);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              "a$port",
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              enabled
                  ? "enabled,  A = ${amp.toStringAsFixed(3)},  φ = ${phase.toStringAsFixed(1)}°,  P = ${power.toStringAsFixed(3)}"
                  : "disabled",
              style: TextStyle(
                fontFamily: "monospace",
                color: enabled ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputRow(int port) {
    final mag = controller.getOutputAmplitude(port);
    final phase = controller.getOutputPhaseDeg(port);
    final power = controller.getOutputPower(port);

    final bool nearZero = mag < 0.05;
    final bool strong = mag > 0.65 && mag < 0.75;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              "b$port",
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "|b$port| = ${mag.toStringAsFixed(4)},  ∠b$port = ${phase.toStringAsFixed(1)}°,  P = ${power.toStringAsFixed(4)}",
            style: TextStyle(
              fontFamily: "monospace",
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: nearZero ? Colors.grey : Colors.black,
            ),
          ),
          if (nearZero)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "Near Zero",
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
          if (strong)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "≈ -3 dB",
                style: TextStyle(fontSize: 11, color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStandardSParameters(SourceController controller) {
    final oldFreq = controller.freqGHz;
    final oldExcitations = controller.excitations.map((e) => [e.enabled, e.amplitude, e.phaseDeg]).toList();

    for (int i = 0; i < 4; i++) {
      controller.excitations[i].enabled = (i == 0);
      controller.excitations[i].amplitude = (i == 0) ? 1.0 : 0.0;
      controller.excitations[i].phaseDeg = 0.0;
    }
    controller.calculateAll();

    final s11Mag = controller.b1.magnitude;
    final s21Mag = controller.b2.magnitude;
    final s31Mag = controller.b3.magnitude;
    final s41Mag = controller.b4.magnitude;

    final s11Phase = controller.getOutputPhaseDeg(1);
    final s21Phase = controller.getOutputPhaseDeg(2);
    final s31Phase = controller.getOutputPhaseDeg(3);
    final s41Phase = controller.getOutputPhaseDeg(4);

    final s11dB = 20 * math.log(s11Mag.clamp(1e-6, 1.0)) / math.ln10;
    final s21dB = 20 * math.log(s21Mag.clamp(1e-6, 1.0)) / math.ln10;
    final s31dB = 20 * math.log(s31Mag.clamp(1e-6, 1.0)) / math.ln10;
    final s41dB = 20 * math.log(s41Mag.clamp(1e-6, 1.0)) / math.ln10;

    controller.freqGHz = oldFreq;
    for (int i = 0; i < 4; i++) {
      controller.excitations[i].enabled = oldExcitations[i][0] as bool;
      controller.excitations[i].amplitude = oldExcitations[i][1] as double;
      controller.excitations[i].phaseDeg = oldExcitations[i][2] as double;
    }
    controller.calculateAll();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Frequency: ${oldFreq.toStringAsFixed(2)} GHz", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text("S₁₁ = ${s11Mag.toStringAsFixed(4)} ∠ ${s11Phase.toStringAsFixed(1)}° = ${s11dB.toStringAsFixed(2)} dB", style: const TextStyle(fontSize: 11)),
          Text("S₂₁ = ${s21Mag.toStringAsFixed(4)} ∠ ${s21Phase.toStringAsFixed(1)}° = ${s21dB.toStringAsFixed(2)} dB", style: const TextStyle(fontSize: 11)),
          Text("S₃₁ = ${s31Mag.toStringAsFixed(4)} ∠ ${s31Phase.toStringAsFixed(1)}° = ${s31dB.toStringAsFixed(2)} dB", style: const TextStyle(fontSize: 11)),
          Text("S₄₁ = ${s41Mag.toStringAsFixed(4)} ∠ ${s41Phase.toStringAsFixed(1)}° = ${s41dB.toStringAsFixed(2)} dB", style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSParameterPlot(SourceController controller) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("S-Parameters vs Frequency", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("Current frequency: ${controller.freqGHz.toStringAsFixed(2)} GHz", style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            const Wrap(spacing: 14, children: [
              _LegendDot(color: Colors.red, text: "S11"),
              _LegendDot(color: Colors.blue, text: "S21"),
              _LegendDot(color: Colors.purple, text: "S31"),
              _LegendDot(color: Colors.green, text: "S41"),
            ]),
            const SizedBox(height: 8),
            const Text("Note: When curves overlap, only one line may be visible.", style: TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            SizedBox(height: 300, width: double.infinity, child: CustomPaint(painter: _CouplerPlotPainter(controller: controller))),
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

class _CouplerPlotPainter extends CustomPainter {
  final SourceController controller;
  _CouplerPlotPainter({required this.controller});

  @override
  void paint(Canvas canvas, Size size) {
    final freqs = controller.sweepFreqGHz;
    final s11 = controller.sweepS11dB();
    final s21 = controller.sweepS21dB();
    final s31 = controller.sweepS31dB();
    final s41 = controller.sweepS41dB();

    // Wilkinson样式：背景和边框
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

    const left = 42.0, right = 14.0, top = 16.0, bottom = 28.0;
    final plot = Rect.fromLTWH(left, top, size.width - left - right, size.height - top - bottom);

    final xMin = freqs.first, xMax = freqs.last;
    final allVals = [...s11, ...s21, ...s31, ...s41];
    final yMin = (allVals.reduce((a, b) => a < b ? a : b) / 10).floor() * 10.0;
    final yMax = 0.0;

    final gridPaint = Paint()
      ..color = const Color(0xFFEAEAEA)
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 1.2;

    double xOf(double f) => plot.left + (f - xMin) / (xMax - xMin) * plot.width;
    double yOf(double db) => plot.bottom - (db - yMin) / (yMax - yMin) * plot.height;

    for (double db = yMin; db <= yMax; db += 10) {
      final y = yOf(db);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      _paintText(canvas, "${db.toInt()} dB", Offset(4, y - 7), const TextStyle(fontSize: 10, color: Colors.black54));
    }

    for (int i = 0; i <= 4; i++) {
      final f = xMin + (xMax - xMin) * i / 4;
      final x = xOf(f);
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), gridPaint);
      _paintText(canvas, f.toStringAsFixed(1), Offset(x - 10, plot.bottom + 6), const TextStyle(fontSize: 10, color: Colors.black54));
    }

    canvas.drawLine(Offset(plot.left, plot.top), Offset(plot.left, plot.bottom), axisPaint);
    canvas.drawLine(Offset(plot.left, plot.bottom), Offset(plot.right, plot.bottom), axisPaint);

    _paintText(canvas, "Freq (GHz)", Offset(plot.center.dx - 24, size.height - 18), const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500));

    _drawCurve(canvas, freqs, s11, xOf, yOf, Colors.red);
    _drawCurve(canvas, freqs, s21, xOf, yOf, Colors.blue);
    _drawCurve(canvas, freqs, s31, xOf, yOf, Colors.purple);
    _drawCurve(canvas, freqs, s41, xOf, yOf, Colors.green);
  }

  void _drawCurve(Canvas canvas, List<double> xs, List<double> ys, Function xOf, Function yOf, Color color) {
    final path = Path();
    for (int i = 0; i < xs.length; i++) {
      final x = xOf(xs[i]);
      final y = yOf(ys[i]);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, Paint()..color = color..strokeWidth = 2.2..style = PaintingStyle.stroke);
  }

  void _paintText(Canvas canvas, String text, Offset pos, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

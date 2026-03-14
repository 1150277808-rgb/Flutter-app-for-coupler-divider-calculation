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
                            "Simulation Status:\nActive inputs: $active",
                            style: TextStyle(fontSize: 13, color: Colors.brown[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
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
}
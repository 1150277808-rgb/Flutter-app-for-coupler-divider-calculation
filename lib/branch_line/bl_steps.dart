import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'bl_globalvar.dart';

class BranchLineSteps extends StatelessWidget {
  final BranchLineController controller;

  const BranchLineSteps({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final bool offCenter =
            (controller.freqGHz - controller.centerFreq).abs() > 0.05;

        final double s11dB = _db20(controller.s1_mag);
        final double s21dB = _db20(controller.s2_mag);
        final double s31dB = _db20(controller.s3_mag);
        final double s41dB = _db20(controller.s4_mag);

        final double thetaDeg = _radToDeg(controller.theta);

        return Column(
          children: [
            _buildHeader(),

            _buildMathCard(
              title: "Step 1: Even Mode (Theory @ f = f₀)",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Assumption: frequency is exactly at the center frequency, so each branch has electrical length λ/4 (90°).",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Equivalent circuit: λ/4 line (Y₀/k) with open stubs (jY₀).",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text("The even-mode ABCD matrix is:"),
                  _buildLeftMath(
                    r'\begin{bmatrix} C_{11} & C_{12} \\ C_{21} & C_{22} \end{bmatrix}_e='
                    r'\begin{bmatrix} 1 & 0 \\ jY_0 & 1 \end{bmatrix}'
                    r'\begin{bmatrix} 0 & jZ_0/k \\ jkY_0 & 0 \end{bmatrix}'
                    r'\begin{bmatrix} 1 & 0 \\ jY_0 & 1 \end{bmatrix}'
                    r'=\frac{1}{k}\begin{bmatrix} -1 & jZ_0 \\ jY_0(k^2-1) & -1 \end{bmatrix}',
                  ),
                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'\Gamma_e='
                    r'\frac{Z_0 C_{11}+C_{12}-Z_0^2 C_{21}-Z_0 C_{22}}{Z_0 C_{11}+C_{12}+Z_0^2 C_{21}+Z_0 C_{22}}',
                  ),
                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'\Gamma_e=0 \Rightarrow -jkZ_0+j\frac{2Z_0}{k}=0 \Rightarrow k=\sqrt{2}',
                  ),
                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'\tau_e=\frac{1}{\sqrt{2}}(-1-j)',
                  ),
                ],
              ),
            ),

            _buildMathCard(
              title: "Step 2: Odd Mode (Theory @ f = f₀)",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Assumption: line length remains λ/4, while the stubs become shorted in odd-mode analysis.",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("The odd-mode ABCD matrix is:"),
                  _buildLeftMath(
                    r'\begin{bmatrix} C_{11} & C_{12} \\ C_{21} & C_{22} \end{bmatrix}_o='
                    r'\begin{bmatrix} 1 & 0 \\ -jY_0 & 1 \end{bmatrix}'
                    r'\begin{bmatrix} 0 & jZ_0/k \\ jkY_0 & 0 \end{bmatrix}'
                    r'\begin{bmatrix} 1 & 0 \\ -jY_0 & 1 \end{bmatrix}'
                    r'=\frac{1}{k}\begin{bmatrix} 1 & jZ_0 \\ jY_0(k^2-1) & 1 \end{bmatrix}',
                  ),
                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'\Gamma_o='
                    r'\frac{Z_0 C_{11}+C_{12}-Z_0^2 C_{21}-Z_0 C_{22}}{Z_0 C_{11}+C_{12}+Z_0^2 C_{21}+Z_0 C_{22}}',
                  ),
                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'\Gamma_o=0 \Rightarrow -jkZ_0+j\frac{2Z_0}{k}=0 \Rightarrow k=\sqrt{2}',
                  ),
                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'\tau_o=\frac{1}{\sqrt{2}}(1-j)',
                  ),
                ],
              ),
            ),

            _buildMathCard(
              title: "Step 3: Ideal S-Matrix and Frequency-Dependent Extension",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "At the center frequency, superposition gives the ideal quadrature-hybrid response:",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _buildLeftMath(r'S_{11}(f_0)=0'),
                  _buildLeftMath(r'S_{21}(f_0)=\frac{-j}{\sqrt{2}}'),
                  _buildLeftMath(r'S_{31}(f_0)=\frac{-1}{\sqrt{2}}'),
                  _buildLeftMath(r'S_{41}(f_0)=0'),
                  const SizedBox(height: 8),
                  Center(
                    child: Math.tex(
                      r'[S](f_0)=\frac{-1}{\sqrt{2}}'
                      r'\begin{bmatrix}'
                      r'0 & j & 1 & 0 \\'
                      r'j & 0 & 0 & 1 \\'
                      r'1 & 0 & 0 & j \\'
                      r'0 & 1 & j & 0'
                      r'\end{bmatrix}',
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const Divider(height: 24),
                  const Text(
                    "For the app simulation away from f₀, the response is made frequency-dependent through the electrical length:",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _buildLeftMath(r'\theta(f)=\frac{\pi}{2}\frac{f}{f_0}'),
                  _buildFormulaWithValue(
                    r'\theta',
                    '${controller.theta.toStringAsFixed(4)} rad (${thetaDeg.toStringAsFixed(2)}°)',
                    Colors.indigo,
                  ),
                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'P_{\mathrm{tx}}(f)=\cos^2\!\left(\theta-\frac{\pi}{2}\right)',
                  ),
                  _buildLeftMath(
                    r'P_{\mathrm{rem}}(f)=1-P_{\mathrm{tx}}(f)',
                  ),
                  _buildLeftMath(
                    r'|S_{21}(f)|=|S_{31}(f)|=\sqrt{\frac{P_{\mathrm{tx}}(f)}{2}}',
                  ),
                  _buildLeftMath(
                    r'|S_{11}(f)|=|S_{41}(f)|=\sqrt{\frac{P_{\mathrm{rem}}(f)}{2}}',
                  ),
                  const SizedBox(height: 8),
                  _buildLeftMath(r'\angle S_{21}(f)=-\theta(f)'),
                  _buildLeftMath(r'\angle S_{31}(f)=-\theta(f)-\frac{\pi}{2}'),
                  _buildLeftMath(r'\angle S_{11}(f)=\pi-2\theta(f)'),
                  _buildLeftMath(r'\angle S_{41}(f)=-2\theta(f)'),
                  if (offCenter) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Current frequency is away from the center frequency, so the branch lines are no longer exactly λ/4. Therefore the ideal cancellation in the design-point S-matrix does not hold exactly.",
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            _buildMathCard(
              title: "Step 4: Actual Simulation (Current f)",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Input: Port ${controller.inputPort} @ ${controller.freqGHz.toStringAsFixed(3)} GHz",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                        if (offCenter)
                          const Tooltip(
                            message: "Off-center frequency changes the electrical length and S-parameters.",
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Electrical length: θ = ${controller.theta.toStringAsFixed(4)} rad (${thetaDeg.toStringAsFixed(2)}°)',
                  ),
                  const SizedBox(height: 10),
                  _buildResultRow(
                    "Through |S21|",
                    controller.s2_mag,
                    s21dB,
                    Colors.blue,
                    phaseDeg: _radToDeg(controller.s2_phase),
                  ),
                  _buildResultRow(
                    "Coupled |S31|",
                    controller.s3_mag,
                    s31dB,
                    Colors.blue,
                    phaseDeg: _radToDeg(controller.s3_phase),
                  ),
                  _buildResultRow(
                    "Isolated |S41|",
                    controller.s4_mag,
                    s41dB,
                    Colors.grey,
                    phaseDeg: _radToDeg(controller.s4_phase),
                  ),
                  _buildResultRow(
                    "Reflection |S11|",
                    controller.s1_mag,
                    s11dB,
                    Colors.red,
                    phaseDeg: _radToDeg(controller.s1_phase),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "These displayed values are now frequency-dependent, and the wave animation uses the same magnitudes and phases.",
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeftMath(String tex) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Math.tex(
            tex,
            textStyle: const TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.indigo[50],
      child: const Column(
        children: [
          Text(
            "Theoretical Derivation vs. Frequency-Dependent Simulation",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            "Steps 1-2 summarize the design-point derivation at the center frequency. Steps 3-4 show the frequency-dependent S-parameter model used by the app and the current calculated response.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMathCard({
    required String title,
    required Widget content,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
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

  Widget _buildFormulaWithValue(String tex, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                tex,
                textStyle: const TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text("="),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    double linearVal,
    double dbVal,
    Color color, {
    double? phaseDeg,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                linearVal.toStringAsFixed(4),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${dbVal.toStringAsFixed(2)} dB',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (phaseDeg != null) ...[
                const SizedBox(width: 10),
                Text(
                  '${phaseDeg.toStringAsFixed(1)}°',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: linearVal.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: Colors.grey.shade200,
            color: color,
          ),
        ],
      ),
    );
  }

  double _db20(double x) {
    if (x <= 1e-6) return -120.0;
    return 20.0 * log(x) / ln10;
  }

  double _radToDeg(double rad) => rad * 180.0 / pi;
}
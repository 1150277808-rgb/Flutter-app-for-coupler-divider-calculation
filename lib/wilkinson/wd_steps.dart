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

  String _formatVal(double val) {
    if (val.abs() < 0.001 && val.abs() > 1e-12) {
      final exp = (math.log(val.abs()) / math.ln10).floor();
      final mantissa = val.abs() / math.pow(10, exp);
      return '${mantissa.toStringAsFixed(3)} \\times 10^{$exp}';
    }
    if (val.abs() <= 1e-12) return '0';
    return val.toStringAsFixed(4);
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
              title: "Step 4: Frequency-Dependent S(f)",
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
                  "Detailed Calculation Steps:",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Step 1: Substitute frequency into S-parameters to get complex values:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Math.tex('S_{11}(f) = \\cos(\\theta) = \\cos(${sample.theta.toStringAsFixed(3)}) = ${_formatVal(sample.s11)}', textStyle: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Math.tex('S_{21}(f) = \\sqrt{\\frac{1}{1+K^2}} \\sin(\\theta) = \\sqrt{\\frac{1}{${(1+controller.kSquared).toStringAsFixed(2)}}} \\times ${_formatVal(math.sin(sample.theta))} = ${_formatVal(sample.s21)}', textStyle: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Math.tex('S_{31}(f) = \\sqrt{\\frac{K^2}{1+K^2}} \\sin(\\theta) = \\sqrt{\\frac{${controller.kSquared.toStringAsFixed(2)}}{${(1+controller.kSquared).toStringAsFixed(2)}}} \\times ${_formatVal(math.sin(sample.theta))} = ${_formatVal(sample.s31)}', textStyle: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Math.tex('S_{23}(f) = \\cos(\\theta) = ${_formatVal(sample.s23)}', textStyle: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 10),
                      const Text("Step 2: Convert magnitude to dB using 20×log₁₀(|S|):", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Math.tex('S_{11} = 20 \\times \\log_{10}(${_formatVal(sample.s11)}) = ${s11dB.toStringAsFixed(2)}\\,\\text{dB}', textStyle: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Math.tex('S_{21} = 20 \\times \\log_{10}(${_formatVal(sample.s21)}) = ${s21dB.toStringAsFixed(2)}\\,\\text{dB}', textStyle: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Math.tex('S_{31} = 20 \\times \\log_{10}(${_formatVal(sample.s31)}) = ${s31dB.toStringAsFixed(2)}\\,\\text{dB}', textStyle: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Math.tex('S_{23} = 20 \\times \\log_{10}(${_formatVal(sample.s23)}) = ${s23dB.toStringAsFixed(2)}\\,\\text{dB}', textStyle: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Final S-parameters (dB):",
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
                "Step 5: Final Results",
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
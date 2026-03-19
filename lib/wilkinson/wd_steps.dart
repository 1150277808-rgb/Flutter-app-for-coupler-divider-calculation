import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math' as math;
import 'wd_globalvar.dart';

class WilkinsonSteps extends StatelessWidget {
  final WilkinsonController controller;

  const WilkinsonSteps({super.key, required this.controller});

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
            final valK2 = controller.kSquared.toStringAsFixed(2);
            final valZ03 = controller.z03.toStringAsFixed(1);
            final valZ02 = controller.z02.toStringAsFixed(1);
            final valR = controller.rIso.toStringAsFixed(1);

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
            final k2 = controller.kSquared <= 0 ? 1.0 : controller.kSquared;
            final k = math.sqrt(k2);

            final s11 = _limit01(controller.s11);
            final s21 = _limit01(controller.s21);
            final s31 = _limit01(controller.s31);
            final s23 = _limit01(controller.s23);

            final s11dB = _toDb(s11);
            final s21dB = _toDb(s21);
            final s31dB = _toDb(s31);
            final s23dB = _toDb(s23);

            final idealS21 = 1 / math.sqrt(1 + k2);
            final idealS31 = k / math.sqrt(1 + k2);

            final powerSum = s21 * s21 + s31 * s31;

            return _buildStepTile(
              title: "Step 4: Detailed Calculation of Current Results",
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Current controller values are converted into the displayed simulation results below.",
                    style: TextStyle(
                      color: Colors.indigo[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                const Text(
                  "1) Convert the division setting",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildFormula(
                  'K = \\sqrt{K^2} = \\sqrt{${controller.kSquared.toStringAsFixed(4)}} = ${k.toStringAsFixed(4)}',
                ),

                const SizedBox(height: 8),
                const Text(
                  "2) Ideal target transmission magnitudes",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildFormula(
                  r'|S_{21}|_{ideal} = \frac{1}{\sqrt{1+K^2}}'
                  ' = ${idealS21.toStringAsFixed(4)}',
                ),
                _buildFormula(
                  r'|S_{31}|_{ideal} = \frac{K}{\sqrt{1+K^2}}'
                  ' = ${idealS31.toStringAsFixed(4)}',
                ),
                const SizedBox(height: 4),
                Text(
                  "So ideally, Port 2 and Port 3 amplitudes are set by the chosen unequal split ratio.",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),

                const SizedBox(height: 12),
                const Text(
                  "3) Convert current linear magnitudes to dB",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildFormula(
                  r'S_{11}(dB)=20\log_{10}|S_{11}|'
                  ' = 20\\log_{10}(${s11.toStringAsFixed(4)})'
                  ' = ${s11dB.toStringAsFixed(2)}\\,dB',
                ),
                _buildFormula(
                  r'S_{21}(dB)=20\log_{10}|S_{21}|'
                  ' = 20\\log_{10}(${s21.toStringAsFixed(4)})'
                  ' = ${s21dB.toStringAsFixed(2)}\\,dB',
                ),
                _buildFormula(
                  r'S_{31}(dB)=20\log_{10}|S_{31}|'
                  ' = 20\\log_{10}(${s31.toStringAsFixed(4)})'
                  ' = ${s31dB.toStringAsFixed(2)}\\,dB',
                ),
                _buildFormula(
                  r'S_{23}(dB)=20\log_{10}|S_{23}|'
                  ' = 20\\log_{10}(${s23.toStringAsFixed(4)})'
                  ' = ${s23dB.toStringAsFixed(2)}\\,dB',
                ),

                const SizedBox(height: 12),
                const Text(
                  "4) Power check",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildFormula(
                  r'|S_{21}|^2 + |S_{31}|^2'
                  ' = (${s21.toStringAsFixed(4)})^2 + (${s31.toStringAsFixed(4)})^2'
                  ' = ${powerSum.toStringAsFixed(4)}',
                ),
                Text(
                  "If matching/isolation are close to ideal, this value should be close to 1.",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),

                const SizedBox(height: 12),
                const Text(
                  "5) Final displayed simulation results",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),

                _buildResultRow("S11 (Refl)", s11dB, s11, Colors.red),
                _buildResultRow("S21 (Port 2)", s21dB, s21, Colors.blue),
                _buildResultRow("S31 (Port 3)", s31dB, s31, Colors.blue),
                _buildResultRow("S23 (Iso)", s23dB, s23, Colors.green),
              ],
            );
          },
        ),
      ],
    );
  }

  double _limit01(double x) {
    if (x < 0) return 0;
    if (x > 1) return 1;
    return x;
  }

  double _toDb(double v) {
    if (v <= 0.001) return -60;
    return 20 * math.log(v) / math.ln10;
  }

  Widget _buildFormula(String tex) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Math.tex(tex, textStyle: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildStepTile({
    required String title,
    required List<Widget> children,
  }) {
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
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    double dbVal,
    double linVal,
    Color color,
  ) {
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
          ),
        ],
      ),
    );
  }
}
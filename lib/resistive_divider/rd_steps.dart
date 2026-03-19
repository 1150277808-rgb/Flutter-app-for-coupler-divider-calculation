import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'rd_globalvar.dart';
import 'dart:math';

class ResistiveDividerSteps extends StatelessWidget {
  final ResistiveDividerController controller;

  const ResistiveDividerSteps({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final z0 = controller.z0;
        final r = controller.resistor;
        final g = (r - z0) / (r + z0);

        final zParallel = (r + z0) / 2.0;
        final zin = r + zParallel;

        final s11 = controller.s11;
        final s21 = controller.s21;
        final s31 = controller.s31;

        final mag11 = s11.abs();
        final mag21 = s21.abs();
        final mag31 = s31.abs();

        final pref = mag11 * mag11 * 100.0;
        final pout2 = mag21 * mag21 * 100.0;
        final pout3 = mag31 * mag31 * 100.0;
        final pdiss = (100.0 - pref - pout2 - pout3).clamp(0.0, 100.0);

        final port = controller.inputPort;
        final labelRef = "S$port$port";
        final others = [1, 2, 3]..remove(port);
        final labelTrans1 = "S${others[0]}$port";
        final labelTrans2 = "S${others[1]}$port";

        return Column(
          children: [
            _buildStepTile(
              title: "Step 1: Circuit & Matching",
              children: [
                const Text(
                  "Structure: symmetric Y-junction with three equal resistors R.",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text("With the other two ports terminated in Z0:"),
                const SizedBox(height: 5),
                Math.tex(
                  'Z_p = \\frac{R + Z_0}{2} = \\frac{${_fmt(r)} + ${_fmt(z0)}}{2} = ${_fmt(zParallel)}\\,\\Omega',
                  textStyle: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 5),
                Math.tex(
                  'Z_{in} = R + Z_p = ${_fmt(r)} + ${_fmt(zParallel)} = ${_fmt(zin)}\\,\\Omega',
                  textStyle: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 5),
                Math.tex(
                  'S_{11} = \\frac{Z_{in} - Z_0}{Z_{in} + Z_0} = ${_fmtSigned(s11)}',
                  textStyle: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),
                Text(
                  s11.abs() < 1e-6
                      ? "Conclusion: Perfectly matched."
                      : "Conclusion: Not perfectly matched for the current R/Z0.",
                  style: TextStyle(
                    color: s11.abs() < 1e-6 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Math.tex(
                  'R = Z_0/3 \\Rightarrow S_{11}=0',
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            _buildStepTile(
              title: "Step 2: Transmission",
              children: [
                const Text(
                  "Define the normalized parameter:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Math.tex(
                  'g = \\frac{R - Z_0}{R + Z_0} = \\frac{${_fmt(r)} - ${_fmt(z0)}}{${_fmt(r)} + ${_fmt(z0)}} = ${_fmtSigned(g)}',
                  textStyle: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),
                const Text(
                  "For the symmetric resistive divider:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Math.tex(
                  'S_{21} = S_{31} = \\frac{1-g}{3} = ${_fmtSigned(s21)}',
                  textStyle: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 5),
                Math.tex(
                  'S_{11} = \\frac{1+2g}{3} = ${_fmtSigned(s11)}',
                  textStyle: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Therefore, changing R or Z0 changes the current divider behavior through the ratio R/Z0.",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            _buildStepTile(
              title: "Step 3: S-Matrix & Power",
              children: [
                const Text("General scattering matrix:"),
                const SizedBox(height: 10),
                Center(
                  child: Math.tex(
                    '[S] = \\begin{bmatrix}'
                    '\\frac{1+2g}{3} & \\frac{1-g}{3} & \\frac{1-g}{3} \\\\'
                    '\\frac{1-g}{3} & \\frac{1+2g}{3} & \\frac{1-g}{3} \\\\'
                    '\\frac{1-g}{3} & \\frac{1-g}{3} & \\frac{1+2g}{3}'
                    '\\end{bmatrix}',
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Numerical matrix for current inputs:"),
                const SizedBox(height: 8),
                Center(
                  child: Math.tex(
                    '\\begin{bmatrix}'
                    '${_fmtSigned(s11)} & ${_fmtSigned(s21)} & ${_fmtSigned(s31)} \\\\'
                    '${_fmtSigned(s21)} & ${_fmtSigned(s11)} & ${_fmtSigned(s31)} \\\\'
                    '${_fmtSigned(s21)} & ${_fmtSigned(s31)} & ${_fmtSigned(s11)}'
                    '\\end{bmatrix}',
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Power Analysis:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Math.tex(
                  '|S_{11}|^2 = ${_fmt(mag11 * mag11)} \\Rightarrow ${pref.toStringAsFixed(1)}\\%',
                  textStyle: const TextStyle(fontSize: 14),
                ),
                Math.tex(
                  '|S_{21}|^2 = ${_fmt(mag21 * mag21)} \\Rightarrow ${pout2.toStringAsFixed(1)}\\%',
                  textStyle: const TextStyle(fontSize: 14),
                ),
                Math.tex(
                  '|S_{31}|^2 = ${_fmt(mag31 * mag31)} \\Rightarrow ${pout3.toStringAsFixed(1)}\\%',
                  textStyle: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  "Dissipated in resistors: ${pdiss.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text(
                "Step 4: Simulation Results",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              initiallyExpanded: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResultRow("$labelRef (Reflection)", s11),
                      _buildResultRow("$labelTrans1 (Transmission)", s21),
                      _buildResultRow("$labelTrans2 (Transmission)", s31),
                      const SizedBox(height: 15),
                      const Text(
                        "Outgoing-wave calculation:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Math.tex(
                        '\\mathbf{b}=\\mathbf{S}\\mathbf{a}',
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Math.tex(
                        '\\mathbf{a}=${_inputVectorLatex(port)}',
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Math.tex(
                        '\\mathbf{b}=${_outputVectorLatex(port, s11, s21, s31)}',
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Interpretation",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "• Current ratio R/Z0 = ${(r / z0).toStringAsFixed(4)}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            const Text(
                              "• Frequency only affects the animation, not the analytical S-parameters.",
                              style: TextStyle(fontSize: 12),
                            ),
                            const Text(
                              "• Ideal equal split occurs when R = Z0/3.",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepTile({required String title, required List<Widget> children}) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, double value) {
    final mag = value.abs().clamp(0.0, 1.0);
    final power = mag * mag * 100.0;
    final dbVal = mag <= 0.0001 ? -100.0 : 20 * (log(mag) / ln10);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text(
                value.toStringAsFixed(4),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: mag,
                  backgroundColor: Colors.grey[200],
                  color: mag > 0.1 ? Colors.blue : Colors.grey,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${dbVal.toStringAsFixed(1)} dB",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${power.toStringAsFixed(1)}% Pwr",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) => v.toStringAsFixed(4);
  static String _fmtSigned(double v) => v.toStringAsFixed(4);

  static String _inputVectorLatex(int port) {
    if (port == 1) {
      return '\\begin{bmatrix}1\\\\0\\\\0\\end{bmatrix}';
    } else if (port == 2) {
      return '\\begin{bmatrix}0\\\\1\\\\0\\end{bmatrix}';
    } else {
      return '\\begin{bmatrix}0\\\\0\\\\1\\end{bmatrix}';
    }
  }

  static String _outputVectorLatex(int port, double s11, double s21, double s31) {
    if (port == 1) {
      return '\\begin{bmatrix}${_fmtSigned(s11)}\\\\${_fmtSigned(s21)}\\\\${_fmtSigned(s31)}\\end{bmatrix}';
    } else if (port == 2) {
      return '\\begin{bmatrix}${_fmtSigned(s21)}\\\\${_fmtSigned(s11)}\\\\${_fmtSigned(s31)}\\end{bmatrix}';
    } else {
      return '\\begin{bmatrix}${_fmtSigned(s21)}\\\\${_fmtSigned(s31)}\\\\${_fmtSigned(s11)}\\end{bmatrix}';
    }
  }
}
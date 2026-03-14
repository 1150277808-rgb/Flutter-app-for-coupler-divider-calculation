import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'bl_globalvar.dart';

class BranchLineSteps extends StatelessWidget {
  final BranchLineController controller;

  const BranchLineSteps({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 判断当前频率是否偏离中心频率 (假设中心频率是 3GHz，这里做一个简单的视觉提示)
    // 在实际教学APP中，你可能有一个明确的 centerFreq 变量，这里我们假设 3GHz 是由参数决定的设计点
    bool offCenter = (controller.freqGHz - 3.0).abs() > 0.1;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ListView(
          padding: const EdgeInsets.only(bottom: 50),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildHeader(),

            // --- Step 1: Even Mode Analysis ---
            _buildMathCard(
              // 标题增加说明
              title: "Step 1: Even Mode (Theory @ f=f₀)", 
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Assumption: Frequency is exactly at center frequency f₀, so line length = λ/4 (90°).",
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Equivalent circuit: λ/4 line (Y0/k) flanked by open stubs (jY0).",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text("The overall ABCD matrix is:"),
                  _buildLeftMath(
                    r'\begin{bmatrix} C_{11} & C_{12} \\ C_{21} & C_{22} \end{bmatrix}_e = \begin{bmatrix} 1 & 0 \\ jY_0 & 1 \end{bmatrix} \begin{bmatrix} 0 & jZ_0/k \\ jkY_0 & 0 \end{bmatrix} \begin{bmatrix} 1 & 0 \\ jY_0 & 1 \end{bmatrix} = \frac{1}{k} \begin{bmatrix} -1 & jZ_0 \\ jY_0(k^2-1) & -1 \end{bmatrix}'
                  ),

                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'\Gamma_e = S_{11,e} = \frac{Z_0 C_{11} + C_{12} - Z_0^2 C_{21} - Z_0 C_{22}}{Z_0 C_{11} + C_{12} + Z_0^2 C_{21} + Z_0 C_{22}}'
                  ),
                  
                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'\text{To make } \Gamma_e = 0, \quad -jkZ_0 + j2Z_0/k = 0 \quad \Rightarrow \quad k = \sqrt{2}'
                  ),

                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'[C]_e = \begin{bmatrix} -1/\sqrt{2} & jZ_0/\sqrt{2} \\ jY_0/\sqrt{2} & -1/\sqrt{2} \end{bmatrix}'
                  ),

                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'\tau_e = S_{21,e} = \frac{2Z_0}{Z_0 C_{22} + Z_0 C_{11} + C_{12} + Z_0^2 C_{21}} = \frac{1}{\sqrt{2}}(-1-j)'
                  ),
                ],
              ),
            ),

            // --- Step 2: Odd Mode Analysis ---
            _buildMathCard(
               // 标题增加说明
              title: "Step 2: Odd Mode (Theory @ f=f₀)",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Assumption: Line length = λ/4 (90°). Stubs are shorted.",
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text("The overall ABCD matrix is:"),
                  _buildLeftMath(
                    r'\begin{bmatrix} C_{11} & C_{12} \\ C_{21} & C_{22} \end{bmatrix}_o = \begin{bmatrix} 1 & 0 \\ -jY_0 & 1 \end{bmatrix} \begin{bmatrix} 0 & jZ_0/k \\ jkY_0 & 0 \end{bmatrix} \begin{bmatrix} 1 & 0 \\ -jY_0 & 1 \end{bmatrix} = \frac{1}{k} \begin{bmatrix} 1 & jZ_0 \\ jY_0(k^2-1) & 1 \end{bmatrix}'
                  ),

                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'\Gamma_o = S_{11,o} = \frac{Z_0 C_{11} + C_{12} - Z_0^2 C_{21} - Z_0 C_{22}}{Z_0 C_{11} + C_{12} + Z_0^2 C_{21} + Z_0 C_{22}}'
                  ),

                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'\text{To make } \Gamma_o = 0, \quad -jkZ_0 + j2Z_0/k = 0 \quad \Rightarrow \quad k = \sqrt{2}'
                  ),

                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'[C]_o = \begin{bmatrix} 1/\sqrt{2} & jZ_0/\sqrt{2} \\ jY_0/\sqrt{2} & 1/\sqrt{2} \end{bmatrix}'
                  ),

                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'\tau_o = S_{21,o} = \frac{2Z_0}{Z_0 C_{22} + Z_0 C_{11} + C_{12} + Z_0^2 C_{21}} = \frac{1}{\sqrt{2}}(1-j)'
                  ),
                ],
              ),
            ),

            // --- Step 3: Superposition ---
            _buildMathCard(
              title: "Step 3: Ideal S-Matrix (at f₀)",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Using superposition (valid perfectly only at center freq):"),
                  const SizedBox(height: 10),
                  _buildLeftMath(r'S_{11} = \frac{1}{2}(\Gamma_e + \Gamma_o) = 0'),
                  const SizedBox(height: 5),
                  _buildLeftMath(r'S_{21} = \frac{1}{2}(\tau_e + \tau_o) = \frac{-j}{\sqrt{2}}'),
                  const SizedBox(height: 5),
                  _buildLeftMath(r'S_{31} = \frac{1}{2}(\tau_e - \tau_o) = \frac{-1}{\sqrt{2}}'),
                  const SizedBox(height: 5),
                  _buildLeftMath(r'S_{41} = \frac{1}{2}(\Gamma_e - \Gamma_o) = 0'),
                  
                  const Divider(height: 20),
                  const Text("Resulting Ideal S-Matrix:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Center(
                    child: Math.tex(
                      r'[S] = \frac{-1}{\sqrt{2}} \begin{bmatrix} 0 & j & 1 & 0 \\ j & 0 & 0 & 1 \\ 1 & 0 & 0 & j \\ 0 & 1 & j & 0 \end{bmatrix}',
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),

            // --- Step 4: Results ---
            _buildMathCard(
              title: "Step 4: Actual Simulation (Current f)",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.indigo[50], borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Input: Port ${controller.inputPort} @ ${controller.freqGHz.toStringAsFixed(2)} GHz",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                        ),
                        if (offCenter)
                           const Tooltip(
                             message: "Frequency mismatch causes reflections!",
                             child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                           )
                      ],
                    ),
                  ),
                  if (offCenter)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Note: Frequency is NOT at center (3GHz). Lines are not λ/4. Ideal cancellation in Steps 1-3 fails, causing reflection (S11 increases).",
                        style: TextStyle(fontSize: 12, color: Colors.red[700], fontStyle: FontStyle.italic),
                      ),
                    ),
                  const SizedBox(height: 10),
                  _buildResultRow("Through (S21)", controller.s2_mag),
                  _buildResultRow("Coupled (S31)", controller.s3_mag),
                  _buildResultRow("Isolated (S41)", controller.s4_mag),
                  _buildResultRow("Reflection (S11)", controller.s1_mag),
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
            "Theoretical Derivation vs. Simulation",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            "Steps 1-3 derive the design criteria at the Center Frequency (f₀). Step 4 simulates the actual response at your chosen frequency.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget _buildMathCard({required String title, required Widget content}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: content,
          )
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double val) {
    bool isIso = val < 0.1;
    bool isGood = val > 0.6 && val < 0.8;
    // 如果反射很大，标红
    bool isBadReflection = label.contains("S11") && val > 0.1;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          const Text(" = "),
          Text(
            val.toStringAsFixed(4), 
            style: TextStyle(
              fontFamily: "monospace",
              fontSize: 15,
              fontWeight: FontWeight.bold, 
              color: isBadReflection ? Colors.red : (isIso ? Colors.grey : (isGood ? Colors.green[700] : Colors.black))
            )
          ),
          if (isGood) ...[
            const SizedBox(width: 8),
            const Text("(-3dB)", style: TextStyle(fontSize: 11, color: Colors.green)),
          ],
          if (isBadReflection) ...[
             const SizedBox(width: 8),
            const Text("(Mismatch!)", style: TextStyle(fontSize: 11, color: Colors.red)),
          ]
        ],
      ),
    );
  }
}
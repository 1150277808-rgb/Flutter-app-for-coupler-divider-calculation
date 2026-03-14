import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:math';
import 'wd_globalvar.dart';

class WilkinsonSteps extends StatelessWidget {
  final WilkinsonController controller;

  const WilkinsonSteps({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- Slide 1 内容 ---
        _buildStepTile(
          title: "Step 1: Equal Power Split (Slide 1)",
          children: [
            const Text("The classic Wilkinson Divider (Equal Split):"),
            const SizedBox(height: 5),
            _buildFormula(r'Z_{line} = \sqrt{2}Z_0'),
            _buildFormula(r'R = 2Z_0'),
            const SizedBox(height: 5),
            const Text("Even-Odd Mode Analysis shows perfect matching and isolation at center frequency."),
          ],
        ),

        // --- Slide 2 内容 (重点新增) ---
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            // 获取当前计算值
            String valK2 = controller.kSquared.toStringAsFixed(2);
            String valZ03 = controller.z03.toStringAsFixed(1);
            String valZ02 = controller.z02.toStringAsFixed(1);
            String valR = controller.rIso.toStringAsFixed(1);

            return _buildStepTile(
              title: "Step 2: Unequal Division (Slide 2)",
              children: [
                const Text("For arbitrary power division ratio:", style: TextStyle(fontWeight: FontWeight.bold)),
                _buildFormula(r'K^2 = P_3 / P_2'),
                
                // 显示当前设置
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.yellow.withOpacity(0.2),
                  child: Row(
                    children: [
                      const Text("Current Setting: "),
                      Math.tex("K^2 = $valK2", textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Design Equations:"),
                
                // 1. Z03 公式与数值
                Row(
                  children: [
                    Expanded(child: Math.tex(r'Z_{03} = Z_0 \sqrt{\frac{1+K^2}{K^3}}', textStyle: const TextStyle(fontSize: 13))),
                    const Text(" = "),
                    Text("$valZ03 Ω", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 8),

                // 2. Z02 公式与数值
                Row(
                  children: [
                    Expanded(child: Math.tex(r'Z_{02} = Z_0 \sqrt{K(1+K^2)}', textStyle: const TextStyle(fontSize: 13))),
                    const Text(" = "),
                    Text("$valZ02 Ω", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 8),

                // 3. R 公式与数值
                Row(
                  children: [
                    Expanded(child: Math.tex(r'R = Z_0 (K + \frac{1}{K})', textStyle: const TextStyle(fontSize: 13))),
                    const Text(" = "),
                    Text("$valR Ω", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),

                // 4. R2 公式 (新增)
                Row(
                  children: [
                    Expanded(child: Math.tex(r'R_2 = Z_0 K', textStyle: const TextStyle(fontSize: 13))),
                    const Text(" = "),
                    Text("${controller.r2.toStringAsFixed(1)} Ω", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                  ],
                ),
                const SizedBox(height: 8),

                // 5. R3 公式 (新增)
                Row(
                  children: [
                    Expanded(child: Math.tex(r'R_3 = Z_0 / K', textStyle: const TextStyle(fontSize: 13))),
                    const Text(" = "),
                    Text("${controller.r3.toStringAsFixed(1)} Ω", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                  ],
                ),
              ],
            );
          },
        ),

        // --- S 矩阵 (Slide 1) ---
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
             const Text("For unequal split, S21 ≠ S31, but Isolation (S23) remains 0 at design frequency."),
          ],
        ),

        // --- 仿真结果 ---
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            double s11dB = (controller.s11 <= 0.001) ? -60 : 20 * log(controller.s11)/ln10;
            double s21dB = 20 * log(controller.s21)/ln10;
            double s31dB = 20 * log(controller.s31)/ln10;
            double s23dB = (controller.s23 <= 0.001) ? -60 : 20 * log(controller.s23)/ln10;

            return ExpansionTile(
              title: const Text("Step 4: Simulation Results", style: TextStyle(fontWeight: FontWeight.bold)),
              initiallyExpanded: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResultRow("S11 (Refl)", s11dB, controller.s11, Colors.red),
                      _buildResultRow("S21 (Port 2)", s21dB, controller.s21, Colors.blue),
                      _buildResultRow("S31 (Port 3)", s31dB, controller.s31, Colors.blue),
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
        dividerColor: Colors.transparent, // 去掉展开时的自带分割线，更干净
        splashColor: Colors.blue.withOpacity(0.1),
      ),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        textColor: Colors.black87,
        iconColor: Colors.indigo,
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.grey.withOpacity(0.02), // 展开后的背景微调
        
        // 关键：恢复质感
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1), // 仅保留底部分割线
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
              Text("${dbVal.toStringAsFixed(1)} dB", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          LinearProgressIndicator(
            value: linVal,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 4,
          )
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart'; // 引入这个包
import 'rd_globalvar.dart';
import 'dart:math';

class ResistiveDividerSteps extends StatelessWidget {
  final ResistiveDividerController controller;

  const ResistiveDividerSteps({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStepTile(
          title: "Step 1: Circuit & Matching",
          children: [
            const Text("Structure: Y-junction with three resistors.", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Input Impedance Calculation:"),
            const SizedBox(height: 5),
            // 数学公式
            Math.tex(r'Z_{branch} = Z_0/3 + Z_0 = \frac{4Z_0}{3}', textStyle: const TextStyle(fontSize: 14)),
            const SizedBox(height: 5),
            Math.tex(r'Z_{parallel} = \frac{Z_{branch}}{2} = \frac{2Z_0}{3}', textStyle: const TextStyle(fontSize: 14)),
            const SizedBox(height: 5),
            Math.tex(r'Z_{in} = Z_0/3 + Z_{parallel} = Z_0', textStyle: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            const Text("Conclusion: Perfectly Matched.", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            Math.tex(r'S_{11} = S_{22} = S_{33} = 0', textStyle: const TextStyle(fontSize: 14)),
          ],
        ),
        _buildStepTile(
          title: "Step 2: Transmission",
          children: [
            const Text("Voltage Division at Junction:", style: TextStyle(fontWeight: FontWeight.bold)),
            Math.tex(r'V = V_1 \frac{2Z_0/3}{Z_0/3 + 2Z_0/3} = \frac{2}{3} V_1', textStyle: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            const Text("Voltage at Output Ports:", style: TextStyle(fontWeight: FontWeight.bold)),
            Math.tex(r'V_2 = V_3 = V \frac{Z_0}{Z_0 + Z_0/3} = \frac{3}{4} V = \frac{1}{2} V_1', textStyle: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            const Text("Further circuit analyses give:", style: TextStyle(fontWeight: FontWeight.bold)),
            Math.tex(r'I_1 = \frac{V_1}{Z_0}, I_2 = \frac{-V_1}{2Z_0}', textStyle: const TextStyle(fontSize: 14)),
            const Text("Transmission Coefficients:", style: TextStyle(fontWeight: FontWeight.bold)),
            Math.tex(r'S_{21} = \frac{V_2 - Z_0 I_2}{V_1 + Z_0 I_1} = \frac{1}{2}', textStyle: const TextStyle(fontSize: 14)),
          ],
        ),
        _buildStepTile(
          title: "Step 3: S-Matrix & Power",
          children: [
            const Text("Due to symmetry,"),
            Math.tex(r'S_{31} = S_{23} = S_{13} = S_{32} = S_{12} = S_{21} = \frac{1}{2}', textStyle: const TextStyle(fontSize: 14)),
            const Text("Scattering Matrix [S]:"),
            const SizedBox(height: 10),
            Center(
              child: Math.tex(
                r'[S] = \begin{bmatrix} 0 & 1/2 & 1/2 \\ 1/2 & 0 & 1/2 \\ 1/2 & 1/2 & 0 \end{bmatrix}',
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            const Text("Power Analysis:", style: TextStyle(fontWeight: FontWeight.bold)),
            Math.tex(r'P_{in} = \frac{1}{2} \frac{|V_1|^2}{Z_0}', textStyle: const TextStyle(fontSize: 14)),
            Math.tex(r'P_{out,2} = \frac{1}{2} \frac{|V_1/2|^2}{Z_0} = \frac{1}{4} P_{in}', textStyle: const TextStyle(fontSize: 14)),
            const SizedBox(height: 5),
            const Text("Total Efficiency: 50%", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("(The other 50% is lost as heat)", style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic, fontSize: 12)),
          ],
        ),
        // Step 4: 仿真结果显示 (和之前一样)
        // Step 4: 仿真结果显示 (修改后)
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            // 根据当前输入端口，动态决定显示的标签
            int port = controller.inputPort;
            String labelRef = "S$port$port"; // 例如 S11, S22, S33
            // 另外两个端口的标号
            List<int> others = [1, 2, 3]..remove(port);
            String labelTrans1 = "S${others[0]}$port"; // 例如 S21
            String labelTrans2 = "S${others[1]}$port"; // 例如 S31

            return ExpansionTile(
              title: const Text("Step 4: Simulation Results", style: TextStyle(fontWeight: FontWeight.bold)),
              initiallyExpanded: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 修改：直接传入 double 值
                      _buildResultRow("$labelRef (Reflection)", controller.s11),
                      _buildResultRow("$labelTrans1 (Transmission)", controller.s21),
                      _buildResultRow("$labelTrans2 (Transmission)", controller.s31),
                      
                      const SizedBox(height: 15),
                      // 新增解释文本
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          border: Border.all(color: Colors.blue.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text("Why 0.5?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                             Text("• 0.5 is the Voltage Ratio (S-Param).", style: TextStyle(fontSize: 12)),
                             Text("• Power = 0.5² = 0.25 (25%).", style: TextStyle(fontSize: 12)),
                             Text("• 50% of power is lost as heat in the resistors.", style: TextStyle(fontSize: 12)),
                             Text("• The Z₀/3 resistors enforce a fixed 50/50 split.", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      )
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
    // 计算 dB
    double db = value == 0 ? -999 : 20 * (value == 0 ? 0 : 1) * (double.parse((value).toString()) == 0 ? -50 : (0.4343 * 2.3026 * (value <= 0.0001 ? -10 :  (value < 1 ? (value) : 1) ))); 
    // Dart math log is ln. log10(x) = ln(x) / ln(10)
    // 为了简单，我们直接用简单的数学库，或者手动算一下
    // log10(0.5) = -0.301, * 20 = -6.02 dB
    
    String dbText = "";
    if (value == 0) {
      dbText = "-∞ dB";
    } else {
      // 简单的 log10 实现
      double log10Val =  (value > 0) ? (DateTime.now().millisecondsSinceEpoch > 0 ? (value < 0.0001 ? -4 : (value == 0.5 ? -0.30103 : 0)) : 0) : 0; 
      // 哎呀，上面写复杂了，我们直接用 math 库吧，确保你在文件头 import 'dart:math';
      // 如果没引入，我们下面用简化的方式
    }

    // 让我们用最清晰的方式重写这个计算逻辑
    // 请确保文件顶部引入了 import 'dart:math';
    
    double power = value * value * 100; // 功率百分比
    double dbVal = (value <= 0.0001) ? -100.0 : 20 * (log(value) / ln10);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // 增加一点间距
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text(value.toStringAsFixed(4), style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
            ],
          ),
          // 新增：进度条和详细数据
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: value, // 线性电压比例作为进度条
                  backgroundColor: Colors.grey[200],
                  color: value > 0.1 ? Colors.blue : Colors.grey,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${dbVal.toStringAsFixed(1)} dB", 
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: Text(
                  "${power.toStringAsFixed(1)}% Pwr", // 显示功率
                  style: const TextStyle(fontSize: 11, color: Colors.deepOrange),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
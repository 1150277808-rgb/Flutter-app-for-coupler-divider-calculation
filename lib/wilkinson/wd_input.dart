import 'package:flutter/material.dart';
import 'wd_globalvar.dart';

class WilkinsonInput extends StatelessWidget {
  final WilkinsonController controller;

  const WilkinsonInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F8), 
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 12),
          
          // Frequency Slider (不变)
          Row(
            children: [
              const Text("Freq (GHz): "),
              Text(controller.frequency.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: Slider(
                    value: controller.frequency,
                    min: 1.0,
                    max: 5.0,
                    divisions: 40,
                    onChanged: (v) => controller.setFrequency(v),
                  ),
                ),
              ),
            ],
          ),
          
          const Divider(color: Colors.white),

          // Power Split Slider (改为 dB 控制)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Split Ratio (dB):", style: TextStyle(fontSize: 13)),
              // 显示 dB 和 K^2
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${controller.splitDB.toStringAsFixed(1)} dB", 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16)),
                  Text("(K² = ${controller.kSquared.toStringAsFixed(2)})", 
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
          
          SizedBox(
            height: 30,
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                return Slider(
                  value: controller.splitDB,
                  min: 0.0,     // 0 dB (1:1)
                  max: 20.0,    // 10 dB (1:10)
                  divisions: 200, // 细粒度调节
                  activeColor: Colors.orange,
                  label: "${controller.splitDB.toStringAsFixed(1)} dB",
                  onChanged: (v) => controller.setSplitDB(v), // 调用新的 setSplitDB
                );
              },
            ),
          ),
          const Center(
            child: Text("Power Difference: 10log(P3/P2)", 
              style: TextStyle(fontSize: 10, color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
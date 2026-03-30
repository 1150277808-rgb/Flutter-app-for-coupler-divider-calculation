import 'package:flutter/material.dart';
import 'wd_globalvar.dart';

class WilkinsonInput extends StatefulWidget {
  final WilkinsonController controller;

  const WilkinsonInput({super.key, required this.controller});

  @override
  State<WilkinsonInput> createState() => _WilkinsonInputState();
}

class _WilkinsonInputState extends State<WilkinsonInput> {
  late TextEditingController _freqController;

  @override
  void initState() {
    super.initState();
    _freqController = TextEditingController(text: widget.controller.frequency.toStringAsFixed(2));
    widget.controller.addListener(_updateFreqText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateFreqText);
    _freqController.dispose();
    super.dispose();
  }

  void _updateFreqText() {
    if (!_freqController.selection.isValid) {
      _freqController.text = widget.controller.frequency.toStringAsFixed(2);
    }
  }

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

          Row(
            children: [
              const Text("Freq (GHz): "),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _freqController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (val) {
                    final freq = double.tryParse(val);
                    if (freq != null && freq > 0) {
                      widget.controller.setFrequency(freq);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final freq = double.tryParse(_freqController.text);
                  if (freq != null && freq > 0) {
                    widget.controller.setFrequency(freq);
                  }
                },
                child: const Text("Update"),
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
                  Text("${widget.controller.splitDB.toStringAsFixed(1)} dB",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16)),
                  Text("(K² = ${widget.controller.kSquared.toStringAsFixed(2)})",
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),

          SizedBox(
            height: 30,
            child: ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) {
                return Slider(
                  value: widget.controller.splitDB,
                  min: 0.0,
                  max: 20.0,
                  divisions: 200,
                  activeColor: Colors.orange,
                  label: "${widget.controller.splitDB.toStringAsFixed(1)} dB",
                  onChanged: (v) => widget.controller.setSplitDB(v),
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
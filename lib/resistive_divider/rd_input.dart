import 'package:flutter/material.dart';
import 'rd_globalvar.dart';

class ResistiveDividerParamEditor extends StatefulWidget {
  final ResistiveDividerController controller;

  const ResistiveDividerParamEditor({super.key, required this.controller});

  @override
  State<ResistiveDividerParamEditor> createState() =>
      _ResistiveDividerParamEditorState();
}

class _ResistiveDividerParamEditorState
    extends State<ResistiveDividerParamEditor> {
  late TextEditingController _freqCtrl;
  late TextEditingController _z0Ctrl;
  late TextEditingController _rCtrl;

  @override
  void initState() {
    super.initState();
    _freqCtrl =
        TextEditingController(text: widget.controller.frequency.toString());
    _z0Ctrl = TextEditingController(text: widget.controller.z0.toString());
    _rCtrl = TextEditingController(text: widget.controller.resistor.toString());
  }

  @override
  void dispose() {
    _freqCtrl.dispose();
    _z0Ctrl.dispose();
    _rCtrl.dispose();
    super.dispose();
  }

  void _update() {
    final f = double.tryParse(_freqCtrl.text);
    final z0 = double.tryParse(_z0Ctrl.text);
    final r = double.tryParse(_rCtrl.text);

    widget.controller.setParameters(
      frequency: f,
      z0: z0,
      resistor: r,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),

            // 原有频率输入行
            Row(
              children: [
                const Text("Frequency (GHz): "),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _freqCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _update,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Update"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 新增一行 Z0 和 R
            Row(
              children: [
                const Text("Z0 (Ω): "),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _z0Ctrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                const Text("R (Ω): "),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _rCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),
            const Text(
              "Note: Frequency is only used for animation. For the resistive divider, S-parameters depend on R/Z0. Ideal equal split occurs when R = Z0/3.",
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const Divider(height: 20),

            const Text(
              "Select Input Port (Calculation):",
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 5),
            ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPortButton(1, "Port 1"),
                    _buildPortButton(2, "Port 2"),
                    _buildPortButton(3, "Port 3"),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortButton(int port, String label) {
    final isSelected = widget.controller.inputPort == port;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) widget.controller.setInputPort(port);
      },
      selectedColor: Colors.red.withOpacity(0.2),
      labelStyle: TextStyle(color: isSelected ? Colors.red : Colors.black),
    );
  }
}
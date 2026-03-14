import 'package:flutter/material.dart';
import 'rd_globalvar.dart';

class ResistiveDividerParamEditor extends StatefulWidget {
  final ResistiveDividerController controller;
  
  const ResistiveDividerParamEditor({super.key, required this.controller});

  @override
  State<ResistiveDividerParamEditor> createState() => _ResistiveDividerParamEditorState();
}

class _ResistiveDividerParamEditorState extends State<ResistiveDividerParamEditor> {
  late TextEditingController _freqCtrl;

  @override
  void initState() {
    super.initState();
    _freqCtrl = TextEditingController(text: widget.controller.frequency.toString());
  }

  @override
  void dispose() {
    _freqCtrl.dispose();
    super.dispose();
  }

  void _update() {
    double? f = double.tryParse(_freqCtrl.text);
    if (f != null) {
      widget.controller.setFrequency(f);
    }
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
            const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 10),
            
            // 1. 频率输入
            Row(
              children: [
                const Text("Frequency (GHz): "),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _freqCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _update,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                  child: const Text("Update"),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              "Note: Ideally, resistive divider is frequency independent.",
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            const Divider(height: 20),

            // 2. 端口选择
            const Text("Select Input Port (Simulation):", style: TextStyle(fontSize: 12)),
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
    bool isSelected = widget.controller.inputPort == port;
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
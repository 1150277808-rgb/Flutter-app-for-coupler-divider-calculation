import 'package:flutter/material.dart';
import 'bl_globalvar.dart';

class BranchLineParamEditor extends StatefulWidget {
  final BranchLineController controller;
  final Function(double) onUpdate;

  const BranchLineParamEditor({
    super.key,
    required this.controller,
    required this.onUpdate,
  });

  @override
  State<BranchLineParamEditor> createState() => _BranchLineParamEditorState();
}

class _BranchLineParamEditorState extends State<BranchLineParamEditor> {
  late TextEditingController _freqCtrl;
  late TextEditingController _z0Ctrl;
  late TextEditingController _zhCtrl;
  late TextEditingController _zvCtrl;

  @override
  void initState() {
    super.initState();
    _freqCtrl =
        TextEditingController(text: widget.controller.freqGHz.toStringAsFixed(4));
    _z0Ctrl =
        TextEditingController(text: widget.controller.z0.toStringAsFixed(4));
    _zhCtrl =
        TextEditingController(text: widget.controller.zh.toStringAsFixed(4));
    _zvCtrl =
        TextEditingController(text: widget.controller.zv.toStringAsFixed(4));
  }

  @override
  void dispose() {
    _freqCtrl.dispose();
    _z0Ctrl.dispose();
    _zhCtrl.dispose();
    _zvCtrl.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    final f = double.tryParse(_freqCtrl.text);
    final z0 = double.tryParse(_z0Ctrl.text);
    final zh = double.tryParse(_zhCtrl.text);
    final zv = double.tryParse(_zvCtrl.text);

    widget.controller.setParameters(
      frequency: f,
      z0: z0,
      zh: zh,
      zv: zv,
      notify: false,
    );

    widget.onUpdate(widget.controller.freqGHz);
  }

  void _handleReset() {
    widget.controller.resetToIdeal();

    _freqCtrl.text = widget.controller.freqGHz.toStringAsFixed(4);
    _z0Ctrl.text = widget.controller.z0.toStringAsFixed(4);
    _zhCtrl.text = widget.controller.zh.toStringAsFixed(4);
    _zvCtrl.text = widget.controller.zv.toStringAsFixed(4);

    widget.onUpdate(widget.controller.freqGHz);
  }

  Widget _buildSmallField(String label, TextEditingController controller) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => _handleUpdate(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Settings",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),

            Row(
              children: [
                const Text(
                  "Frequency (GHz):  ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _freqCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixText: "GHz",
                      hintText: "e.g. 3.0",
                    ),
                    onSubmitted: (_) => _handleUpdate(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _handleUpdate,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text("Update"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _buildSmallField("Z0 (Ω)", _z0Ctrl),
                const SizedBox(width: 10),
                _buildSmallField("Zh (Ω)", _zhCtrl),
                const SizedBox(width: 10),
                _buildSmallField("Zv (Ω)", _zvCtrl),
              ],
            ),

            const SizedBox(height: 10),
            Text(
              "Ideal design near f0=${widget.controller.centerFreq.toStringAsFixed(1)} GHz: "
              "Zh=Z0/√2, Zv=Z0",
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text(
                    "Center Freq = ${widget.controller.centerFreq} GHz (90° branch length)",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _handleReset,
                    child: const Text("Reset"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
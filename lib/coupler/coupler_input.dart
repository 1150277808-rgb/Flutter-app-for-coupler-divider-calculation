import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'coupler_globalvar.dart';

class ParamEditor extends StatefulWidget {
  final SourceController sourceController;

  const ParamEditor({super.key, required this.sourceController});

  @override
  State<ParamEditor> createState() => _ParamEditorState();
}

class _ParamEditorState extends State<ParamEditor> {
  late TextEditingController _freqController;
  late List<TextEditingController> _ampControllers;
  late List<TextEditingController> _phaseControllers;
  late List<bool> _enabled;

  @override
  void initState() {
    super.initState();
    _freqController = TextEditingController();
    _ampControllers = List.generate(4, (_) => TextEditingController());
    _phaseControllers = List.generate(4, (_) => TextEditingController());
    _enabled = List.filled(4, false);
    _loadFromController();
  }

  @override
  void dispose() {
    _freqController.dispose();
    for (final c in _ampControllers) {
      c.dispose();
    }
    for (final c in _phaseControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _loadFromController() {
    final c = widget.sourceController;
    _freqController.text = c.freqGHz.toString();

    for (int i = 0; i < 4; i++) {
      final e = c.excitations[i];
      _enabled[i] = e.enabled;
      _ampControllers[i].text = e.amplitude.toStringAsFixed(2);
      _phaseControllers[i].text = e.phaseDeg.toStringAsFixed(1);
    }
  }

  void _handleUpdateFreq() {
    final val = double.tryParse(_freqController.text);
    if (val != null && val > 0) {
      widget.sourceController.freqGHz = val;
      widget.sourceController.update();
      FocusScope.of(context).unfocus();
      setState(() {
        _loadFromController();
      });
    } else {
      _freqController.text = widget.sourceController.freqGHz.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid positive frequency.")),
      );
    }
  }

  void _applyExcitations() {
    final amps = <double>[];
    final phases = <double>[];

    for (int i = 0; i < 4; i++) {
      final amp = double.tryParse(_ampControllers[i].text);
      final phase = double.tryParse(_phaseControllers[i].text);

      if (amp == null || amp < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid amplitude at Port ${i + 1}.")),
        );
        return;
      }

      if (phase == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid phase at Port ${i + 1}.")),
        );
        return;
      }

      amps.add(amp);
      phases.add(phase);
    }

    widget.sourceController.applyExcitations(
      enabled: List<bool>.from(_enabled),
      amplitudes: amps,
      phasesDeg: phases,
    );

    FocusScope.of(context).unfocus();
    setState(() {
      // 不重新加载，保持用户输入
    });
  }

  void _applySinglePortPreset(int port) {
    widget.sourceController.setInputPort(port);
    setState(() {
      _loadFromController();
    });
  }

  void _applyPairPreset(int p1, int p2, double phase2) {
    final enabled = [false, false, false, false];
    final amps = [0.0, 0.0, 0.0, 0.0];
    final phases = [0.0, 0.0, 0.0, 0.0];

    enabled[p1 - 1] = true;
    enabled[p2 - 1] = true;
    amps[p1 - 1] = 1.0;
    amps[p2 - 1] = 1.0;
    phases[p1 - 1] = 0.0;
    phases[p2 - 1] = phase2;

    widget.sourceController.applyExcitations(
      enabled: enabled,
      amplitudes: amps,
      phasesDeg: phases,
    );

    setState(() {
      _loadFromController();
    });
  }

  void _clearAll() {
    widget.sourceController.clearAllExcitations();
    setState(() {
      _loadFromController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 760;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 10),

                if (!narrow)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Frequency (GHz): ",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _freqController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            suffixText: "GHz",
                            hintText: "e.g. 3.0",
                          ),
                          onSubmitted: (_) => _handleUpdateFreq(),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _handleUpdateFreq,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text("Update"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        "Frequency (GHz): ",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: 220,
                        child: TextField(
                          controller: _freqController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            suffixText: "GHz",
                            hintText: "e.g. 3.0",
                          ),
                          onSubmitted: (_) => _handleUpdateFreq(),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _handleUpdateFreq,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text("Update"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 10),
                Text(
                  "Ideal lossless matched model. Multi-input response is computed using b = S a.",
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),

                const SizedBox(height: 16),
                const Text(
                  "Excitations (normalized wave amplitude)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  "You may enable any subset of Port 1~4, and assign amplitude and phase freely.",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),

                for (int i = 0; i < 4; i++) _buildPortRow(i),

                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: const Text("Single P1"),
                      onPressed: () => _applySinglePortPreset(1),
                    ),
                    ActionChip(
                      label: const Text("Single P2"),
                      onPressed: () => _applySinglePortPreset(2),
                    ),
                    ActionChip(
                      label: const Text("Single P3"),
                      onPressed: () => _applySinglePortPreset(3),
                    ),
                    ActionChip(
                      label: const Text("Single P4"),
                      onPressed: () => _applySinglePortPreset(4),
                    ),
                    ActionChip(
                      label: const Text("P1 + P3 (0°)"),
                      onPressed: () => _applyPairPreset(1, 3, 0.0),
                    ),
                    ActionChip(
                      label: const Text("P1 + P3 (180°)"),
                      onPressed: () => _applyPairPreset(1, 3, 180.0),
                    ),
                    ActionChip(
                      label: const Text("P2 + P4 (0°)"),
                      onPressed: () => _applyPairPreset(2, 4, 0.0),
                    ),
                    ActionChip(
                      label: const Text("P2 + P4 (180°)"),
                      onPressed: () => _applyPairPreset(2, 4, 180.0),
                    ),
                    ActionChip(
                      label: const Text("Clear"),
                      onPressed: _clearAll,
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _applyExcitations,
                      icon: const Icon(Icons.tune),
                      label: const Text("Apply Excitations"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final center = widget.sourceController.centerFreq;
                        widget.sourceController.freqGHz = center;
                        widget.sourceController.update();
                        setState(() {
                          _loadFromController();
                        });
                      },
                      child: const Text("Reset Frequency"),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                AnimatedBuilder(
                  animation: widget.sourceController,
                  builder: (context, _) {
                    final c = widget.sourceController;
                    final active = c.activeInputPorts.isEmpty
                        ? "None"
                        : c.activeInputPorts.map((e) => "P$e").join(", ");

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 8,
                        children: [
                          Text("Active Inputs: $active", style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text("Pin = ${c.totalInputPower.toStringAsFixed(3)}"),
                          Text("Pout = ${c.totalOutputPower.toStringAsFixed(3)}"),
                          Text("ΔP = ${c.powerBalanceError.toStringAsFixed(6)}"),
                        ],
                      ),
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                      Text(
                        "Center Frequency = ${widget.sourceController.centerFreq} GHz",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortRow(int i) {
    final port = i + 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Wrap(
          spacing: 14,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 90,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _enabled[i],
                    onChanged: (val) {
                      setState(() {
                        _enabled[i] = val ?? false;
                        if (!_enabled[i]) {
                          _ampControllers[i].text = "0.00";
                        } else {
                          if ((double.tryParse(_ampControllers[i].text) ?? 0) == 0) {
                            _ampControllers[i].text = "1.00";
                          }
                        }
                      });
                    },
                  ),
                  Text("P$port"),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Amp"),
                const SizedBox(width: 6),
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _ampControllers[i],
                    enabled: _enabled[i],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Phase (°)"),
                const SizedBox(width: 6),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _phaseControllers[i],
                    enabled: _enabled[i],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
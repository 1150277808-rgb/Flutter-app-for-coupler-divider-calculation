import 'package:flutter/material.dart';
import 'bl_globalvar.dart';

class BranchLineParamEditor extends StatefulWidget {
  final BranchLineController controller;
  // 1. 定义回调函数：当用户点击Update时，不仅更新变量，还要通知外部去计算
  final Function(double) onUpdate; 

  const BranchLineParamEditor({
    super.key,
    required this.controller,
    required this.onUpdate, // 2. 构造函数里必须接收这个方法
  });

  @override
  State<BranchLineParamEditor> createState() => _BranchLineParamEditorState();
}

class _BranchLineParamEditorState extends State<BranchLineParamEditor> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.freqGHz.toString());
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    final double? val = double.tryParse(_textController.text);

    if (val != null) {
      // 3. 核心修复：
      // 先更新控制器的频率 (让动画和界面变)
      widget.controller.setFrequency(val);
      
      // 再调用回调函数 (触发 bl_main.dart 里的数学计算)
      widget.onUpdate(val); 
    }
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
            const Text("Settings", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Frequency (GHz):  ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text(
                    "Center Freq = ${widget.controller.centerFreq} GHz (90° Shift)",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // 重置逻辑
                      double def = widget.controller.centerFreq;
                      widget.controller.setFrequency(def);
                      _textController.text = def.toString();
                      widget.onUpdate(def); // 重置时也触发计算
                    },
                    child: const Text("Reset"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
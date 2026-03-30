import 'package:flutter/material.dart';
import 'rd_globalvar.dart';
import 'rd_input.dart';
import 'rd_steps.dart';
import 'rd_painter.dart';

class ResistiveDividerMain extends StatelessWidget {
  const ResistiveDividerMain({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Resistive Power Divider"),
          backgroundColor: const Color(0xFFF5F6FA),
          surfaceTintColor: Colors.transparent,
          titleTextStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Calculation"),
              Tab(text: "Schematic"),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Row(
              children: [
                SizedBox(
                  width: 900,
                  child: Column(
                    children: [
                      ResistiveDividerParamEditor(controller: rdController),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(right: 10, bottom: 40),
                          child: ResistiveDividerSteps(controller: rdController),
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1, color: Colors.black12),
                Expanded(
                  child: ClipRect(
                    child: Container(
                      color: const Color(0xFFFAFAFA),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          const _WaveLegend(
                            items: [
                              _LegendItem(color: Colors.red, text: "Excited Input"),
                              _LegendItem(color: Colors.blue, text: "Outgoing Wave"),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Text(
                              "Note: Waves may not be visible at very high frequencies.",
                              style: TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: ResistiveDividerPainterFrame(controller: rdController),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              color: Colors.white,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: Image.asset(
                  'assets/images/rd_schematic.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveLegend extends StatelessWidget {
  final List<_LegendItem> items;
  const _WaveLegend({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 8,
      children: items
          .map(
            (e) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: e.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  e.text,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _LegendItem {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});
}
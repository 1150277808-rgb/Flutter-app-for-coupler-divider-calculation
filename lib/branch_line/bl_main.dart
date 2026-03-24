import 'package:flutter/material.dart';
import 'bl_globalvar.dart';
import 'bl_input.dart';
import 'bl_steps.dart';
import 'bl_painter.dart';
import 'bl_plot.dart';

class BranchLineMain extends StatelessWidget {
  const BranchLineMain({super.key});

  void _recalculateSParams(double freq) {
    blController.recalc();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Branch Line Hybrid (Quadrature)"),
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
              Tab(text: "Simulation"),
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
                      BranchLineParamEditor(
                        controller: blController,
                        onUpdate: (val) => _recalculateSParams(val),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(right: 10, bottom: 40),
                            child: Column(
                              children: [
                                BranchLineSPlot(controller: blController),
                                BranchLineSteps(controller: blController),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(width: 1, color: Colors.grey.shade200),
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
                              _LegendItem(color: Colors.grey, text: "Near Zero Output"),
                            ],
                          ),
                          Expanded(
                            child: BranchLinePainterFrame(controller: blController),
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
                  'assets/images/bl_schematic.png',
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
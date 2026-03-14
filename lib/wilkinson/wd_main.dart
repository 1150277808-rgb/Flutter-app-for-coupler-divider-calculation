import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'wd_globalvar.dart';
import 'wd_painter.dart';
import 'wd_steps.dart';
import 'wd_input.dart';

class WilkinsonMain extends StatefulWidget {
  const WilkinsonMain({super.key});

  @override
  State<WilkinsonMain> createState() => _WilkinsonMainState();
}

class _WilkinsonMainState extends State<WilkinsonMain> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _animationValue = 0.0;

  @override
  void initState() {
    super.initState();
    wdController.recalc();
    _ticker = createTicker((Duration elapsed) {
      setState(() {
        _animationValue = (elapsed.inMilliseconds % 1000) / 1000.0;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Wilkinson Power Divider"),
          backgroundColor: const Color(0xFFF5F6FA),
          surfaceTintColor: Colors.transparent,
          titleTextStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
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
                      WilkinsonInput(controller: wdController),
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 40),
                            child: WilkinsonSteps(controller: wdController),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(width: 1, color: Colors.grey.shade200),
                Expanded(
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
                        Expanded(
                          child: ClipRect(
                            child: CustomPaint(
                              painter: WilkinsonPainter(
                                controller: wdController,
                                animationValue: _animationValue,
                              ),
                              size: Size.infinite,
                            ),
                          ),
                        ),
                      ],
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
                  'assets/images/wd_schematic.png',
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
import 'package:flutter/material.dart';
import 'coupler_globalvar.dart';
import 'coupler_input.dart';
import 'coupler_step.dart';
import 'coupler_source.dart';

class CouplerMain extends StatefulWidget {
  const CouplerMain({super.key});

  @override
  State<CouplerMain> createState() => _CouplerMainState();
}

class _CouplerMainState extends State<CouplerMain> {
  final SourceController controllerSource = SourceController();

  @override
  void dispose() {
    controllerSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Rat-Race Coupler Calculation"),
          backgroundColor: const Color(0xFFF5F6FA),
          surfaceTintColor: Colors.transparent,
          titleTextStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
          bottom: const TabBar(
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.indigo,
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
            _buildSimulationView(),
            const _CouplerSchematicOnlyView(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool narrow = constraints.maxWidth < 950;

        if (narrow) {
          return Column(
            children: [
              Expanded(
                child: _buildLeftPanel(),
              ),
              const Divider(height: 1, color: Colors.black12),
              SizedBox(
                height: 360,
                width: double.infinity,
                child: Container(
                  color: const Color(0xFFFAFAFA),
                  child: SourceMotion(controller: controllerSource),
                ),
              ),
            ],
          );
        }

        final double leftWidth =
            (constraints.maxWidth * 0.58).clamp(460.0, 760.0).toDouble();

        return Row(
          children: [
            SizedBox(
              width: leftWidth,
              child: _buildLeftPanel(),
            ),
            VerticalDivider(width: 1, color: Colors.grey.shade200),
            Expanded(
              child: Container(
                color: const Color(0xFFFAFAFA),
                child: SourceMotion(controller: controllerSource),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      color: Colors.white,
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          primary: true,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              ParamEditor(sourceController: controllerSource),
              PolarizationSteps(controller: controllerSource),
            ],
          ),
        ),
      ),
    );
  }
}

class _CouplerSchematicOnlyView extends StatelessWidget {
  const _CouplerSchematicOnlyView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Image.asset(
        'assets/images/coupler_schematic.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Schematic image not found.\n\n"
              "Please place the image at:\n"
              "assets/images/coupler_schematic.png",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        },
      ),
    );
  }
}
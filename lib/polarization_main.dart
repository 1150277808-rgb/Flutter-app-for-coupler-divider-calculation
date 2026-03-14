import 'package:flutter/material.dart';

import 'package:polarization/polarization_input.dart';
import 'package:polarization/polarization_step.dart';
import 'package:polarization/polarization_source.dart';

import 'package:polarization/shared/scroll/scroll.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Step-by-Step Guide for EM Polarization',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Step-by-Step Guide for EM Polarization'),
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
    );
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  GlobalKey sourceStepKey = GlobalKey();
  SourceController controllerSource = SourceController();

  @override
  void initState() {
    super.initState();
    // controllerSource.init();
    controllerSource.addListener(_sourceUpdate);
  }

  @override
  void dispose() {
    controllerSource.dispose();
    super.dispose();
  }

  void _sourceUpdate() {
    // setState(() {});
    // sourceStepKey.currentState?.initState();
    sourceStepKey.currentState?.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title, maxLines: 2, overflow: TextOverflow.ellipsis,),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            ParamEditor(
              sourceController: controllerSource,
            ),
            PolarizationSteps(
              key: sourceStepKey,
              controller: controllerSource, 
            ),
            // SourceWave(
            //   key: sourceWaveKey,
            //   controller: controllerSource,
            // ),
            // Source(
            //   waveKey: sourceWaveKey,
            //   motionKey: sourceMotionKey,
            //   controller: controllerSource,
            // ),
          ],
        ),
      ),
    );
  }
}




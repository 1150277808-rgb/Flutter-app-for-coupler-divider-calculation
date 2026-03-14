import 'package:flutter/material.dart';

// to solve the problem that scroll not working in desktop and browser
// check https://stackoverflow.com/questions/71338242/
import 'package:flutter/gestures.dart';

// to solve the problem that scroll not working in desktop and browser
class MyCustomScrollBehavior extends MaterialScrollBehavior {
 // Override behavior methods and getters like dragDevices
 @override
 Set<PointerDeviceKind> get dragDevices => {
   PointerDeviceKind.touch,
   PointerDeviceKind.mouse,
   PointerDeviceKind.trackpad,
   PointerDeviceKind.stylus,
   // etc.
 };
}
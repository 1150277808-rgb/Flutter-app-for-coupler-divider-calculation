import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';



class Steps3 extends StatefulWidget {
  const Steps3({
    super.key,
    required this.steps,
  });

  final List<List<List>> steps;

  //  [ // body
  //    [ // first step
  //      [ // heading
  //      ],
  //      [ // substep
  //        [ // heading
  //        ],
  //        [ // content
  //        ],
  //      ],
  //      [ // substep
  //        [ // heading
  //        ],
  //        [ // content
  //        ],
  //      ],
  //      ...
  //    ],
  //    [ // second step
  //      [ // heading
  //      ],
  //      [ // substep
  //        [ // heading
  //        ],
  //        [ // content
  //        ],
  //      ],
  //      ...
  //    ],
  //    ...
  //  ]


  static Widget genHeading(int stepNo, String heading) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        'Step $stepNo: $heading',
        style: TextStyle(fontSize: 20),
      ), 
    );
  }

  static Widget genText(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        text, 
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.left,
        softWrap: true,
      ),

    );
  }

  static Widget genEqL(String eq) {
    return Container(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(2),
        scrollDirection: Axis.horizontal,
        child: Math.tex(
          eq, 
          mathStyle: MathStyle.display,
          textStyle: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  static Widget genEq(String eq) {
    return Container(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(2),
        scrollDirection: Axis.horizontal,
        child: Math.tex(
          eq, 
          mathStyle: MathStyle.display,
          textStyle: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  static Widget genGeneral(Widget subWidget) {
    return Container(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(2),
        scrollDirection: Axis.horizontal,
        child: subWidget, 
      ),
    );
  }



  @override
  State<Steps3> createState() => _Steps3State();
}

class _Steps3State extends State<Steps3> {

  List<List<List>> _steps = [];
  List<List<bool>> _expanded = [];

  @override
  void initState() {
    super.initState();
    _steps = widget.steps;
    _resetDisplay();
  }

  @override
  void didUpdateWidget(covariant Steps3 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.steps != oldWidget.steps) {
      setState(() {
        _steps = widget.steps;
        _resetDisplay();
      });
    }
  }

  void _resetDisplay() {
    while (_expanded.length < _steps.length) {
      _expanded.add([false]);
    }
    for (var i = 0; i < _steps.length; i++) {
      while (_expanded[i].length < _steps[i].length) {
        _expanded[i].add(false);
      }
    }
  }

  Widget _genSubStep(int index, int superIndex, List<List<Widget>> content) {

    // parameter [content] be like
    // [ // substep
    //   [ // [0] heading
    //   ],
    //   [ // [1] content
    //   ],
    // ],
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
      child: InkWell(
        onTap: () {
          setState(() {
            _expanded[superIndex][index] = !_expanded[superIndex][index];
          });
        },
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.blue[50], 
            border: Border.all(
              color: Colors.grey, 
              width: 2.0, 
              style: BorderStyle.solid
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: _expanded[superIndex][0] ? (
              _expanded[superIndex][index] ? (
                [...content[0], Divider(height: 10), ...content[1]]
              ) : (
                [...content[0]]
              )
            ) : (
              []
            ),
          ),
        ),
      ),
    );
  }

  Widget _genStep(int index, List<List<dynamic>> content) {

    // input [content] be like
    // [ // index-th step
    //   [ // [0] heading
    //   ],
    //   [ // [1] substep
    //     [ // heading
    //     ],
    //     [ // content
    //     ],
    //   ],
    //   [ // [2] substep
    //     [ // heading
    //     ],
    //     [ // content
    //     ],
    //   ],
    //   ...
    // ],

    List<Widget> w = List<Widget>.from(content[0]);
    if (_expanded[index][0] == true) {
      if (content.length > 1) {
        w.add(Divider(height: 20));
        for (int i = 1; i < content.length; i++) {
          w.add(_genSubStep(i, index, List<List<Widget>>.from(content[i])));
        }
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      child: InkWell(
        onTap: () {
          setState(() {
            _expanded[index][0] = !_expanded[index][0];
          });
        },
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[50], 
            border: Border.all(
              color: Colors.grey, 
              width: 2.0, 
              style: BorderStyle.solid
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: w,
          ),
        ),
      ),
    );
  }

  List<Widget> _show() {
    List<Widget> displayingSteps = [];
    for (var i = 0; i < _steps.length; i++) {
      displayingSteps.add(
        _genStep(i, _steps[i])
      );
    }
    return displayingSteps;
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ..._show(),
        // TextButton(
        //   onPressed: () {
        //     print('steps: $_steps');
        //     print('expanded: $_expanded');
        //   }, 
        //   child: Text('test'),
        // ),
      ],
    );
  }
}
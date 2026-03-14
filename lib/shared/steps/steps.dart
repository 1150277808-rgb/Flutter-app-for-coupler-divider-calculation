import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';



class Steps extends StatefulWidget {
  const Steps({
    super.key,
    required this.steps,
  });

  final List<List> steps;



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
  State<Steps> createState() => _StepsState();
}

class _StepsState extends State<Steps> {

  int _stepShown = 1;
  List<List> _steps = [];
  List<bool> _expanded = [];

  @override
  void initState() {
    super.initState();
    _steps = widget.steps;
    _resetDisplay();
  }

  @override
  void didUpdateWidget(covariant Steps oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.steps != oldWidget.steps) {
      setState(() {
        _steps = widget.steps;
        _resetDisplay();
      });
    }
  }

  void _resetDisplay() {
    // _stepShown = 1;
    while (_expanded.length < _steps.length) {
      _expanded.add(false);
    }
    // _expanded.fillRange(0, _expanded.length, false);
  }


  Widget _genStep(int index, Widget heading, List<Widget> content) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      child: InkWell(
        onTap: () {
          setState(() {
            _expanded[index] = !_expanded[index];
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
            children: _expanded[index] ? [heading, Divider(height: 20,), ...content] : [heading],
          ),
        ),
      ),
    );
  }

  List<Widget> _show() {
    if (_stepShown > _steps.length) {
      _stepShown = 1;
    }
    List<Widget> displayingSteps = [];
    for (var i = 0; i < _stepShown; i++) {
      displayingSteps.add(
        _genStep(i, _steps[i][0], _steps[i][1])
      );
    }
    return displayingSteps;
  }



  Widget _button() {
    List<Widget> btnSR = [];
    if (_stepShown < _steps.length) {
      btnSR = [
        TextButton(
          onPressed: () {
            setState(() {
              _stepShown++;
            });
          }, 
          child: Text('next step'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _stepShown = _steps.length;
            });
          }, 
          child: Text('all steps'),
        ),
      ];
    }
    else {
      btnSR = [
        TextButton(
          onPressed: () {
            setState(() {
              _expanded.fillRange(0, _expanded.length, false);
              _stepShown = 1;
            });
          }, 
          child: Text('reset'),
        ),
      ];
    }

    Widget expanding;
    bool allExpanded = true;
    for (var v in _expanded) {
      allExpanded &= v;
    }
    if (allExpanded) {
      expanding = TextButton(
        onPressed: () {
          setState(() {
            _expanded.fillRange(0, _expanded.length, false);
          });
        }, 
        child: Text('collaspe all'),
      );
    }
    else {
      expanding = TextButton(
        onPressed: () {
          setState(() {
            _expanded.fillRange(0, _expanded.length, true);
          });
        }, 
        child: Text('expand all'),
      );
    }

    return Container(
      width: 400,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [...btnSR, expanding],
      )
    );
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _button(),
        ..._show(),
        _button(),
      ],
    );
  }
}
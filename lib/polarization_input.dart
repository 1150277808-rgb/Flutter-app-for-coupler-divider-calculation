import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:polarization/polarization_globalvar.dart';
import 'package:polarization/shared/senum/senum.dart';
import 'package:polarization/polarization_symbols.dart';
import 'package:polarization/polarization_source.dart';
part 'polarization_inputPreset.dart';


/// TODO: accept H-field and convert to E-field! 
/// see Example 12.19
/// nabla cross H = j omega epsilon E
/// FURTHER: accept exp format



/// tricky way to pass value by reference (by value in default)
class ValuePasser<T> {
  T val;
  ValuePasser(this.val);
}


class ParamEditor extends StatefulWidget {
  const ParamEditor({
    super.key,
    this.sourceController,
  });

  final SourceController? sourceController;

  @override
  State<ParamEditor> createState() => _ParamEditorState();
}

class _ParamEditorState extends State<ParamEditor> {

  // double deltaT = 0.5;

  late SourceController controller;

  // time domain
  // Eq. 12.127
  // Ex = |Ex| cos(wt-bz+p1)
  // Ey = |Ey| cos(wt-bz+p2)
  // E  = Ex + Ey

  // where w = 2pi f
  // and b = w sqrt(ue) = w / c_medium

  // for omega and beta, they are the same between x and y axis
  final controllerParamOmega = TextEditingController();
  final controllerParamBeta = TextEditingController();

  ValuePasser<Sign> paramBetaSign = ValuePasser(Sign.minus);

  SourceField type = SourceField.ep;

  // et
  final controllerParamEtEx = TextEditingController();
  final controllerParamEtEy = TextEditingController();
  final controllerParamEtPhix = TextEditingController();
  final controllerParamEtPhiy = TextEditingController();
  ValuePasser<AngleUnit> paramEtPhixUnit = ValuePasser(AngleUnit.deg);
  ValuePasser<AngleUnit> paramEtPhiyUnit = ValuePasser(AngleUnit.deg);
  ValuePasser<TriFunc> paramEtExTf = ValuePasser(TriFunc.cos);
  ValuePasser<TriFunc> paramEtEyTf = ValuePasser(TriFunc.cos);
  
  // ep
  final controllerParamEpExRe = TextEditingController();
  final controllerParamEpExIm = TextEditingController();
  final controllerParamEpEyRe = TextEditingController();
  final controllerParamEpEyIm = TextEditingController();
  final controllerParamEpExAbs = TextEditingController();
  final controllerParamEpExArg = TextEditingController();
  final controllerParamEpEyAbs = TextEditingController();
  final controllerParamEpEyArg = TextEditingController();
  ValuePasser<ComplexFormat> paramEpExFmt = ValuePasser(ComplexFormat.rect);
  ValuePasser<ComplexFormat> paramEpEyFmt = ValuePasser(ComplexFormat.rect);
  ValuePasser<AngleUnit> paramEpExAngleUnit = ValuePasser(AngleUnit.deg);
  ValuePasser<AngleUnit> paramEpEyAngleUnit = ValuePasser(AngleUnit.deg);

  // et
  final controllerParamMtHx = TextEditingController();
  final controllerParamMtHy = TextEditingController();
  final controllerParamMtPhix = TextEditingController();
  final controllerParamMtPhiy = TextEditingController();
  ValuePasser<AngleUnit> paramMtPhixUnit = ValuePasser(AngleUnit.deg);
  ValuePasser<AngleUnit> paramMtPhiyUnit = ValuePasser(AngleUnit.deg);
  ValuePasser<TriFunc> paramMtHxTf = ValuePasser(TriFunc.cos);
  ValuePasser<TriFunc> paramMtHyTf = ValuePasser(TriFunc.cos);

  // ep
  final controllerParamMpHxRe = TextEditingController();
  final controllerParamMpHxIm = TextEditingController();
  final controllerParamMpHyRe = TextEditingController();
  final controllerParamMpHyIm = TextEditingController();
  final controllerParamMpHxAbs = TextEditingController();
  final controllerParamMpHxArg = TextEditingController();
  final controllerParamMpHyAbs = TextEditingController();
  final controllerParamMpHyArg = TextEditingController();
  ValuePasser<ComplexFormat> paramMpHxFmt = ValuePasser(ComplexFormat.rect);
  ValuePasser<ComplexFormat> paramMpHyFmt = ValuePasser(ComplexFormat.rect);
  ValuePasser<AngleUnit> paramMpHxAngleUnit = ValuePasser(AngleUnit.deg);
  ValuePasser<AngleUnit> paramMpHyAngleUnit = ValuePasser(AngleUnit.deg);

  //hxx
  // planewave
  final controllerOmega = TextEditingController();
  final controllerFreq = TextEditingController();

  final controllerEpsilon = TextEditingController();
  final controllerMu = TextEditingController();
  // final controllerSigma = TextEditingController(text: '1000');

  final controllerEpsilonR2 = TextEditingController();
  final controllerMuR2 = TextEditingController();
  final controllerSigma2 = TextEditingController();


  final controllerThetaI = TextEditingController();
  ValuePasser<AngleUnit> paramAngleUnit = ValuePasser(AngleUnit.deg);
  ValuePasser<FreqUnit> paramFreqUnit = ValuePasser(FreqUnit.mhz);
  final controllerParamKx = TextEditingController();
  final controllerParamKz = TextEditingController();

  late String givenFreq;

  @override
  void initState() {
    super.initState();

    controller = widget.sourceController ?? SourceController();

    setParam({
      // 'omega': '1000000',
      'beta': '0.003333',
      'EtEx': '10',
      'EtEy': '10',
      'EtPhix': '-120',
      'EtPhiy': '150',
      'EtPhixUnit': AngleUnit.deg,
      'EtPhiyUnit': AngleUnit.deg,
      'EtExTf': TriFunc.cos,
      'EtEyTf': TriFunc.sin,
      'EpExRe': '5',
      'EpExIm': '0',
      'EpEyRe': '0',
      'EpEyIm': '-5',
      'EpExAbs': '5',
      'EpExArg': '0',
      'EpEyAbs': '5',
      'EpEyArg': '-90',
      'EpExFmt': ComplexFormat.polar,
      'EpEyFmt': ComplexFormat.polar,
      'EpExAngleUnit': AngleUnit.deg,
      'EpEyAngleUnit': AngleUnit.deg,
      'MtHx': '0',
      'MtHy': '1',
      'MtPhix': '0',
      'MtPhiy': '0',
      'MtPhixUnit': AngleUnit.npi,
      'MtPhiyUnit': AngleUnit.npi,
      'MtHxTf': TriFunc.cos,
      'MtHyTf': TriFunc.cos,
      'MpHxRe': '0',
      'MpHxIm': '0',
      'MpHyRe': '1',
      'MpHyIm': '0',
      'MpHxAbs': '0',
      'MpHxArg': '0',
      'MpHyAbs': '1',
      'MpHyArg': '0',
      'MpHxFmt': ComplexFormat.rect,
      'MpHyFmt': ComplexFormat.rect,
      'MpHxAngleUnit': AngleUnit.npi,
      'MpHyAngleUnit': AngleUnit.npi,
      'BetaSign': Sign.minus,
      'SourceType':SourceField.ep,

      // New parameters
      'freq': '318',
      'freqUnit': FreqUnit.mhz,
      'epsr_1':'2.25',
      'epsr_2':'1',
      'mur_1':'1',
      'mur_2':'1',
      'sigma_2':'0',
      'k_x': '8',
      'k_z': '6',
      'givenFreq': 'false',
      // 'omega': '1000000',
      // 'beta': '0.003333',
      // 'EtEx': '1',
      // 'EtEy': '1',
      // 'EtPhix': '0',
      // 'EtPhiy': '0.5',
      // 'EtPhixUnit': AngleUnit.npi,
      // 'EtPhiyUnit': AngleUnit.npi,
      // 'EtExTf': TriFunc.cos,
      // 'EtEyTf': TriFunc.cos,
      // 'EpExRe': '1',
      // 'EpExIm': '0',
      // 'EpEyRe': '0',
      // 'EpEyIm': '1',
      // 'EpExAbs': '1',
      // 'EpExArg': '0',
      // 'EpEyAbs': '1',
      // 'EpEyArg': '0.5',
      // 'EpExFmt': ComplexFormat.rect,
      // 'EpEyFmt': ComplexFormat.rect,
      // 'EpExAngleUnit': AngleUnit.npi,
      // 'EpEyAngleUnit': AngleUnit.npi,
      // 'MtHx': '-1',
      // 'MtHy': '1',
      // 'MtPhix': '0.5',
      // 'MtPhiy': '0',
      // 'MtPhixUnit': AngleUnit.npi,
      // 'MtPhiyUnit': AngleUnit.npi,
      // 'MtHxTf': TriFunc.cos,
      // 'MtHyTf': TriFunc.cos,
      // 'MpHxRe': '0',
      // 'MpHxIm': '-1',
      // 'MpHyRe': '1',
      // 'MpHyIm': '0',
      // 'MpHxAbs': '-1',
      // 'MpHxArg': '0.5',
      // 'MpHyAbs': '1',
      // 'MpHyArg': '0',
      // 'MpHxFmt': ComplexFormat.rect,
      // 'MpHyFmt': ComplexFormat.rect,
      // 'MpHxAngleUnit': AngleUnit.npi,
      // 'MpHyAngleUnit': AngleUnit.npi,
    });

  }

  @override
  void dispose() {
    controllerParamOmega.dispose();
    controllerParamBeta.dispose();
    
    controllerParamEtEx.dispose();
    controllerParamEtEy.dispose();
    controllerParamEtPhix.dispose();
    controllerParamEtPhiy.dispose();

    controllerParamEpExRe.dispose();
    controllerParamEpExIm.dispose();
    controllerParamEpEyRe.dispose();
    controllerParamEpEyIm.dispose();
    controllerParamEpExAbs.dispose();
    controllerParamEpExArg.dispose();
    controllerParamEpEyAbs.dispose();
    controllerParamEpEyArg.dispose();

    controllerParamMtHx.dispose();
    controllerParamMtHy.dispose();
    controllerParamMtPhix.dispose();
    controllerParamMtPhiy.dispose();

    controllerParamMpHxRe.dispose();
    controllerParamMpHxIm.dispose();
    controllerParamMpHyRe.dispose();
    controllerParamMpHyIm.dispose();
    controllerParamMpHxAbs.dispose();
    controllerParamMpHxArg.dispose();
    controllerParamMpHyAbs.dispose();
    controllerParamMpHyArg.dispose();

    super.dispose();
  }

  TextStyle equationMathStyle = const TextStyle(
    // fontSize: 16,
  );
  TextStyle equationTextStyle = const TextStyle(
    fontFamily: 'Euclid',
    // fontSize: 16,
  );

  Widget equationFixed(String eq) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Math.tex(
        eq,
        textStyle: equationMathStyle,
      ),
    );
  }

  Widget equationHidden(String hidden, String show, {AlignmentGeometry alignment = AlignmentDirectional.centerStart}) {
    return Stack(
      alignment: alignment,
      children: [
        Container(
          color: Colors.transparent,
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Math.tex(
            hidden,
            mathStyle: MathStyle.display,
            textStyle: TextStyle(color: Colors.transparent, decorationColor: Colors.transparent),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Math.tex(
            show,
            textStyle: equationMathStyle,
          ),
        )
      ],
    );
  }

  Widget equationParamPositive(String symbol, TextEditingController controller, {String unit = '', double width = 60}) {
    return Container(
      width: width,
      child: TextField(
        controller: controller,

        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.bottom,

        style: equationTextStyle,

        // onSubmitted: (value) {
        //   updateParamToController();
        // },
        // onEditingComplete:() {
        //   updateParamToController();
        // },

        onTapOutside: (event){
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
            updateParamToController();
          }
        },

        keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          FocusScope.of(context).unfocus();
          updateParamToController();
        },

        
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'(^\d+\.?\d*)')),
        ],
        decoration: InputDecoration(
          label: Math.tex(
            symbol,
            textStyle: equationMathStyle,
          ),
          floatingLabelAlignment: FloatingLabelAlignment.center,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          alignLabelWithHint: true,

          suffix: Math.tex(
            unit,
            textStyle: equationMathStyle,
          ),
          // suffixText: unit,
        ),
      ),
    );
  }

  Widget equationParamReal(String symbol, TextEditingController controller, {String unit = '', double width = 60}) {
    return Container(
      width: width,
      child: TextField(
        controller: controller,

        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.bottom,

        style: equationTextStyle,

        // onSubmitted: (value) {
        //   updateParamToController();
        // },
        // onEditingComplete:() {
        //   updateParamToController();
        // },
        onTapOutside: (event){
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
            updateParamToController();
          }
        },

        keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          FocusScope.of(context).unfocus();
          updateParamToController();
        },

        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'(^(\-?|\+?)\d+\.?\d*)|(^(\-?|\+?)$)')),
        ],
        decoration: InputDecoration(
          label: Math.tex(
            symbol,
            textStyle: equationMathStyle,
          ),
          floatingLabelAlignment: FloatingLabelAlignment.center,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          alignLabelWithHint: true,

          suffix: Math.tex(
            unit,
            textStyle: equationMathStyle,
          ),
        ),
      ),
    );
  }

  Widget equationBetaSign(ValuePasser<Sign> sign) {
    return Container(
      width: 14,
      child: DropdownButtonFormField(
        value: sign.val,
        isDense: true,
        isExpanded: true,
        iconSize: 0,
        decoration: InputDecoration(labelText: ''),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        focusColor: Color.fromARGB(0, 255, 255, 255),
        onChanged: (value) {
          setState(() {
            sign.val = value ?? sign.val;
            updateParamToController();
          });
        },
        items: Sign.values.map<DropdownMenuItem<Sign>>(
          (e) => DropdownMenuItem<Sign>(
            value: e, 
            child: Text(
              e.t, 
              style: equationTextStyle
            ),
          )
        ).toList(),
        selectedItemBuilder: (context) => Sign.values.map<Widget>(
          (e) => Math.tex(
            e.t, 
            textStyle: equationMathStyle,
          ),
        ).toList(),
      ),
    );
  }

  Widget equationBetaSignExp(ValuePasser<Sign> sign) {
    return Container(
      width: 40,
      child: DropdownButtonFormField(
        value: sign.val,
        isDense: true,
        isExpanded: true,
        iconSize: 0,
        decoration: InputDecoration(labelText: ''),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        focusColor: Color.fromARGB(0, 255, 255, 255),
        onChanged: (value) {
          setState(() {
            sign.val = value ?? sign.val;
            updateParamToController();
          });
        },
        items: Sign.values.map<DropdownMenuItem<Sign>>(
          (e) => DropdownMenuItem<Sign>(
            value: e, 
            child: Text(
              e.t, 
              style: equationTextStyle
            ),
          )
        ).toList(),
        selectedItemBuilder: (context) => Sign.values.map<Widget>(
          (e) => Math.tex(
            e.e, 
            textStyle: equationMathStyle,
          ),
        ).toList(),
      ),
    );
  }

  Widget equationTriFunc(ValuePasser<TriFunc> func) {
    return Container(
      width: 26,
      child: DropdownButtonFormField(
        value: func.val,
        isDense: true,
        isExpanded: true,
        iconSize: 0,
        decoration: InputDecoration(labelText: ''),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        focusColor: Color.fromARGB(0, 255, 255, 255),
        onChanged: (value) {
          setState(() {
            func.val = value ?? func.val;
            updateParamToController();
          });
        },
        items: TriFunc.values.map<DropdownMenuItem<TriFunc>>(
          (e) => DropdownMenuItem<TriFunc>(
            value: e, 
            child: Text(
              e.name, 
              style: equationTextStyle
            ),
          )
        ).toList(),
        selectedItemBuilder: (context) => TriFunc.values.map<Widget>(
          (e) => Math.tex(
            e.tex, 
            textStyle: equationMathStyle,
          ),
        ).toList(),
      ),
    );
  }

  Widget equationFreqUnit(ValuePasser<FreqUnit> unit) {
    return Container(
      width: 40,

      child: DropdownButtonFormField(
        value: unit.val,
        isDense: true,
        isExpanded: true,
        iconSize: 0,
        decoration: InputDecoration(labelText: ''),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        focusColor: Color.fromARGB(0, 255, 255, 255),
        onChanged: (value) {
          setState(() {
            unit.val = value ?? unit.val;
            updateParamToController();
          });
        },
        items: FreqUnit.values.map<DropdownMenuItem<FreqUnit>>(
          (e) => DropdownMenuItem<FreqUnit>(
            value: e, 
            // child: Math.tex(e.texUnit),
            child: Text(
              e.abbr, 
              // style: equationTextStyle
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 10,
              ),
            ),
          )
        ).toList(),
        selectedItemBuilder: (context) => FreqUnit.values.map<Widget>(
          (e) => Math.tex(
            e.texUnit,
            textStyle: equationMathStyle,
          ),
        ).toList(),
      ),
    );
  }

  Widget equationAngleUnit(ValuePasser<AngleUnit> unit) {
    return Container(
      width: 40,

      child: DropdownButtonFormField(
        value: unit.val,
        isDense: true,
        isExpanded: true,
        iconSize: 0,
        decoration: InputDecoration(labelText: ''),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        focusColor: Color.fromARGB(0, 255, 255, 255),
        onChanged: (value) {
          setState(() {
            unit.val = value ?? unit.val;
            updateParamToController();
          });
        },
        items: AngleUnit.values.map<DropdownMenuItem<AngleUnit>>(
          (e) => DropdownMenuItem<AngleUnit>(
            value: e, 
            // child: Math.tex(e.texUnit),
            child: Text(
              e.unit, 
              // style: equationTextStyle
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 10,
              ),
            ),
          )
        ).toList(),
        selectedItemBuilder: (context) => AngleUnit.values.map<Widget>(
          (e) => Math.tex(
            e.texUnit,
            textStyle: equationMathStyle,
          ),
        ).toList(),
      ),
    );
  }

  List<Widget> equationAngle(
    String symbol,
    TextEditingController controller,
    ValuePasser<AngleUnit> unit,
  ) {
    return [
      equationParamReal(symbol, controller, width: 60),
      equationAngleUnit(unit),
    ];
  }

  List<Widget> equationFreq(
    String symbol,
    TextEditingController controller,
    ValuePasser<FreqUnit> unit,
  ) {
    return [
      equationParamReal(symbol, controller, width: 60),
      equationFreqUnit(unit),
    ];
  }

  List<Widget> equationComplex(
    String symbolRe,
    String symbolIm,
    String symbolAbs,
    String symbolArg,
    ValuePasser<ComplexFormat> fmt,
    ValuePasser<AngleUnit> angleUnit,
    TextEditingController controllerRe,
    TextEditingController controllerIm,
    TextEditingController controllerAbs,
    TextEditingController controllerArg,
  ) {
    List<Widget> complex = [];
    if (fmt.val == ComplexFormat.rect) {
      complex = [
        equationFixed(r'('),
        equationParamReal(symbolRe, controllerRe),
        equationFixed(r' + j'),
        equationParamReal(symbolIm, controllerIm, width: 60),
        equationFixed(r')'),
      ];
    }
    else if (fmt.val == ComplexFormat.polar) {
      complex = [
        equationFixed(r'('),
        equationParamReal(symbolAbs, controllerAbs),
        equationFixed(r'\angle'),
        ...equationAngle(symbolArg, controllerArg, angleUnit),
        equationFixed(r')'),
      ];
    }
    else {
      complex = [
        Placeholder(),
      ];
    }

    complex.add(
      Container(
        width: 24,
        child: PopupMenuButton<ComplexFormat>(
        tooltip: '',
        onSelected: (value) {
          setState(() {
            fmt.val = value;
            updateParamToController();
          });
        },
        itemBuilder:(context) => ComplexFormat.values.map(
          (e) => PopupMenuItem<ComplexFormat>(
            value: e,
            child: SizedBox(
              width: 60,
              child: Text(
                e.name,
                style: equationTextStyle,
              ),
            ),
          ),
        ).toList(),
        child: InputDecorator(
          decoration: InputDecoration(labelText: '', ),
          child: Icon(Icons.arrow_drop_down),
        ),
      ),
        // child: DropdownButtonFormField(
        //   value: fmt.val,
        //   isDense: true,
        //   isExpanded: true,
        //   decoration: InputDecoration(
        //     labelText: '',
        //     border: InputBorder.none,
        //   ),
        //   borderRadius: BorderRadius.all(Radius.circular(8)),
        //   focusColor: Color.fromARGB(0, 255, 255, 255),
        //   onChanged: (value) {
        //     setState(() {
        //       fmt.val = value ?? fmt.val;
        //     });
        //   },
        //   items: ComplexFormat.values.map<DropdownMenuItem<ComplexFormat>>(
        //     (e) => DropdownMenuItem<ComplexFormat>(
        //       value: e, 
        //       child: Text(
        //         e.engRepresentation, 
        //         style: equationTextStyle,
        //       ),
        //     )
        //   ).toList(),
        //   selectedItemBuilder: (context) => ComplexFormat.values.map<Widget>(
        //     (e) => SizedBox.shrink(),
        //   ).toList(),
        // ),
      ),
    );

    return complex;
  }

  void updateParamToController() {
    try {
      setState(() {
        // update to controller
        switch (type) {
          case SourceField.et:
            paramEt = {
              'Ex': double.parse(controllerParamEtEx.text),
              'Ey': double.parse(controllerParamEtEy.text),
              'trix': paramEtExTf.val,
              'triy': paramEtEyTf.val,
              'phix': angleParser(paramEtPhixUnit, controllerParamEtPhix),
              'phiy': angleParser(paramEtPhiyUnit, controllerParamEtPhiy),
              'sign': paramBetaSign.val,
            };
            break;
          case SourceField.ep:
            paramEp = {
              'Ex': complexParser(
                paramEpExFmt,
                controllerParamEpExRe,
                controllerParamEpExIm,
                controllerParamEpExAbs,
                controllerParamEpExArg,
                paramEpExAngleUnit, 
              ),
              'Ey': complexParser(
                paramEpEyFmt,
                controllerParamEpEyRe,
                controllerParamEpEyIm,
                controllerParamEpEyAbs,
                controllerParamEpEyArg,
                paramEpEyAngleUnit, 
              ),
              'sign': paramBetaSign.val,
            };
            break;
          case SourceField.mt:
            paramMt = {
              'Hx': double.parse(controllerParamMtHx.text),
              'Hy': double.parse(controllerParamMtHy.text),
              'trix': paramMtHxTf.val,
              'triy': paramMtHyTf.val,
              'phix': angleParser(paramMtPhixUnit, controllerParamMtPhix),
              'phiy': angleParser(paramMtPhiyUnit, controllerParamMtPhiy),
              'sign': paramBetaSign.val,
            };
            break;
          case SourceField.mp:
            paramMp = {
              'Hx': complexParser(
                paramMpHxFmt,
                controllerParamMpHxRe,
                controllerParamMpHxIm,
                controllerParamMpHxAbs,
                controllerParamMpHxArg,
                paramMpHxAngleUnit,
              ),
              'Hy': complexParser(
                paramMpHyFmt,
                controllerParamMpHyRe,
                controllerParamMpHyIm,
                controllerParamMpHyAbs,
                controllerParamMpHyArg,
                paramMpHyAngleUnit,
              ),
              'sign': paramBetaSign.val,
            };
            break;
        }
      });
      
      // Media Parameters
      epsilonR1 = double.tryParse(controllerEpsilon.text) ?? 1.0;
      epsilonR2 = double.tryParse(controllerEpsilonR2.text) ?? 1.0;
      muR1 = double.tryParse(controllerMu.text)?? 1.0;
      muR2 = double.tryParse(controllerMuR2.text) ?? 1.0;
      sigma2 = double.tryParse(controllerSigma2.text) ?? 0.0;
      
      
      // Given kx, kz or Theta_i
      if (double.tryParse(controllerParamKx.text)==null || double.tryParse(controllerParamKz.text)==null){
        isGivenThetai = true;
        angleI = angleParser(paramAngleUnit, controllerThetaI);
      }
      else{
        isGivenThetai = false;
        kx = double.parse(controllerParamKx.text);
        kz = double.parse(controllerParamKz.text);
        // controllerThetaI.text = con
      }

      // Given Omega or Freq
      // omega = double.parse(controllerOmega.text);
      if (double.tryParse(controllerFreq.text)!=null){
        isGivenFreq = true;
        freq = freqParser(paramFreqUnit, controllerFreq);
        omega = freqParser(paramFreqUnit, controllerFreq) * 2 * pi;
      }
      else{
        isGivenFreq = true;
        omega = double.parse(controllerOmega.text);
        freq = omega / 2 / pi;
      }

      if(givenFreq == 'true'){
        isGivenFreq = true;
      }
      else{
        isGivenFreq = false;
      }


      controller.update();


      try {
        // get other fields from controller
        setState(() {
          switch (type) {
            case SourceField.et:
              Complex epEx = paramEp['Ex'] as Complex;
              
              controllerParamEpExRe.text = epEx.re.toStringAsPrecision(4);
              controllerParamEpExIm.text = epEx.im.toStringAsPrecision(4);
              controllerParamEpExAbs.text = epEx.modulus.toStringAsPrecision(4);
              controllerParamEpExArg.text = epEx.arg.ori.toStringAsPrecision(4);
              paramEpExAngleUnit.val = epEx.arg.src;
              Complex epEy = paramEp['Ey'] as Complex;
              
              controllerParamEpEyRe.text = epEy.re.toStringAsPrecision(4);
              controllerParamEpEyIm.text = epEy.im.toStringAsPrecision(4);
              controllerParamEpEyAbs.text = epEy.modulus.toStringAsPrecision(4);
              controllerParamEpEyArg.text = epEy.arg.ori.toStringAsPrecision(4);
              paramEpEyAngleUnit.val = epEy.arg.src;
              break;
            case SourceField.ep:
              controllerParamEtEx.text = paramEt['Ex'].toStringAsPrecision(4);
              controllerParamEtEy.text = paramEt['Ey'].toStringAsPrecision(4);
              Angle etPhix = paramEt['phix'] as Angle;
              controllerParamEtPhix.text = etPhix.ori.toStringAsPrecision(4);
              paramEtPhixUnit.val = etPhix.src;
              Angle etPhiy = paramEt['phiy'] as Angle;
              controllerParamEtPhiy.text = etPhiy.ori.toStringAsPrecision(4);
              paramEtPhiyUnit.val = etPhiy.src;
              break;
            default:
          }
        });
      } catch (e) {
        print(e);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Internal error: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop(); 
                  },
                  child: Text('OK'),
                ),
              ],
            );
          }
        );
      }
      
    }
    catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please check whether there are any unfinished fields. '),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(); 
                },
                child: Text('OK'),
              ),
            ],
          );
        }
      );
    }
  }

  void setParam(Map<String, dynamic> p) {
    try {
      setState(() {
        controllerParamOmega.text = p['omega'] ?? controllerParamOmega.text;
        controllerParamBeta.text = p['beta'] ?? controllerParamBeta.text;

        controllerParamEtEx.text = p['EtEx'] ?? controllerParamEtEx.text;
        controllerParamEtEy.text = p['EtEy'] ?? controllerParamEtEy.text;
        controllerParamEtPhix.text = p['EtPhix'] ?? controllerParamEtPhix.text;
        controllerParamEtPhiy.text = p['EtPhiy'] ?? controllerParamEtPhiy.text;
        paramEtPhixUnit.val = p['EtPhixUnit'] ?? paramEtPhixUnit.val;
        paramEtPhiyUnit.val = p['EtPhiyUnit'] ?? paramEtPhiyUnit.val;
        paramEtExTf.val = p['EtExTf'] ?? paramEtExTf.val;
        paramEtEyTf.val = p['EtEyTf'] ?? paramEtEyTf.val;

        paramBetaSign.val = p['BetaSign'] ?? paramBetaSign.val;

        controllerParamEpExRe.text = p['EpExRe'] ?? controllerParamEpExRe.text;
        controllerParamEpExIm.text = p['EpExIm'] ?? controllerParamEpExIm.text;
        controllerParamEpEyRe.text = p['EpEyRe'] ?? controllerParamEpEyRe.text;
        controllerParamEpEyIm.text = p['EpEyIm'] ?? controllerParamEpEyIm.text;
        controllerParamEpExAbs.text = p['EpExAbs'] ?? controllerParamEpExAbs.text;
        controllerParamEpExArg.text = p['EpExArg'] ?? controllerParamEpExArg.text;
        controllerParamEpEyAbs.text = p['EpEyAbs'] ?? controllerParamEpEyAbs.text;
        controllerParamEpEyArg.text = p['EpEyArg'] ?? controllerParamEpEyArg.text;
        paramEpExFmt.val = p['EpExFmt'] ?? paramEpExFmt.val;
        paramEpEyFmt.val = p['EpEyFmt'] ?? paramEpEyFmt.val;
        paramEpExAngleUnit.val = p['EpExAngleUnit'] ?? paramEpExAngleUnit.val;
        paramEpEyAngleUnit.val = p['EpEyAngleUnit'] ?? paramEpEyAngleUnit.val;

        controllerParamMtHx.text = p['MtHx'] ?? controllerParamMtHx.text;
        controllerParamMtHy.text = p['MtHy'] ?? controllerParamMtHy.text;
        controllerParamMtPhix.text = p['MtPhix'] ?? controllerParamMtPhix.text;
        controllerParamMtPhiy.text = p['MtPhiy'] ?? controllerParamMtPhiy.text;
        paramMtPhixUnit.val = p['MtPhixUnit'] ?? paramMtPhixUnit.val;
        paramMtPhiyUnit.val = p['MtPhiyUnit'] ?? paramMtPhiyUnit.val;
        paramMtHxTf.val = p['MtHxTf'] ?? paramMtHxTf.val;
        paramMtHyTf.val = p['MtHyTf'] ?? paramMtHyTf.val;

        controllerParamMpHxRe.text = p['MpHxRe'] ?? controllerParamMpHxRe.text;
        controllerParamMpHxIm.text = p['MpHxIm'] ?? controllerParamMpHxIm.text;
        controllerParamMpHyRe.text = p['MpHyRe'] ?? controllerParamMpHyRe.text;
        controllerParamMpHyIm.text = p['MpHyIm'] ?? controllerParamMpHyIm.text;
        controllerParamMpHxAbs.text = p['MpHxAbs'] ?? controllerParamMpHxAbs.text;
        controllerParamMpHxArg.text = p['MpHxArg'] ?? controllerParamMpHxArg.text;
        controllerParamMpHyAbs.text = p['MpHyAbs'] ?? controllerParamMpHyAbs.text;
        controllerParamMpHyArg.text = p['MpHyArg'] ?? controllerParamMpHyArg.text;
        paramMpHxFmt.val = p['MpHxFmt'] ?? paramMpHxFmt.val;
        paramMpHyFmt.val = p['MpHyFmt'] ?? paramMpHyFmt.val;
        paramMpHxAngleUnit.val = p['MpHxAngleUnit'] ?? paramMpHxAngleUnit.val;
        paramMpHyAngleUnit.val = p['MpHyAngleUnit'] ?? paramMpHyAngleUnit.val;

        controllerFreq.text = p['freq'] ?? controllerFreq.text;
        paramFreqUnit.val = p['freqUnit'] ?? paramFreqUnit.val;
        controllerEpsilon.text = p['epsr_1'] ?? controllerEpsilon.text;
        controllerEpsilonR2.text = p['epsr_2'] ?? controllerEpsilonR2.text;
        controllerMu.text = p['mur_1'] ?? controllerMu.text;
        controllerMuR2.text = p['mur_2'] ?? controllerMuR2.text;
        controllerSigma2.text = p['sigma_2'] ?? controllerSigma2.text;
        controllerParamKx.text = p['k_x'] ?? '';
        controllerParamKz.text = p['k_z'] ?? '';

        controllerThetaI.text = p['thetaI'] ?? '';
        paramAngleUnit.val = p['thetaIUnit'] ?? paramAngleUnit.val;
        controllerOmega.text = p['omega'] ?? '';

        type = SourceField.ep;
        givenFreq = p['givenFreq'] ?? 'true';
      });
      updateParamToController();
    }
    catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Internal error: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(); 
                },
                child: Text('OK'),
              ),
            ],
          );
        }
      );
    }
  }

  // record of preset index
  int presetLinear = 0;
  int presetElliptical = 0;
  int presetCircular = 0;

  // void nextPreset(Preset type) {
  //   switch (type) {
  //     case Preset.linear:
  //       setParam(Preset.linear.profiles[presetLinear]);
  //       presetLinear++;
  //       presetLinear %= Preset.linear.profiles.length;
  //       break;
  //     case Preset.elliptical:
  //       setParam(Preset.elliptical.profiles[presetLinear]);
  //       presetLinear++;
  //       presetLinear %= Preset.elliptical.profiles.length;
  //       break;
  //     case Preset.circular:
  //       setParam(Preset.circular.profiles[presetLinear]);
  //       presetLinear++;
  //       presetLinear %= Preset.circular.profiles.length;
  //       break;
  //     default:
  //   }
  // }
  void nextPreset() {
    setParam(preset[presetLinear]);
        presetLinear++;
        presetLinear %= preset.length;
    // switch (type) {
    //   case Preset.linear:
    //     setParam(Preset.linear.profiles[presetLinear]);
    //     presetLinear++;
    //     presetLinear %= Preset.linear.profiles.length;
    //     break;
    //   case Preset.elliptical:
    //     setParam(Preset.elliptical.profiles[presetLinear]);
    //     presetLinear++;
    //     presetLinear %= Preset.elliptical.profiles.length;
    //     break;
    //   case Preset.circular:
    //     setParam(Preset.circular.profiles[presetLinear]);
    //     presetLinear++;
    //     presetLinear %= Preset.circular.profiles.length;
    //     break;
    //   default:
    // }
  }

  Angle angleParser(
    ValuePasser<AngleUnit> unit,
    TextEditingController valController,
  ) => switch(unit.val) {
    AngleUnit.deg => AngleDegree(double.parse(valController.text)),
    AngleUnit.rad => AngleRadian(double.parse(valController.text)),
    AngleUnit.npi => AngleDemiTurn(double.parse(valController.text))
  };

  double freqParser(
    ValuePasser<FreqUnit> unit,
    TextEditingController valController,
  ) => double.parse(valController.text) * unit.val.value;

  Complex complexParser(
    ValuePasser<ComplexFormat> fmt,
    TextEditingController reController,
    TextEditingController imController,
    TextEditingController absController,
    TextEditingController argController,
    ValuePasser<AngleUnit> argUnit
  ) => switch(fmt.val) {
    ComplexFormat.rect => ComplexRect(double.parse(reController.text), double.parse(imController.text)),
    ComplexFormat.polar => ComplexPolar(double.parse(absController.text), angleParser(argUnit, argController))
  };


  @override
  Widget build(BuildContext context) {

    Widget eq = switch (type) {
      SourceField.et => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              equationFixed('$symEt = $symAx'),
              equationParamReal('$symEtEx', controllerParamEtEx),
              equationTriFunc(paramEtExTf),
              equationFixed(r'('),
              equationFixed('$symOmega t '),
              equationBetaSign(paramBetaSign),
              equationFixed('$symBeta z + '),
              ...equationAngle(symEtPhix, controllerParamEtPhix, paramEtPhixUnit),
              equationFixed(r')'),
            ],
          ),
          Row(
            children: [
              equationHidden(r'E = \ ', r'+', alignment: Alignment.centerRight),
              equationFixed(symAy),
              equationParamReal('$symEtEy', controllerParamEtEy),
              equationTriFunc(paramEtEyTf),
              equationFixed(r'('),
              equationFixed('$symOmega t '),
              equationBetaSign(paramBetaSign),
              equationFixed('$symBeta z + '),
              ...equationAngle(symEtPhiy, controllerParamEtPhiy, paramEtPhiyUnit),
              equationFixed(r')'),
            ],
          ),
        ],
      ),
      
      SourceField.ep => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              //hxx
              equationFixed('$symEp _{i||} = (\\cos $symThetai $symAx  - \\sin $symThetai $symAz)'),
              //equationFixed('$symEp _{||} = $symAx'),
              ...equationComplex(
                '$symRe \\{ $symEpV \\}', 
                '$symIm \\{ $symEpV \\}', 
                '| $symEpV |', 
                '$symArg \\{ $symEpV \\}', 
                paramEpExFmt, 
                paramEpExAngleUnit, 
                controllerParamEpExRe, 
                controllerParamEpExIm, 
                controllerParamEpExAbs, 
                controllerParamEpExArg,
              ),

              //hxx
              //equationBetaSignExp(paramBetaSign),
              equationFixed('$symE ^{ -j $symKx \\mathbf{x} - j $symKz \\mathbf{z} }'),
              equationFixed(symExpJOmegaTCancel),
            ]
          ),
          Row(
            children: [
             // equationHidden(r'E = \ ', r'+', alignment: Alignment.centerRight),
             equationFixed('\\overrightarrow{E}_{i\\perp} = $symAy'),
              ...equationComplex(
                '$symRe \\{ $symEpH \\}', 
                '$symIm \\{ $symEpH \\}', 
                '| $symEpH |', 
                '$symArg \\{ $symEpH \\}', 
                paramEpEyFmt, 
                paramEpEyAngleUnit, 
                controllerParamEpEyRe, 
                controllerParamEpEyIm, 
                controllerParamEpEyAbs, 
                controllerParamEpEyArg,
              ),
              //equationBetaSignExp(paramBetaSign),
              equationFixed('$symE ^{ -j $symKx \\mathbf{x} - j $symKz \\mathbf{z} }'),
              equationFixed(symExpJOmegaTCancel),
            ],
          ),
        ],
      ),
      
      SourceField.mt => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              equationFixed('$symHt = $symAx'),
              equationParamReal(symMtHx, controllerParamMtHx),
              equationTriFunc(paramMtHxTf),
              equationFixed(r'('),
              equationFixed('$symOmega t '),
              equationBetaSign(paramBetaSign),
              equationFixed('$symBeta z + '),
              ...equationAngle(symMtPhix, controllerParamMtPhix, paramMtPhixUnit),
              equationFixed(r')'),
            ],
          ),
          Row(
            children: [
              equationHidden(r'H = \ ', r'+', alignment: Alignment.centerRight),
              equationFixed(symAy),
              equationParamReal(symMtHy, controllerParamMtHy),
              equationTriFunc(paramMtHyTf),
              equationFixed(r'('),
              equationFixed('$symOmega t '),
              equationBetaSign(paramBetaSign),
              equationFixed('$symBeta z + '),
              ...equationAngle(symMtPhiy, controllerParamMtPhiy, paramMtPhiyUnit),
              equationFixed(r')'),
            ],
          ),
        ],
      ),

      SourceField.mp => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              equationFixed('$symHp = $symAx'),
              ...equationComplex(
                '$symRe \\{ $symMpHx \\}', 
                '$symIm \\{ $symMpHx \\}', 
                '| $symMpHy |', 
                '$symArg \\{ $symMpHx \\}', 
                paramMpHxFmt, 
                paramMpHxAngleUnit, 
                controllerParamMpHxRe, 
                controllerParamMpHxIm, 
                controllerParamMpHxAbs, 
                controllerParamMpHxArg,
              ),
              equationBetaSignExp(paramBetaSign),
              equationFixed(symExpJOmegaTCancel),
            ],
          ),
          Row(
            children: [
              equationHidden(r'H = \ ', r'+', alignment: Alignment.centerRight),
              equationFixed(symAy),
              ...equationComplex(
                '$symRe \\{ $symMpHy \\}', 
                '$symIm \\{ $symMpHy \\}', 
                '| $symMpHy |', 
                '$symArg \\{ $symMpHy \\}', 
                paramMpHyFmt, 
                paramMpHyAngleUnit, 
                controllerParamMpHyRe, 
                controllerParamMpHyIm, 
                controllerParamMpHyAbs, 
                controllerParamMpHyArg,
              ),
              equationBetaSignExp(paramBetaSign),
              equationFixed(symExpJOmegaTCancel),
            ],
          ),
        ],
      ),
    };
    // UI builder
    return Container(
      child: Column(
        children: [
          // title, select input form
          // Container(
          //   width: 300,
          //   child: DropdownButtonFormField(
          //     value: type,
          //     isDense: true,
          //     isExpanded: true,
          //     decoration: InputDecoration(labelText: ''),
          //     borderRadius: BorderRadius.all(Radius.circular(8)),
          //     focusColor: Color.fromARGB(0, 255, 255, 255),
          //     onChanged: (value) {
          //       setState(() {
          //         type = value ?? type;
          //         updateParamToController();
          //       });
          //     },
          //     items: [SourceField.ep, SourceField.et].map<DropdownMenuItem<SourceField>>(
          //     // items: SourceField.values.map<DropdownMenuItem<SourceField>>(
          //       (e) => DropdownMenuItem<SourceField>(
          //         value: e, 
          //         child: Container(
          //           alignment: Alignment.center, 
          //           child: Text(e.name),
          //         ),
          //       )
          //     ).toList(),
          //     // items: SourceField.values.map<DropdownMenuItem<SourceField>>(
          //     //   (e) => DropdownMenuItem<SourceField>(
          //     //     value: e, 
          //     //     child: Container(
          //     //       alignment: Alignment.center, 
          //     //       child: Text(e.name),
          //     //     ),
          //     //   )
          //     // ).toList(),
          //   ),
          // ),
          const SizedBox(height: 5,),
          const Text('Incident wave expression', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          // equation
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: eq,
          ),
          const SizedBox(height: 18,),
          const Text('Incident wave parameters', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),),
          // eq,
          //hxx input parameters
           SingleChildScrollView(
            scrollDirection: Axis.horizontal,
             child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  equationFixed('$symThetai = '),
                  ...equationAngle('', controllerThetaI, paramAngleUnit),
                  const SizedBox(width: 20,),       
           
                  equationFixed('\\omega = '),
                  equationParamReal('', controllerOmega),
                  equationFixed('\\text{rad/s}'),
                  const SizedBox(width: 20,), 
           
                  equationFixed('f = '),
                  // equationParamReal('', controllerFreq),
                  ...equationFreq('', controllerFreq, paramFreqUnit),
                ]
              ),
           ),
            Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                equationFixed('\\overrightarrow{k}_i ='),
                equationParamReal(symKx, controllerParamKx),
                equationFixed('$symAx + '),
                equationParamReal(symKz, controllerParamKz),
                equationFixed(symAz)
              ],
            ), 
          const SizedBox(height: 18,),
          const Text('Medium parameters', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),),
           Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                equationFixed(r'\text{Medium 1: }\varepsilon_{r1} = '),
                equationParamReal('', controllerEpsilon),
                const SizedBox(width: 20,),   
                equationFixed(r'\mu_{r1} = '),
                equationParamReal('', controllerMu),
              ],
            ), 
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              equationFixed(r'\text{Medium 2: }\varepsilon_{r2} = '),
              equationParamReal('', controllerEpsilonR2),
              const SizedBox(width: 20,),  
              equationFixed(r'\mu_{r2} = '),
              equationParamReal('', controllerMuR2),
              const SizedBox(width: 20,),  
              equationFixed(r'\sigma_{2} = '), 
              equationParamReal('', controllerSigma2),
              equationFixed('\\text{S/m}'),
              ],
            ),
          ),
          
          // buttons
          Container(
            width: 400,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    nextPreset();
                  }, 
                  child: Text('Examples'),
                ),
                // TextButton(
                //   onPressed: () {
                //     nextPreset(Preset.circular);
                //   }, 
                //   child: Text('circular'),
                // ),
                // TextButton(
                //   onPressed: () {
                //     nextPreset(Preset.elliptical);
                //   }, 
                //   child: Text('elliptical'),
                // ),

                // TextButton(
                //   onPressed: () {
                //     updateParamToController();
                //   }, 
                //   child: Text('calculate'),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

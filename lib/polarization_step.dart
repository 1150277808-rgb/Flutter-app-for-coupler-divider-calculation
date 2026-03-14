import 'dart:math' as math;

import 'package:polarization/polarization_symbols.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:flutter/material.dart' hide Step;
import 'package:polarization/polarization_globalvar.dart';
import 'package:polarization/polarization_source.dart';
import 'package:polarization/shared/steps/steps3.dart';
import 'package:polarization/shared/senum/senum.dart';





class PolarizationSteps extends StatefulWidget {
  const PolarizationSteps({
    super.key,
    required this.controller, 
  });

  final SourceController controller;


  @override
  State<PolarizationSteps> createState() => _PolarizationStepsState();
}

class _PolarizationStepsState extends State<PolarizationSteps> {

  late SourceController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
  }


  List<List> inciWave(){
      return [
      [
        Steps3.genEqL('\\text{The incident angle } $symThetai = ${texAngleIRad} $symUnitRad = ${texAngleIDeg}'),
      ],
      [
        [Steps3.genEqL('\\text{More details on incident angle}'),],
        [
          Steps3.genEq(r'\begin{aligned}'
          '$symThetai &= $symThetaiEq ' r'\\' '&=  \\arctan( \\frac{${SciNum.sciTex(kx)}}{${SciNum.sciTex(kz)}})' r'\\'
          '& = ${texAngleIRad} $symUnitRad = ${texAngleIDeg}' r'\end{aligned}')
        ]
      ]
    ];
  }

  List<List> inciFreq(){
    return [
      [
        Steps3.genEqL('\\text{The frequency of incident wave } f = ${texFreq} $symUnitFreq'),
      ],
      [
        [Steps3.genEqL('\\text{More details on frequency}'),],
        [
          Steps3.genEq(r'\begin{aligned}' 'f &= $symFreqEq' r'\\'
          '&=\\frac{\\sqrt{${texKx}^2+${texKz}^2}}{2\\pi\\sqrt{${texMu1} \\times ${texEps1}}}'r'\\'
          '&=${texFreq} $symUnitFreq'
          r'\end{aligned}'),
          // Steps3.genText('where'),
        ]
      ]
    ];
  }
 



  List<List> poyntingVectorT(){
    return[
      [
        Steps3.genEqL('\\text{Time-averaging Ponying vector of transmitted wave}'),
        // Steps3.genEq('\\vec{H}_{ot\\|} = ${texParamTHx} $symAx + ${texParamTHz} $symAz'),
        // Steps3.genEq('\\vec{H}_{ot\\perp} = ${texParamTHy} $symAy'),
        Steps3.genEq(
          '\\overrightarrow{S}_t = '
          '$symAx ${texPynTx}+ $symAy ${texPynTy} + $symAz ${texPynTz}  $symPoyntingUnit'
        ),
      ],
      [
        [
        Steps3.genText('Cross Product')
        ],
        [
          Steps3.genEq(symPoyntingTimeAvgFormula),
          Steps3.genEq(
            r'\begin{aligned}'
            '$symHpt $symConjFixed &= '
            '\\left( ${texTHpStandard} \\right) $symConjFlex '
            r'\\'
            '&= '
            '${texTHpStandardConj}'
            r'\end{aligned}'
        ),
        Steps3.genEq(
          r'\begin{aligned}'
          '$symPoyntingTimeAvgInsideRe &= '
          // '\\left( ${texEpStandard} \\right) \\times'
          // '\\left( ${texMpStandard} \\right) $symConjFlex '

          // r'\\'

          // '&= '
          '\\left( ${texTEpStandard} \\right) ' r'\\'
          '& \\times \\left( ${texTHpStandardConj} \\right) '

          r'\\'

          '&= '
          '$symDetBegin'
          '$symAx & $symAy & $symAz ' r'\\'
          '${texParamTEx} & ${texParamTEy} & ${texParamTEz}' r'\\'
          '${texParamTHxConj} & ${texParamTHyConj} & ${texParamTHzConj}' r'\\'
          '$symDetEnd'

          r'\end{aligned}'
        ),
        Steps3.genText('Use cofactor expansion'),
        Steps3.genEq(
          r'\begin{aligned}'
          '$symPoyntingTimeAvgInsideRe &= '
          '$symAx '
          '$symDetBegin'
          '${texParamTEy} & ${texParamTEz}' r'\\'
          '${texParamTHyConj} & ${texParamTHzConj}' r'\\'
          '$symDetEnd'
          '- $symAy '
          '$symDetBegin'
          '${texParamTEx} & ${texParamTEz}' r'\\'
          '${texParamTHxConj} & ${texParamTHzConj}' r'\\'
          '$symDetEnd'
          '+ $symAz '
          '$symDetBegin'
          '${texParamTEx} & ${texParamTEy}' r'\\'
          '${texParamTHxConj} & ${texParamTHyConj}' r'\\'
          '$symDetEnd' r'\\'
          '&=$symAx ${texSTx} + $symAy ${texSTy} + $symAz ${texSTz}'
          r'\end{aligned}'
        ),

        
        Steps3.genEq(
          r'\begin{aligned}'
          '\\overrightarrow{S}_t = '
          '\\frac{1}{2} $symRe \\left\\{ $symAx ${texSTx} + $symAy ${texSTy} + $symAz ${texSTz} \\right\\}'
          '= '
          '$symAx ${texPynTx}+ $symAy ${texPynTy} + $symAz ${texPynTz}'
          r'\end{aligned}'
        ),
        Steps3.genText('Alternatively, '),
        Steps3.genEq(
          r'\begin{aligned}'
          '$symPoyntingTimeAvg _t &= '
          '$symAkt \\frac{1}{2} \\left| $symEp _t \\right|^2 $symRe \\left\\{ \\frac{1}{$symEta _2} \\right\\} '

          r'\\'
          '&= (${texAkt}) \\frac{1}{2} \\left[ ${texParamTExAmp}^2 + ${texParamTEyAmp}^2 + ${texParamTEzAmp}^2 \\right] \\frac{1}{${texEta2}} '
          r'\\'
          // '&= ${texPoyntingTimeAvg}  $symPoyntingUnit'
          '&=$symAx ${texPynTx} + $symAy ${texPynTy} + $symAz ${texPynTz}  $symPoyntingUnit'
          r'\end{aligned}'
        ),
      ]]];
      
  }





  List<List<List>> steps3() {
    List<List<List>> steps = [];

    // can change order here! 


    if (!isGivenFreq){
      steps.add(inciFreq());
    }
    if (!isGivenThetai){
      steps.add(inciWave());
    }

    

    steps.add(poyntingVectorT());
    

    return steps;

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: Steps3(
          steps: steps3(),
        ),
      
    );
  }
}
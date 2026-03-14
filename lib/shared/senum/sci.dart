import 'dart:math' as math;
import 'package:sprintf/sprintf.dart';
import 'misc.dart';

class SciNum {

  static String sciTex(double val, {bool ignoreNoise = false, int sigFigs = 4, bool withSign = false}) {
    bool withPlus = false;
    if (withSign && val >= 0){
      withPlus = true;
    }
    if (ignoreNoise && val.abs()<1e-10){
      val = 0;
    }

    return scientificNotation(sprintf('%.${sigFigs}g', [val]), withPlus: withPlus);

    // num round = roundToSignificantFigures(val, sigFigs);

    // if (round == 0) {
    //   return '0';
    // }
    // else if (
    //   ((round.abs() < 1e3) || (round.abs() < math.pow(10, sigFigs-1))) &&
    //   (round.abs() > 1e-2)
    // ) {
    //   return sprintf('%.${sigFigs}g', [val]);
    //   // return round.toStringAsPrecision(sigFigs);
    // }
    // else {
    //   return scientificNotation(sprintf('%.${sigFigs}g', [val]));
    //   // return '${round.toStringAsExponential(sigFigs-1).replaceAll(r'e', r'\times 10^{').replaceAll('+', '')}}';
    // }
  }

}

String scientificNotation(String numStr, {bool withPlus = false}){
  if (withPlus){
    numStr = '+' + numStr;
  }
  if (!(numStr.contains('e'))){
    return numStr;
  }
  String outputStr = "";
  numStr = numStr.replaceAll("e+0", "e");
  numStr = numStr.replaceAll("e+", "e");
  numStr = numStr.replaceAll("e-0", "e-");
  List<String> strList = numStr.split('e');
  outputStr = strList[0] + r'\times 10^{' + strList[1] + '}';
  return outputStr;
}
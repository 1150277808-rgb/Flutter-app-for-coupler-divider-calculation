import 'dart:math' as math;

num roundToSignificantFigures(num value, int sigFigs) {
  if (value == 0.0) {
    return 0.0;
  }

  num magnitude = value.abs();
  int digits = (magnitude == 0.0) ? 0 : ((math.log10e * math.log(magnitude)).ceil());

  int precision = sigFigs - digits;

  num roundedValue = (precision >= 0)
      ? (value * math.pow(10, precision)).round() / math.pow(10, precision)
      : (value / math.pow(10, -precision)).round() * math.pow(10, -precision);

  return roundedValue;
}
import 'dart:math' as math;
import 'package:flutter/material.dart';

class Complex {
  final double re;
  final double im;

  const Complex(this.re, [this.im = 0.0]);

  static const Complex zero = Complex(0.0, 0.0);
  static const Complex one = Complex(1.0, 0.0);

  Complex operator +(Complex other) => Complex(re + other.re, im + other.im);

  Complex operator -(Complex other) => Complex(re - other.re, im - other.im);

  Complex operator -() => Complex(-re, -im);

  Complex operator *(Complex other) => Complex(
        re * other.re - im * other.im,
        re * other.im + im * other.re,
      );

  Complex operator /(Complex other) {
    final den = other.re * other.re + other.im * other.im;
    if (den == 0) return Complex.zero;
    return Complex(
      (re * other.re + im * other.im) / den,
      (im * other.re - re * other.im) / den,
    );
  }

  Complex scale(double k) => Complex(re * k, im * k);

  double abs() => math.sqrt(re * re + im * im);

  double phaseRad() => math.atan2(im, re);

  double phaseDeg() => phaseRad() * 180.0 / math.pi;

  String fmt([int digits = 4]) {
    final r = re.toStringAsFixed(digits);
    final i = im.abs().toStringAsFixed(digits);
    final sign = im >= 0 ? '+' : '-';
    return '$r $sign j$i';
  }
}

class _Abcd2x2 {
  final Complex a;
  final Complex b;
  final Complex c;
  final Complex d;

  const _Abcd2x2({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
  });
}

_Abcd2x2 _matMul(_Abcd2x2 m1, _Abcd2x2 m2) {
  return _Abcd2x2(
    a: m1.a * m2.a + m1.b * m2.c,
    b: m1.a * m2.b + m1.b * m2.d,
    c: m1.c * m2.a + m1.d * m2.c,
    d: m1.c * m2.b + m1.d * m2.d,
  );
}

_Abcd2x2 _shunt(Complex y) {
  return _Abcd2x2(
    a: Complex.one,
    b: Complex.zero,
    c: y,
    d: Complex.one,
  );
}

_Abcd2x2 _line(double zc, double theta) {
  final ct = math.cos(theta);
  final st = math.sin(theta);
  return _Abcd2x2(
    a: Complex(ct, 0),
    b: Complex(0, zc * st),
    c: Complex(0, st / zc),
    d: Complex(ct, 0),
  );
}

Complex _s11FromAbcd(_Abcd2x2 m, double z0) {
  final num = m.a + m.b.scale(1 / z0) - m.c.scale(z0) - m.d;
  final den = m.a + m.b.scale(1 / z0) + m.c.scale(z0) + m.d;
  return num / den;
}

Complex _s21FromAbcd(_Abcd2x2 m, double z0) {
  final den = m.a + m.b.scale(1 / z0) + m.c.scale(z0) + m.d;
  return Complex(2.0, 0.0) / den;
}

double _safeTan(double x) {
  final t = math.tan(x);
  if (t.isNaN) return 1e12;
  if (t.isInfinite) return t.isNegative ? -1e12 : 1e12;
  if (t.abs() > 1e12) return t.isNegative ? -1e12 : 1e12;
  return t;
}

double _safeCot(double x) {
  final t = _safeTan(x);
  if (t.abs() < 1e-12) return t.isNegative ? -1e12 : 1e12;
  return 1.0 / t;
}

class BranchLineDetailedResult {
  final double thetaRad;
  final double thetaDeg;
  final double thetaHalfDeg;
  final double k;

  final Complex yEvenStub;
  final Complex yOddStub;

  final Complex ae;
  final Complex be;
  final Complex ce;
  final Complex de;

  final Complex ao;
  final Complex bo;
  final Complex co;
  final Complex dO;

  final Complex gammaE;
  final Complex tauE;
  final Complex gammaO;
  final Complex tauO;

  final Complex s11;
  final Complex s21;
  final Complex s31;
  final Complex s41;

  const BranchLineDetailedResult({
    required this.thetaRad,
    required this.thetaDeg,
    required this.thetaHalfDeg,
    required this.k,
    required this.yEvenStub,
    required this.yOddStub,
    required this.ae,
    required this.be,
    required this.ce,
    required this.de,
    required this.ao,
    required this.bo,
    required this.co,
    required this.dO,
    required this.gammaE,
    required this.tauE,
    required this.gammaO,
    required this.tauO,
    required this.s11,
    required this.s21,
    required this.s31,
    required this.s41,
  });

  factory BranchLineDetailedResult.zero() {
    return const BranchLineDetailedResult(
      thetaRad: 0.0,
      thetaDeg: 0.0,
      thetaHalfDeg: 0.0,
      k: 0.0,
      yEvenStub: Complex.zero,
      yOddStub: Complex.zero,
      ae: Complex.zero,
      be: Complex.zero,
      ce: Complex.zero,
      de: Complex.zero,
      ao: Complex.zero,
      bo: Complex.zero,
      co: Complex.zero,
      dO: Complex.zero,
      gammaE: Complex.zero,
      tauE: Complex.zero,
      gammaO: Complex.zero,
      tauO: Complex.zero,
      s11: Complex.zero,
      s21: Complex.zero,
      s31: Complex.zero,
      s41: Complex.zero,
    );
  }

  factory BranchLineDetailedResult.calculate({
    required double freqGHz,
    required double centerFreqGHz,
    required double z0,
    required double zh,
    required double zv,
  }) {
    if (freqGHz <= 0 ||
        centerFreqGHz <= 0 ||
        z0 <= 0 ||
        zh <= 0 ||
        zv <= 0) {
      return BranchLineDetailedResult.zero();
    }

    final thetaRad = (math.pi / 2.0) * (freqGHz / centerFreqGHz);
    final thetaDeg = thetaRad * 180.0 / math.pi;
    final thetaHalf = thetaRad / 2.0;
    final thetaHalfDeg = thetaHalf * 180.0 / math.pi;

    final k = z0 / zh;
    final yv = 1.0 / zv;

    final yEvenStub = Complex(0.0, yv * _safeTan(thetaHalf));
    final yOddStub = Complex(0.0, -yv * _safeCot(thetaHalf));

    final even = _matMul(
      _matMul(_shunt(yEvenStub), _line(zh, thetaRad)),
      _shunt(yEvenStub),
    );

    final odd = _matMul(
      _matMul(_shunt(yOddStub), _line(zh, thetaRad)),
      _shunt(yOddStub),
    );

    final gammaE = _s11FromAbcd(even, z0);
    final tauE = _s21FromAbcd(even, z0);

    final gammaO = _s11FromAbcd(odd, z0);
    final tauO = _s21FromAbcd(odd, z0);

    final s11 = (gammaE + gammaO).scale(0.5);
    final s21 = (tauE + tauO).scale(0.5);
    final s31 = (tauE - tauO).scale(0.5);
    final s41 = (gammaE - gammaO).scale(0.5);

    return BranchLineDetailedResult(
      thetaRad: thetaRad,
      thetaDeg: thetaDeg,
      thetaHalfDeg: thetaHalfDeg,
      k: k,
      yEvenStub: yEvenStub,
      yOddStub: yOddStub,
      ae: even.a,
      be: even.b,
      ce: even.c,
      de: even.d,
      ao: odd.a,
      bo: odd.b,
      co: odd.c,
      dO: odd.d,
      gammaE: gammaE,
      tauE: tauE,
      gammaO: gammaO,
      tauO: tauO,
      s11: s11,
      s21: s21,
      s31: s31,
      s41: s41,
    );
  }
}

class BranchLineController extends ChangeNotifier {
  int inputPort = 1;

  double _frequency = 3.0;
  final double centerFreq = 3.0;

  double z0 = 50.0;
  double zh = 50.0 / math.sqrt(2.0);
  double zv = 50.0;

  double s1_mag = 0.0;
  double s2_mag = 0.7071;
  double s3_mag = 0.7071;
  double s4_mag = 0.0;

  BranchLineDetailedResult detailed = BranchLineDetailedResult.zero();

  BranchLineController() {
    recalculate(notify: false);
  }

  double get frequency => _frequency;
  double get freqGHz => _frequency;

  BranchLineDetailedResult get solution => detailed;

  Complex get s11 => detailed.s11;
  Complex get s21 => detailed.s21;
  Complex get s31 => detailed.s31;
  Complex get s41 => detailed.s41;

  set freqGHz(double val) {
    setFrequency(val);
  }

  void setInputPort(int port) {
    inputPort = port;
    notifyListeners();
  }

  void setFrequency(double freq) {
    if (freq <= 0) return;
    _frequency = freq;
    recalculate();
  }

  void setParameters({
    double? frequency,
    double? z0,
    double? zh,
    double? zv,
    bool notify = true,
  }) {
    if (frequency != null && frequency > 0) {
      _frequency = frequency;
    }
    if (z0 != null && z0 > 0) {
      this.z0 = z0;
    }
    if (zh != null && zh > 0) {
      this.zh = zh;
    }
    if (zv != null && zv > 0) {
      this.zv = zv;
    }
    recalculate(notify: notify);
  }

  void resetToIdeal() {
    _frequency = centerFreq;
    z0 = 50.0;
    zh = 50.0 / math.sqrt(2.0);
    zv = 50.0;
    recalculate();
  }

  void update() {
    notifyListeners();
  }

  void updateResults([double? s1, double? s2, double? s3, double? s4]) {
    recalculate();
  }

  void recalculate({bool notify = true}) {
    detailed = BranchLineDetailedResult.calculate(
      freqGHz: _frequency,
      centerFreqGHz: centerFreq,
      z0: z0,
      zh: zh,
      zv: zv,
    );

    s1_mag = _limit01(detailed.s11.abs());
    s2_mag = _limit01(detailed.s21.abs());
    s3_mag = _limit01(detailed.s31.abs());
    s4_mag = _limit01(detailed.s41.abs());

    if (notify) notifyListeners();
  }

  double _limit01(double x) {
    if (x < 0) return 0.0;
    if (x > 1) return 1.0;
    return x;
  }
}

final BranchLineController blController = BranchLineController();
import 'dart:math';
import 'package:flutter/material.dart';

class BranchLineController extends ChangeNotifier {
  BranchLineController() {
    _frequency = centerFreq;
    recalc();
  }

  // --- Input controls ---
  int inputPort = 1;

  // In current UI there is only one frequency input,
  // so we treat it as the design/center frequency as well.
  double centerFreq = 3.0;
  double _frequency = 3.0;

  // Current electrical length
  double theta = pi / 2;

  // --- S-parameter magnitudes ---
  double s1_mag = 0.0; // |S11|
  double s2_mag = 1 / sqrt(2); // |S21|
  double s3_mag = 1 / sqrt(2); // |S31|
  double s4_mag = 0.0; // |S41|

  // --- S-parameter phases (rad) ---
  double s1_phase = pi;
  double s2_phase = -pi / 2;
  double s3_phase = -pi;
  double s4_phase = 0.0;

  // --- Sweep data ---
  List<double> sweepFreqGHz = [];
  List<double> sweepS11dB = [];
  List<double> sweepS21dB = [];
  List<double> sweepS31dB = [];
  List<double> sweepS41dB = [];

  double get frequency => _frequency;
  double get freqGHz => _frequency;

  set freqGHz(double val) {
    final f = val.clamp(0.1, 100.0).toDouble();
    _frequency = f;
    centerFreq = f;
    recalc();
  }

  void setInputPort(int port) {
    inputPort = port.clamp(1, 4).toInt();
    notifyListeners();
  }

  void setFrequency(double freq) {
    final f = freq.clamp(0.1, 100.0).toDouble();
    _frequency = f;
    centerFreq = f;
    recalc();
  }

  void update() {
    recalc();
  }

  void updateResults(
    double s1,
    double s2,
    double s3,
    double s4, {
    double? p1,
    double? p2,
    double? p3,
    double? p4,
  }) {
    s1_mag = s1;
    s2_mag = s2;
    s3_mag = s3;
    s4_mag = s4;

    if (p1 != null) s1_phase = p1;
    if (p2 != null) s2_phase = p2;
    if (p3 != null) s3_phase = p3;
    if (p4 != null) s4_phase = p4;

    notifyListeners();
  }

  void recalc() {
    final result = _solveAt(_frequency);
    _apply(result);

    computeSweep(
      fStart: max(0.5, centerFreq - 2.0),
      fStop: centerFreq + 2.0,
      points: 161,
      notify: false,
    );

    notifyListeners();
  }

  void computeSweep({
    double? fStart,
    double? fStop,
    int points = 161,
    bool notify = true,
  }) {
    final start = fStart ?? max(0.5, centerFreq - 2.0);
    final stop = fStop ?? (centerFreq + 2.0);
    final n = max(2, points);

    sweepFreqGHz = [];
    sweepS11dB = [];
    sweepS21dB = [];
    sweepS31dB = [];
    sweepS41dB = [];

    for (int i = 0; i < n; i++) {
      final f = start + (stop - start) * i / (n - 1);
      final r = _solveAt(f);

      sweepFreqGHz.add(f);
      sweepS11dB.add(_toDb(r.s1));
      sweepS21dB.add(_toDb(r.s2));
      sweepS31dB.add(_toDb(r.s3));
      sweepS41dB.add(_toDb(r.s4));
    }

    if (notify) {
      notifyListeners();
    }
  }

  _BlState _solveAt(double fGHz) {
    // Since the current UI uses one frequency input,
    // the entered value is treated as the center frequency.
    // Thus the current simulation point is always evaluated at theta = pi/2.
    final thetaRaw = (pi / 2.0) * (fGHz / centerFreq);
    final thetaWrapped = _wrapPhase(thetaRaw);

    final delta = thetaRaw - pi / 2.0;

    final pTransmitTotal =
        pow(cos(delta), 2).toDouble().clamp(0.0, 1.0);
    final pRemain = max(0.0, 1.0 - pTransmitTotal);

    final p21 = 0.5 * pTransmitTotal;
    final p31 = 0.5 * pTransmitTotal;
    final p11 = 0.5 * pRemain;
    final p41 = 0.5 * pRemain;

    final s11 = sqrt(p11);
    final s21 = sqrt(p21);
    final s31 = sqrt(p31);
    final s41 = sqrt(p41);

    final s11Phase = _wrapPhase(pi - 2.0 * thetaRaw);
    final s21Phase = _wrapPhase(-thetaRaw);
    final s31Phase = _wrapPhase(-thetaRaw - pi / 2.0);
    final s41Phase = _wrapPhase(-2.0 * thetaRaw);

    return _BlState(
      theta: thetaWrapped,
      s1: s11,
      s2: s21,
      s3: s31,
      s4: s41,
      p1: s11Phase,
      p2: s21Phase,
      p3: s31Phase,
      p4: s41Phase,
    );
  }

  void _apply(_BlState s) {
    theta = s.theta;
    s1_mag = s.s1;
    s2_mag = s.s2;
    s3_mag = s.s3;
    s4_mag = s.s4;
    s1_phase = s.p1;
    s2_phase = s.p2;
    s3_phase = s.p3;
    s4_phase = s.p4;
  }

  double _wrapPhase(double x) => atan2(sin(x), cos(x));

  double _toDb(double mag) {
    final m = max(mag, 1e-6);
    return 20.0 * log(m) / ln10;
  }
}

class _BlState {
  final double theta;
  final double s1;
  final double s2;
  final double s3;
  final double s4;
  final double p1;
  final double p2;
  final double p3;
  final double p4;

  _BlState({
    required this.theta,
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    required this.p1,
    required this.p2,
    required this.p3,
    required this.p4,
  });
}

final BranchLineController blController = BranchLineController();
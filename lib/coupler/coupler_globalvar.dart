import 'package:flutter/material.dart';
import 'dart:math';

class ComplexWave {
  final double re;
  final double im;

  const ComplexWave(this.re, this.im);
  const ComplexWave.zero()
      : re = 0.0,
        im = 0.0;

  factory ComplexWave.fromPolar(double magnitude, double phaseRad) {
    return ComplexWave(
      magnitude * cos(phaseRad),
      magnitude * sin(phaseRad),
    );
  }

  double get magnitude => sqrt(re * re + im * im);
  double get phaseRad => atan2(im, re);
  double get phaseDeg => phaseRad * 180.0 / pi;

  ComplexWave operator +(ComplexWave other) {
    return ComplexWave(re + other.re, im + other.im);
  }

  ComplexWave operator *(ComplexWave other) {
    return ComplexWave(
      re * other.re - im * other.im,
      re * other.im + im * other.re,
    );
  }
}

class PortExcitation {
  bool enabled;
  double amplitude; // normalized wave amplitude
  double phaseDeg;

  PortExcitation({
    required this.enabled,
    required this.amplitude,
    required this.phaseDeg,
  });

  ComplexWave toWave() {
    if (!enabled || amplitude.abs() < 1e-9) return const ComplexWave.zero();
    return ComplexWave.fromPolar(amplitude, phaseDeg * pi / 180.0);
  }
}

class SourceController extends ChangeNotifier {
  final double centerFreq = 3.0;
  double freqGHz = 3.0;

  // 兼容旧代码
  int inputPort = 2;

  late List<PortExcitation> excitations;

  ComplexWave b1 = const ComplexWave.zero();
  ComplexWave b2 = const ComplexWave.zero();
  ComplexWave b3 = const ComplexWave.zero();
  ComplexWave b4 = const ComplexWave.zero();

  // 兼容旧 step / painter
  double s_out1_mag = 0.0;
  double s_out2_mag = 0.0;
  double s_out3_mag = 0.0;
  double s_out4_mag = 0.0;

  double s_out1_phase_deg = 0.0;
  double s_out2_phase_deg = 0.0;
  double s_out3_phase_deg = 0.0;
  double s_out4_phase_deg = 0.0;

  int isolatedPort = 0;

  double theta_deg = 90.0;
  double abcd_A = 0.0;
  double abcd_B_norm = 0.0;

  SourceController() {
    excitations = List.generate(
      4,
      (i) => PortExcitation(
        enabled: i == 1,
        amplitude: i == 1 ? 1.0 : 0.0,
        phaseDeg: 0.0,
      ),
    );
    calculateAll();
  }

  void update() {
    calculateAll();
    notifyListeners();
  }

  void setInputPort(int port) {
    inputPort = port;
    for (int i = 0; i < 4; i++) {
      excitations[i].enabled = (i + 1 == port);
      excitations[i].amplitude = (i + 1 == port) ? 1.0 : 0.0;
      excitations[i].phaseDeg = 0.0;
    }
    calculateAll();
    notifyListeners();
  }

  void clearAllExcitations() {
    for (final e in excitations) {
      e.enabled = false;
      e.amplitude = 0.0;
      e.phaseDeg = 0.0;
    }
    calculateAll();
    notifyListeners();
  }

  void applyExcitations({
    required List<bool> enabled,
    required List<double> amplitudes,
    required List<double> phasesDeg,
  }) {
    for (int i = 0; i < 4; i++) {
      excitations[i].enabled = enabled[i];
      excitations[i].amplitude = enabled[i] ? amplitudes[i] : 0.0;
      excitations[i].phaseDeg = _normalizePhase(phasesDeg[i]);
    }

    final active = activeInputPorts;
    if (active.isNotEmpty) {
      inputPort = active.first;
    }

    calculateAll();
    notifyListeners();
  }

  List<int> get activeInputPorts {
    final result = <int>[];
    for (int i = 0; i < 4; i++) {
      if (excitations[i].enabled && excitations[i].amplitude.abs() > 1e-9) {
        result.add(i + 1);
      }
    }
    return result;
  }

  bool isPortExcited(int port) {
    final e = excitations[port - 1];
    return e.enabled && e.amplitude.abs() > 1e-9;
  }

  double getInputAmplitude(int port) => excitations[port - 1].amplitude;
  double getInputPhaseDeg(int port) => excitations[port - 1].phaseDeg;
  double getInputPower(int port) {
    final a = excitations[port - 1].amplitude;
    return a * a;
  }

  double getOutputAmplitude(int port) {
    switch (port) {
      case 1:
        return b1.magnitude;
      case 2:
        return b2.magnitude;
      case 3:
        return b3.magnitude;
      case 4:
        return b4.magnitude;
      default:
        return 0.0;
    }
  }

  double getOutputPhaseDeg(int port) {
    switch (port) {
      case 1:
        return _normalizePhase(b1.phaseDeg);
      case 2:
        return _normalizePhase(b2.phaseDeg);
      case 3:
        return _normalizePhase(b3.phaseDeg);
      case 4:
        return _normalizePhase(b4.phaseDeg);
      default:
        return 0.0;
    }
  }

  double getOutputPhaseRad(int port) {
    switch (port) {
      case 1:
        return b1.phaseRad;
      case 2:
        return b2.phaseRad;
      case 3:
        return b3.phaseRad;
      case 4:
        return b4.phaseRad;
      default:
        return 0.0;
    }
  }

  double getOutputPower(int port) {
    final b = getOutputAmplitude(port);
    return b * b;
  }

  double get totalInputPower =>
      getInputPower(1) + getInputPower(2) + getInputPower(3) + getInputPower(4);

  double get totalOutputPower =>
      getOutputPower(1) + getOutputPower(2) + getOutputPower(3) + getOutputPower(4);

  double get powerBalanceError => totalOutputPower - totalInputPower;

  void calculateAll() {
    final ratio = freqGHz / centerFreq;
    theta_deg = 90.0 * ratio;
    final theta = theta_deg * pi / 180.0;

    abcd_A = cos(theta);
    abcd_B_norm = sin(theta);

    final a = excitations.map((e) => e.toWave()).toList();
    final s = _idealRatRaceS();

    final b = List<ComplexWave>.generate(4, (row) {
      ComplexWave sum = const ComplexWave.zero();
      for (int col = 0; col < 4; col++) {
        sum = sum + (s[row][col] * a[col]);
      }
      return sum;
    });

    b1 = b[0];
    b2 = b[1];
    b3 = b[2];
    b4 = b[3];

    s_out1_mag = b1.magnitude;
    s_out2_mag = b2.magnitude;
    s_out3_mag = b3.magnitude;
    s_out4_mag = b4.magnitude;

    s_out1_phase_deg = _normalizePhase(b1.phaseDeg);
    s_out2_phase_deg = _normalizePhase(b2.phaseDeg);
    s_out3_phase_deg = _normalizePhase(b3.phaseDeg);
    s_out4_phase_deg = _normalizePhase(b4.phaseDeg);

    isolatedPort = _estimateIsolatedPort();
  }

  List<List<ComplexWave>> _idealRatRaceS() {
    final z = const ComplexWave.zero();
    final m = 1 / sqrt(2);

    final minusJ = ComplexWave(0.0, -m);
    final plusJ = ComplexWave(0.0, m);

    return [
      [z, minusJ, minusJ, z],
      [minusJ, z, z, plusJ],
      [minusJ, z, z, minusJ],
      [z, plusJ, minusJ, z],
    ];
  }

  int _estimateIsolatedPort() {
    final active = activeInputPorts;

    if (active.length == 1) {
      final inIdx = active.first - 1;
      final s = _idealRatRaceS();
      for (int row = 0; row < 4; row++) {
        if (row == inIdx) continue;
        if (s[row][inIdx].magnitude < 1e-9) {
          return row + 1;
        }
      }
    }

    final mags = [
      b1.magnitude,
      b2.magnitude,
      b3.magnitude,
      b4.magnitude,
    ];

    int idx = 0;
    double minVal = mags[0];
    for (int i = 1; i < mags.length; i++) {
      if (mags[i] < minVal) {
        minVal = mags[i];
        idx = i;
      }
    }
    return idx + 1;
  }

  double _normalizePhase(double deg) {
    double x = deg;
    while (x > 180) x -= 360;
    while (x <= -180) x += 360;
    return x;
  }
}
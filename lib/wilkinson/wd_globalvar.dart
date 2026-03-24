import 'dart:math' as math;
import 'package:flutter/material.dart';

class WdSample {
  final double frequency;
  final double theta;
  final double s11;
  final double s21;
  final double s31;
  final double s23;

  const WdSample({
    required this.frequency,
    required this.theta,
    required this.s11,
    required this.s21,
    required this.s31,
    required this.s23,
  });
}

class WilkinsonController extends ChangeNotifier {
  // 系统参数
  final double z0 = 50.0;
  final double designFreq = 3.0;

  double frequency = 3.0;

  // 功率比 K^2 = P3 / P2
  double kSquared = 1.0;

  // 对应 dB：10log10(P3/P2)
  double splitDB = 0.0;

  // 电路参数
  double z02 = 70.71;
  double z03 = 70.71;
  double rIso = 100.0;
  double r2 = 50.0;
  double r3 = 50.0;

  // 当前频点 S 参数幅度
  double s11 = 0.0;
  double s21 = 0.707;
  double s31 = 0.707;
  double s23 = 0.0;

  WilkinsonController() {
    recalc(notify: false);
  }

  double get k => math.sqrt(kSquared);

  void setFrequency(double val) {
    frequency = val;
    recalc();
  }

  void setSplitDB(double dbVal) {
    splitDB = dbVal;
    kSquared = math.pow(10, dbVal / 10.0).toDouble();
    recalc();
  }

  double electricalLengthAt(double f) {
    return math.pi / 2.0 * (f / designFreq);
  }

  WdSample sampleAt(double f) {
    final theta = electricalLengthAt(f);

    // 教学演示用频率响应模型：
    // 在 f0 时 sin(theta)=1 -> 完美分功
    // 偏离 f0 时，反射与隔离恶化
    final double sinTheta = math.sin(theta).abs();
    final double cosTheta = math.cos(theta).abs();

    final double p2Ratio = 1.0 / (1.0 + kSquared);
    final double p3Ratio = kSquared / (1.0 + kSquared);

    final double s21Val = math.sqrt(p2Ratio) * sinTheta;
    final double s31Val = math.sqrt(p3Ratio) * sinTheta;
    final double s11Val = cosTheta;
    final double s23Val = cosTheta;

    return WdSample(
      frequency: f,
      theta: theta,
      s11: s11Val.clamp(0.0, 1.0),
      s21: s21Val.clamp(0.0, 1.0),
      s31: s31Val.clamp(0.0, 1.0),
      s23: s23Val.clamp(0.0, 1.0),
    );
  }

  List<WdSample> sweepSamples({
    double minFreq = 1.0,
    double maxFreq = 5.0,
    int count = 81,
  }) {
    final double step = (maxFreq - minFreq) / (count - 1);
    return List.generate(count, (i) => sampleAt(minFreq + i * step));
  }

  void recalc({bool notify = true}) {
    final double kk = k;

    // 设计公式
    z03 = z0 * math.sqrt((1 + kSquared) / math.pow(kk, 3));
    z02 = kSquared * z03;
    rIso = z0 * (kk + 1 / kk);
    r2 = z0 * kk;
    r3 = z0 / kk;

    // 当前频点 S 参数
    final sample = sampleAt(frequency);
    s11 = sample.s11;
    s21 = sample.s21;
    s31 = sample.s31;
    s23 = sample.s23;

    if (notify) notifyListeners();
  }
}

final wdController = WilkinsonController();
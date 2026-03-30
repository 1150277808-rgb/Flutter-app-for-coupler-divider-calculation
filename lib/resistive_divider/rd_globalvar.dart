import 'package:flutter/material.dart';
import 'dart:math';

class ResistiveDividerController extends ChangeNotifier {
  // 输入参数
  double frequency = 3.0; // 保留，仅用于动画
  double z0 = 50.0;       // 系统参考阻抗
  double resistor = 50.0 / 3.0; // 每条支路电阻，默认理想值 Z0/3
  int inputPort = 1;      // 1=Port1, 2=Port2, 3=Port3

  // 计算结果
  double s11 = 0.0;
  double s21 = 0.5;
  double s31 = 0.5;

  ResistiveDividerController() {
    updateResults(notify: false);
  }

  // 对称三电阻 Y 型三端口
  // S = gI + (1-g)J/3
  // g = (R - Z0)/(R + Z0)
  void updateResults({bool notify = true}) {
    if (z0 <= 0 || resistor <= 0) return;

    final g = (resistor - z0) / (resistor + z0);

    s11 = (1 + 2 * g) / 3;
    s21 = (1 - g) / 3;
    s31 = s21;

    if (notify) notifyListeners();
  }

  void setInputPort(int port) {
    inputPort = port;
    notifyListeners();
  }

  void setFrequency(double val) {
    if (val <= 0) return;
    frequency = val;
    notifyListeners(); // 只刷新动画/显示
  }

  void setParameters({
    double? frequency,
    double? z0,
    double? resistor,
  }) {
    if (frequency != null && frequency > 0) {
      this.frequency = frequency;
    }
    if (z0 != null && z0 > 0) {
      this.z0 = z0;
    }
    if (resistor != null && resistor > 0) {
      this.resistor = resistor;
    }
    updateResults();
  }

  // 频率扫描（S参数不变，但为了一致性添加）
  List<double> get sweepFreqGHz {
    final fMin = frequency * 0.5;
    final fMax = frequency * 1.5;
    return List.generate(41, (i) => fMin + (fMax - fMin) * i / 40);
  }

  double _toDb(double mag) {
    if (mag <= 1e-6) return -120.0;
    return 20 * log(mag.abs()) / ln10;
  }

  List<double> get sweepS11dB => List.filled(41, _toDb(s11));
  List<double> get sweepS21dB => List.filled(41, _toDb(s21));
  List<double> get sweepS31dB => List.filled(41, _toDb(s31));
}

// 全局单例
final rdController = ResistiveDividerController();
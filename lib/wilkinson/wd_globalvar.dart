import 'dart:math';
import 'package:flutter/material.dart';

class WilkinsonController extends ChangeNotifier {
  // 系统参数
  final double z0 = 50.0;
  final double designFreq = 3.0;
  
  double frequency = 3.0;
  
  // 核心变量：功率比 K^2 = P3 / P2
  double kSquared = 1.0; 
  
  // 新增：对应的 dB 值 (方便 UI 显示)
  double splitDB = 0.0; 

  // 电路元件参数
  double z02 = 70.71;
  double z03 = 70.71;
  double rIso = 100.0;
  // 新增：输出端负载电阻
  double r2 = 50.0;
  double r3 = 50.0;

  // S参数仿真结果
  double s11 = 0.0;
  double s21 = 0.707;
  double s31 = 0.707;
  double s23 = 0.0;

  void setFrequency(double val) {
    frequency = val;
    recalc();
  }

  // 新增：通过 dB 设置功率比 (User Requirement 2)
  void setSplitDB(double dbVal) {
    splitDB = dbVal;
    // dB = 10 * log10(P3/P2)
    // P3/P2 = 10^(dB/10)
    kSquared = pow(10, dbVal / 10.0).toDouble();
    recalc();
  }

  void recalc() {
    double k = sqrt(kSquared); // K parameter

    // 1. 计算传输线阻抗
    z03 = z0 * sqrt((1 + kSquared) / pow(k, 3));
    z02 = kSquared * z03; // 或者 z0 * sqrt(k * (1 + k*k))

    // 2. 计算隔离电阻
    rIso = z0 * (k + 1/k);

    // 3. 新增：计算输出端负载电阻 (User Requirement 1)
    // 课件公式: R2 = Z0 * K, R3 = Z0 / K
    r2 = z0 * k;
    r3 = z0 / k;

    // --- S 参数仿真 (保持不变) ---
    double mismatch = (frequency - designFreq).abs() / designFreq;
    double matchFactor = max(0, 1.0 - 1.5 * mismatch);

    s11 = 0.9 * (1.0 - matchFactor); 

    double pTotal = 1.0 - (s11 * s11);
    double p2_ratio = 1 / (1 + kSquared);
    double p3_ratio = kSquared / (1 + kSquared);

    s21 = sqrt(pTotal * p2_ratio);
    s31 = sqrt(pTotal * p3_ratio);
    s23 = 0.8 * (1.0 - matchFactor);

    notifyListeners();
  }
}

final wdController = WilkinsonController();
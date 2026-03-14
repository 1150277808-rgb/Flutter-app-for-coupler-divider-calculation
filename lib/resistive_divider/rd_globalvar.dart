import 'package:flutter/material.dart';

class ResistiveDividerController extends ChangeNotifier {
  // 输入参数
  double frequency = 3.0; // 虽然理论上无关，但为了界面一致性保留
  int inputPort = 1;      // 1=Port1 (Input), 2=Port2, 3=Port3
  
  // 计算结果 (S-Parameters)
  // 根据课件：S21 = S31 = 0.5, S11 = 0
  double s11 = 0.0;
  double s21 = 0.5;
  double s31 = 0.5;

  // 更新 S 参数 (Resistive Divider 理论上是宽带的，S参数不随频率变)
  void updateResults() {
    // 理想情况下始终保持常数
    s11 = 0.0000;
    s21 = 0.5000; 
    s31 = 0.5000;
    notifyListeners();
  }

  // 切换输入端口 (用于动画演示)
  void setInputPort(int port) {
    inputPort = port;
    notifyListeners();
  }

  // 改变频率 (仅用于显示数值，不影响理想模型的S参数)
  void setFrequency(double val) {
    frequency = val;
    updateResults(); // 触发更新
  }
}

// 全局单例
final rdController = ResistiveDividerController();
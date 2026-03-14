import 'package:flutter/material.dart';

class BranchLineController extends ChangeNotifier {
  // --- 1. 输入控制变量 ---
  int inputPort = 1;
  
  // 内部频率变量
  double _frequency = 3.0;

  // 常量 (界面显示用)
  final double centerFreq = 3.0; 

  // --- 2. 计算结果变量 (就是这些漏导致了 bl_steps 报错) ---
  // 用于存储 Step 4 计算出的 S参数幅度
  double s1_mag = 0.0; // Reflection
  double s2_mag = 0.707; // Through (默认理想值)
  double s3_mag = 0.707; // Coupled (默认理想值)
  double s4_mag = 0.0; // Isolation

  // --- 3. 兼容性 Getters/Setters ---
  
  // 动画 Painter 使用
  double get frequency => _frequency;

  // 界面 Input 使用
  double get freqGHz => _frequency;
  
  set freqGHz(double val) {
    _frequency = val;
    notifyListeners();
  }

  // --- 4. 方法 ---

  void setInputPort(int port) {
    inputPort = port;
    notifyListeners();
  }

  // 设置频率
  void setFrequency(double freq) {
    _frequency = freq;
    notifyListeners();
  }

  // 强制刷新 (Input 界面使用)
  void update() {
    notifyListeners();
  }
  
  // 辅助方法：一次性更新计算结果 (方便 Step 4 调用)
  void updateResults(double s1, double s2, double s3, double s4) {
    s1_mag = s1;
    s2_mag = s2;
    s3_mag = s3;
    s4_mag = s4;
    notifyListeners();
  }
}

// 全局实例
final BranchLineController blController = BranchLineController();
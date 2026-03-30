import 'package:flutter/material.dart';

// 引入各个模块的主入口
import 'resistive_divider/rd_main.dart';
import 'wilkinson/wd_main.dart';
import 'coupler/coupler_main.dart';
import 'branch_line/bl_main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Microwave Design Labs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          surface: const Color(0xFFF8F9FA),
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1100 ? 4 : (screenWidth > 600 ? 2 : 1);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: const Text(
              "Microwave Labs", 
              style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black87)
            ),
            centerTitle: false,
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(
                "Select a component to see calculation:",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid.count(
              crossAxisCount: crossAxisCount, 
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.0, 
              children: [
                // --- 1. Resistive Divider ---
                _buildModuleCard(
                  context,
                  title: "Resistive Divider",
                  desc: "Basic 3-port splitter using lumped resistors (Y-shape). Broadband but lossy.",
                  iconWidget: CustomPaint(
                    painter: ResistiveIconPainter(color: Colors.red),
                    size: const Size(40, 40),
                  ),
                  color: Colors.red,
                  destination: const ResistiveDividerMain(),
                ),

                // --- 2. Wilkinson Divider ---
                _buildModuleCard(
                  context,
                  title: "Wilkinson Divider",
                  desc: "The standard PCB power splitter. Features a loop with an isolation resistor.",
                  iconWidget: CustomPaint(
                    painter: WilkinsonIconPainter(color: Colors.indigo),
                    size: const Size(40, 40),
                  ),
                  color: Colors.indigo,
                  destination: const WilkinsonMain(),
                ),

                // --- 3. Rat Race (Hybrid Ring) ---
                // 修改：标题改为 Rat Race，图标改为圆环
                _buildModuleCard(
                  context,
                  title: "Rat Race Coupler",
                  desc: "Also known as Hybrid Ring. A 4-port circular device for sum/difference patterns.",
                  iconWidget: CustomPaint(
                    painter: RatRaceIconPainter(color: Colors.teal),
                    size: const Size(40, 40),
                  ),
                  color: Colors.teal,
                  destination: const CouplerMain(),
                ),
                
                // --- 4. Branch Line Coupler ---
                _buildModuleCard(
                  context,
                  title: "Branch Line Hybrid",
                  desc: "90° Quadrature coupler using λ/4 lines (Box shape structure).",
                  iconWidget: CustomPaint(
                    // 修改：去掉了内部对角线的 Painter
                    painter: BranchLineIconPainter(color: Colors.orange),
                    size: const Size(40, 40),
                  ),
                  color: Colors.orange,
                  destination: const BranchLineMain(), 
                ),
              ],
            ),
          ),
          
          // 底部声明
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 24),
                  
                  // 1. 课程引用声明
                  Text(
                    "Calculations based on EE6128 lecture notes.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 2. 特别鸣谢
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(
                        "Special Thanks to ",
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      Text(
                        "Prof. Tan Eng Leong",
                        style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, {
    required String title, 
    required String desc, 
    required Widget iconWidget, 
    required Color color, 
    required Widget destination
  }) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        splashColor: color.withOpacity(0.1),
        hoverColor: color.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: iconWidget),
              ),
              
              const Spacer(),
              
              Text(
                title, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              
              Text(
                desc,
                style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 10),
              Row(
                children: [
                  Text("Open Calculation", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 14, color: color)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// Painter Implementations
// ==========================================

// 1. Resistive Divider (Y-Shape)
class ResistiveIconPainter extends CustomPainter {
  final Color color;
  ResistiveIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    canvas.drawCircle(center, 2, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke;

    canvas.drawLine(center, Offset(0, cy), paint);
    canvas.drawLine(center, Offset(size.width, 0), paint);
    canvas.drawLine(center, Offset(size.width, size.height), paint);

    final boxPaint = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: Offset(cx/2, cy), width: 8, height: 4), boxPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + cx/2, cy/2), width: 8, height: 4), boxPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + cx/2, cy + cy/2), width: 8, height: 4), boxPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 2. Wilkinson Divider (Loop)
class WilkinsonIconPainter extends CustomPainter {
  final Color color;
  WilkinsonIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final cy = h / 2;

    canvas.drawLine(Offset(0, cy), Offset(w * 0.2, cy), paint);

    Path pathTop = Path();
    pathTop.moveTo(w * 0.2, cy);
    pathTop.quadraticBezierTo(w * 0.5, 0, w * 0.8, cy * 0.6);
    canvas.drawPath(pathTop, paint);

    Path pathBot = Path();
    pathBot.moveTo(w * 0.2, cy);
    pathBot.quadraticBezierTo(w * 0.5, h, w * 0.8, cy * 1.4);
    canvas.drawPath(pathBot, paint);

    canvas.drawLine(Offset(w * 0.8, cy * 0.6), Offset(w, cy * 0.6), paint);
    canvas.drawLine(Offset(w * 0.8, cy * 1.4), Offset(w, cy * 1.4), paint);

    paint.strokeWidth = 2.0;
    canvas.drawLine(Offset(w * 0.8, cy * 0.6), Offset(w * 0.8, cy * 1.4), paint);
    
    final boxPaint = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.8, cy), width: 4, height: 8), boxPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 3. [已修正] Rat Race / Hybrid Ring (Circle)
class RatRaceIconPainter extends CustomPainter {
  final Color color;
  RatRaceIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    // 画一个大圆环
    double radius = size.width * 0.35;
    canvas.drawCircle(center, radius, paint);

    // 画四个端口 (上下左右)
    // Port 1 (左)
    canvas.drawLine(Offset(0, center.dy), Offset(center.dx - radius, center.dy), paint);
    // Port 2 (上)
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, center.dy - radius), paint);
    // Port 3 (右)
    canvas.drawLine(Offset(size.width, center.dy), Offset(center.dx + radius, center.dy), paint);
    // Port 4 (下)
    canvas.drawLine(Offset(center.dx, size.height), Offset(center.dx, center.dy + radius), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 4. [已修正] Branch Line (Clean Box)
class BranchLineIconPainter extends CustomPainter {
  final Color color;
  BranchLineIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    
    // 1. 画外框 (正方形)
    double padding = 6.0;
    Rect box = Rect.fromLTRB(padding, padding, w-padding, h-padding);
    canvas.drawRect(box, paint);

    // 2. 画端口引脚
    // Port 1 (左上)
    canvas.drawLine(Offset(0, padding), Offset(padding, padding), paint);
    // Port 2 (右上)
    canvas.drawLine(Offset(w-padding, padding), Offset(w, padding), paint);
    // Port 3 (右下)
    canvas.drawLine(Offset(w-padding, h-padding), Offset(w, h-padding), paint);
    // Port 4 (左下)
    canvas.drawLine(Offset(0, h-padding), Offset(padding, h-padding), paint);

    // 这里把之前的交叉线 (X) 代码删掉了，保持内部干净
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
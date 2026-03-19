import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'bl_globalvar.dart';

class BranchLineSteps extends StatelessWidget {
  final BranchLineController controller;

  const BranchLineSteps({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final sol = controller.solution;

        final offCenter =
            (controller.freqGHz - controller.centerFreq).abs() > 0.01;

        final idealZh = controller.z0 / math.sqrt(2.0);
        final idealZv = controller.z0;

        final offIdealImpedance =
            (controller.zh - idealZh).abs() > 0.05 ||
            (controller.zv - idealZv).abs() > 0.05;

        final input = controller.inputPort;
        final bVec = _outgoingVector(input, controller);

        return ListView(
          padding: const EdgeInsets.only(bottom: 50),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildHeader(),

            _buildMathCard(
              title: "Step 1: Design Point (Ideal Branch-Line Hybrid)",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "At the design frequency f0, all four branches are quarter-wave long.",
                  ),
                  const SizedBox(height: 8),
                  _buildLeftMath(r'\theta_0 = 90^\circ'),
                  const SizedBox(height: 6),
                  _buildLeftMath(r'Z_h = \frac{Z_0}{\sqrt{2}}, \quad Z_v = Z_0'),
                  const SizedBox(height: 10),
                  Text(
                    "Current values: Z0=${controller.z0.toStringAsFixed(4)} Ω, "
                    "Zh=${controller.zh.toStringAsFixed(4)} Ω, "
                    "Zv=${controller.zv.toStringAsFixed(4)} Ω",
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Ideal values for this Z0 would be: "
                    "Zh=${idealZh.toStringAsFixed(4)} Ω, Zv=${idealZv.toStringAsFixed(4)} Ω",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (offIdealImpedance)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Note: current line impedances are not at the ideal branch-line design values.",
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            _buildMathCard(
              title: "Step 2: Current Electrical Length and Modal Stub Admittances",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLeftMath(
                    '\\theta = \\frac{\\pi}{2}\\frac{f}{f_0} = '
                    '\\frac{\\pi}{2}\\frac{${_f(controller.freqGHz)}}{${_f(controller.centerFreq)}}'
                    ' = ${_f(sol.thetaDeg)}^\\circ',
                  ),
                  const SizedBox(height: 6),
                  _buildLeftMath(
                    '\\theta/2 = ${_f(sol.thetaHalfDeg)}^\\circ',
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Even mode uses open-circuited stubs; odd mode uses short-circuited stubs.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildLeftMath(
                    'Y_{e,stub} = j\\frac{1}{Z_v}\\tan(\\theta/2) = ${_cTex(sol.yEvenStub)}',
                  ),
                  const SizedBox(height: 6),
                  _buildLeftMath(
                    'Y_{o,stub} = -j\\frac{1}{Z_v}\\cot(\\theta/2) = ${_cTex(sol.yOddStub)}',
                  ),
                  if (offCenter)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Because f ≠ f0, the branches are no longer exactly 90°.",
                        style: TextStyle(
                          color: Colors.red[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            _buildMathCard(
              title: "Step 3: Even/Odd ABCD and Modal 2-Port S-Parameters",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "The reduced even/odd 2-port networks are built numerically from:",
                  ),
                  const SizedBox(height: 8),
                  _buildLeftMath(
                    r'[C]_e=[1\ 0;Y_{e,stub}\ 1]\,[\text{line}(Z_h,\theta)]\,[1\ 0;Y_{e,stub}\ 1]',
                  ),
                  const SizedBox(height: 6),
                  _buildLeftMath(
                    r'[C]_o=[1\ 0;Y_{o,stub}\ 1]\,[\text{line}(Z_h,\theta)]\,[1\ 0;Y_{o,stub}\ 1]',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Numerical even-mode ABCD:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  _buildLeftMath(_matrix2x2Tex(sol.ae, sol.be, sol.ce, sol.de)),
                  const SizedBox(height: 10),
                  const Text(
                    "Numerical odd-mode ABCD:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  _buildLeftMath(_matrix2x2Tex(sol.ao, sol.bo, sol.co, sol.dO)),
                  const SizedBox(height: 12),
                  _buildLeftMath(
                    '\\Gamma_e = ${_cTex(sol.gammaE)}, \\quad \\tau_e = ${_cTex(sol.tauE)}',
                  ),
                  const SizedBox(height: 6),
                  _buildLeftMath(
                    '\\Gamma_o = ${_cTex(sol.gammaO)}, \\quad \\tau_o = ${_cTex(sol.tauO)}',
                  ),
                ],
              ),
            ),

            _buildMathCard(
              title: "Step 4: Recombine to the 4-Port S-Parameters",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLeftMath(
                    'S_{11}=\\frac{\\Gamma_e+\\Gamma_o}{2}=${_cTex(sol.s11)}',
                  ),
                  const SizedBox(height: 6),
                  _buildLeftMath(
                    'S_{21}=\\frac{\\tau_e+\\tau_o}{2}=${_cTex(sol.s21)}',
                  ),
                  const SizedBox(height: 6),
                  _buildLeftMath(
                    'S_{31}=\\frac{\\tau_e-\\tau_o}{2}=${_cTex(sol.s31)}',
                  ),
                  const SizedBox(height: 6),
                  _buildLeftMath(
                    'S_{41}=\\frac{\\Gamma_e-\\Gamma_o}{2}=${_cTex(sol.s41)}',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Reference 4-port matrix form:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  _buildLeftMath(
                    r'\mathbf{S}=\begin{bmatrix}'
                    r'S_{11}&S_{21}&S_{31}&S_{41}\\'
                    r'S_{21}&S_{11}&S_{41}&S_{31}\\'
                    r'S_{31}&S_{41}&S_{11}&S_{21}\\'
                    r'S_{41}&S_{31}&S_{21}&S_{11}'
                    r'\end{bmatrix}',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Current input port: Port $input",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildLeftMath('\\mathbf{{a}}=${_inputVectorTex(input)}'),
                  const SizedBox(height: 6),
                  _buildLeftMath('\\mathbf{{b}}=${_vector4Tex(bVec)}'),
                ],
              ),
            ),

            _buildMathCard(
              title: "Step 5: Magnitudes Seen in the Simulation",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResultRow("Reflection |S11|", controller.s1_mag),
                  _buildResultRow("Through |S21|", controller.s2_mag),
                  _buildResultRow("Coupled |S31|", controller.s3_mag),
                  _buildResultRow("Isolation |S41|", controller.s4_mag),
                  const SizedBox(height: 12),
                  if (!offCenter && !offIdealImpedance)
                    const Text(
                      "At the ideal point, reflection and isolation should approach zero while through/coupled approach 0.707.",
                      style: TextStyle(fontSize: 12),
                    )
                  else
                    Text(
                      "Deviation from ideal frequency and/or ideal impedances changes the cancellation condition, so S11 and S41 may increase.",
                      style: TextStyle(fontSize: 12, color: Colors.red[700]),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static List<Complex> _outgoingVector(
    int inputPort,
    BranchLineController c,
  ) {
    final matrix = [
      [c.s11, c.s21, c.s31, c.s41],
      [c.s21, c.s11, c.s41, c.s31],
      [c.s31, c.s41, c.s11, c.s21],
      [c.s41, c.s31, c.s21, c.s11],
    ];

    return [
      matrix[0][inputPort - 1],
      matrix[1][inputPort - 1],
      matrix[2][inputPort - 1],
      matrix[3][inputPort - 1],
    ];
  }

  Widget _buildLeftMath(String tex) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Math.tex(
            tex,
            textStyle: const TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.indigo[50],
      child: const Column(
        children: [
          Text(
            "Theoretical Derivation vs. Simulation",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            "This version computes the branch-line coupler from current Z0, Zh, Zv and frequency.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMathCard({required String title, required Widget content}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: content,
          )
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double val) {
    final db = val <= 1e-6 ? -120.0 : 20 * math.log(val) / math.ln10;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 140,
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Text(" = "),
              Text(
                val.toStringAsFixed(4),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${db.toStringAsFixed(1)} dB",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: val.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  static String _f(double v) => v.toStringAsFixed(4);

  static String _cTex(Complex c) {
    final r = c.re.toStringAsFixed(4);
    final i = c.im.abs().toStringAsFixed(4);
    final sign = c.im >= 0 ? '+' : '-';
    return '$r$sign j$i';
  }

  static String _matrix2x2Tex(Complex a, Complex b, Complex c, Complex d) {
    return '\\begin{bmatrix}'
        '${_cTex(a)} & ${_cTex(b)} \\\\ '
        '${_cTex(c)} & ${_cTex(d)}'
        '\\end{bmatrix}';
  }

  static String _inputVectorTex(int port) {
    if (port == 1) return '\\begin{bmatrix}1\\\\0\\\\0\\\\0\\end{bmatrix}';
    if (port == 2) return '\\begin{bmatrix}0\\\\1\\\\0\\\\0\\end{bmatrix}';
    if (port == 3) return '\\begin{bmatrix}0\\\\0\\\\1\\\\0\\end{bmatrix}';
    return '\\begin{bmatrix}0\\\\0\\\\0\\\\1\\end{bmatrix}';
  }

  static String _vector4Tex(List<Complex> v) {
    return '\\begin{bmatrix}'
        '${_cTex(v[0])}\\\\'
        '${_cTex(v[1])}\\\\'
        '${_cTex(v[2])}\\\\'
        '${_cTex(v[3])}'
        '\\end{bmatrix}';
  }
}
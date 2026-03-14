import 'dart:math' as math;
import 'dart:ui';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:polarization/shared/senum/senum.dart';
import 'package:polarization/polarization_symbols.dart';



enum SourceField {
  et('Electric Field, Time'),
  ep('Electric Field, Phasor'),
  mt('Magnetic Field, Time'),
  mp('Magnetic Field, Phasor'),
  ;

  final String name;

  const SourceField(
    this.name,
  );
}

enum TriFunc {
  cos(
    name: 'cos',
    tex: r'\cos'
  ),
  sin(
    name: 'sin',
    tex: r'\sin',
  ),
  ;

  final String name;
  final String tex;

  const TriFunc({
    required this.name,
    required this.tex,
  });
}

enum Sign {
  plus(true, '+', symExpJBetaZPositive, -1),
  minus(false, '-', symExpJBetaZNegative, 1);

  /// positive? 
  final bool b;
  /// text
  final String t;
  /// exponential jbz tex string
  final String e;
  /// 1 or -1 (used for ak cross az)
  /// 
  /// +1 -> ak = +az, <br />
  /// -1 -> ak = -az
  final int i;

  const Sign(
    this.b,
    this.t,
    this.e,
    this.i,
  );
}


/// init
/// New parameters for plane wave
/// Incident E field


/// Incident H field


/// Reflected E field


/// Reflected H field



/// Transmitted E field
Complex _paramTEx = ComplexRect(0, 0);
Complex _paramTEy = ComplexRect(0, 0);
Complex _paramTEz = ComplexRect(0, 0);
Complex get paramTEx => _paramTEx;
Complex get paramTEy => _paramTEy;
Complex get paramTEz => _paramTEz;
String get texParamTEx => texComplex(_paramTEx);
String get texParamTEy => texComplex(_paramTEy);
String get texParamTEz => texComplex(_paramTEz);
String get texParamTExAmp => '(${SciNum.sciTex(_paramTEx.modulus, ignoreNoise: true)})';
String get texParamTEyAmp => '(${SciNum.sciTex(_paramTEy.modulus, ignoreNoise: true)})';
String get texParamTEzAmp => '(${SciNum.sciTex(_paramTEz.modulus, ignoreNoise: true)})';

/// Transmitted H field
Complex _paramTHx = ComplexRect(0, 0);
Complex _paramTHy = ComplexRect(0, 0);
Complex _paramTHz = ComplexRect(0, 0);
Complex get paramTHx => _paramTHx;
Complex get paramTHy => _paramTHy;
Complex get paramTHz => _paramTHz;
String get texParamTHx => texComplex(_paramTHx);
String get texParamTHy => texComplex(_paramTHy);
String get texParamTHz => texComplex(_paramTHz);

String get texParamTHxConj => texComplex(_paramTHx.conjugate());
String get texParamTHyConj => texComplex(_paramTHy.conjugate());
String get texParamTHzConj => texComplex(_paramTHz.conjugate());

/// Time-average Ponying vector S


Complex _sTx = ComplexRect(0, 0);
Complex _sTy = ComplexRect(0, 0);
Complex _sTz = ComplexRect(0, 0);
Complex get sTx => _sTx;
Complex get sTy => _sTy;
Complex get sTz => _sTz;
String get texSTx => texComplex(_sTx, hideNoise: true, format: ComplexFormat.polar, withBracket: true);
String get texSTy => texComplex(_sTy, hideNoise: true, format: ComplexFormat.polar, withBracket: true);
String get texSTz => texComplex(_sTz, hideNoise: true, format: ComplexFormat.polar, withBracket: true);
double _pynTx = 0;
double _pynTy = 0;
double _pynTz = 0;
double get pynTx => _pynTx;
double get pynTy => _pynTy;
double get pynTz => _pynTz;
String get texPynTx => '(${SciNum.sciTex(_pynTx, ignoreNoise: true)})';
String get texPynTy => '(${SciNum.sciTex(_pynTy, ignoreNoise: true)})';
String get texPynTz => '(${SciNum.sciTex(_pynTz, ignoreNoise: true)})';


SourceField _type = SourceField.ep;
Sign _paramBetaSign = Sign.minus;

// converted standard e-field
double _paramEx = 1;
double _paramEy = 1;
Angle _paramEPhix = AngleDemiTurn(-31);
Angle _paramEPhiy = AngleDemiTurn(-53);
Angle _paramEPhiz = AngleDemiTurn(-121);

// converted standard h-field
double _paramHx = 1;
double _paramHy = 1;
Angle _paramHPhix = AngleDemiTurn(0);
Angle _paramHPhiy = AngleDemiTurn(0.5);

// e-field time-domain input
double _paramEtEx = 1;
double _paramEtEy = 1;
TriFunc _paramEtExTri = TriFunc.cos;
TriFunc _paramEtEyTri = TriFunc.cos;
Angle _paramEtPhix = AngleDemiTurn(0);
Angle _paramEtPhiy = AngleDemiTurn(0.5);

// e-field phasor-format input
Complex _paramEpEx = ComplexRect(1, 0);
Complex _paramEpEy = ComplexRect(1, 0);

// h-field time-domain input
double _paramMtHx = 1;
double _paramMtHy = 1;
TriFunc _paramMtHxTri = TriFunc.cos;
TriFunc _paramMtHyTri = TriFunc.cos;
Angle _paramMtPhix = AngleDemiTurn(0);
Angle _paramMtPhiy = AngleDemiTurn(0.5);

// h-field phasor-format input
Complex _paramMpHx = ComplexRect(1, 0);
Complex _paramMpHy = ComplexRect(1, 0);

void init() {
  _paramUpdate();
}

final double _eta0 = math.sqrt(Constant.mu0.val / Constant.epsilon0.val);
double get eta0 => _eta0;


  
//////   Paras of Medium 1   ///////
// eps
double _epsilonR1 = 1;
double get epsilonR1 => _epsilonR1;
set epsilonR1(double val) {
  _epsilonR1 = val;
  _update();
}
double get epsilon1 => _epsilonR1 * Constant.epsilon0.val;
String get texEps1 => SciNum.sciTex(epsilon1);
String get texEpsR1 => SciNum.sciTex(epsilonR1);
String get texMuR1 => SciNum.sciTex(muR1);

// mu
double _muR1 = 1;
set muR1(double val) {
  _muR1 = val;
  _update();
}
double get muR1 => _muR1;
double get mu1 => _muR1 * Constant.mu0.val;
String get texMu1 => SciNum.sciTex(mu1);
String get texEpsR2 => SciNum.sciTex(epsilonR2);
String get texMuR2 => SciNum.sciTex(muR2);

// Complex eps
Complex _epsilonC1 = ComplexRect(0, 0);
Complex get epsilonC1 => _epsilonC1;
String get texEpsilonC1 => texComplex(_epsilonC1);

// vp
double _vp1 = 0;
double get vp1 => _vp1;

// gamma
Complex _gamma1 = ComplexRect(0, 0);
Complex get gamma1 => _gamma1;
String get texGamma1 => texComplex(_gamma1);

// beta
double _beta1 = 0;
double get beta1 => _beta1;

// lambda
double _lambda1 = 0;
double get lambda1 => _lambda1;

// eta
double _eta1 = 0;
double get eta1 => _eta1;
String get texEta1 => SciNum.sciTex(_eta1);

// k
double _k1 = 0;
double get k1 =>_k1;
String get texK1 => SciNum.sciTex(_k1);
////////////////////////////////////////

//////   Paras of Medium 2   ///////
/// whether medium 2 is lossy
bool _isMedium2Lossy = true;
bool get isMedium2Lossy => _isMedium2Lossy;
set isMedium2Lossy(bool val){
  _isMedium2Lossy = val;
  _update();
}
/// eps
double _epsilonR2 = 1;
double get epsilonR2 => _epsilonR2;
set epsilonR2(double val) {
  _epsilonR2 = val;
  _update();
}
double get epsilon2 => _epsilonR2 * Constant.epsilon0.val;

/// mu
double _muR2 = 1;
set muR2(double val) {
  _muR2 = val;
  _update();
}
double get muR2 => _muR2;
double get mu2 => _muR2 * Constant.mu0.val;
String get texMu2 => SciNum.sciTex(mu2);

/// sigma
double _sigma2 = 0;
double get sigma2 => _sigma2;
set sigma2(double val) {
  _sigma2 = val;
  _update();
}

/// Complex eps
Complex _epsilonC2 = ComplexRect(0, 0);
Complex get epsilonC2 => _epsilonC2;
String get texEpsilonC2 => texComplex(_epsilonC2);

/// vp
double _vp2 = 0;
double get vp2 => _vp2;
// alpha
double _alpha2 = 0;
double get alpha2 => _alpha2;
// beta
double _beta2 = 0;
double get beta2 => _beta2;
// delta
double _delta2 = 0;
double get delta2 => _delta2;
// gamma
Complex _gamma2 = ComplexRect(0, 0);
Complex get gamma2 => _gamma2;
String get texGamma2 => texComplex(_gamma2, format: ComplexFormat.rect);
// lambda
double _lambda2 = 0;
double get lambda2 => _lambda2;
// k
Complex _k2 = ComplexRect(0, 0);
Complex get k2 => _k2;
String get texK2 => texComplex(_k2, format: ComplexFormat.rect);
// eta
Complex _eta2 = ComplexRect(0, 0);
Complex get eta2 => _eta2;
String get texEta2 => texComplex(_eta2, format: ComplexFormat.rect);
////////////////////////////////////////

//Input Mode
bool _isGivenThetai = false;
bool get isGivenThetai => _isGivenThetai;
set isGivenThetai(bool val){
  _isGivenThetai = val;
  _update();
}

bool _isGivenFreq = false;
bool get isGivenFreq => _isGivenFreq;
set isGivenFreq(bool val){
  _isGivenFreq = val;
  _update();
}

//k vector (kx and kz)
double _kx = 0;
double _kz = 0;
double get kx => _kx;
double get kz => _kz;

Complex get kxt => k2 * _angleTSin;
Complex get kzt => k2 * _angleTCos;
String get kxtTex => texComplex(kxt, format:ComplexFormat.rect, hideNoise: true);
String get kztTex => texComplex(kzt, format:ComplexFormat.rect, hideNoise: true);

String get texKx => SciNum.sciTex(_kx);
String get texKz => SciNum.sciTex(_kz);
String get txtExpI => 'e^{-j[($texKx) \\mathbf{x} + ($texKz) \\mathbf{z}]}';
String get txtExpR => 'e^{-j[($texKx) \\mathbf{x} - ($texKz) \\mathbf{z}]}';
String get txtExpT => 'e^{-j[($kxtTex) \\mathbf{x} + ($kztTex) \\mathbf{z}]}';

set kx(double val){
  _kx = val;
  _update();
}
set kz(double val){
  _kz = val;
  _update();
}
// right?
double _k = 0;
double get k => _k;



// Incident angle (Theta_i)
Angle _angleI = AngleDegree(0);
Angle get angleI => _angleI;
set angleI(Angle val) {
  _angleI = val;
  _paramUpdate();
}
String get texAngleI => texAngle(_angleI);
String get texAngleIRad => texAngle(_angleI, unit: AngleUnit.rad);
String get texAngleIDeg => texAngle(_angleI, unit: AngleUnit.deg);


// Transmission angle


Complex _angleTSin = ComplexRect(1, 0);
Complex get angleTSin => _angleTSin;
set angleTSin(Complex val) {
  _angleTSin = val;
  _update();
}

String get texAngleTSin{
  if (_angleTSin.im.abs() > 1e-6){
    return texComplex(_angleTSin, format: ComplexFormat.rect);
  }
  else{
    return SciNum.sciTex(_angleTSin.re);
  }
}

Complex _angleTCos = ComplexRect(1, 0);
Complex get angleTCos => _angleTCos;
// set angleTCos(Complex val) {
//   _angleTCos = val;
//   _update();
// }

String get texAngleTCos{
  if (_angleTCos.im.abs() > 1e-6){
    return texComplex(_angleTCos, format:ComplexFormat.rect, hideNoise: true);
  }
  else{
    return SciNum.sciTex(_angleTCos.re);
  }
}

String get texAngleTCosPM => '\\pm ($texAngleTCos)';

String get texAngleTCosC{
  if (_angleTCos.im.abs() > 1e-6){
    return texComplex(_angleTCos, format:ComplexFormat.rect, hideNoise: true);
  }
  else{
    return SciNum.sciTex(_angleTCos.re);
  }
}

String get texAngleTCosConj{
  if (_angleTCos.im.abs() > 1e-6){
    return texComplex(_angleTCos.conjugate(), format:ComplexFormat.rect, hideNoise: true);
  }
  else{
    return SciNum.sciTex(_angleTCos.re);
  }
}

String get texAngleTCosNega{
  if (_angleTCos.im.abs() > 1e-6){
    return texComplex(-_angleTCos, format:ComplexFormat.rect, hideNoise: true);
  }
  else{
    return SciNum.sciTex(-_angleTCos.re);
  }
}

// Angular velocity (Omega)
double _omega = 1;
set omega(double val) {
  _omega = val;
  _update();
}
double get omega => _omega;
String get texOmega => SciNum.sciTex(_omega);

double _freq = 1;
set freq(double val) {
  _freq = val;
  _update();
}
double get freq => _freq;
String get texFreq => SciNum.sciTex(_freq);



// Direction of propagation


Complex _aktX = ComplexRect(0, 0);
Complex get aktX => _aktX; 
String get texAktX => texComplex(aktX, withBracket: true, hideNoise: true, format: ComplexFormat.rect);
String get texAktXPolar => texComplex(aktX, hideNoise: true, format: ComplexFormat.polar);

Complex _aktZ = ComplexRect(0, 0);
Complex get aktZ => _aktZ; 
String get texAktZ => texComplex(aktZ, withBracket: true, hideNoise: true, format: ComplexFormat.rect);
String get texAktZPolar => texComplex(aktZ, hideNoise: true, format: ComplexFormat.polar);

String get texAkt => '$texAktX $symAx + $texAktZ $symAz';
String get texAktPolar => '$texAktXPolar $symAx + $texAktZPolar $symAz';










void _update(){


  //medium 2

  _eta2 = ComplexRect(376.7,0);

  
  // Calculate the incident field
  if (_isGivenThetai){
    _kx = _k1 * math.sin(_angleI.rad);
    _kz = _k1 * math.cos(_angleI.rad);
  }
  else{
    _angleI = AngleRadian(math.atan(_kx/ _kz));
  }
  _k = math.sqrt(_kx*_kx + _kz*_kz);



  
  _angleTSin = ComplexRect(1.2,0);  
  _angleTCos = Complex.sqrt(ComplexRect(1, 0) - _angleTSin * _angleTSin);
  
  if ((k2 *_angleTCos).im > 0){
    _angleTCos = -_angleTCos;
  }

  

  // Calculate the direction of propagation 


  _aktX = _angleTSin;
  _aktZ = _angleTCos;
  // notifyListeners();
  _paramEpUpdate();
  
}


// param


/// To get the type of input as [SourceField]
/// 
/// possible values: <br />
/// [SourceField.et] - electric field, time domain, <br />
/// [SourceField.ep] - electric field, phasor format, <br />
/// [SourceField.mt] - magnetic field, time domain, <br />
/// [SourceField.mp] - magnetic field, phasor format. 
SourceField get type => _type;

/// To get the sign of beta as [Sign]
/// 
/// [Sign.minus] indicate propogation to +z direction, 
/// i.e. exp(-jbz)
/// <br />
/// [Sign.plus] indicate propogation to -z direction,
/// or exp(+jbz)
Sign get paramBetaSign => _paramBetaSign;

double get paramEtEx => _paramEtEx;
double get paramEtEy => _paramEtEy;
TriFunc get paramEtExTri => _paramEtExTri;
TriFunc get paramEtEyTri => _paramEtEyTri;
Angle get paramEtPhix => _paramEtPhix;
Angle get paramEtPhiy => _paramEtPhiy;
Map<String, dynamic> get paramEt => {
  'type': _type,
  'Ex': _paramEtEx,
  'Ey': _paramEtEy,
  'trix': _paramEtExTri,
  'triy': _paramEtEyTri,
  'phix': _paramEtPhix,
  'phiy': _paramEtPhiy,
  'sign': _paramBetaSign,
};
set paramEt(Map<String, dynamic> p) {
  _type = SourceField.et;

  _paramBetaSign = p['sign'] ?? _paramBetaSign;

  _paramEtEx = p['Ex'] ?? _paramEtEx;
  _paramEtEy = p['Ey'] ?? _paramEtEy;
  _paramEtExTri = p['trix'] ?? _paramEtExTri;
  _paramEtEyTri = p['triy'] ?? _paramEtEyTri;
  _paramEtPhix = p['phix'] ?? _paramEtPhix;
  _paramEtPhiy = p['phiy'] ?? _paramEtPhiy;

  _paramEtUpdate();
}

void _paramEtUpdate() {
  
  

  _paramUpdate();
}

Complex get paramEpEx => _paramEpEx;
Complex get paramEpEy => _paramEpEy;
Map<String, dynamic> get paramEp => {
  'type': _type,
  'Ex': _paramEpEx,
  'Ey': _paramEpEy,
  'sign': _paramBetaSign,
};
set paramEp(Map<String, dynamic> p) {
  _type = SourceField.ep;

  _paramBetaSign = p['sign'] ?? _paramBetaSign;

  _paramEpEx = p['Ex'] ?? _paramEpEx;
  _paramEpEy = p['Ey'] ?? _paramEpEy;

  _paramEpUpdate();
}

/////// Modify here
void _paramEpUpdate() {
  


  // incident params



  // reflected params
 
  // transmitted params // try
  
  _paramTEx = ComplexPolar(5.138, AngleDegree(-31.09));

  _paramTEy = ComplexPolar(8.05, AngleDegree(-53.61));

  _paramTEz = ComplexPolar(9.295, AngleDegree(-121.1));

  _paramTHx = ComplexPolar(0.01417, AngleDegree(36.39));

  _paramTHy = ComplexPolar(0.02056, AngleDegree(58.91));

  _paramTHz = ComplexPolar(0.02564, AngleDegree(-53.61));

  // poynting vectors
  

  _sTx = _paramTEy * _paramTHz.conjugate() - _paramTEz * _paramTHy.conjugate();
  _sTy = _paramTEz * _paramTHx.conjugate() - _paramTEx * _paramTHz.conjugate();
  _sTz = _paramTEx * _paramTHy.conjugate() - _paramTEy * _paramTHx.conjugate();

  
  _pynTx = _sTx.re / 2;
  _pynTy = _sTy.re / 2;
  _pynTz = _sTz.re / 2;
  _paramUpdate();
}

double get paramMtHx => _paramMtHx;
double get paramMtHy => _paramMtHy;
TriFunc get paramMtHxTri => _paramMtHxTri;
TriFunc get paramMtHyTri => _paramMtHyTri;
Angle get paramMtPhix => _paramMtPhix;
Angle get paramMtPhiy => _paramMtPhiy;
Map<String, dynamic> get paramMt => {
  'type': _type,
  'Hx': _paramMtHx,
  'Hy': _paramMtHy,
  'trix': _paramMtHxTri,
  'triy': _paramMtHyTri,
  'phix': _paramMtPhix,
  'phiy': _paramMtPhiy,
  'sign': _paramBetaSign,
};
set paramMt(Map<String, dynamic> p) {
  _type = SourceField.mt;

  _paramBetaSign = p['sign'] ?? _paramBetaSign;

  _paramMtHx = p['Hx'] ?? _paramMtHx;
  _paramMtHy = p['Hy'] ?? _paramMtHy;
  _paramMtHxTri = p['trix'] ?? _paramMtHxTri;
  _paramMtHyTri = p['triy'] ?? _paramMtHyTri;
  _paramMtPhix = p['phix'] ?? _paramMtPhix;
  _paramMtPhiy = p['phiy'] ?? _paramMtPhiy;

  _paramMtUpdate();
}

void _paramMtUpdate() {
  // to mp
  _paramMpHx = ComplexPolar(_paramMtHx, _paramMtPhix);
  _paramMpHy = ComplexPolar(_paramMtHy, _paramMtPhiy);

  // Hx
  if (_paramMtHx >= 0) { // actually we don't care when it is zero
    _paramHx = _paramMtHx;
    _paramHPhix = switch (_paramMtHxTri) {
      TriFunc.cos => _paramMtPhix.inLongitude(),
      TriFunc.sin => (_paramMtPhix - AngleDemiTurn(0.5)).inLongitude(), // sin(x) -> cos(x-pi/2)
    };
  }
  else {
    _paramHx = -_paramMtHx;
    _paramHPhix = switch (_paramMtHxTri) {
      TriFunc.cos => (_paramMtPhix + AngleDemiTurn(1)).inLongitude(),   // -cos(x) -> cos(x+pi)
      TriFunc.sin => (_paramMtPhix + AngleDemiTurn(0.5)).inLongitude(), // -sin(x) -> cos(x+pi/2)
    };
  }

  // Hy
  if (_paramMtHy >= 0) { // actually we don't care when it is zero
    _paramHy = _paramMtHy;
    _paramHPhiy = switch (_paramMtHyTri) {
      TriFunc.cos => _paramMtPhiy.inLongitude(),
      TriFunc.sin => (_paramMtPhiy - AngleDemiTurn(0.5)).inLongitude(), // sin(x) -> cos(x-pi/2)
    };
  }
  else {
    _paramHy = -_paramMtHy;
    _paramHPhiy = switch (_paramMtHyTri) {
      TriFunc.cos => (_paramMtPhiy + AngleDemiTurn(1)).inLongitude(),   // -cos(x) -> cos(x+pi)
      TriFunc.sin => (_paramMtPhiy + AngleDemiTurn(0.5)).inLongitude(), // -sin(x) -> cos(x+pi/2)
    };
  }

  // to et
  _paramEtEx = _paramMtHy * _eta0 * _paramBetaSign.i;
  _paramEtExTri = _paramMtHyTri;
  _paramEtPhix = _paramMtPhiy;
  _paramEtEy = _paramMtHx * (-_eta0 * _paramBetaSign.i);
  _paramEtEyTri = _paramMtHxTri;
  _paramEtPhiy = _paramMtPhix;

  // to ep
  _paramEpEx = ComplexPolar(_paramMtHx, _paramMtPhix).multiply(_eta0 * _paramBetaSign.i);
  _paramEpEy = ComplexPolar(_paramMtHy, _paramMtPhiy).multiply(-_eta0 * _paramBetaSign.i);

  // Ex
  _paramEx = _paramEpEx.simplify().modulus;
  _paramEPhix = _paramEpEx.simplify().arg.inLongitude();

  // Ey
  _paramEy = _paramEpEy.simplify().modulus;
  _paramEPhiy = _paramEpEy.simplify().arg.inLongitude();

  // // Ex = eta Hy
  // if (_paramMtHy >= 0) { // actually we don't care when it is zero
  //   _paramEx = _paramMtHy * _eta0;
  //   _paramEPhix = switch (_paramMtHyTri) {
  //     TriFunc.cos => _paramMtPhiy.inLongitude(),
  //     TriFunc.sin => (_paramMtPhiy - AngleDemiTurn(0.5)).inLongitude(), // sin(x) -> cos(x-pi/2)
  //   };
  // }
  // else {
  //   _paramEx = - _paramMtHy * _eta0;
  //   _paramEPhix = switch (_paramMtHyTri) {
  //     TriFunc.cos => (_paramMtPhiy + AngleDemiTurn(1)).inLongitude(),   // -cos(x) -> cos(x+pi)
  //     TriFunc.sin => (_paramMtPhiy + AngleDemiTurn(0.5)).inLongitude(), // -sin(x) -> cos(x+pi/2)
  //   };
  // }

  // // Ey
  // // Ey = - eta Hx
  // if (_paramMtHx >= 0) { // actually we don't care when it is zero
  //   _paramEy = _eta0 * _paramMtHx;
  //   _paramEPhiy = switch (_paramMtHxTri) {
  //     TriFunc.cos => _paramMtPhix.inLongitude(),
  //     TriFunc.sin => (_paramMtPhix - AngleDemiTurn(0.5)).inLongitude(), // sin(x) -> cos(x-pi/2)
  //   };
  // }
  // else {
  //   _paramEy = - _paramMtHx * _eta0;
  //   _paramEPhiy = switch (_paramMtHxTri) {
  //     TriFunc.cos => (_paramMtPhix + AngleDemiTurn(1)).inLongitude(),   // -cos(x) -> cos(x+pi)
  //     TriFunc.sin => (_paramMtPhix + AngleDemiTurn(0.5)).inLongitude(), // -sin(x) -> cos(x+pi/2)
  //   };
  // }

  _paramUpdate();
}

Complex get paramMpHx => _paramMpHx;
Complex get paramMpHy => _paramMpHy;
Map<String, dynamic> get paramMp => {
  'type': _type,
  'Ex': _paramMpHx,
  'Ey': _paramMpHy,
  'sign': _paramBetaSign,
};
set paramMp(Map<String, dynamic> p) {
  _type = SourceField.mp;

  _paramBetaSign = p['sign'] ?? _paramBetaSign;

  _paramMpHx = p['Hx'] ?? _paramMpHx;
  _paramMpHy = p['Hy'] ?? _paramMpHy;

  _paramMpUpdate();
}

void _paramMpUpdate() {
  // to mt
  _paramMtHx = _paramMpHx.modulus;
  _paramMtHxTri = TriFunc.cos;
  _paramMtPhix = _paramMpHx.arg;
  _paramMtHy = _paramMpHy.modulus;
  _paramMtHyTri = TriFunc.cos;
  _paramMtPhiy = _paramMpHy.arg;

  // Hx
  _paramHx = _paramMpHx.simplify().modulus;
  _paramHPhix = _paramMpHx.simplify().arg.inLongitude();

  // Hy
  _paramHy = _paramMpHy.simplify().modulus;
  _paramHPhiy = _paramMpHy.simplify().arg.inLongitude();



  // to et
  _paramEtEx = _paramMpHy.modulus * _eta0 * _paramBetaSign.i;
  _paramEtExTri = TriFunc.cos;
  _paramEtPhix = _paramMpHy.arg;
  _paramEtEy = _paramMpHx.modulus * (-_eta0 * _paramBetaSign.i);
  _paramEtEyTri = TriFunc.cos;
  _paramEtPhiy = _paramMpHx.arg;

  // tp ep
  _paramEpEx = _paramMpHy.multiply(_eta0 * _paramBetaSign.i);
  _paramEpEy = _paramMpHx.multiply(-_eta0 * _paramBetaSign.i);

  // Ex
  _paramEx = _paramEpEx.simplify().modulus;
  _paramEPhix = _paramEpEx.simplify().arg.inLongitude();

  // Ey
  _paramEy = _paramEpEy.simplify().modulus;
  _paramEPhiy = _paramEpEy.simplify().arg.inLongitude();

  _paramUpdate();
}


/// value of Ex in standard form
double get paramEx => _paramEx;
/// value of Ey in standard form
double get paramEy => _paramEy;
/// value of phiEx in standard form
Angle get paramEPhix => _paramEPhix;
/// value of phiEy in standard form
Angle get paramEPhiy => _paramEPhiy;
/// value of Ex (complex number) in standard form
Complex get paramExComplex => ComplexPolar(_paramEx, _paramEPhix);
/// value of Ey (complex number) in standard form
Complex get paramEyComplex => ComplexPolar(_paramEy, _paramEPhiy);

Map<String, dynamic> get paramE {
  return {
    'Ex': _paramEx,
    'Ey': _paramEy,
    'phix': _paramEPhix,
    'phiy': _paramEPhiy,
  };
}

/// value of Hx in standard form
double get paramHx => _paramHx;
/// value of Hy in standard form
double get paramHy => _paramHy;
/// value of phiHx in standard form
Angle get paramHPhix => _paramHPhix;
/// value of phiHy in standard form
Angle get paramHPhiy => _paramHPhiy;
/// value of Hx (complex number) in standard form
Complex get paramHxComplex => ComplexPolar(_paramHx, _paramHPhix);
/// value of Hx (complex number) in standard form
Complex get paramHyComplex => ComplexPolar(_paramHy, _paramHPhiy);

Map<String, dynamic> get paramH {
  return {
    'Hx': _paramHx,
    'Hy': _paramHy,
    'phix': _paramHPhix,
    'phiy': _paramHPhiy,
  };
}



/// should be called after value change
void _paramUpdate() {

  // notifyListeners();

  // developer.log('Updates: ', name: 'SourceController');

  // developer.log('EtEx: EtEx=$_paramEtEx, EtPhix.ori=${_paramEtPhix.ori}, EtPhix.src=${_paramEtPhix.src}, EtExTri=$_paramEtExTri', name: 'SourceController');
  // developer.log('EtEy: EtEy=$_paramEtEy, EtPhiy.ori=${_paramEtPhiy.ori}, EtPhiy.src=${_paramEtPhiy.src}, EtEyTri=$_paramEtEyTri', name: 'SourceController');
  // developer.log('EpEx: EpEx.re=${_paramEpEx.re}, EpEx.im=${_paramEpEx.im}, EpEx.modulus=${_paramEpEx.modulus}, EpEx.arg.ori=${_paramEpEx.arg.ori}, EpEx.arg.src=${_paramEpEx.arg.src}', name: 'SourceController');
  // developer.log('EpEy: EpEy.re=${_paramEpEy.re}, EpEy.im=${_paramEpEy.im}, EpEy.modulus=${_paramEpEy.modulus}, EpEy.arg.ori=${_paramEpEy.arg.ori}, EpEy.arg.src=${_paramEpEy.arg.src}', name: 'SourceController');

  // developer.log('MtHx: MtHx=$_paramMtHx, MtPhix.ori=${_paramMtPhix.ori}, MtPhix.src=${_paramMtPhix.src}, MtHxTri=$_paramMtHxTri', name: 'SourceController');
  // developer.log('MtHy: MtHy=$_paramMtHy, MtPhiy.ori=${_paramMtPhiy.ori}, MtPhiy.src=${_paramMtPhiy.src}, MtHyTri=$_paramMtHyTri', name: 'SourceController');
  // developer.log('MpHx: MpHx.re=${_paramMpHx.re}, MpHx.im=${_paramMpHx.im}, MpHx.modulus=${_paramMpHx.modulus}, MpHx.arg.ori=${_paramMpHx.arg.ori}, MpHx.arg.src=${_paramMpHx.arg.src}', name: 'SourceController');
  // developer.log('MpHy: MpHy.re=${_paramMpHy.re}, MpHy.im=${_paramMpHy.im}, MpHy.modulus=${_paramMpHy.modulus}, MpHy.arg.ori=${_paramMpHy.arg.ori}, MpHy.arg.src=${_paramMpHy.arg.src}', name: 'SourceController');

  // developer.log('EStd: Ex=$_paramEx, EPhix.ori=${_paramEPhix.ori}, EPhix.src=${_paramEPhix.src}; Ey=$_paramEy, EPhiy.ori=${_paramEPhiy.ori}, EPhiy.src=${_paramEPhiy.src}', name: 'SourceController');
  // developer.log('HStd: Hx=$_paramHx, HPhix.ori=${_paramHPhix.ori}, HPhix.src=${_paramHPhix.src}; Hy=$_paramHy, HPhiy.ori=${_paramHPhiy.ori}, HPhiy.src=${_paramHPhiy.src}', name: 'SourceController');

  developer.log(
    '''
    Updates: 
    EtEx: EtEx=$_paramEtEx, EtPhix.ori=${_paramEtPhix.ori}, EtPhix.src=${_paramEtPhix.src}, EtExTri=$_paramEtExTri
    EtEy: EtEy=$_paramEtEy, EtPhiy.ori=${_paramEtPhiy.ori}, EtPhiy.src=${_paramEtPhiy.src}, EtEyTri=$_paramEtEyTri
    EpEx: EpEx.re=${_paramEpEx.re}, EpEx.im=${_paramEpEx.im}, EpEx.modulus=${_paramEpEx.modulus}, EpEx.arg.ori=${_paramEpEx.arg.ori}, EpEx.arg.src=${_paramEpEx.arg.src}
    EpEy: EpEy.re=${_paramEpEy.re}, EpEy.im=${_paramEpEy.im}, EpEy.modulus=${_paramEpEy.modulus}, EpEy.arg.ori=${_paramEpEy.arg.ori}, EpEy.arg.src=${_paramEpEy.arg.src}
    MtHx: MtHx=$_paramMtHx, MtPhix.ori=${_paramMtPhix.ori}, MtPhix.src=${_paramMtPhix.src}, MtHxTri=$_paramMtHxTri
    MtHy: MtHy=$_paramMtHy, MtPhiy.ori=${_paramMtPhiy.ori}, MtPhiy.src=${_paramMtPhiy.src}, MtHyTri=$_paramMtHyTri
    MpHx: MpHx.re=${_paramMpHx.re}, MpHx.im=${_paramMpHx.im}, MpHx.modulus=${_paramMpHx.modulus}, MpHx.arg.ori=${_paramMpHx.arg.ori}, MpHx.arg.src=${_paramMpHx.arg.src}
    MpHy: MpHy.re=${_paramMpHy.re}, MpHy.im=${_paramMpHy.im}, MpHy.modulus=${_paramMpHy.modulus}, MpHy.arg.ori=${_paramMpHy.arg.ori}, MpHy.arg.src=${_paramMpHy.arg.src}
    EStd: Ex=$_paramEx, EPhix.ori=${_paramEPhix.ori}, EPhix.src=${_paramEPhix.src}; Ey=$_paramEy, EPhiy.ori=${_paramEPhiy.ori}, EPhiy.src=${_paramEPhiy.src}
    HStd: Hx=$_paramHx, HPhix.ori=${_paramHPhix.ori}, HPhix.src=${_paramHPhix.src}; Hy=$_paramHy, HPhiy.ori=${_paramHPhiy.ori}, HPhiy.src=${_paramHPhiy.src}
    ''',
    name: 'SourceController'
  );
}



/// param and expression in string (latex)

String intOrDouble(num val, {int precision = 2}) {
  for (var d = 0; d <= precision; d++) {
    // DO NOT find reminder like this
    // float is not accurate! 
    // if ((val.remainder(math.pow(0.1, d)).abs()) < math.pow(0.1, d+1)) {
    //   return val.toStringAsFixed(d);
    // }
    if ((math.pow(10, d) * val % 1) == 0) {
      return val.toStringAsFixed(d);
    }
  }
  // the value is too long, cut it down
  return val.toStringAsFixed(precision);
}
String intOrDoubleCoefficient(double val, {int precision = 2}) {
  if (val == 1) {
    return '';
  }
  else {
    return intOrDouble(val, precision: precision);
  }
}
String texAngleWithPi(double rad, {int precision = 2}) {
  if (rad == 0) {
    return '0';
  }
  else {
    return ('${intOrDoubleCoefficient(rad, precision: precision)}' r'\pi');
  }
}

String texAngle(Angle angle, {AngleUnit? unit}) {
  if (unit != null){
    switch (unit) {
    case AngleUnit.deg:
      return '{${SciNum.sciTex(angle.deg)}}' r'^\circ ';
    case AngleUnit.rad:
      return SciNum.sciTex(angle.rad);
    case AngleUnit.npi:
      if (angle.npi == 1) {
        return symPi;
      }
      else if (angle.npi == -1 ) {
        return '- $symPi';
      }
      else if (angle.npi == 0) {
        return '0';
      }
      else {
        return '${SciNum.sciTex(angle.npi)}' r'\pi ';
      }
    }
  }
  switch (angle.src) {
    case AngleUnit.deg:
      return '{${SciNum.sciTex(angle.deg)}}' r'^\circ ';
    case AngleUnit.rad:
      return SciNum.sciTex(angle.rad);
    case AngleUnit.npi:
      if (angle.npi == 1) {
        return symPi;
      }
      else if (angle.npi == -1 ) {
        return '- $symPi';
      }
      else if (angle.npi == 0) {
        return '0';
      }
      else {
        return '${SciNum.sciTex(angle.npi)}' r'\pi ';
      }
  }
}

String? texJAngle(Angle angle) {
  if (angle.ori > 0) {
    return 'j ${texAngle(angle)}';
  }
  else if (angle.ori < 0) {
    switch (angle.src) {
      case AngleUnit.deg:
        return '- j ${SciNum.sciTex(angle.deg.abs())}' r'^\circ ';
      case AngleUnit.rad:
        if (angle.rad != 1) {
          return '- j ${SciNum.sciTex(angle.rad.abs())}';
        }
        else {
          return r'- j';
        }
      case AngleUnit.npi:
        if (angle.npi != 1) {
          return '- j ${SciNum.sciTex(angle.npi.abs())}' r'\pi ';
        }
        else {
          return r'- j \pi';
        }
    }
  }
  else {
    return null;
  }
}

String? texSciCoefficient(double val) {
  if (val == 0) {
    return null;
  }
  else if (val == 1) {
    return '';
  }
  else if (val < 0) {
    return '(${SciNum.sciTex(val)})';
  }
  else {
    return SciNum.sciTex(val);
  }
}

String? texComplexCoefficient(Complex c) {
  switch (c.fmt) {
    case ComplexFormat.rect:
      if ((c.re != 0) && (c.im != 0)) { // a+jb
        if (c.im > 0) { // a+jb
          return ' (${SciNum.sciTex(c.re)} + j ${texSciCoefficient(c.im)!}) ';
        }
        else {  // a-jb
          return ' (${SciNum.sciTex(c.re)} - j ${texSciCoefficient(c.im.abs())!}) ';
        }
        
      }
      else if ((c.re != 0) && (c.im == 0)) { // a
        if ((c.re > 0) && (c.re != 1)) {
          return '${SciNum.sciTex(c.re)} ';
        }
        else if ((c.re < 0) && (c.re != -1)) {
          return '(${SciNum.sciTex(c.re)}) ';
        }
        else if (c.re == 1) {
          return '';
        }
        else if (c.re == -1) {
          return '(-1)';
        }
        else {
          return null;
        }
      }
      else if ((c.re == 0) && (c.im != 0)) { // jb
        if (c.im > 0) {
          return 'j ${texSciCoefficient(c.im)!} ';
        }
        else {
          return '(-j ${texSciCoefficient(c.im.abs())!}) ';
        }
      }
      else {  // 0
        return null;
      }
    case ComplexFormat.polar:
      if ((c.modulus != 0) && (c.arg.ori != 0)) { // r<theta
        // note: \phase is not supported
        return r' \left(' '${SciNum.sciTex(c.modulus)} ' r' \angle ' '${texAngle(c.arg)} ' r'\right) ';
      }
      else if ((c.modulus != 0) && (c.arg.ori == 0)) { // r
        if ((c.modulus != 1) && (c.modulus != -1)) {
          return texSciCoefficient(c.modulus);
        }
        else if (c.modulus == 1) {
          return '';
        }
        else if (c.modulus == -1) {
          return '(-1)';
        }
        else {
          return null;
        }
      }
      else { // 0
        return null;
      }
  }
}

//hxx // tryT
String texComplexDeg(Complex c, { bool hideNoise = false}){
  String complexStr = '';
  String reStr = texAngle(AngleRadian(c.re), unit: AngleUnit.deg);
  String imStr = texAngle(AngleRadian(c.im), unit: AngleUnit.deg);
  if ((c.re != 0) && (c.im != 0)) { // a+jb
        if (c.im > 0) { // a+jb
          complexStr =  ' $reStr + j $imStr ';
        }
        else {  // a-jb
          complexStr =  ' $reStr + j ($imStr) ';
        }
        
      }
      else if ((c.re != 0) && (c.im == 0)) { // a
        complexStr =  '$reStr ';
      }
      else if ((c.re == 0) && (c.im != 0)) { // jb
        if (c.im > 0) {
          complexStr =  'j $imStr ';
        }
        else {
          complexStr =  '-j ($imStr) ';
        }
      }
      else {  // 0
        return '0';
      }
    return complexStr;
}

String texComplex(Complex c, {bool withBracket = false, ComplexFormat? format, AngleUnit? unit, bool hideNoise = false}) {
  String complexStr = '';
  if (hideNoise && c.re.abs() < 1e-9){
    c = ComplexRect(0, c.im); 
  }
  if (hideNoise && c.im.abs() < 1e-9){
    c = ComplexRect(c.re, 0); 
  }

  if (format != null){
    switch (format) {
    case ComplexFormat.rect:
      if ((c.re != 0) && (c.im != 0)) { // a+jb
        if (c.im > 0) { // a+jb
          complexStr =  ' ${SciNum.sciTex(c.re)} + j ${texSciCoefficient(c.im)!} ';
        }
        else {  // a-jb
          complexStr =  ' ${SciNum.sciTex(c.re)} - j ${texSciCoefficient(c.im.abs())!} ';
        }
        
      }
      else if ((c.re != 0) && (c.im == 0)) { // a
        complexStr =  '${SciNum.sciTex(c.re)} ';
      }
      else if ((c.re == 0) && (c.im != 0)) { // jb
        if (c.im > 0) {
          complexStr =  'j ${texSciCoefficient(c.im)!} ';
        }
        else {
          complexStr =  '-j ${texSciCoefficient(c.im.abs())!}';
        }
      }
      else {  // 0
        return '0';
      }
    case ComplexFormat.polar:
      if ((c.modulus != 0) && (c.arg.ori != 0)) { // r<theta
        // note: \phase is not supported
        complexStr =  r' \left(' '${SciNum.sciTex(c.modulus)} ' r' \angle ' '${texAngle(c.arg, unit: AngleUnit.deg)} ' r'\right) ';
      }
      else if ((c.modulus != 0) && (c.arg.ori == 0)) { // r
        complexStr =  texSciCoefficient(c.modulus)!;
      }
      else { // 0
        complexStr =  '0';
      }
  }
  }
  else{
  switch (c.fmt) {
    case ComplexFormat.rect:
      if ((c.re != 0) && (c.im != 0)) { // a+jb
        if (c.im > 0) { // a+jb
          complexStr =  ' ${SciNum.sciTex(c.re)} + j ${texSciCoefficient(c.im)!} ';
        }
        else {  // a-jb
          complexStr =  ' ${SciNum.sciTex(c.re)} - j ${texSciCoefficient(c.im.abs())!} ';
        }
        
      }
      else if ((c.re != 0) && (c.im == 0)) { // a
        complexStr =  '${SciNum.sciTex(c.re)} ';
      }
      else if ((c.re == 0) && (c.im != 0)) { // jb
        if (c.im > 0) {
          complexStr =  'j ${texSciCoefficient(c.im)!} ';
        }
        else {
          complexStr =  '-j ${texSciCoefficient(c.im.abs())!} ';
        }
      }
      else {  // 0
        return '0';
      }
    case ComplexFormat.polar:
      if ((c.modulus != 0) && (c.arg.ori != 0)) { // r<theta
        // note: \phase is not supported
        complexStr =  r' \left(' '${SciNum.sciTex(c.modulus)} ' r' \angle ' '${texAngle(c.arg, unit: AngleUnit.deg)} ' r'\right) ';
      }
      else if ((c.modulus != 0) && (c.arg.ori == 0)) { // r
        complexStr =  texSciCoefficient(c.modulus)!;
      }
      else { // 0
        complexStr =  '0';
      }
  }
  }

  if (c.im != 0 && withBracket){
    complexStr = '(' + complexStr + ')';
  }

  if (c.im == 0 && unit != null){
    complexStr = texAngle(AngleRadian(c.re), unit: unit);
  }
  return complexStr;
}

String texComplexPlusMinus(Complex c) {
  String complexStr = '';

  if (c.re.abs() < 1e-9){
    c = ComplexRect(0, c.im); 
  }
  if (c.im.abs() < 1e-9){
    c = ComplexRect(c.re, 0); 
  }

  if ((c.re != 0) && (c.im != 0)) { // a+jb
    complexStr = ' ${SciNum.sciTex(c.re)} \\pm j ${texSciCoefficient(c.im.abs())!}';
  }
  else if ((c.re == 0) && (c.im != 0)) { // jb
    complexStr = '\\pm j ${texSciCoefficient(c.im.abs())!}';
  }
  return complexStr;
}

String get texOriginalInput {
  String rtn = '';
  switch (_type) {
    case SourceField.et:
      rtn += r'\boldsymbol{E} = ';

      if (_paramEtEx != 0) {
        rtn += r'\hat{\boldsymbol{x}} \cdot ';
        rtn += texSciCoefficient(_paramEtEx)!;
        rtn += switch (_paramEtExTri) {
          TriFunc.cos => r'\cos \left( ',
          TriFunc.sin => r'\sin \left( ',
        };
        rtn += '$symOmega t ';

        if (_paramBetaSign == Sign.minus) {
          rtn += '- $symBeta z ';
        }
        else {
          rtn += '+ $symBeta z';
        }

        // since there is always at least one term before, 
        // phi > 0, add + sign before
        // phi < 0, brings - sign by itself
        // phi = 0, neglect the term
        if (_paramEtPhix.ori > 0) {
          rtn += ' + ${texAngle(_paramEtPhix)}';
        }
        else if (_paramEtPhix.ori < 0) {
          rtn += texAngle(_paramEtPhix);
        }

        rtn += r'\right) ';

        if (_paramEtEy != 0) {
          rtn += r'+ \hat{\boldsymbol{y}} \cdot ';
          rtn += texSciCoefficient(_paramEtEy)!;
          rtn += switch (_paramEtEyTri) {
            TriFunc.cos => r'\cos \left( ',
            TriFunc.sin => r'\sin \left( ',
          };
          rtn += '$symOmega t ';

          if (_paramBetaSign == Sign.minus) {
            rtn += '- $symBeta z ';
          }
          else {
            rtn += '+ $symBeta z';
          }

            // same
            if (_paramEtPhiy.ori > 0) {
              rtn += ' + ${texAngle(_paramEtPhiy)}';
            }
            else if (_paramEtPhiy.ori < 0) {
              rtn += texAngle(_paramEtPhiy);
            }

          rtn += r'\right) ';
        }
      }
      else if (_paramEtEy != 0) {
        rtn += r'\hat{\boldsymbol{y}} \cdot ';
        rtn += texSciCoefficient(_paramEtEy)!;
        rtn += switch (_paramEtEyTri) {
          TriFunc.cos => r'\cos \left( ',
          TriFunc.sin => r'\sin \left( ',
        };
        rtn += '$symOmega t ';

        if (_paramBetaSign == Sign.minus) {
          rtn += '- $symBeta z ';
        }
        else {
          rtn += '+ $symBeta z';
        }

        // same
        if (_paramEtPhiy.ori > 0) {
          rtn += ' + ${texAngle(_paramEtPhiy)}';
        }
        else if (_paramEtPhiy.ori < 0) {
          rtn += texAngle(_paramEtPhiy);
        }

        rtn += r'\right) ';
      }
      else { // ex = 0, ey = 0
        rtn += '0';
      }
      
      break;

    case SourceField.ep:
      rtn += r'\boldsymbol{E} = ';

      if (_paramEpEx.modulus != 0) {
        rtn += r'\hat{\boldsymbol{x}} \cdot ';
        rtn += texComplexCoefficient(_paramEpEx)!;

        if (_paramBetaSign == Sign.minus) {
          rtn += r'\mathrm{e}^{-j ' '$symBeta z}';
        }
        else {
          rtn += r'\mathrm{e}^{j ' '$symBeta z}';
        }
        rtn += r'\cancel{ \mathrm{e}^{j ' '$symOmega t}}';

        if (_paramEpEy.modulus != 0) {
          rtn += r'+ \hat{\boldsymbol{y}} \cdot ';
          rtn += texComplexCoefficient(_paramEpEy)!;

          if (_paramBetaSign == Sign.minus) {
            rtn += r'\mathrm{e}^{-j ' '$symBeta z}';
          }
          else {
            rtn += r'\mathrm{e}^{j ' '$symBeta z}';
          }
          rtn += r'\cancel{ \mathrm{e}^{j ' '$symOmega t}}';
        }
      }
      else if (_paramEpEy.modulus != 0) {
        rtn += r'\hat{\boldsymbol{y}} \cdot ';
        rtn += texComplexCoefficient(_paramEpEy)!;

        if (_paramBetaSign == Sign.minus) {
          rtn += r'\mathrm{e}^{-j ' '$symBeta z}';
        }
        else {
          rtn += r'\mathrm{e}^{j ' '$symBeta z}';
        }
        rtn += r'\cancel{ \mathrm{e}^{j ' '$symOmega t}}';
      }
      else {
        rtn += '0';
      }

      break;
    
    case SourceField.mt:
      rtn += r'\boldsymbol{H} = ';

      if (_paramMtHx != 0) {
        rtn += r'\hat{\boldsymbol{x}} \cdot ';
        rtn += texSciCoefficient(_paramMtHx)!;
        rtn += switch (_paramMtHxTri) {
          TriFunc.cos => r'\cos \left( ',
          TriFunc.sin => r'\sin \left( ',
        };
        rtn += '$symOmega t ';

        if (_paramBetaSign == Sign.minus) {
          rtn += '- $symBeta z ';
        }
        else {
          rtn += '+ $symBeta z';
        }

        // since there is always at least one term before, 
        // phi > 0, add + sign before
        // phi < 0, brings - sign by itself
        // phi = 0, neglect the term
        if (_paramMtPhix.ori > 0) {
          rtn += ' + ${texAngle(_paramMtPhix)}';
        }
        else if (_paramMtPhix.ori < 0) {
          rtn += texAngle(_paramMtPhix);
        }

        rtn += r'\right) ';

        if (_paramMtHy != 0) {
          rtn += r'+ \hat{\boldsymbol{y}} \cdot ';
          rtn += texSciCoefficient(_paramMtHy)!;
          rtn += switch (_paramMtHyTri) {
            TriFunc.cos => r'\cos \left( ',
            TriFunc.sin => r'\sin \left( ',
          };
          rtn += '$symOmega t ';

          if (_paramBetaSign == Sign.minus) {
            rtn += '- $symBeta z ';
          }
          else {
            rtn += '+ $symBeta z';
          }

          // same
          if (_paramMtPhiy.ori > 0) {
            rtn += ' + ${texAngle(_paramMtPhiy)}';
          }
          else if (_paramMtPhiy.ori < 0) {
            rtn += texAngle(_paramMtPhiy);
          }

          rtn += r'\right) ';
        }
      }
      else if (_paramMtHy != 0) {
        rtn += r'\hat{\boldsymbol{y}} \cdot ';
        rtn += texSciCoefficient(_paramMtHy)!;
        rtn += switch (_paramMtHyTri) {
          TriFunc.cos => r'\cos \left( ',
          TriFunc.sin => r'\sin \left( ',
        };
        rtn += '$symOmega t ';

        if (_paramBetaSign == Sign.minus) {
          rtn += '- $symBeta z ';
        }
        else {
          rtn += '+ $symBeta z';
        }

        // same
        if (_paramMtPhiy.ori > 0) {
          rtn += ' + ${texAngle(_paramMtPhiy)}';
        }
        else if (_paramMtPhiy.ori < 0) {
          rtn += texAngle(_paramMtPhiy);
        }

        rtn += r'\right) ';
      }
      else { // ex = 0, ey = 0
        rtn += '0';
      }
      
      break;

    case SourceField.mp:
      rtn += r'\boldsymbol{H} = ';

      if (_paramMpHx.modulus != 0) {
        rtn += r'\hat{\boldsymbol{x}} \cdot ';
        rtn += texComplexCoefficient(_paramMpHx)!;

        if (_paramBetaSign == Sign.minus) {
          rtn += r'\mathrm{e}^{-j ' '$symBeta z}';
        }
        else {
          rtn += r'\mathrm{e}^{j ' '$symBeta z}';
        }
        rtn += r'\cancel{ \mathrm{e}^{j ' '$symOmega t}}';

        if (_paramMpHy.modulus != 0) {
          rtn += r'+ \hat{\boldsymbol{y}} \cdot ';
          rtn += texComplexCoefficient(_paramMpHy)!;

          if (_paramBetaSign == Sign.minus) {
            rtn += r'\mathrm{e}^{-j ' '$symBeta z}';
          }
          else {
            rtn += r'\mathrm{e}^{j ' '$symBeta z}';
          }
          rtn += r'\cancel{ \mathrm{e}^{j ' '$symOmega t}}';
        }
      }
      else if (_paramMpHy.modulus != 0) {
        rtn += r'\hat{\boldsymbol{y}} \cdot ';
        rtn += texComplexCoefficient(_paramMpHy)!;

        if (_paramBetaSign == Sign.minus) {
          rtn += r'\mathrm{e}^{-j ' '$symBeta z}';
        }
        else {
          rtn += r'\mathrm{e}^{j ' '$symBeta z}';
        }
        rtn += r'\cancel{ \mathrm{e}^{j ' '$symOmega t}}';
      }
      else {
        rtn += '0';
      }

      break;
    
  }
  return rtn;
}

String get texEEq {
  String rtn = r'\boldsymbol{E} = ';

  if (_paramEx != 0) {
    rtn += r'\hat{\boldsymbol{x}} \cdot ';
    rtn += texSciCoefficient(_paramEx)!;
    rtn += r'\cos \left( ';

    rtn += '$symOmega t ';

    if (_paramBetaSign == Sign.minus) {
      rtn += '- $symBeta z ';
    }
    else {
      rtn += '+ $symBeta z';
    }

    if (_paramEPhix.ori > 0) {
      rtn += ' + ${texAngle(_paramEPhix)}';
    }
    else if (_paramEPhix.ori < 0) {
      rtn += texAngle(_paramEPhix);
    }

    rtn += r'\right) ';

    if (texSciCoefficient(_paramEy) != null) {
      rtn += r'+ \hat{\boldsymbol{y}} \cdot ';
      rtn += texSciCoefficient(_paramEy)!;
      rtn += r'\cos \left( ';

      rtn += '$symOmega t ';

      if (_paramBetaSign == Sign.minus) {
        rtn += '- $symBeta z ';
      }
      else {
        rtn += '+ $symBeta z';
      }

      if (_paramEPhiy.ori > 0) {
        rtn += ' + ${texAngle(_paramEPhiy)}';
      }
      else if (_paramEPhiy.ori < 0) {
        rtn += texAngle(_paramEPhiy);
      }

      rtn += r'\right) ';
    }
  }
  else if (texSciCoefficient(_paramEy) != null) {
    rtn += r'\hat{\boldsymbol{y}} \cdot ';
    rtn += texSciCoefficient(_paramEy)!;
    rtn += r'\cos \left( ';
    
    rtn += '$symOmega t ';

    if (_paramBetaSign == Sign.minus) {
      rtn += '- $symBeta z ';
    }
    else {
      rtn += '+ $symBeta z';
    }

      if (_paramEPhiy.ori > 0) {
        rtn += ' + ${texAngle(_paramEPhiy)}';
      }
      else if (_paramEPhiy.ori < 0) {
        rtn += texAngle(_paramEtPhiy);
      }

    rtn += r'\right) ';
  }
  else { // ex = 0, ey = 0
    rtn += '0';
  }
      
  return rtn;
}


Angle get phaseDifference => (_paramEPhiy - _paramEPhix);
Angle get phaseDifferencePeriodRanged2Pi => (paramEPhiy - paramEPhix).inPerigon();
Angle get phaseDifferencePeriodRangedPnPi => (paramEPhiy - paramEPhix).inLongitude();

double get maxExy => math.max(_paramEx, _paramEy);
double get normalizedEx => (maxExy != 0) ? (_paramEx/maxExy) : 0 ;
double get normalizedEy => (maxExy != 0) ? (_paramEy/maxExy) : 0 ;

String get texEPhix => texAngle(_paramEPhix);
String get texEPhiy => texAngle(_paramEPhiy);
String get texEPhaseDifference => texAngle(phaseDifference);
String get texEPhaseDifferencePeriodRanged2Pi => texAngle(phaseDifferencePeriodRanged2Pi);
String get texEPhaseDifferencePeriodRangedPnPi => texAngle(phaseDifferencePeriodRangedPnPi);
String get texEPhaseDifferencePeriodRangedPnPiAbs {
  if (phaseDifferencePeriodRangedPnPi.ori < 0) {
    return texAngle(-phaseDifferencePeriodRangedPnPi);
  }
  else {
    return texAngle(phaseDifferencePeriodRangedPnPi);
  }
}


String? get texEtExCoefficient => texSciCoefficient(_paramEtEx);
String? get texEtEyCoefficient => texSciCoefficient(_paramEtEy);
String get texEtExTriInside {
  String rtn = '';
  rtn += '$symOmega t ';
  if (_paramBetaSign == Sign.minus) {
    rtn += '- $symBeta z ';
  }
  else {
    rtn += '+ $symBeta z';
  }
  if (_paramEtPhix.ori > 0) {
    rtn += ' + ${texAngle(_paramEtPhix)}';
  }
  else if (_paramEtPhix.ori < 0) {
    rtn += texAngle(_paramEtPhix);
  }
  return rtn;
}
String get texEtEyTriInside {
  String rtn = '';
  rtn += '$symOmega t ';
  if (_paramBetaSign == Sign.minus) {
    rtn += '- $symBeta z ';
  }
  else {
    rtn += '+ $symBeta z';
  }
  if (_paramEtPhiy.ori > 0) {
    rtn += ' + ${texAngle(_paramEtPhiy)}';
  }
  else if (_paramEtPhiy.ori < 0) {
    rtn += texAngle(_paramEtPhiy);
  }
  return rtn;
}
String get texEtExTriAbs {
  String rtn = '';
  rtn += switch (_paramEtExTri) {
    TriFunc.cos => r'\cos',
    TriFunc.sin => r'\sin',
  };
  rtn += r'\left( ';
  rtn += texEtExTriInside;
  rtn += r'\right) ';
  return rtn;
}
String get texEtExTriSign {
  String rtn = '';
  if (_paramEtEx < 0) {
    rtn += '-';
  }
  rtn += texEtExTriAbs;
  return rtn;
}
String get texEtEyTriAbs {
  String rtn = '';
  rtn += switch (_paramEtEyTri) {
    TriFunc.cos => r'\cos',
    TriFunc.sin => r'\sin',
  };
  rtn += r'\left( ';
  rtn += texEtEyTriInside;
  rtn += r'\right) ';
  return rtn;
}
String get texEtEyTriSign {
  String rtn = '';
  if (_paramEtEy < 0) {
    rtn += '-';
  }
  rtn += texEtEyTriAbs;
  return rtn;
}
String? get texEtEx {
  String rtn = '';
  if (_paramEtEx != 0) {
    rtn += symAx;
    rtn += texEtExCoefficient!;
    rtn += texEtExTriAbs;
  }
  else {
    return null;
  }
  return rtn;
}
String? get texEtEy {
  String rtn = '';
  if (_paramEtEy != 0) {
    rtn += symAy;
    rtn += texEtEyCoefficient!;
    rtn += texEtEyTriAbs;
  }
  else {
    return null;
  }
  return rtn;
}
String? get texEt {
  String rtn = '';
  if (_paramEtEx != 0) {
    rtn += texEtEx!;
    if (_paramEtEy != 0) {
      rtn += '+ ';
      rtn += texEtEy!;
    }
  }
  else if (_paramEtEy != 0) {
    rtn += texEtEy!;
  }
  else {
    return null;
  }
  return rtn;
}
String? get texEtExAsExp {
  String rtn = '';

  if (_paramEx != 0) {
    rtn += symAx;
    rtn += texEtExCoefficient!;
    if (_paramEtExTri == TriFunc.cos) {
      rtn += '$symE ^{j($texEtExTriInside)}';
    }
    else {
      rtn += '$symE ^{j($texEtExTriInside - ${texAngle(_paramEtPhix * 0 + AngleDemiTurn(0.5))})}';
    }
  }
  else {
    return null;
  }

  return rtn;
}
String? get texEtEyAsExp {
  String rtn = '';

  if (_paramEy != 0) {
    rtn += symAy;
    rtn += texEtEyCoefficient!;
    if (_paramEtEyTri == TriFunc.cos) {
      rtn += '$symE ^{j($texEtEyTriInside)}';
    }
    else {
      rtn += '$symE ^{j($texEtEyTriInside - ${texAngle(_paramEtPhiy * 0 + AngleDemiTurn(0.5))})}';
    }
  }
  else {
    return null;
  }

  return rtn;
}
String? get texEtAsExp {
  String rtn = '';

  if (_paramEx != 0) {
    rtn += texEtExAsExp!;

    if (_paramEy != 0) {
      rtn += '+ ';
      rtn += texEtEyAsExp!;
    }
  }
  else if (_paramEy != 0) {
    rtn += texEtEyAsExp!;
  }
  else { // ex = 0, ey = 0
    // rtn += '0';
    return null;
  }
      
  return rtn;
}

String? get texEtStandardPhix {
  return texAngle(_paramEPhix);
}
String? get texEtStandardPhiy {
  return texAngle(_paramEPhiy);
}
String? get texEtStandardExCoefficient => texSciCoefficient(_paramEx);
String? get texEtStandardEyCoefficient => texSciCoefficient(_paramEy);
String get texEtStandardExTriInside {
  String rtn = '';
  rtn += '$symOmega t ';
  if (_paramBetaSign == Sign.minus) {
    rtn += '- $symBeta z ';
  }
  else {
    rtn += '+ $symBeta z';
  }
  if (_paramEPhix.ori > 0) {
    rtn += ' + ${texAngle(_paramEPhix)}';
  }
  else if (_paramEPhix.ori < 0) {
    rtn += texAngle(_paramEPhix);
  }
  return rtn;
}
String get texEtStandardEyTriInside {
  String rtn = '';
  rtn += '$symOmega t ';
  if (_paramBetaSign == Sign.minus) {
    rtn += '- $symBeta z ';
  }
  else {
    rtn += '+ $symBeta z';
  }
  if (_paramEPhiy.ori > 0) {
    rtn += ' + ${texAngle(_paramEPhiy)}';
  }
  else if (_paramEPhiy.ori < 0) {
    rtn += texAngle(_paramEPhiy);
  }
  return rtn;
}
String get texEtStandardExTri {
  String rtn = r'\cos';
  rtn += r'\left( ';
  rtn += texEtStandardExTriInside;
  rtn += r'\right) ';
  return rtn;
}
String get texEtStandardEyTri {
  String rtn = r'\cos';
  rtn += r'\left( ';
  rtn += texEtStandardEyTriInside;
  rtn += r'\right) ';
  return rtn;
}
String? get texEtStandardEx {
  String rtn = '';

  if (_paramEx != 0) {
    rtn += symAx;
    rtn += texEtStandardExCoefficient!;
    rtn += texEtStandardExTri;
  }
  else {
    return null;
  }

  return rtn;
}
String? get texEtStandardExNoAx {
  String rtn = '';

  if (_paramEx != 0) {
    // rtn += symAx;
    rtn += texEtStandardExCoefficient!;
    rtn += texEtStandardExTri;
  }
  else {
    return null;
  }

  return rtn;
}
String? get texEtStandardEy {
  String rtn = '';

  if (_paramEy != 0) {
    rtn += symAy;
    rtn += texEtStandardEyCoefficient!;
    rtn += texEtStandardEyTri;
  }
  else {
    return null;
  }

  return rtn;
}
String? get texEtStandardEyNoAy {
  String rtn = '';

  if (_paramEy != 0) {
    // rtn += symAy;
    rtn += texEtStandardEyCoefficient!;
    rtn += texEtStandardEyTri;
  }
  else {
    return null;
  }

  return rtn;
}
String? get texEtStandard {
  String rtn = '';
  // rtn += symEt;
  // rtn += '=';

  if (_paramEx != 0) {
    rtn += texEtStandardEx!;

    if (_paramEy != 0) {
      rtn += '+ ';
      rtn += texEtStandardEy!;
    }
  }
  else if (_paramEy != 0) {
    rtn += texEtStandardEy!;
  }
  else { // ex = 0, ey = 0
    rtn += '0';
    // return null;
  }
      
  return rtn;
}
String? get texEtStandardExAsExp {
  String rtn = '';

  if (_paramEx != 0) {
    rtn += symAx;
    rtn += texEtStandardExCoefficient!;
    rtn += '$symE ^{j($texEtStandardExTriInside)}';
  }
  else {
    return null;
  }

  return rtn;
}
String? get texEtStandardEyAsExp {
  String rtn = '';

  if (_paramEy != 0) {
    rtn += symAy;
    rtn += texEtStandardEyCoefficient!;
    rtn += '$symE ^{j($texEtStandardEyTriInside)}';
  }
  else {
    return null;
  }

  return rtn;
}
String? get texEtStandardAsExp {
  String rtn = '';

  if (_paramEx != 0) {
    rtn += texEtStandardExAsExp!;

    if (_paramEy != 0) {
      rtn += '+ ';
      rtn += texEtStandardEyAsExp!;
    }
  }
  else if (_paramEy != 0) {
    rtn += texEtStandardEyAsExp!;
  }
  else { // ex = 0, ey = 0
    // rtn += '0';
    return null;
  }
      
  return rtn;
}



String get texEpExAbs {
  if (_paramEpEx.modulus > 0) {
    return SciNum.sciTex(_paramEpEx.modulus);
  }
  else {
    return '(${SciNum.sciTex(_paramEpEx.modulus)})';
  }
}
String get texEpExArg => texAngle(_paramEpEx.arg);
String get texEpExComplex => '$texEpExAbs \\angle $texEpExArg';
String get texEpEyAbs {
  if (_paramEpEy.modulus > 0) {
    return SciNum.sciTex(_paramEpEy.modulus);
  }
  else {
    return '(${SciNum.sciTex(_paramEpEy.modulus)})';
  }
}
String get texEpEyArg => texAngle(_paramEpEy.arg);
String get texEpEyComplex => '$texEpEyAbs \\angle $texEpEyArg';
String? get texEpExCoefficient {
  return texComplexCoefficient(_paramEpEx);
}
String? get texEpEyCoefficient {
  return texComplexCoefficient(_paramEpEy);
}
String? get texEpExCoefficientPolar {
  return texComplexCoefficient(_paramEpEx.toPolar());
}
String? get texEpEyCoefficientPolar {
  return texComplexCoefficient(_paramEpEy.toPolar());
}
String get texEpEjbz => switch(_paramBetaSign) {
  Sign.minus => symExpJBetaZNegative,
  Sign.plus => symExpJBetaZPositive,
};
String get texEpEjwt => symExpJOmegaTCancel;
String? get texEpExAsExpJPhix {
  if (_paramEpEx.arg.ori != 0) {
    return '$symE ^ {${texJAngle(_paramEpEx.arg)}}';
  }
  else {
    return null;
  }  
}
String? get texEpEyAsExpJPhiy {
  if (_paramEpEy.arg.ori != 0) {
    return '$symE ^ {${texJAngle(_paramEpEy.arg)}}';
  }
  else {
    return null;
  }  
}
String? get texEpEx {
  String rtn = '';
  if (_paramEpEx.modulus != 0) {
    rtn += symAx;
    rtn += texEpExCoefficient!;
    rtn += texEpEjbz;
    // rtn += texEpEjwt;
  }
  else {
    return null;
  }
  return rtn;
}
String? get texEpEy {
  String rtn = '';
  if (_paramEpEy.modulus != 0) {
    rtn += symAy;
    rtn += texEpEyCoefficient!;
    rtn += texEpEjbz;
    // rtn += texEpEjwt;
  }
  else {
    return null;
  }
  return rtn;
}
String get texEp {
  String rtn = '';

  if (_paramEpEx.modulus != 0) {
    rtn += texEpEx!;

    if (_paramEpEy.modulus != 0) {
      rtn += '+ ';
      rtn += texEpEy!;
    }
  }
  else if (_paramEpEy.modulus != 0) {
    rtn += texEpEy!;
  }
  else {
    rtn += '0';
  }

  return rtn;
}
String get texEpPolar {
  String rtn = '';

  if (_paramEpEx.modulus != 0) {
    rtn += symAx;
    rtn += texEpExCoefficientPolar!;
    rtn += texEpEjbz;
    rtn += texEpEjwt;

    if (_paramEpEy.modulus != 0) {
      rtn += '+ ';
      rtn += symAy;
      rtn += texEpEyCoefficientPolar!;
      rtn += texEpEjbz;
      rtn += texEpEjwt;
    }
  }
  else if (_paramEpEy.modulus != 0) {
    rtn += symAy;
    rtn += texEpEyCoefficientPolar!;
    rtn += texEpEjbz;
    rtn += texEpEjwt;
  }
  else {
    rtn += '0';
  }

  return rtn;
}
String get texEpPolarAllExp {
  String rtn = '';

  if (_paramEpEx.modulus != 0) {
    rtn += symAx;
    rtn += texEpExAbs;
    rtn += texEpExAsExpJPhix!;
    rtn += texEpEjbz;
    rtn += texEpEjwt;

    if (_paramEpEy.modulus != 0) {
      rtn += '+ ';
      rtn += symAy;
      rtn += texEpEyAbs;
      rtn += texEpEyAsExpJPhiy!;
      rtn += texEpEjbz;
      rtn += texEpEjwt;
    }
  }
  else if (_paramEpEy.modulus != 0) {
    rtn += texEpEyAbs;
    rtn += texEpEyAsExpJPhiy!;
    rtn += texEpEjbz;
    rtn += texEpEjwt;
  }
  else {
    rtn += '0';
  }

  return rtn;
}
String? get texEpStandardExAbs => texSciCoefficient(_paramEx);
String? get texEpStandardEyAbs => texSciCoefficient(_paramEy);
String? get texEpStandardExPolar {
  Complex ex = ComplexPolar(_paramEx, _paramEPhix);
  return '(${SciNum.sciTex(ex.modulus)} \\angle ${texAngle(ex.arg)})';
}
String? get texEpStandardEyPolar {
  Complex ey = ComplexPolar(_paramEy, _paramEPhiy);
  return '(${SciNum.sciTex(ey.modulus)} \\angle ${texAngle(ey.arg)})';
}
String get texEpStandardEjbz => switch(_paramBetaSign) {
  Sign.minus => symExpJBetaZNegative,
  Sign.plus => symExpJBetaZPositive,
};
// String get texEpStandardEjwt => symExpJOmegaTCancel;
String? get texEpStandardExNoAx {
  String rtn = '';
  if (paramExComplex.modulus != 0) {
    // rtn += symAx;
    rtn += texEpStandardExPolar!;
    rtn += texEpStandardEjbz;
    // rtn += texEpStandardEjwt;
  }
  else {
    return null;
  }
  return rtn;
}
String? get texEpStandardEx {
  Complex ex = ComplexPolar(_paramEx, _paramEPhix);
  String rtn = '';
  if (ex.modulus != 0) {
    rtn += symAx;
    rtn += texEpStandardExPolar!;
    rtn += texEpStandardEjbz;
    // rtn += texEpStandardEjwt;
  }
  else {
    return null;
  }
  return rtn;
}
String? get texEpStandardEyNoAy {
  String rtn = '';
  if (paramEyComplex.modulus != 0) {
    // rtn += symAy;
    rtn += texEpStandardEyPolar!;
    rtn += texEpStandardEjbz;
    // rtn += texEpStandardEjwt;
  }
  else {
    return null;
  }
  return rtn;
}
String? get texEpStandardEy {
  Complex ey = ComplexPolar(_paramEy, _paramEPhiy);
  String rtn = '';
  if (ey.modulus != 0) {
    rtn += symAy;
    rtn += texEpStandardEyPolar!;
    rtn += texEpStandardEjbz;
    // rtn += texEpStandardEjwt;
  }
  else {
    return null;
  }
  return rtn;
}
String get texEpStandard {
  Complex ex = ComplexPolar(_paramEx, _paramEPhix);
  Complex ey = ComplexPolar(_paramEy, _paramEPhiy);

  String rtn = '';
  // rtn += symEp;
  // rtn += ' = ';

  if (ex.modulus != 0) {
    rtn += texEpStandardEx!;
    if (ey.modulus != 0) {
      rtn += '+';
      rtn += texEpStandardEy!;
    }
  }
  else if (ey.modulus != 0) {
    rtn += texEpStandardEy!;
  }
  else {
    rtn += '0';
  }

  return rtn;
}





String get texTHpStandard {
  String rtn = '';
  if (_paramTHx.modulus != 0) {
    rtn += '$symAx $texParamTHx $symKtVec';
    if (_paramTHy.modulus != 0) {
      rtn += '+';
      rtn += '$symAy $texParamTHy $symKtVec';
    }
    if (_paramTHz.modulus != 0){
      rtn += '+';
      rtn += '$symAz $texParamTHz $symKtVec';
    }
  }
  else if (_paramTHy.modulus != 0) {
    rtn += '$symAy $texParamTHy $symKtVec';
    if (_paramTHz.modulus != 0){
      rtn += '+';
      rtn += '$symAz $texParamTHz $symKtVec';
    }
  }
  else if (_paramTHz.modulus != 0){
    rtn += '$symAz $texParamTHz $symKtVec';
  }
  else {
    rtn += '0';
  }
  return rtn;
}

String get texTHpStandardConj {
  String rtn = '';
  if (_paramTHx.modulus != 0) {
    rtn += '$symAx $texParamTHxConj $symKtVecConj';
    if (_paramTHy.modulus != 0) {
      rtn += '+';
      rtn += '$symAy $texParamTHyConj $symKtVecConj';
    }
    if (_paramTHz.modulus != 0){
      rtn += '+';
      rtn += '$symAz $texParamTHzConj $symKtVecConj';
    }
  }
  else if (_paramTHy.modulus != 0) {
    rtn += '$symAy $texParamTHyConj $symKtVecConj';
    if (_paramTHz.modulus != 0){
      rtn += '+';
      rtn += '$symAz $texParamTHzConj $symKtVecConj';
    }
  }
  else if (_paramTHz.modulus != 0){
    rtn += '$symAz $texParamTHzConj $symKtVecConj';
  }
  else {
    rtn += '0';
  }
  return rtn;
}


String get texTEpStandard {
  String rtn = '';
  if (_paramTEx.modulus != 0) {
    rtn += '$symAx $texParamTEx $symKtVec';
    if (_paramTEy.modulus != 0) {
      rtn += '+';
      rtn += '$symAy $texParamTEy $symKtVec';
    }
    if (_paramTEz.modulus != 0){
      rtn += '+';
      rtn += '$symAz $texParamTEz $symKtVec';
    }
  }
  else if (_paramTEy.modulus != 0) {
    rtn += '$symAy $texParamTEy $symKtVec';
    if (_paramTEz.modulus != 0){
      rtn += '+';
      rtn += '$symAz $texParamTEz $symKtVec';
    }
  }
  else if (_paramTEz.modulus != 0){
    rtn += '$symAz $texParamTEz $symKtVec';
  }
  else {
    rtn += '0';
  }

  return rtn;
}




String get texEpStandardExPolarAsExpJPhix {
  if (_paramEPhix.ori != 0) {
    return '$symE ^ {${texJAngle(_paramEPhix)}}';
  }
  else {
    return '';
  }  
}
String get texEpStandardEyPolarAsExpJPhiy {
  if (_paramEPhiy.ori != 0) {
    return '$symE ^ {${texJAngle(_paramEPhiy)}}';
  }
  else {
    return '';
  }  
}
String? get texEpStandardExAsExp {
  String rtn = '';
  if (_paramEx != 0) {
    rtn += texSciCoefficient(_paramEx)!;
    rtn += '$symE ^ {${texJAngle(_paramEPhix)}}';
  }
  else {
    return null;
  }
  return rtn;
}
String? get texEpStandardEyAsExp {
  String rtn = '';
  if (_paramEy != 0) {
    rtn += texSciCoefficient(_paramEy)!;
    rtn += '$symE ^ {${texJAngle(_paramEPhiy)}}';
  }
  else {
    return null;
  }
  return rtn;
}
String get texEpStandardAsExp {
  String rtn = '';
  if (_paramEx != 0) {
    rtn += symAx;
    rtn += texEpStandardExAbs!;
    rtn += symExpJOmegaTCancel;
    rtn += texEpStandardEjbz;
    rtn += texEpStandardExPolarAsExpJPhix!;
    if (_paramEy != 0) {
      rtn += '+';
      rtn += symAy;
      rtn += texEpStandardEyAbs!;
      rtn += symExpJOmegaTCancel;
      rtn += texEpStandardEjbz;
      rtn += texEpStandardEyPolarAsExpJPhiy!;
    }
  }
  else if (_paramEy != 0) {
    rtn += symAy;
    rtn += texEpStandardEyAbs!;
    rtn += symExpJOmegaTCancel;
    rtn += texEpStandardEjbz;
    rtn += texEpStandardEyPolarAsExpJPhiy!;
  }
  else {
    rtn += '0';
  }
  return rtn;
}


String? get texMtHxCoefficient => texSciCoefficient(_paramMtHx);
String? get texMtHyCoefficient => texSciCoefficient(_paramMtHy);
String get texMtHxTriInside {
  String rtn = '';
  rtn += '$symOmega t ';
  if (_paramBetaSign == Sign.minus) {
    rtn += '- $symBeta z ';
  }
  else {
    rtn += '+ $symBeta z';
  }
  if (_paramMtPhix.ori > 0) {
    rtn += ' + ${texAngle(_paramMtPhix)}';
  }
  else if (_paramMtPhix.ori < 0) {
    rtn += texAngle(_paramMtPhix);
  }
  return rtn;
}
String get texMtHxTri {
  String rtn = '';
  if (_paramMtHx < 0) {
    rtn += '-';
  }
  rtn += switch (_paramMtHxTri) {
    TriFunc.cos => r'\cos ',
    TriFunc.sin => r'\sin ',
  };
  rtn += r'\left( ';
  rtn += texMtHxTriInside;
  rtn += r'\right) ';
  return rtn;
}
String get texMtHxTriAbs {
  String rtn = '';
  rtn += switch (_paramMtHxTri) {
    TriFunc.cos => r'\cos',
    TriFunc.sin => r'\sin',
  };
  rtn += r'\left( ';
  rtn += texEtExTriInside;
  rtn += r'\right) ';
  return rtn;
}
String get texMtHxTriSign {
  String rtn = '';
  if (_paramMtHx < 0) {
    rtn += '-';
  }
  rtn += texMtHxTriAbs;
  return rtn;
}
String get texMtHyTriInside {
  String rtn = '';
  rtn += '$symOmega t ';
  if (_paramBetaSign == Sign.minus) {
    rtn += '- $symBeta z ';
  }
  else {
    rtn += '+ $symBeta z';
  }
  if (_paramMtPhiy.ori > 0) {
    rtn += ' + ${texAngle(_paramMtPhiy)}';
  }
  else if (_paramMtPhiy.ori < 0) {
    rtn += texAngle(_paramMtPhiy);
  }
  return rtn;
}
String get texMtHyTriAbs {
  String rtn = '';
  rtn += switch (_paramMtHyTri) {
    TriFunc.cos => r'\cos',
    TriFunc.sin => r'\sin',
  };
  rtn += r'\left( ';
  rtn += texMtHyTriInside;
  rtn += r'\right) ';
  return rtn;
}
String get texMtHyTriSign {
  String rtn = '';
  if (_paramMtHy < 0) {
    rtn += '-';
  }
  rtn += texMtHyTriAbs;
  return rtn;
}
String? get texMtHx {
  String rtn = '';
  if (_paramMtHx != 0) {
    rtn += symAx;
    rtn += texMtHxCoefficient!;
    rtn += texMtHxTriAbs;
  }
  else {
    return null;
  }
  return rtn;
}
String? get texMtHy {
  String rtn = '';
  if (_paramMtHy != 0) {
    rtn += symAy;
    rtn += texMtHyCoefficient!;
    rtn += texMtHyTriAbs;
  }
  else {
    return null;
  }
  return rtn;
}
String? get texHt {
  String rtn = '';
  if (_paramMtHx != 0) {
    rtn += texMtHx!;
    if (_paramMtHy != 0) {
      rtn += '+ ';
      rtn += texMtHy!;
    }
  }
  else if (_paramMtHy != 0) {
    rtn += texMtHy!;
  }
  else {
    return null;
  }
  return rtn;
}



String? get texMtStandardHxCoefficient => texSciCoefficient(_paramHx);
String? get texMtStandardHyCoefficient => texSciCoefficient(_paramHy);
String get texMtStandardHxTriInside {
  String rtn = '';
  rtn += '$symOmega t ';
  if (_paramBetaSign == Sign.minus) {
    rtn += '- $symBeta z ';
  }
  else {
    rtn += '+ $symBeta z';
  }
  if (_paramHPhix.ori > 0) {
    rtn += ' + ${texAngle(_paramHPhix)}';
  }
  else if (_paramHPhix.ori < 0) {
    rtn += texAngle(_paramHPhix);
  }
  return rtn;
}
String get texMtStandardHyTriInside {
  String rtn = '';
  rtn += '$symOmega t ';
  if (_paramBetaSign == Sign.minus) {
    rtn += '- $symBeta z ';
  }
  else {
    rtn += '+ $symBeta z';
  }
  if (_paramHPhiy.ori > 0) {
    rtn += ' + ${texAngle(_paramHPhiy)}';
  }
  else if (_paramHPhiy.ori < 0) {
    rtn += texAngle(_paramHPhiy);
  }
  return rtn;
}
String get texMtStandardHxTri {
  String rtn = r'\cos';
  rtn += r'\left( ';
  rtn += '$symOmega t ';
  if (_paramBetaSign == Sign.minus) {
    rtn += '- $symBeta z ';
  }
  else {
    rtn += '+ $symBeta z';
  }
  if (_paramHPhix.ori > 0) {
    rtn += ' + ${texAngle(_paramHPhix)}';
  }
  else if (_paramHPhix.ori < 0) {
    rtn += texAngle(_paramHPhix);
  }
  rtn += r'\right) ';
  return rtn;
}
String get texMtStandardHyTri {
  String rtn = r'\cos';
  rtn += r'\left( ';
  rtn += '$symOmega t ';
  if (_paramBetaSign == Sign.minus) {
    rtn += '- $symBeta z ';
  }
  else {
    rtn += '+ $symBeta z';
  }
  if (_paramHPhiy.ori > 0) {
    rtn += ' + ${texAngle(_paramHPhiy)}';
  }
  else if (_paramHPhiy.ori < 0) {
    rtn += texAngle(_paramHPhiy);
  }
  rtn += r'\right) ';
  return rtn;
}
String? get texMtStandardHx {
  String rtn = '';

  if (_paramHx != 0) {
    rtn += symAx;
    rtn += texSciCoefficient(_paramHx)!;
    rtn += texMtStandardHxTri;
  }
  else {
    return null;
  }

  return rtn;
}
String? get texMtStandardHy {
  String rtn = '';

  if (_paramHy != 0) {
    rtn += symAy;
    rtn += texSciCoefficient(_paramHy)!;
    rtn += texMtStandardHyTri;
  }
  else {
    return null;
  }

  return rtn;
}
String get texMtStandard {
  String rtn = '';

  // rtn += symMt;
  // rtn += '=';

  if (_paramHx != 0) {
    rtn += texMtStandardHx!;
    if (_paramHy != 0) {
      rtn += '+ ';
      rtn += texMtStandardHy!;
    }
  }
  else if (_paramHy != 0) {
    rtn += texMtStandardHy!;
  }
  else { // ex = 0, ey = 0
    rtn += '0';
  }
      
  return rtn;
}
String? get texMtStandardHxAsExp {
  String rtn = '';

  if (_paramHx != 0) {
    rtn += symAx;
    rtn += texMtStandardHxCoefficient!;
    rtn += '$symE ^{j($texMtStandardHxTriInside)}';
  }
  else {
    return null;
  }

  return rtn;
}
String? get texMtStandardHyAsExp {
  String rtn = '';

  if (_paramHy != 0) {
    rtn += symAy;
    rtn += texMtStandardHyCoefficient!;
    rtn += '$symE ^{j($texMtStandardHyTriInside)}';
  }
  else {
    return null;
  }

  return rtn;
}
String? get texMtStandardAsExp {
  String rtn = '';

  if (_paramHx != 0) {
    rtn += texMtStandardHxAsExp!;

    if (_paramHy != 0) {
      rtn += '+ ';
      rtn += texMtStandardHyAsExp!;
    }
  }
  else if (_paramHy != 0) {
    rtn += texMtStandardHyAsExp!;
  }
  else { // ex = 0, ey = 0
    // rtn += '0';
    return null;
  }
      
  return rtn;
}


String get texMpHxAbs {
  if (_paramMpHx.modulus > 0) {
    return SciNum.sciTex(_paramMpHx.modulus);
  }
  else {
    return '(${SciNum.sciTex(_paramMpHx.modulus)})';
  }
}
String get texMpHxArg => texAngle(_paramMpHx.arg);
String get texMpHyAbs {
  if (_paramMpHy.modulus > 0) {
    return SciNum.sciTex(_paramMpHy.modulus);
  }
  else {
    return '(${SciNum.sciTex(_paramMpHy.modulus)})';
  }
}
String get texMpHyArg => texAngle(_paramMpHy.arg);
String? get texMpHxCoefficient {
  return texComplexCoefficient(_paramMpHx);
}
String? get texMpHyCoefficient {
  return texComplexCoefficient(_paramMpHy);
}
String? get texMpHxCoefficientPolar {
  return texComplexCoefficient(_paramMpHx.toPolar());
}
String? get texMpHyCoefficientPolar {
  return texComplexCoefficient(_paramMpHy.toPolar());
}
String? get texMpHxPolar {
  if (_paramMpHx.modulus != 0) {
    return '(${SciNum.sciTex(_paramMpHx.modulus)} \\angle ${texAngle(_paramMpHx.arg)})';
  }
  else {
    return null;
  }
}
String? get texMpHyPolar {
  if (_paramMpHy.modulus != 0) {
    return '(${SciNum.sciTex(_paramMpHy.modulus)} \\angle ${texAngle(_paramMpHy.arg)})';
  }
  else {
    return null;
  }
}
String get texMpEjbz => switch(_paramBetaSign) {
  Sign.minus => symExpJBetaZNegative,
  Sign.plus => symExpJBetaZPositive,
};
// String get texMpEjwt => symExpJOmegaTCancel;
String? get texMpHx {
  String rtn = '';
  if (_paramMpHx.modulus != 0) {
    rtn += symAx;
    rtn += texMpHxPolar!;
    rtn += texMpEjbz;
  }
  else {
    return null;
  }
  return rtn;
}
String? get texMpHy {
  String rtn = '';
  if (_paramMpHy.modulus != 0) {
  rtn += symAy;
  rtn += texMpHyPolar!;
  rtn += texMpEjbz;
  }
  else {
    return null;
  }
  return rtn;
}
String get texMp {
  String rtn = '';
  // rtn += symMp;
  // rtn += '=';

  if (_paramMpHx.modulus != 0) {
    rtn += texMpHx!;

    if (_paramMpHy.modulus != 0) {
      rtn += '+';
      rtn += texMpHy!;
    }
  }
  else if (_paramMpHy.modulus != 0) {
    rtn += texMpHy!;
  }
  else {
    rtn += '0';
  }

  return rtn;
}


String? get texMpStandardHxAbs => texSciCoefficient(_paramHx);
String? get texMpStandardHyAbs => texSciCoefficient(_paramHy);
String? get texMpStandardHxPolarNegativeReal {
  Complex hx = ComplexPolar(- _paramHx, _paramEPhiy);
  if (hx.modulus != 0) {
    return '(${SciNum.sciTex(hx.modulus)} \\angle ${texAngle(hx.arg)})';
  }
  else {
    return null;
  }
}
String? get texMpStandardHxPolar {
  Complex hx = ComplexPolar(_paramHx, _paramHPhix);
  if (hx.modulus != 0) {
    return '(${SciNum.sciTex(hx.modulus)} \\angle ${texAngle(hx.arg)})';
  }
  else {
    return null;
  }
}
String? get texMpStandardHyPolar {
  Complex hy = ComplexPolar(_paramHy, _paramHPhiy);
  if (hy.modulus != 0) {
    return '(${SciNum.sciTex(hy.modulus)} \\angle ${texAngle(hy.arg)})';
  }
  else {
    return null;
  }
}
String get texMpStandardEjbz => switch(_paramBetaSign) {
  Sign.minus => symExpJBetaZNegative,
  Sign.plus => symExpJBetaZPositive,
};
// String get texMpStandardEjwt => symExpJOmegaTCancel;
String? get texMpStandardHx {
  Complex hx = ComplexPolar(_paramHx, _paramHPhix);
  String rtn = '';
  if (hx.modulus != 0) {
    rtn += symAx;
    rtn += texMpStandardHxPolar!;
    rtn += texMpStandardEjbz;
    // rtn += texMpStandardEjwt;
  }
  else {
    return null;
  }
  return rtn;
}
String? get texMpStandardHy {
  Complex hy = ComplexPolar(_paramHy, _paramHPhiy);
  String rtn = '';
  if (hy.modulus != 0) {
  rtn += symAy;
  rtn += texMpStandardHyPolar!;
  rtn += texMpStandardEjbz;
  // rtn += texMpStandardEjwt;
  }
  else {
    return null;
  }
  return rtn;
}
String? get texMpStandardHxNoAx {
  Complex hx = ComplexPolar(_paramHx, _paramHPhix);
  String rtn = '';
  if (hx.modulus != 0) {
    // rtn += symAx;
    rtn += texMpStandardHxPolar!;
    rtn += texMpStandardEjbz;
    // rtn += texMpStandardEjwt;
  }
  else {
    return null;
  }
  return rtn;
}
String? get texMpStandardHyNoAy {
  Complex hy = ComplexPolar(_paramHy, _paramHPhiy);
  String rtn = '';
  if (hy.modulus != 0) {
  // rtn += symAy;
  rtn += texMpStandardHyPolar!;
  rtn += texMpStandardEjbz;
  // rtn += texMpStandardEjwt;
  }
  else {
    return null;
  }
  return rtn;
}
String get texMpStandard {
  Complex hx = ComplexPolar(_paramHx, _paramHPhix);
  Complex hy = ComplexPolar(_paramHy, _paramHPhiy);

  String rtn = '';
  // rtn += symMp;
  // rtn += '=';

  if (hx.modulus != 0) {
    rtn += texMpStandardHx!;

    if (hy.modulus != 0) {
      rtn += '+';
      rtn += texMpStandardHy!;
    }
  }
  else if (hy.modulus != 0) {
    rtn += texMpStandardHy!;
  }
  else {
    rtn += '0';
  }

  return rtn;
}


String? get texMpStandardHxAsExp {
  String rtn = '';
  if (_paramHx != 0) {
    rtn += texSciCoefficient(_paramHx)!;
    rtn += '$symE ^ {${texJAngle(_paramHPhix)}}';
  }
  else {
    return null;
  }
  return rtn;
}
String? get texMpStandardHyAsExp {
  String rtn = '';
  if (_paramHy != 0) {
    rtn += texSciCoefficient(_paramHy)!;
    rtn += '$symE ^ {${texJAngle(_paramHPhiy)}}';
  }
  else {
    return null;
  }
  return rtn;
}
String get texMpStandardHxPolarAsExpJPhix {
  if (_paramHPhix.ori != 0) {
    return '$symE ^ {${texJAngle(_paramHPhix)}}';
  }
  else {
    return '';
  }  
}
String get texMpStandardHyPolarAsExpJPhiy {
  if (_paramHPhiy.ori != 0) {
    return '$symE ^ {${texJAngle(_paramHPhiy)}}';
  }
  else {
    return '';
  }  
}
String get texMpStandardAsExp {
  String rtn = '';
  if (_paramHx != 0) {
    rtn += symAx;
    rtn += texMpStandardHxAbs!;
    rtn += symExpJOmegaTCancel;
    rtn += texMpStandardEjbz;
    rtn += texMpStandardHxPolarAsExpJPhix!;
    if (_paramHy != 0) {
      rtn += '+';
      rtn += symAy;
      rtn += texMpStandardHyAbs!;
      rtn += symExpJOmegaTCancel;
      rtn += texMpStandardEjbz;
      rtn += texMpStandardHyPolarAsExpJPhiy!;
    }
  }
  else if (_paramHy != 0) {
    rtn += symAy;
    rtn += texMpStandardHyAbs!;
    rtn += symExpJOmegaTCancel;
    rtn += texMpStandardEjbz;
    rtn += texMpStandardHyPolarAsExpJPhiy!;
  }
  else {
    rtn += '0';
  }
  return rtn;
}

String? get texMpStandardHxPolarConj {
  Complex hx = ComplexPolar(_paramHx, _paramHPhix).conjugate();
  if (hx.modulus != 0) {
    return '(${SciNum.sciTex(hx.modulus)} \\angle ${texAngle(hx.arg)})';
  }
  else {
    return null;
  }
}
String? get texMpStandardHyPolarConj {
  Complex hy = ComplexPolar(_paramHy, _paramHPhiy).conjugate();
  if (hy.modulus != 0) {
    return '(${SciNum.sciTex(hy.modulus)} \\angle ${texAngle(hy.arg)})';
  }
  else {
    return null;
  }
}
String get texMpStandardEjbzConj => switch(_paramBetaSign) {
  Sign.plus => symExpJBetaZNegative,
  Sign.minus => symExpJBetaZPositive,
};
String? get texMpStandardHxConjNoAx {
  String rtn = '';
  if (paramHxComplex.conjugate().modulus != 0) {
    // rtn += symAx;
    rtn += texMpStandardHxPolarConj!;
    rtn += texMpStandardEjbzConj;
  }
  else {
    return null;
  }
  return rtn;
}
String? get texMpStandardHxConj {
  String rtn = '';
  if (paramHxComplex.conjugate().modulus != 0) {
    rtn += symAx;
    rtn += texMpStandardHxPolarConj!;
    rtn += texMpStandardEjbzConj;
  }
  else {
    return null;
  }
  return rtn;
}
String? get texMpStandardHyConjNoAy {
  String rtn = '';
  if (paramHyComplex.conjugate().modulus != 0) {
  // rtn += symAy;
  rtn += texMpStandardHyPolarConj!;
  rtn += texMpStandardEjbzConj;
  }
  else {
    return null;
  }
  return rtn;
}



String? get texPoyntingStep {
  String rtn = '';

  if (_paramEx != 0 && _paramHy != 0) {
    rtn += symAz;
    rtn += texEpStandardExNoAx!;
    rtn += texMpStandardHyConjNoAy!;
    if (_paramEy != 0 && _paramHx != 0) {
      rtn += '-';
      rtn += symAz;
      rtn += texEpStandardEyNoAy!;
      rtn += texMpStandardHxConjNoAx!;
    }
  }
  else if (_paramEy != 0 && _paramHx != 0) {
    rtn += symAz;
    rtn += texEpStandardEyNoAy!;
    rtn += texMpStandardHxConjNoAx!;
  }
  else {
    rtn = '0';
  }

  return rtn;
}

String? get texPoynting {
  String rtn = '';

  rtn += symAz;

  double p = (
      (_paramEx * _paramHy * math.cos(_paramEPhix.rad - _paramHPhiy.rad))
    - (_paramEy * _paramHx * math.cos(_paramEPhiy.rad - _paramHPhix.rad))
  ) / 2;

  if (p < 0) {
    rtn += '(${SciNum.sciTex(p)})';
  }
  else {
    rtn += SciNum.sciTex(p);
  }

  return rtn;
}



/// points

int _maxPts = 720;

int get maxPts => _maxPts;

List<Offset> _pts = [];
List<Offset> _ptsx = [];
List<Offset> _ptsy = [];

List<Offset> get pts => _pts;
List<Offset> get ptsx => _ptsx;
List<Offset> get ptsy => _ptsy;



import 'dart:math' as math;

import 'angle.dart';



enum ComplexFormat {
  rect(
    name: 'rectangular',
    mathRepresentation: 'a+bi',
    mathTexRepresentation: r'a+bi',
    engRepresentation: 'a+jb',
    engTexRepresentation: r'a+jb',
    type: ComplexRect,
  ),
  polar(
    name: 'polar',
    mathRepresentation: 'r∠θ',
    mathTexRepresentation: r'r\angle\theta',
    engRepresentation: 'r∠θ',
    engTexRepresentation: r'r\angle\theta',
    type: ComplexPolar,
  ),
  ;

  final String name;
  final String mathRepresentation;
  final String mathTexRepresentation;
  final String engRepresentation;
  final String engTexRepresentation;
  final Type type;

  const ComplexFormat({
    required this.name,
    required this.mathRepresentation,
    required this.mathTexRepresentation,
    required this.engRepresentation,
    required this.engTexRepresentation,
    required this.type,
  });
}



abstract interface class Complex {
  Complex(double d, int i);


  ComplexFormat get fmt;

  double get re;
  double get im;
  double get modulus;
  Angle get arg;

  double abs();  // the same as modulus
  double absoluteSquare(); // the same as squaredModulus
  double squaredModulus();

  Complex conjugate();

  Complex simplify(); // designed for polar form

  ComplexRect toRect();
  ComplexPolar toPolar();

  @override
  int get hashCode;

  @override
  bool operator ==(Object other);

  int compareTo(Complex other);
  
  Complex operator +(Complex other);
  Complex operator -(Complex other);
  Complex operator *(Complex other);
  Complex operator /(Complex other);
  Complex operator -();

  Complex multiply(double other);
  Complex divideby(double other);
  
  static Complex sqrt(Complex val) {
    return ComplexPolar(math.sqrt(val.modulus.abs()) * val.modulus.sign, val.arg / 2);
  }

  static Complex ln(Complex val) {
    return ComplexRect(math.log(val.modulus), val.arg.inLongitude().rad);
  }

  static Complex sin(Complex val) {
    return ComplexRect(
      math.sin(val.re) * (math.exp(val.im) + math.exp(-val.im)) / 2, 
      math.cos(val.re) * (math.exp(val.im) - math.exp(-val.im)) / 2
    );
  }

  static Complex cos(Complex val) {
    return ComplexRect(
      math.cos(val.re) * (math.exp(val.im) + math.exp(-val.im)) / 2, 
      - math.sin(val.re) * (math.exp(val.im) - math.exp(-val.im)) / 2
    );
  }

  static Complex arcsin(Complex val) {
    Complex inside = (val * ComplexRect(0, 1) + Complex.sqrt(ComplexRect(1, 0) - val * val)).simplify(); 
    Complex l = ComplexRect(math.log(inside.modulus), inside.arg.inLongitude().rad);
    return l * ComplexRect(0, -1);
  }


  static Complex arctan(Complex val) {
    Complex inside = ((ComplexRect(0, 1) - val) / (ComplexRect(0, 1) + val)).simplify(); 
    Complex l = ComplexRect(math.log(inside.modulus), inside.arg.inLongitude().rad);
    return l / ComplexRect(0, 2);
  }
}



class ComplexRect implements Complex {

  double _re;
  double _im;

  ComplexRect(double re, double im) : 
    _re = re, 
    _im = im;

  @override
  ComplexFormat get fmt => ComplexFormat.rect;

  @override
  double get re => _re;

  @override
  double get im => _im;

  @override
  double get modulus => math.sqrt(_re * _re + _im * _im);

  @override
  Angle get arg => AngleRadian(math.atan2(_im, _re)).toNpi();

  @override
  double abs() => modulus;

  @override
  double absoluteSquare() => (_re * _re + _im * _im);

  @override
  double squaredModulus() => (_re * _re + _im * _im);

  @override
  ComplexRect conjugate() => ComplexRect(_re, -_im);

  @override
  ComplexRect simplify() => this;

  @override
  ComplexRect toRect() => this;

  @override
  ComplexPolar toPolar() => ComplexPolar(modulus, arg);

  @override
  int get hashCode => Object.hash(ComplexRect, _re, _im);

  @override
  bool operator ==(Object other) {
    if (other is Complex) {
      return ((other.re == _re) && (other.im == _im));
    }
    return false;
  }

  @override
  int compareTo(Complex other) {
    ComplexRect a = simplify();
    Complex b = other.simplify();
    if (a.re == b.re) {
      return a.im.compareTo(b.im);
    }
    else {
      return a.re.compareTo(b.re);
    }
  }
  
  @override
  ComplexRect operator +(Complex other) => ComplexRect(_re + other.re, _im + other.im);

  @override
  ComplexRect operator -(Complex other) => ComplexRect(_re - other.re, _im - other.im);

  @override
  ComplexRect operator *(Complex other) => ComplexRect(
    _re * other.re - _im * other.im,  // re: ac-bd
    _re * other.im + _im * other.re,  // im: ad+bc
  );
  
  @override
  ComplexRect operator /(Complex other) => ComplexRect(
    _re * other.re + _im * other.im,  // re: (ac+bd) / |other|^2
    _im * other.re - _re * other.im,  // im: (bc-ad) / |other|^2
  ).divideby(other.absoluteSquare());

  @override
  ComplexRect operator -() => ComplexRect(-_re, -_im);

  @override
  ComplexRect multiply(num other) => ComplexRect(_re*other, _im*other);

  @override
  ComplexRect divideby(num other) => ComplexRect(_re/other, _im/other);
  
}



class ComplexPolar implements Complex {

  double _modulus;
  Angle _arg;

  ComplexPolar(double modulus, Angle arg) : 
    _modulus = modulus, 
    _arg = arg;

  @override
  ComplexFormat get fmt => ComplexFormat.polar;

  @override
  double get re => _modulus * math.cos(_arg.rad);

  @override
  double get im => _modulus * math.sin(_arg.rad);

  @override
  double get modulus => _modulus;

  @override
  Angle get arg => _arg;

  @override
  double abs() => modulus;

  @override
  double absoluteSquare() => _modulus * _modulus;

  @override
  double squaredModulus() => _modulus * _modulus;

  @override
  ComplexPolar conjugate() => ComplexPolar(_modulus, -_arg);

  @override
  ComplexPolar simplify() {
    double m = _modulus;
    Angle a = _arg;
    if (_modulus < 0) {
      m = -_modulus;
      a += AngleDemiTurn(1); // + pi
    }
    else if (_modulus == 0) {
      m *= 0; // when modulus is zero, fix angle to zero
    }
    return ComplexPolar(m, a.inLongitude());
  }

  @override
  ComplexRect toRect() => ComplexRect(re, im);

  @override
  ComplexPolar toPolar() => this;

  @override
  int get hashCode => Object.hash(ComplexPolar, _modulus, _arg);

  @override
  bool operator ==(Object other) {
    if (other is Complex) {
      return ((other.modulus == _modulus) && (other.arg == _arg));
    }
    return false;
  }

  @override
  int compareTo(Complex other) {
    ComplexPolar a = simplify();
    Complex b = other.simplify();
    if (a.modulus == b.modulus) {
      return a.arg.compareTo(b.arg);
    }
    else {
      return a.modulus.compareTo(b.modulus);
    }
  }
  
  @override
  ComplexRect operator +(Complex other) => ComplexRect(re + other.re, im + other.im);

  @override
  ComplexRect operator -(Complex other) => ComplexRect(re - other.re, im - other.im);

  @override
  ComplexPolar operator *(Complex other) => ComplexPolar(
    _modulus * other.modulus,
    _arg + other.arg,
  );
  
  @override
  ComplexPolar operator /(Complex other) => ComplexPolar(
    _modulus / other.modulus,
    _arg - other.arg,
  );

  @override
  ComplexPolar operator -() => ComplexPolar(_modulus, _arg + AngleDemiTurn(1));

  @override
  ComplexPolar multiply(num other) => ComplexPolar(_modulus * other, _arg);

  @override
  ComplexPolar divideby(num other) => ComplexPolar(_modulus / other, _arg);
  
}
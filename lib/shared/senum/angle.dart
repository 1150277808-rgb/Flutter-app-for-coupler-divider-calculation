import 'dart:math' as math;



enum AngleUnit {
  deg(
    name: 'degree',
    abbr: 'deg',
    type: AngleDegree,
    unit: '°',
    texUnit: r'{}^\circ'
  ),
  rad(
    name: 'radian',
    abbr: 'rad',
    type: AngleRadian,
    unit: 'rad',
    texUnit: r'rad',
  ),
  npi(
    name: 'demiturn',
    abbr: 'npi',
    type: AngleDemiTurn,
    unit: 'π rad',
    texUnit: r'\pi \text{ rad}'
  )
  ;

  final String name;
  final String abbr;
  final Type type;
  final String unit;
  final String texUnit;

  const AngleUnit({
    required this.name,
    required this.abbr,
    required this.type,
    required this.unit,
    required this.texUnit,
  });
}

enum FreqUnit {
  hz(
    name: 'Hertz',
    abbr: 'Hz',
    value: 1,
    texUnit: r'\text{Hz}'
  ),
  khz(
    name: 'KiloHertz',
    abbr: 'kHz',
    value: 1e3,
    texUnit: r'\text{kHz}'
  ),
  mhz(
    name: 'MegaHertz',
    abbr: 'MHz',
    value: 1e6,
    texUnit: r'\text{MHz}'
  ),
  ghz(
    name: 'GigaHertz',
    abbr: 'GHz',
    value: 1e9,
    texUnit: r'\text{GHz}'
  );

  final String name;
  final String abbr;
  final double value;
  final String texUnit;

  const FreqUnit({
    required this.name,
    required this.abbr,
    required this.value,
    required this.texUnit,
  });
}


abstract interface class Angle implements Comparable<Angle> {

  AngleUnit get src;
  double get ori;
  double get deg;
  double get rad;
  double get npi;

  // angle conversion
  // pi rad = 180 deg

  /// convert angle from degree to radian
  static double deg2rad(double deg) => (deg / 180 * math.pi);
  /// convert angle from degree to demiturn
  static double deg2npi(double deg) => (deg / 180);
  /// convert angle from radian to degree
  static double rad2deg(double rad) => (rad / math.pi * 180);
  /// convert angle from radian to demiturn
  static double rad2npi(double rad) => (rad / math.pi);
  /// convert angle from demiturn to degree
  static double npi2deg(double npi) => (npi * 180);
  /// convert angle from demiturn to radian
  static double npi2rad(double npi) => (npi * math.pi);

  /// Return a new [Angle] object in type of [AngleDegree]
  AngleDegree toDeg();

  /// Return a new [Angle] object in type of [AngleRadian]
  AngleRadian toRad();

  /// Return a new [Angle] object in type of [AngleDemiTurn]
  AngleDemiTurn toNpi();

  /// Return a new [Angle] object with the same type
  /// 
  /// Range in 0 inclusive to 360 exclusive degree for [AngleDegree], 
  /// range in 0 inclusive to 2pi exclusive radian for [AngleRadian], 
  /// and range in 0 inclusive to 2 exclusive demiturn for [AngleDemiTurn].
  Angle inPerigon();

  /// Return a new [Angle] object with the same type
  /// 
  /// Range in -180 exclusive to 180 exclusive degree for [AngleDegree], 
  /// range in -pi exclusive to pi inclusive radian for [AngleRadian], 
  /// and range in -1 exclusive to 1 inclusive demiturn for [AngleDemiTurn].
  Angle inLongitude();

  @override
  int get hashCode;

  @override
  bool operator ==(Object other);

  @override
  int compareTo(Angle other);

  bool operator <(Angle other);
  bool operator <=(Angle other);
  bool operator >(Angle other);
  bool operator >=(Angle other);
  Angle operator +(Angle other);
  Angle operator -(Angle other);
  Angle operator *(double val);
  Angle operator /(double val);
  Angle operator -();
}

// class Angle implements Comparable<Angle> {
//   AngleUnit _src;
//   double _deg;
//   double _rad;
//   double _npi; // rad in pi
  
//   Angle.fromDeg(double deg) : 
//     _src = AngleUnit.deg, 
//     _deg = deg.toDouble(), 
//     _rad = _deg2rad(deg),
//     _npi = _deg2npi(deg);
  
//   Angle.fromRad(double rad) : 
//     _src = AngleUnit.rad, 
//     _deg = _rad2deg(rad), 
//     _rad = rad.toDouble(),
//     _npi = _rad2npi(rad);

//   Angle.fromNpi(double npi) : 
//     _src = AngleUnit.npi, 
//     _deg = _npi2deg(npi), 
//     _rad = _npi2rad(npi),
//     _npi = npi.toDouble();

//   AngleUnit get src => _src;
//   double get deg => _deg;
//   double get rad => _rad;
//   double get npi => _npi;

//   Angle asDeg() => Angle.fromDeg(_deg);
//   Angle asRad() => Angle.fromRad(_rad);
//   Angle asNpi() => Angle.fromNpi(_npi);

//   Angle inPerigon() => switch(_src) {
//     AngleUnit.deg => Angle.fromDeg(((_deg+180) % 360) - 180),
//     AngleUnit.rad => Angle.fromRad(((_rad+math.pi) % (2 * math.pi)) - math.pi),
//     AngleUnit.npi => Angle.fromNpi(((_npi+1) % 2) - 1),
//   };

//   // FIXME: this is actually [-180, 180), [-pi, pi), [-1, 1), find new ways! 
//   Angle inLongitude() => switch (_src) {
//     AngleUnit.deg => Angle.fromDeg(((_deg+180) % 360) - 180),
//     AngleUnit.rad => Angle.fromRad(((_rad+math.pi) % (2 * math.pi)) - math.pi),
//     AngleUnit.npi => Angle.fromRad(((_npi+1) % 2) - 1),
//   };

//   // angle conversion
//   // pi rad = 180 deg
//   static double _deg2rad(double deg) => (deg / 180 * math.pi);
//   static double _deg2npi(double deg) => (deg / 180);
//   static double _rad2deg(double rad) => (rad / math.pi * 180);
//   static double _rad2npi(double rad) => (rad / math.pi);
//   static double _npi2deg(double npi) => (npi * 180);
//   static double _npi2rad(double npi) => (npi * math.pi);



//   @override
//   int get hashCode => _deg.hashCode;

//   @override
//   bool operator ==(Object other) {
//     if (other is Angle) {
//       return (other.hashCode == hashCode);
//     }
//     return false;
//   }

//   @override
//   int compareTo(Angle other) => switch (_src) {
//     AngleUnit.deg => _deg.compareTo(other._deg),
//     AngleUnit.rad => _rad.compareTo(other._rad),
//     AngleUnit.npi => _npi.compareTo(other._npi),
//   };

//   bool operator <(Angle other) => switch(_src) {
//     AngleUnit.deg => (_deg < other._deg),
//     AngleUnit.rad => (_rad < other._rad),
//     AngleUnit.npi => (_npi < other._npi),
//   };
//   bool operator <=(Angle other) => switch(_src) {
//     AngleUnit.deg => (_deg <= other._deg),
//     AngleUnit.rad => (_rad <= other._rad),
//     AngleUnit.npi => (_npi <= other._npi),
//   };
//   bool operator >(Angle other) => switch(_src) {
//     AngleUnit.deg => (_deg > other._deg),
//     AngleUnit.rad => (_rad > other._rad),
//     AngleUnit.npi => (_npi > other._npi),
//   };
//   bool operator >=(Angle other) => switch(_src) {
//     AngleUnit.deg => (_deg >= other._deg),
//     AngleUnit.rad => (_rad >= other._rad),
//     AngleUnit.npi => (_npi >= other._npi),
//   };
  
//   Angle operator +(Angle other) => switch(_src) {
//     AngleUnit.deg => Angle.fromDeg(_deg + other._deg),
//     AngleUnit.rad => Angle.fromRad(_rad + other._rad),
//     AngleUnit.npi => Angle.fromNpi(_npi + other._npi),
//   };
//   Angle operator -(Angle other) => switch(_src) {
//     AngleUnit.deg => Angle.fromDeg(_deg - other._deg),
//     AngleUnit.rad => Angle.fromRad(_rad - other._rad),
//     AngleUnit.npi => Angle.fromNpi(_npi - other._npi),
//   };

//   Angle operator *(double val) => switch(_src) {
//     AngleUnit.deg => Angle.fromDeg(_deg * val),
//     AngleUnit.rad => Angle.fromRad(_rad * val),
//     AngleUnit.npi => Angle.fromNpi(_npi * val),
//   };
//   Angle operator /(double val)  => switch(_src) {
//     AngleUnit.deg => Angle.fromDeg(_deg / val),
//     AngleUnit.rad => Angle.fromRad(_rad / val),
//     AngleUnit.npi => Angle.fromNpi(_npi / val),
//   };

//   Angle operator -()  => switch(_src) {
//     AngleUnit.deg => Angle.fromDeg(-_deg),
//     AngleUnit.rad => Angle.fromRad(-_rad),
//     AngleUnit.npi => Angle.fromNpi(-_npi),
//   };
// }



class AngleDegree implements Angle {
  double _deg;

  AngleDegree(double deg) : _deg = deg;

  @override
  AngleUnit get src => AngleUnit.deg;

  @override
  double get ori => _deg;

  @override
  double get deg => _deg;

  @override
  double get rad => Angle.deg2rad(_deg);

  @override
  double get npi => Angle.deg2npi(_deg);

  @override
  AngleDegree toDeg() => this;

  @override
  AngleRadian toRad() => AngleRadian(rad);

  @override
  AngleDemiTurn toNpi() => AngleDemiTurn(npi);

  @override
  AngleDegree inPerigon() => AngleDegree(_deg % 360);

  @override
  AngleDegree inLongitude() {
    double a = _deg % 360; // [0, 360)
    if (a > 180) {
      a -= 360;
    }
    return AngleDegree(a);
  }

  @override
  int get hashCode => Object.hash(this, AngleUnit.deg);

  @override
  bool operator ==(Object other) {
    if (other is Angle) {
      return (other.deg == _deg);
    }
    return false;
  }

  @override
  int compareTo(Angle other) => _deg.compareTo(other.deg);

  @override
  bool operator <(Angle other) => (_deg < other.deg);

  @override
  bool operator <=(Angle other) => (_deg <= other.deg);

  @override
  bool operator >(Angle other) => (_deg > other.deg);

  @override
  bool operator >=(Angle other) => (_deg >= other.deg);

  @override
  AngleDegree operator +(Angle other) => AngleDegree(_deg + other.deg);

  @override
  AngleDegree operator -(Angle other) => AngleDegree(_deg - other.deg);

  @override
  AngleDegree operator *(double val) => AngleDegree(_deg * val);

  @override
  AngleDegree operator /(double val) => AngleDegree(_deg / val);

  @override
  AngleDegree operator -() => AngleDegree(-_deg);
}



class AngleRadian implements Angle {
  double _rad;

  AngleRadian(double rad) : _rad = rad;

  @override
  AngleUnit get src => AngleUnit.rad;

  @override
  double get ori => _rad;

  @override
  double get deg => Angle.rad2deg(_rad);

  @override
  double get rad => _rad;

  @override
  double get npi => Angle.rad2npi(_rad);

  @override
  AngleDegree toDeg() => AngleDegree(deg);

  @override
  AngleRadian toRad() => this;

  @override
  AngleDemiTurn toNpi() => AngleDemiTurn(npi);

  @override
  AngleRadian inPerigon() => AngleRadian(_rad % (2 * math.pi));

  @override
  AngleRadian inLongitude() {
    double a = _rad % (2 * math.pi);
    if (a > math.pi) {
      a -= 2 * math.pi;
    }
    return AngleRadian(a);
  }

  @override
  int get hashCode => Object.hash(this, AngleUnit.rad);

  @override
  bool operator ==(Object other) {
    if (other is Angle) {
      return (other.rad == _rad);
    }
    return false;
  }

  @override
  int compareTo(Angle other) => _rad.compareTo(other.rad);

  @override
  bool operator <(Angle other) => (_rad < other.rad);

  @override
  bool operator <=(Angle other) => (_rad <= other.rad);

  @override
  bool operator >(Angle other) => (_rad > other.rad);

  @override
  bool operator >=(Angle other) => (_rad >= other.rad);

  @override
  AngleRadian operator +(Angle other) => AngleRadian(_rad + other.rad);

  @override
  AngleRadian operator -(Angle other) => AngleRadian(_rad - other.rad);

  @override
  AngleRadian operator *(double val) => AngleRadian(_rad * val);

  @override
  AngleRadian operator /(double val) => AngleRadian(_rad / val);

  @override
  AngleRadian operator -() => AngleRadian(-_rad);
}



class AngleDemiTurn implements Angle {
  double _npi;

  AngleDemiTurn(double npi) : _npi = npi;

  @override
  AngleUnit get src => AngleUnit.npi;

  @override
  double get ori => _npi;

  @override
  double get deg => Angle.npi2deg(_npi);

  @override
  double get rad => _npi * math.pi;

  @override
  double get npi => _npi;

  @override
  AngleDegree toDeg() => AngleDegree(deg);

  @override
  AngleRadian toRad() => AngleRadian(rad);

  @override
  AngleDemiTurn toNpi() => this;

  @override
  AngleDemiTurn inPerigon() => AngleDemiTurn(_npi % 2);

  @override
  AngleDemiTurn inLongitude() {
    double a = _npi % 2;
    if (a > 1) {
      a -= 2;
    }
    return AngleDemiTurn(a);
  }

  @override
  int get hashCode => Object.hash(this, AngleUnit.npi);

  @override
  bool operator ==(Object other) {
    if (other is Angle) {
      return (other.npi == _npi);
    }
    return false;
  }

  @override
  int compareTo(Angle other) => _npi.compareTo(other.npi);

  @override
  bool operator <(Angle other) => (_npi < other.npi);

  @override
  bool operator <=(Angle other) => (_npi <= other.npi);

  @override
  bool operator >(Angle other) => (_npi > other.npi);

  @override
  bool operator >=(Angle other) => (_npi >= other.npi);

  @override
  AngleDemiTurn operator +(Angle other) => AngleDemiTurn(_npi + other.npi);

  @override
  AngleDemiTurn operator -(Angle other) => AngleDemiTurn(_npi - other.npi);

  @override
  AngleDemiTurn operator *(double val) => AngleDemiTurn(_npi * val);

  @override
  AngleDemiTurn operator /(double val) => AngleDemiTurn(_npi / val);

  @override
  AngleDemiTurn  operator -() => AngleDemiTurn(-_npi);
}



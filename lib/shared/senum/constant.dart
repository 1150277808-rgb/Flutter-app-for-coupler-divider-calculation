

/// check CODATA recommanded values at 
/// https://physics.nist.gov/cuu/Constants/index.html
/// https://physics.nist.gov/cuu/Constants/Table/allascii.txt
enum Constant {

  /// speed of light in vacuum
  c0(val: 299792458),
  
  /// elementary charge
  e0(val: 1.602176634e-19),

  /// vacuum electric permittivity, \varepsilon_0
  epsilon0(val: 8.8541878128e-12),

  /// vacuum magnetic permeability, \mu_0
  mu0(val: 1.25663706212e-6),
  ;

  final num val;
  const Constant({
    required this.val,
  });
}

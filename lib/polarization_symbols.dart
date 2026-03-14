import 'package:polarization/shared/senum/senum.dart' show Angle, AngleUnit;
import 'package:polarization/shared/senum/complex.dart';
import 'package:polarization/polarization_source.dart';


const String symRe = r'\text{Re} ';
const String symIm = r'\text{Im} ';
const String symArg = r'\text{Arg} ';

const String symAx = r'\overrightarrow{a_{\text x}} ';
const String symAy = r'\overrightarrow{a_{\text y}} ';
const String symAz = r'\overrightarrow{a_{\text z}} ';
const String symAk = r'\overrightarrow{a_{\text k}} ';

const String symEta = r'\eta ';
const String symEtaFormula = '$symEta = \\sqrt{ \\frac{ $symMu }{ $symEpsilon } }';
const String symMu = r'\mu ';
const String symEpsilon = r'\varepsilon ';

const String symOhm = r'\Omega';

const String symThetai = r'\theta_{i}'; 
const String symThetar = r'\theta_{r}'; 
const String symThetat = r'\theta_{t}'; 

const String symThetaBrew = r'\theta_{B\|}'; 
const String symThetaCrit = r'\theta_{c}'; 

const String symKx = 'k_{xi}';
const String symKy = 'k_{yi}';
const String symKz = 'k_{zi}';

const String symAki = r'\vec{a}_{ki}';
const String symAkr = r'\vec{a}_{kr}';
const String symAkt = r'\vec{a}_{kt}';

const String symAkiEq = '$symSinThetaI $symAx + $symCosThetaI $symAz';
const String symAkrEq = '$symSinThetaR $symAx - $symCosThetaR $symAz \\quad \\quad($symThetar = $symThetai)';
const String symAktEq = '$symSinThetaT $symAx + $symCosThetaT $symAz';

const String symReflV = r'\Gamma_\perp ';
const String symReflH = r'\Gamma_\parallel';
const String symTransV = r'\tau_\perp ';
const String symTransH = r'\tau_\parallel';

const String symCosThetaR = r'\cos\theta_r';
const String symSinThetaR = r'\sin\theta_r';
const String symCosThetaT = r'\cos\theta_t';
const String symSinThetaT = r'\sin\theta_t';
const String symCosThetaI = r'\cos\theta_i';
const String symSinThetaI = r'\sin\theta_i';

const String symThetaiEq = r'\arctan(\frac{k_{xi}}{k_{zi}})';
const String symThetatEq = r' \sin \theta _i \cdot \sqrt{\frac{\mu_1 \varepsilon_1}{\mu_2 \varepsilon_2} }  ';
const String symReflVEq = r'\frac{\eta_2 \cos\theta_i-\eta_1 \cos \theta_t}{\eta_2 \cos \theta_i+\eta_1 \cos \theta_t}';
const String symReflHEq = r'\frac{\eta_2 \cos\theta_t-\eta_1 \cos \theta_i}{\eta_2 \cos \theta_t+\eta_1 \cos \theta_i}';
const String symTransVEq = r'\frac{2 \eta_2 \cos\theta_i}{\eta_2 \cos \theta_i+\eta_1 \cos \theta_t}';
const String symTransHEq = r'\frac{2 \eta_2 \cos\theta_i}{\eta_2 \cos \theta_t+\eta_1 \cos \theta_i}';
const String symSnellLawEq = r'\frac{\sin(\theta_t)}{\sin(\theta_i)}=\sqrt{\frac{\mu_1\varepsilon_1}{\mu_2\varepsilon_2}}';
const String symSnellLawEqR = r'\frac{\sin(\theta_t)}{\sin(\theta_i)}=\sqrt{\frac{\mu_1\varepsilon_1}{\mu_2\varepsilon_2}}=\sqrt{\frac{\mu_{r1}\varepsilon_{r1}}{\mu_{r2}\varepsilon_{r2}}} \quad (\text{when } \sigma_2=0)';
const String symSinToCosEq = r'\sqrt{1-\sin^2(\theta_t)}';
const String symFreqEq = r'\frac{k_i}{2\pi \sqrt{\mu_1 \varepsilon_1} } = \frac{\sqrt{k_x^2+k_z^2}}{2\pi \sqrt{\mu_1 \varepsilon_1} } ';
// const String symKiEq = r'k_i=\sqrt{k_x^2+k_z^2}';

const String symThetaBrewEq = r'\arctan(\sqrt{\frac{\varepsilon_2}{\varepsilon_1}})'; 
const String symThetaBrewEqR = r'\arctan(\sqrt{\frac{\varepsilon_2}{\varepsilon_1}})= \arctan(\sqrt{\frac{\varepsilon_{r2}}{\varepsilon_{r1}}}) \quad (\text{when } \sigma_2=0)'; 
const String symThetaBrewEqC = r'\arctan(\sqrt{\frac{\varepsilon_2(\varepsilon_2 \mu_1-\varepsilon_1 \mu_2)}{\varepsilon_1(\varepsilon_2 \mu_2-\varepsilon_1 \mu_1)}})';
const String symThetaBrewEqCR = r'\arctan(\sqrt{\frac{\varepsilon_2(\varepsilon_2 \mu_1-\varepsilon_1 \mu_2)}{\varepsilon_1(\varepsilon_2 \mu_2-\varepsilon_1 \mu_1)}})=\arctan(\sqrt{\frac{\varepsilon_{r2}(\varepsilon_{r2} \mu_{r1}-\varepsilon_{r1} \mu_{r2})}{\varepsilon_{r1}(\varepsilon_{r2} \mu_{r2}-\varepsilon_{r1} \mu_{r1})}})\quad (\text{when } \sigma_2=0)';
const String symThetaCritEq = r'\arcsin(\sqrt{\frac{\varepsilon_2}{\varepsilon_1}})'; 
const String symThetaCritEqR = r'\arcsin(\sqrt{\frac{\varepsilon_2}{\varepsilon_1}}) = \arcsin(\sqrt{\frac{\varepsilon_{r2}}{\varepsilon_{r1}}}) \quad (\text{when } \sigma_2=0)'; 
const String symThetaCritEqC = r'\arcsin(\sqrt{\frac{\mu_2\varepsilon_2}{\mu_1\varepsilon_1}})'; 
const String symThetaCritEqCR = r'\arcsin(\sqrt{\frac{\mu_2\varepsilon_2}{\mu_1\varepsilon_1}}) = \arcsin(\sqrt{\frac{\mu_{r2}\varepsilon_{r2}}{\mu_{r1}\varepsilon_{r1}}}) \quad (\text{when } \sigma_2=0)'; 
const String symMuCond = r'\mu_1 \ne \mu_2';
const String symMuCond0 = r'\mu_1 = \mu_2';

// unit tex
const String symUnitRad = r'\:\text{  rad}';
const String symUnitK = r'\: \text{  rad/m}';
const String symUnitV = r'\: \text{  m/s}';
const String symUnitLambda = r'\: \text{  m}';
const String symUnitEta = r'\:\text{  } \Omega ';
const String symUnitEps = r'\:\text{  F/m}';
const String symUnitMu = r'\:\text{  H/m}';
const String symUnitAlpha = r'\:\text{  Np/m}';
const String symUnitBeta = r'\:\text{  rad/m}';
const String symUnitDelta = r'\:\text{  m}';
const String symPoyntingUnit = r'\:\mathrm{W}/\mathrm{m}^{2} ';
const String symUnitFreq = r'\:\text{  Hz}';
const String symUnitE = r'\:\text{  V/m}';
const String symUnitH = r'\:\text{  A/m}';

// Complex Equation
const String lnComplex = r'\ln(a+bi)=\ln(re^{j\theta})=\ln{r}+j\theta';
const String sqrtComplex = r'\sqrt{a+bi}= \sqrt{re^{j\theta}}=\sqrt{r}e^{j\frac{\theta}{2}}';
const String sqrtComplexPM = r'\sqrt{a+bi}=\pm \sqrt{re^{j\theta}}=\pm \sqrt{r}e^{j\frac{\theta}{2}}';
const String sinComplex = r'\sin(z)=\frac{e^{jz}-e^{-jz}}{2j}';
const String cosComplex = r'\cos(z)=\frac{e^{jz}+e^{-jz}}{2}';
const String arcsinComplex = r'\arcsin(z)=\frac{1}{j}\ln(jz+\sqrt{1-z^2})';
const String arctanComplex = r'\arctan(z)=\frac{1}{2j}\ln(\frac{j-z}{j+z})';


const String symPi = r'\mathrm{\pi}'; // unfortunately it behaves as \pi
const String symDeg = r' ^\circ ';
// const String symDeg = r'\vphantom{}^\circ ';
const String symPmN2Pi = '\\pm n 2 $symPi ';
const String symPmN360 = '\\pm n \\times 360$symDeg ';

const String strPmPiRad = '(-π, π]';
const String strPmRad = '(-3.14, 3.14]';
const String strPmPiDeg = '(-180°, 180°]';
String strPmPi(Angle angle) => switch (angle.src) {
  AngleUnit.deg => strPmPiDeg,
  AngleUnit.rad => strPmRad,
  _ => strPmPiRad,
};

// cos(x) = cos(x +- n2pi)
const String symPCos2CosRad = '\\cos \\theta = \\cos \\left( \\theta $symPmN2Pi \\right) ';
const String symPCos2CosDeg = '\\cos \\theta = \\cos \\left( \\theta $symPmN360 \\right) ';
String symPCos2Cos(Angle angle) => switch (angle.src) {
  AngleUnit.deg => symPCos2CosDeg,
  _ => symPCos2CosRad,
};
// -cos(x) = cos(x + pi +- n2pi)
const String symNCos2CosRad = '-\\cos \\theta = \\cos \\left( \\theta + $symPi $symPmN2Pi \\right) ';
const String symNCos2CosDeg = '-\\cos \\theta = \\cos \\left( \\theta + 180$symDeg $symPmN360 \\right) ';
String symNCos2Cos(Angle angle) => switch (angle.src) {
  AngleUnit.deg => symNCos2CosDeg,
  _ => symNCos2CosRad,
};
// sin(x) = cos(x - pi/2 +- n2pi)
const String symPSin2CosRad = '\\sin \\theta = \\cos \\left( \\theta - \\frac{$symPi}{2} $symPmN2Pi \\right) ';
const String symPSin2CosDeg = '\\sin \\theta = \\cos \\left( \\theta - 90$symDeg $symPmN360 \\right) ';
String symPSin2Cos(Angle angle) => switch (angle.src) {
  AngleUnit.deg => symPSin2CosDeg,
  _ => symPSin2CosRad,
};
// -sin(x) = cos(x + pi/2 +- n2pi)
const String symNSin2CosRad = '-\\sin \\theta = \\cos \\left( \\theta + \\frac{$symPi}{2} $symPmN2Pi \\right) ';
const String symNSin2CosDeg = '-\\sin \\theta = \\cos \\left( \\theta + 90$symDeg $symPmN360 \\right) ';
String symNSin2Cos(Angle angle) => switch (angle.src) {
  AngleUnit.deg => symNSin2CosDeg,
  _ => symNSin2CosRad,
};

const String symPolarNrRad = '-r \\angle \\theta = r \\angle (\\theta + $symPi $symPmN2Pi )';
const String symPolarNrDeg = '-r \\angle \\theta = r \\angle (\\theta + 180$symDeg $symPmN360 )';
String symPolarNr(Angle angle) => switch (angle.src) {
  AngleUnit.deg => symPolarNrDeg,
  _ => symPolarNrRad,
};
const String symPolarPrRad = 'r \\angle \\theta = r \\angle (\\theta $symPmN2Pi)';
const String symPolarPrDeg = 'r \\angle \\theta = r \\angle (\\theta $symPmN360)';
String symPolarPr(Angle angle) => switch (angle.src) {
  AngleUnit.deg => symPolarPrDeg,
  _ => symPolarPrRad,
};



// E time domain
const String symEt = r'\widetilde{E} ';

const String symEtEx = r'E_\text{r0x} ';
const String symEtEy = r'E_\text{r0y} ';
const String symEtPhix = r'\phi_\text{ex} ';
const String symEtPhiy = r'\phi_\text{ey} ';

// E phasor form
const String symEp = r'\overrightarrow{E} ';

const String symEpEx = r'E_\text{c0x} ';
const String symEpEy = r'E_\text{c0y} ';

const String symEpV = r'E_{i\perp} ';
const String symEpH = r'E_{i\parallel} ';

// E standard
const String symEEx = r'E_\text{0x} ';
const String symEExAbs = '|$symEEx| ';
const String symEEy = r'E_\text{0y} ';
const String symEEyAbs = '|$symEEy| ';
const String symEPhix = r'\phi_\text{0x} ';
const String symEPhiy = r'\phi_\text{0y} ';

const String symDetBegin = r'\det \begin{bmatrix} ';
const String symDetEnd = r'\end{bmatrix} ';

// H time domain
const String symHt = r'\widetilde{H} ';

const String symMtHx = r'H_\text{r0x} ';
const String symMtHy = r'H_\text{r0y} ';
const String symMtPhix = r'\phi_\text{hx} ';
const String symMtPhiy = r'\phi_\text{hy} ';

// H phasor form
const String symHp = r'\overrightarrow{H} ';

const String symMpHx = r'H_\text{c0x} ';
const String symMpHy = r'H_\text{c0y} ';

// H standard
const String symMHx = r'H_\text{0x} ';
const String symMHxAbs = '|$symMHx| ';
const String symMHy = r'H_\text{0y} ';
const String symMHyAbs = '|$symMHy| ';
const String symMPhix = r'\phi_\text{0x} ';
const String symMPhiy = r'\phi_\text{0y} ';



const String symE = r'\mathrm{e} ';

const String symOmega = r'\omega ';
// const String symBeta = r'\beta ';
const String symBeta = r'k ';
const String symExpJBetaZNegative = ' $symE ^{-j $symBeta z } ';
const String symExpJBetaZPositive = ' $symE ^{+j $symBeta z } ';
const String symExpJOmegaT = '$symE ^{j $symOmega ' r't } ';
const String symExpJOmegaTCancel = '\\cancel { $symE ^{j $symOmega ' r't } } ';

const String symSign = r'\mathrm{sign} ';

// const String symEulersFormular = '$symE ^{j \\theta} = \\cos ( \\theta ) + j \\sin ( \\theta ) ';
const String symEulersFormular = '$symRe \\{ $symE ^{j \\theta} \\} = $symRe \\{ \\cos ( \\theta ) + j \\sin ( \\theta ) \\} = \\cos ( \\theta ) ';

// please also update details in polarization_step.dart file _PolarizationStepsState class handedness function
const String symHandednessAngleTermLeading = '$symSign \\left( \\sin \\left(';
const String symHandednessAngleTermInside = '$symEPhiy - $symEPhix ';
const String symHandednessAngleTermEnding = '\\right) \\right)';
const String symHandednessAngleTerm = '$symHandednessAngleTermLeading $symHandednessAngleTermInside $symHandednessAngleTermEnding ';
const String symHandednessAkTerm = '$symSign \\left( $symAk \\cdot $symAz \\right)';
const String symHandedness = 
  '| $symEEx $symEEy | \\times $symHandednessAngleTerm \\times $symHandednessAkTerm ';
const String symHandednessWithResult = 
  '$symHandedness '
  r' \begin{cases}'
  ' < 0 \\Rightarrow &\\text{right-handed } ' r'\\'
  ' = 0 \\Rightarrow &\\text{linear, no handedness } ' r'\\'
  ' > 0 \\Rightarrow &\\text{left-handed } '
  r'\end{cases} ';


const String symMt2Et = '$symEt = $symEta $symHt \\times $symAk';
const String symMp2Ep = '$symEp = $symEta $symHp \\times $symAk ';
const String symEt2Mt = '$symHt = \\frac{1}{$symEta} $symAk \\times $symEt ';
const String symEp2Mp = '$symHp = \\frac{1}{$symEta} $symAk \\times $symEp ';
const String symEpI2MpI = '$symHpi = \\frac{1}{$symEta _1} $symAki \\times $symEpi ';
const String symEpR2MpR = '$symHpr = \\frac{1}{$symEta _1} $symAkr \\times $symEpr ';
const String symEpT2MpT = '$symHpt = \\frac{1}{$symEta _2} $symAkt \\times $symEpt ';

const String symEpi = r'\vec{E}_{i}';
const String symHpi = r'\vec{H}_{i}'; 
const String symEpr = r'\vec{E}_{r}';
const String symHpr = r'\vec{H}_{r}'; 
const String symEpt = r'\vec{E}_{t}';
const String symHpt = r'\vec{H}_{t}'; 
// const String sysHp2PMH = r'\vec{H}_{oi\perp}'; 
const String symEiExp = r'[\hat{E}_{oi\|}(\cos \theta_i \vec{a}_{x}-\sin \theta_i \vec{a}_{z})+\hat{E}_{oi\perp}\vec{a}_{y}] e^{-jk(\sin\theta_i x+\cos\theta_i z)}';
const String symErExp = r'[\hat{E}_{or\|}(\cos \theta_r \vec{a}_{x}+\sin \theta_r \vec{a}_{z})+\hat{E}_{or\perp}\vec{a}_{y}] e^{-jk(\sin\theta_r x-\cos\theta_r z)}';
const String symEtExp = r'[\hat{E}_{ot\|}(\cos \theta_t \vec{a}_{x}-\sin \theta_t \vec{a}_{z})+\hat{E}_{ot\perp}\vec{a}_{y}] e^{-jk(\sin\theta_t x+\cos\theta_t z)}';

const String symAkExp = r'\sin\theta_i\vec{a}_{x}+\cos\theta_i \vec{a}_{z}';
const String symAkrExp = r'\sin\theta_r\vec{a}_{x}-\cos\theta_r \vec{a}_{z}';
const String symAktExp = r'\sin\theta_t\vec{a}_{x}+\cos\theta_t \vec{a}_{z}';

const String symKiVec = r'e^{-j(kx_i x +kz_i z)}';
const String symKrVec = r'e^{-j(kx_r x -kz_r z)}';
const String symKtVec = r'e^{-j(kx_t x +kz_t z)}';

const String symKiVecT = r'e^{-jk_1(\sin\theta_i x+\cos\theta_i z)}';
const String symKrVecT = r'e^{-jk_1(\sin\theta_r x-\cos\theta_r z)}';
const String symKtVecT = r'e^{-jk_2(\sin\theta_t x+\cos\theta_t z)}';

const String symKiVecConj = r'e^{+j(kx_i x +kz_i z)}';
const String symKrVecConj = r'e^{+j(kx_r x -kz_r z)}';
const String symKtVecConj = r'e^{+j(kx_t x +kz_t z)}';

const String symConjFixed = r'\vphantom{}^{*} ';
const String symConjFlex = r'^{*} ';
const String symPoynting = r'\overrightarrow{S} ';
const String symPoyntingFormula = '$symPoynting = \\frac{1}{2} $symRe \\left\\{ $symEp \\times $symHp $symConjFixed \\right\\} ';


const String symEi=r'E_\text{i}';
const String angle=r'\theta';

const String symPoyntingTimeAvg = r'\overrightarrow{S} ';
const String symPoyntingTimeAvgInsideRe = '$symEp \\times $symHp $symConjFixed ';
const String symPoyntingTimeAvgFormula = '$symPoyntingTimeAvg = \\frac{1}{2} $symRe \\left\\{ $symPoyntingTimeAvgInsideRe \\right\\} ';


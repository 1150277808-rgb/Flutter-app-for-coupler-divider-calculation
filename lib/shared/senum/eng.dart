import 'misc.dart';

enum EngineeringSuffix {
  exa(
    symbol: 'E',
    tex: r'\mathrm{E}',
    multiplicand: 1e18,
  ),
  peta(
    symbol: 'P',
    tex: r'\mathrm{P}',
    multiplicand: 1e15,
  ),
  tera(
    symbol: 'T',
    tex: r'\mathrm{T}',
    multiplicand: 1e12,
  ),
  giga(
    symbol: 'G',
    tex: r'\mathrm{G}',
    multiplicand: 1e9,
  ),
  mega(
    symbol: 'M',
    tex: r'\mathrm{M}',
    multiplicand: 1e6,
  ),
  kilo(
    symbol: 'k',
    tex: r'\mathrm{k}',
    multiplicand: 1e3,
  ),

  milli(
    symbol: 'm',
    tex: r'\mathrm{m}',
    multiplicand: 1e-3,
  ),
  micro(
    symbol: 'μ',
    // tex: r'\text{\char"03FC}', // This should work but...
    tex: r'\mathrm{\mu}', // FIXME: this is italic
    multiplicand: 1e-6,
  ),
  nano(
    symbol: 'n',
    tex: r'\mathrm{n}',
    multiplicand: 1e-9,
  ),
  pico(
    symbol: 'p',
    tex: r'\mathrm{p}',
    multiplicand: 1e-12,
  ),
  femto(
    symbol: 'f',
    tex: r'\mathrm{f}',
    multiplicand: 1e-15,
  ),
  atto(
    symbol: 'a',
    tex: r'\mathrm{a}',
    multiplicand: 1e-18,
  )
  ;

  const EngineeringSuffix({
    required this.symbol,
    required this.tex,
    required this.multiplicand,
  });

  final String symbol;
  final String tex;
  final double multiplicand;
}

class EngNum {

  static String engTex(num val, {int sigFigs = 4}) {

    num round = roundToSignificantFigures(val, sigFigs);
    num judge = round;

    if (sigFigs == 2) {
      judge *= 10;
    }
    else if (sigFigs == 1) {
      judge *= 100;
      assert(sigFigs == 1); // why do you use this small value?
    }

    if (judge >= 1e3) {
      List<EngineeringSuffix> suffixList = [
        EngineeringSuffix.kilo,
        EngineeringSuffix.mega,
        EngineeringSuffix.giga,
        EngineeringSuffix.tera,
        EngineeringSuffix.peta,
        EngineeringSuffix.exa,
      ];
      EngineeringSuffix suffix = EngineeringSuffix.kilo;
      for (var element in suffixList) {
        if (judge >= element.multiplicand) {
          suffix = element;
        }
      }
      return '${(round/suffix.multiplicand).toStringAsPrecision(sigFigs)}\\ ${suffix.tex}';
    }
    else if (judge < 1) {
      List<EngineeringSuffix> suffixList = [
        EngineeringSuffix.atto,
        EngineeringSuffix.femto,
        EngineeringSuffix.pico,
        EngineeringSuffix.nano,
        EngineeringSuffix.micro,
        EngineeringSuffix.milli,
      ];
      EngineeringSuffix suffix = EngineeringSuffix.atto;
      for (var element in suffixList) {
        if (judge >= element.multiplicand) {
          suffix = element;
        }
      }
      return '${(round/suffix.multiplicand).toStringAsPrecision(sigFigs)}\\ ${suffix.tex}';
    }
    else {
      return '${round.toStringAsPrecision(sigFigs)}\\ ';
    }
    
  }

}
import 'dart:math' as math;

/// Calculation method for Fajr/Isha angles.
enum CalculationMethod {
  muslimWorldLeague,  // MWL:       Fajr 18°,   Isha 17°
  northAmerica,       // ISNA:      Fajr 15°,   Isha 15°
  egyptian,           //            Fajr 19.5°, Isha 17.5°
  karachi,            //            Fajr 18°,   Isha 18°
  kuwait,             //            Fajr 18°,   Isha 17.5°
  qatar,              //            Fajr 18°,   Isha 90 min after Maghrib
  singapore,          //            Fajr 20°,   Isha 18°
  turkey,             //            Fajr 18°,   Isha 17°
  dubai,              //            Fajr 18.2°, Isha 18.2°
  tehran,             //            Fajr 17.7°, Isha 14°
}

/// Asr juristic school.
enum AsrJuristic {
  standard, // Shafi / Maliki / Hanbali: shadow factor 1
  hanafi,   // Hanafi: shadow factor 2
}

class _MethodParams {
  final double fajrAngle;
  final double ishaAngle;
  final int? ishaMinutesAfterMaghrib; // null → use angle
  const _MethodParams(this.fajrAngle, this.ishaAngle, {this.ishaMinutesAfterMaghrib});
}

class PrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });
}

class PrayerCalculator {
  static const _methods = <CalculationMethod, _MethodParams>{
    CalculationMethod.muslimWorldLeague: _MethodParams(18.0,  17.0),
    CalculationMethod.northAmerica:      _MethodParams(15.0,  15.0),
    CalculationMethod.egyptian:          _MethodParams(19.5,  17.5),
    CalculationMethod.karachi:           _MethodParams(18.0,  18.0),
    CalculationMethod.kuwait:            _MethodParams(18.0,  17.5),
    CalculationMethod.qatar:             _MethodParams(18.0,   0.0, ishaMinutesAfterMaghrib: 90),
    CalculationMethod.singapore:         _MethodParams(20.0,  18.0),
    CalculationMethod.turkey:            _MethodParams(18.0,  17.0),
    CalculationMethod.dubai:             _MethodParams(18.2,  18.2),
    CalculationMethod.tehran:            _MethodParams(17.7,  14.0),
  };

  static PrayerTimes calculate(
    double latitude,
    double longitude,
    DateTime date, {
    CalculationMethod method = CalculationMethod.muslimWorldLeague,
    AsrJuristic asrJuristic = AsrJuristic.standard,
  }) {
    final params = _methods[method]!;
    final tz = date.timeZoneOffset.inHours.toDouble();
    final jd = _julianDate(date.year, date.month, date.day) - longitude / (15 * 24);

    final dhuhrTime  = _midDay(jd, longitude, tz);
    final sunriseTime = dhuhrTime - _sunAngleTime(jd, 0.833, latitude, true);
    final sunsetTime  = dhuhrTime + _sunAngleTime(jd, 0.833, latitude, false);
    final fajrTime    = dhuhrTime - _sunAngleTime(jd, params.fajrAngle, latitude, true);

    final ishaTime = params.ishaMinutesAfterMaghrib != null
        ? sunsetTime + params.ishaMinutesAfterMaghrib! / 60.0
        : dhuhrTime + _sunAngleTime(jd, params.ishaAngle, latitude, false);

    final asrFactor = asrJuristic == AsrJuristic.hanafi ? 2 : 1;
    final asrTime = dhuhrTime + _asrTime(jd, latitude, asrFactor);

    return PrayerTimes(
      fajr:    _timeToDateTime(date, fajrTime),
      sunrise: _timeToDateTime(date, sunriseTime),
      dhuhr:   _timeToDateTime(date, dhuhrTime),
      asr:     _timeToDateTime(date, asrTime),
      maghrib: _timeToDateTime(date, sunsetTime),
      isha:    _timeToDateTime(date, ishaTime),
    );
  }

  static double _julianDate(int y, int m, int d) {
    int year = y, month = m;
    if (month <= 2) { year--; month += 12; }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() + (30.6001 * (month + 1)).floor() + d + b - 1524.5;
  }

  static double _midDay(double jd, double lng, double tz) {
    final eqT = _equationOfTime(jd + 0.5);
    return 12 + tz - lng / 15 - eqT;
  }

  static double _sunAngleTime(double jd, double angle, double lat, [bool ccw = false]) {
    final decl  = _sunDeclination(jd + 0.5);
    final latR  = lat  * math.pi / 180;
    final declR = decl * math.pi / 180;
    final cosV  = (math.sin(-angle * math.pi / 180) - math.sin(latR) * math.sin(declR))
                  / (math.cos(latR) * math.cos(declR));
    if (cosV.abs() > 1) return 0; // sun never reaches this angle (polar)
    return math.acos(cosV) / (15 * math.pi / 180);
  }

  static double _asrTime(double jd, double lat, int factor) {
    final decl  = _sunDeclination(jd + 0.5);
    final angle = math.atan(1.0 / (factor + math.tan((lat - decl).abs() * math.pi / 180)));
    final latR  = lat  * math.pi / 180;
    final declR = decl * math.pi / 180;
    final cosV  = (math.sin(angle) - math.sin(latR) * math.sin(declR))
                  / (math.cos(latR) * math.cos(declR));
    if (cosV.abs() > 1) return 0;
    return math.acos(cosV) / (15 * math.pi / 180);
  }

  static double _sunDeclination(double jd) => _sunPosition(jd)['declination']!;
  static double _equationOfTime(double jd) => _sunPosition(jd)['equation']!;

  static Map<String, double> _sunPosition(double jd) {
    final d = jd - 2451545.0;
    final g = _fixAngle(357.529 + 0.98560028 * d);
    final q = _fixAngle(280.459 + 0.98564736 * d);
    final l = _fixAngle(q + 1.915 * _sin(g) + 0.020 * _sin(2 * g));
    final e = 23.439 - 0.00000036 * d;
    final ra  = math.atan2(_cos(e) * _sin(l), _cos(l)) / (math.pi / 180) / 15;
    final eqT = q / 15 - _fixHour(ra);
    final decl = math.asin(_sin(e) * _sin(l)) / (math.pi / 180);
    return {'declination': decl, 'equation': eqT};
  }

  static double _fixAngle(double a) => a - 360 * (a / 360).floor();
  static double _fixHour(double a)  => a -  24 * (a /  24).floor();
  static double _sin(double d) => math.sin(d * math.pi / 180);
  static double _cos(double d) => math.cos(d * math.pi / 180);

  static DateTime _timeToDateTime(DateTime date, double time) {
    if (time.isNaN || time.isInfinite) return date;
    time = _fixHour(time);
    final hours   = time.floor();
    final minutes = ((time - hours) * 60).round();
    return DateTime(date.year, date.month, date.day, hours, minutes.clamp(0, 59));
  }
}

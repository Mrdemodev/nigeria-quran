class HijriDate {
  final int year;
  final int month;
  final int day;

  const HijriDate(this.year, this.month, this.day);

  static const List<String> _monthNames = [
    'Muharram', 'Safar', 'Rabi\' al-Awwal', 'Rabi\' al-Thani',
    'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha\'ban',
    'Ramadan', 'Shawwal', 'Dhul Qi\'dah', 'Dhul Hijjah',
  ];

  String get monthName => _monthNames[month - 1];

  String formatted() => '$day $monthName $year AH';

  static HijriDate now() => fromGregorian(DateTime.now());

  static HijriDate fromGregorian(DateTime date) {
    final y = date.year;
    final m = date.month;
    final d = date.day;
    final jd = _toJulianDay(y, m, d);
    return _fromJulianDay(jd.round());
  }

  static double _toJulianDay(int y, int m, int d) {
    int yr = y, mo = m;
    if (mo <= 2) { yr--; mo += 12; }
    final a = (yr / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (yr + 4716)).floor() + (30.6001 * (mo + 1)).floor() + d + b - 1524.5;
  }

  static HijriDate _fromJulianDay(int jd) {
    final z = jd;
    final a = z;
    final b = a + 1524;
    final c = ((b - 122.1) / 365.25).floor();
    final d = (365.25 * c).floor();
    final e = ((b - d) / 30.6001).floor();
    final f = (b - d - (30.6001 * e).floor());

    // Gregorian date
    final day = f;
    final month = e < 14 ? e - 1 : e - 13;
    final year = month > 2 ? c - 4716 : c - 4715;

    // Now convert Gregorian to Hijri using the tabular method
    return _gregorianToHijri(year, month, day);
  }

  static HijriDate _gregorianToHijri(int gy, int gm, int gd) {
    return _simpleGregorianToHijri(gy, gm, gd);
  }

  // Reliable tabular Gregorian to Hijri conversion
  static HijriDate _simpleGregorianToHijri(int gy, int gm, int gd) {
    // Using the algorithm from: https://www.islamicfinder.org/
    var yy = gy;
    var mm = gm;
    var dd = gd;

    if (mm < 3) { yy--; mm += 12; }
    final a = (yy / 100).floor();
    final b = 2 - a + (a / 4).floor();
    var jd = (365.25 * (yy + 4716)).floor() + (30.6001 * (mm + 1)).floor() + dd + b - 1524;

    var l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    final j = ((10985 - l) / 5316).floor() * ((50 * l) / 17719).floor() +
        (l / 5670).floor() * ((43 * l) / 15238).floor();
    l = l - ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() + 29;
    final hMonth = (24 * l / 709).floor();
    final hDay = l - (709 * hMonth / 24).floor();
    final hYear = 30 * n + j - 30;

    return HijriDate(hYear, hMonth.clamp(1, 12), hDay.clamp(1, 30));
  }
}

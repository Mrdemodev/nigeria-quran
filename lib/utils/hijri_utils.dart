import 'package:hijri/hijri_calendar.dart';

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
    final h = HijriCalendar.fromDate(date);
    return HijriDate(h.hYear, h.hMonth, h.hDay);
  }
}

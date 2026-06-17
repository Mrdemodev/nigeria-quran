import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../providers/prayer_provider.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _prayerChannel = AndroidNotificationChannel(
    'prayer_times', 'Prayer Times',
    description: 'Athan alerts for each prayer',
    importance: Importance.high,
    playSound: true,
  );

  static const _dailyChannel = AndroidNotificationChannel(
    'daily_reminder', 'Daily Reminders',
    description: 'Daily Ayah and Hadith notifications',
    importance: Importance.defaultImportance,
  );

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Lagos'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_prayerChannel);
    await androidPlugin?.createNotificationChannel(_dailyChannel);

    _initialized = true;
  }

  Future<void> requestPermission() async {
    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    } catch (_) {}
  }

  Future<bool> get hasPermission async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.areNotificationsEnabled() ?? false;
  }

  Future<void> schedulePrayerNotifications(
    PrayerTimesData? times, {
    bool enabled = true,
    PrayerTimesData? tomorrowTimes,
  }) async {
    try {
      await init();
      for (int i = 1; i <= 10; i++) {
        try { await _plugin.cancel(i); } catch (_) {}
      }
      if (!enabled || times == null) return;

      final prayers = [
        (1, 'Fajr',    times.fajr,    'Dawn Prayer'),
        (2, 'Dhuhr',   times.dhuhr,   'Midday Prayer'),
        (3, 'Asr',     times.asr,     'Afternoon Prayer'),
        (4, 'Maghrib', times.maghrib, 'Sunset Prayer'),
        (5, 'Isha',    times.isha,    'Night Prayer'),
      ];

      final tomorrowPrayers = tomorrowTimes == null ? null : [
        (6,  'Fajr',    tomorrowTimes.fajr,    'Dawn Prayer'),
        (7,  'Dhuhr',   tomorrowTimes.dhuhr,   'Midday Prayer'),
        (8,  'Asr',     tomorrowTimes.asr,     'Afternoon Prayer'),
        (9,  'Maghrib', tomorrowTimes.maghrib, 'Sunset Prayer'),
        (10, 'Isha',    tomorrowTimes.isha,    'Night Prayer'),
      ];

      final now = DateTime.now();
      for (final p in prayers) {
        if (p.$3.isAfter(now)) {
          try { await _schedulePrayerAlert(id: p.$1, name: p.$2, subtitle: p.$4, time: p.$3); } catch (_) {}
        }
      }
      if (tomorrowPrayers != null) {
        for (final p in tomorrowPrayers) {
          try { await _schedulePrayerAlert(id: p.$1, name: p.$2, subtitle: p.$4, time: p.$3); } catch (_) {}
        }
      }
    } catch (_) {}
  }

  Future<void> scheduleDailyAyah({
    int hour = 7,
    int minute = 0,
    bool enabled = true,
    String? ayahArabic,
    String? ayahTranslation,
    String? surahInfo,
  }) async {
    try {
      await init();
      try { await _plugin.cancel(100); } catch (_) {}
      if (!enabled) return;

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

      final title = surahInfo != null ? 'Ayah of the Day · $surahInfo' : 'Daily Ayah';
      final body = ayahArabic != null && ayahTranslation != null
          ? '$ayahArabic\n$ayahTranslation'
          : ayahArabic ?? 'Open Qur\'an NG for your ayah of the day';

      await _plugin.zonedSchedule(
        100,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder', 'Daily Reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
            styleInformation: ayahArabic != null
                ? BigTextStyleInformation(body, contentTitle: title)
                : null,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  Future<void> scheduleDailyHadith({int hour = 18, int minute = 0, bool enabled = true}) async {
    try {
      await init();
      try { await _plugin.cancel(101); } catch (_) {}
      if (!enabled) return;

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

      await _plugin.zonedSchedule(
        101,
        'Daily Hadith',
        'Your daily hadith reminder from Quran NG',
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder', 'Daily Reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    try { await _plugin.cancelAll(); } catch (_) {}
  }

  Future<void> _schedulePrayerAlert({
    required int id,
    required String name,
    required String subtitle,
    required DateTime time,
  }) async {
    final tzTime = tz.TZDateTime.from(time, tz.local);
    await _plugin.zonedSchedule(
      id,
      'Prayer Time: $name',
      '$subtitle - It is time for $name prayer',
      tzTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times', 'Prayer Times',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

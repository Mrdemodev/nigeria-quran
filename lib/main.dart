import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/settings_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/download_provider.dart';
import 'providers/progress_provider.dart';
import 'services/notification_service.dart';
import 'services/audio_handler.dart';
import 'services/ads_service.dart';
import 'services/remote_config_service.dart';
import 'app.dart';

void main() {
  runZonedGuarded(_appMain, (error, stack) {
    debugPrint('Caught unhandled error: $error');
  });
}

Future<void> _appMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // Firebase must init before Remote Config or Ads
  await Firebase.initializeApp();
  await RemoteConfigService.instance.init();

  final settings = SettingsProvider();
  await settings.load();

  NotificationService().init().then((_) async {
    await NotificationService().scheduleDailyAyah(enabled: settings.dailyAyahNotificationEnabled);
    await NotificationService().scheduleDailyHadith(enabled: settings.dailyHadithNotificationEnabled);
  }).catchError((_) {});

  final audioHandler = await AudioService.init<QuranAudioHandler>(
    builder: () => QuranAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.nigeriaquran.nigeria_quran.audio',
      androidNotificationChannelName: "Qur'an Playback",
      androidNotificationIcon: 'drawable/ic_stat_music_note',
      androidShowNotificationBadge: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) {
          final q = QuranProvider();
          q.loadSurahs();
          return q;
        }),
        ChangeNotifierProvider(create: (_) {
          final b = BookmarkProvider();
          b.init();
          return b;
        }),
        ChangeNotifierProvider(create: (_) {
          final p = ProgressProvider();
          p.init();
          return p;
        }),
        ChangeNotifierProvider(create: (_) {
          final d = DownloadProvider();
          d.init(settings.selectedReciterId);
          return d;
        }),
        ChangeNotifierProvider(create: (_) => AudioProvider(audioHandler)),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
      ],
      child: const NigeriaQuranApp(),
    ),
  );

  // Init ads AFTER runApp — never blocks startup or first frame
  AdsService.instance.initialize();
}

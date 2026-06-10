import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

final RouteObserver<ModalRoute<void>> appRouteObserver = RouteObserver<ModalRoute<void>>();

class NigeriaQuranApp extends StatefulWidget {
  const NigeriaQuranApp({super.key});

  @override
  State<NigeriaQuranApp> createState() => _NigeriaQuranAppState();
}

class _NigeriaQuranAppState extends State<NigeriaQuranApp> {
  @override
  void initState() {
    super.initState();
    // Request notification permission after first frame — requires active Activity
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().requestPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      title: "Qur'an NG",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      navigatorObservers: [appRouteObserver],
      home: const SplashScreen(),
    );
  }
}

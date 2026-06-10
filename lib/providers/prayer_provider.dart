import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/prayer_calculator.dart';
import '../services/notification_service.dart';
import '../data/nigerian_cities.dart';

class PrayerTimesData {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String locationName;

  const PrayerTimesData({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.locationName,
  });
}

class PrayerProvider extends ChangeNotifier {
  PrayerTimesData? _prayerTimes;
  DateTime? _tomorrowFajr;
  bool _isLoading = false;
  String? _error;
  bool _usingGps = false;
  String? _selectedCityName;
  CalculationMethod _method = CalculationMethod.muslimWorldLeague;
  AsrJuristic _asrJuristic = AsrJuristic.standard;

  PrayerTimesData? get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get usingGps => _usingGps;
  String? get selectedCityName => _selectedCityName;
  CalculationMethod get calculationMethod => _method;
  AsrJuristic get asrJuristic => _asrJuristic;

  PrayerProvider() {
    Future.microtask(() => _init());
  }

  String get nextPrayerName {
    if (_prayerTimes == null) return '';
    final now = DateTime.now();
    final prayers = [
      ('Fajr',    _prayerTimes!.fajr),
      ('Dhuhr',   _prayerTimes!.dhuhr),
      ('Asr',     _prayerTimes!.asr),
      ('Maghrib', _prayerTimes!.maghrib),
      ('Isha',    _prayerTimes!.isha),
    ];
    for (final p in prayers) {
      if (p.$2.isAfter(now)) return p.$1;
    }
    return 'Fajr'; // tomorrow
  }

  DateTime get nextPrayerTime {
    if (_prayerTimes == null) return DateTime.now();
    final now = DateTime.now();
    final times = [
      _prayerTimes!.fajr,
      _prayerTimes!.dhuhr,
      _prayerTimes!.asr,
      _prayerTimes!.maghrib,
      _prayerTimes!.isha,
    ];
    for (final t in times) {
      if (t.isAfter(now)) return t;
    }
    // All prayers passed — return tomorrow's Fajr
    return _tomorrowFajr ?? _prayerTimes!.fajr.add(const Duration(days: 1));
  }

  Duration get timeToNextPrayer {
    final diff = nextPrayerTime.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    // Load saved calculation method
    final methodStr = prefs.getString('prayerMethod') ?? 'muslimWorldLeague';
    _method = CalculationMethod.values.firstWhere(
      (m) => m.name == methodStr,
      orElse: () => CalculationMethod.muslimWorldLeague,
    );
    final asrStr = prefs.getString('asrJuristic') ?? 'standard';
    _asrJuristic = AsrJuristic.values.firstWhere(
      (a) => a.name == asrStr,
      orElse: () => AsrJuristic.standard,
    );

    // Load saved city first (fastest path)
    final savedCity = prefs.getString('selectedCityName');
    if (savedCity != null) {
      final city = kNigerianCities.firstWhere(
        (c) => c.name == savedCity,
        orElse: () => kNigerianCities.first,
      );
      _selectedCityName = city.name;
      _calculatePrayerTimes(city.latitude, city.longitude, '${city.name}, ${city.state}');
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Try saved GPS coords
    final savedLat = prefs.getDouble('savedLat');
    final savedLng = prefs.getDouble('savedLng');
    if (savedLat != null && savedLng != null) {
      _calculatePrayerTimes(savedLat, savedLng, 'Saved Location');
      _isLoading = false;
      notifyListeners();
    }

    // Try GPS silently
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 10)),
        );
        _calculatePrayerTimes(pos.latitude, pos.longitude, 'Current Location');
        _usingGps = true;
        await prefs.setDouble('savedLat', pos.latitude);
        await prefs.setDouble('savedLng', pos.longitude);
        _isLoading = false;
        notifyListeners();
        return;
      }
    } catch (_) {}

    if (savedLat == null && savedCity == null) {
      // Default to Lagos for Nigerian users
      final lagos = kNigerianCities.firstWhere((c) => c.name == 'Lagos');
      _selectedCityName = lagos.name;
      _calculatePrayerTimes(lagos.latitude, lagos.longitude, '${lagos.name}, ${lagos.state}');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFromCity(NigerianCity city) async {
    _isLoading = true;
    _error = null;
    _usingGps = false;
    _selectedCityName = city.name;
    notifyListeners();

    _calculatePrayerTimes(city.latitude, city.longitude, '${city.name}, ${city.state}');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCityName', city.name);
    await prefs.remove('savedLat');
    await prefs.remove('savedLng');

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadWithGPS() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        _error = 'Location permission permanently denied. Please enable in Settings.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 10)),
      );
      _calculatePrayerTimes(pos.latitude, pos.longitude, 'Current Location');
      _usingGps = true;
      _selectedCityName = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('savedLat', pos.latitude);
      await prefs.setDouble('savedLng', pos.longitude);
      await prefs.remove('selectedCityName');
    } catch (e) {
      _error = 'Could not get location. Check GPS and try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setCalculationMethod(CalculationMethod method) async {
    _method = method;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prayerMethod', method.name);
    _recalculateCurrent();
  }

  Future<void> setAsrJuristic(AsrJuristic juristic) async {
    _asrJuristic = juristic;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('asrJuristic', juristic.name);
    _recalculateCurrent();
  }

  /// Recalculate with current coords and new method/juristic.
  void _recalculateCurrent() {
    if (_prayerTimes == null) return;
    // We need coords — try to get them from saved location
    SharedPreferences.getInstance().then((prefs) {
      final savedCity = prefs.getString('selectedCityName');
      if (savedCity != null) {
        final city = kNigerianCities.firstWhere(
          (c) => c.name == savedCity,
          orElse: () => kNigerianCities.first,
        );
        _calculatePrayerTimes(city.latitude, city.longitude, '${city.name}, ${city.state}');
        notifyListeners();
        return;
      }
      final lat = prefs.getDouble('savedLat');
      final lng = prefs.getDouble('savedLng');
      if (lat != null && lng != null) {
        _calculatePrayerTimes(lat, lng, _prayerTimes!.locationName);
        notifyListeners();
      }
    });
  }

  void _calculatePrayerTimes(double lat, double lng, String location) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final times = PrayerCalculator.calculate(lat, lng, today, method: _method, asrJuristic: _asrJuristic);
    final tomorrowTimes = PrayerCalculator.calculate(lat, lng, tomorrow, method: _method, asrJuristic: _asrJuristic);

    _tomorrowFajr = tomorrowTimes.fajr;
    _prayerTimes = PrayerTimesData(
      fajr: times.fajr, sunrise: times.sunrise, dhuhr: times.dhuhr,
      asr: times.asr, maghrib: times.maghrib, isha: times.isha,
      locationName: location,
    );

    final tomorrowData = PrayerTimesData(
      fajr: tomorrowTimes.fajr, sunrise: tomorrowTimes.sunrise, dhuhr: tomorrowTimes.dhuhr,
      asr: tomorrowTimes.asr, maghrib: tomorrowTimes.maghrib, isha: tomorrowTimes.isha,
      locationName: location,
    );

    SharedPreferences.getInstance().then((prefs) {
      final enabled = prefs.getBool('prayerNotifications') ?? true;
      NotificationService().schedulePrayerNotifications(
        _prayerTimes!,
        enabled: enabled,
        tomorrowTimes: tomorrowData,
      ).catchError((_) {});
    });
  }
}

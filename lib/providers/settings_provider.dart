import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TranslationLanguage { english, hausa, yoruba }

class SettingsProvider extends ChangeNotifier {
  static const _themeKey = 'isDarkMode';
  static const _translationKey = 'translationLanguage';
  static const _selectedReciterKey = 'selectedReciterId';
  static const _lastReadSurahKey = 'lastReadSurah';
  static const _lastReadAyahKey = 'lastReadAyah';
  static const _fontSizeKey = 'arabicFontSize';
  static const _prayerNotifKey = 'prayerNotifications';
  static const _dailyAyahNotifKey = 'dailyAyahNotification';
  static const _dailyHadithNotifKey = 'dailyHadithNotification';
  static const _hideTranslationKey = 'hideTranslation';

  bool _isDarkMode = false;
  TranslationLanguage _translationLanguage = TranslationLanguage.english;
  String _selectedReciterId = 'alafasy';
  int _lastReadSurah = 1;
  int _lastReadAyah = 1;
  double _arabicFontSize = 26.0;
  bool _prayerNotificationsEnabled = false;
  bool _dailyAyahNotificationEnabled = false;
  bool _dailyHadithNotificationEnabled = false;
  bool _hideTranslation = false;

  bool get isDarkMode => _isDarkMode;
  TranslationLanguage get translationLanguage => _translationLanguage;
  String get selectedReciterId => _selectedReciterId;
  int get lastReadSurah => _lastReadSurah;
  int get lastReadAyah => _lastReadAyah;
  double get arabicFontSize => _arabicFontSize;
  bool get prayerNotificationsEnabled => _prayerNotificationsEnabled;
  bool get dailyAyahNotificationEnabled => _dailyAyahNotificationEnabled;
  bool get dailyHadithNotificationEnabled => _dailyHadithNotificationEnabled;
  bool get hideTranslation => _hideTranslation;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    final lang = prefs.getString(_translationKey) ?? 'english';
    _translationLanguage = lang == 'hausa'
        ? TranslationLanguage.hausa
        : lang == 'yoruba'
            ? TranslationLanguage.yoruba
            : TranslationLanguage.english;
    _selectedReciterId = prefs.getString(_selectedReciterKey) ?? 'alafasy';
    _lastReadSurah = prefs.getInt(_lastReadSurahKey) ?? 1;
    _lastReadAyah = prefs.getInt(_lastReadAyahKey) ?? 1;
    _arabicFontSize = prefs.getDouble(_fontSizeKey) ?? 26.0;
    _prayerNotificationsEnabled = prefs.getBool(_prayerNotifKey) ?? true;
    _dailyAyahNotificationEnabled = prefs.getBool(_dailyAyahNotifKey) ?? true;
    _dailyHadithNotificationEnabled = prefs.getBool(_dailyHadithNotifKey) ?? true;
    _hideTranslation = prefs.getBool(_hideTranslationKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setTranslation(TranslationLanguage lang) async {
    _translationLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    final langStr = lang == TranslationLanguage.hausa ? 'hausa'
        : lang == TranslationLanguage.yoruba ? 'yoruba'
        : 'english';
    await prefs.setString(_translationKey, langStr);
    notifyListeners();
  }

  Future<void> setSelectedReciter(String id) async {
    _selectedReciterId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedReciterKey, id);
    notifyListeners();
  }

  Future<void> saveLastRead(int surah, int ayah) async {
    _lastReadSurah = surah;
    _lastReadAyah = ayah;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastReadSurahKey, surah);
    await prefs.setInt(_lastReadAyahKey, ayah);
    notifyListeners();
  }

  Future<void> setPrayerNotifications(bool val) async {
    _prayerNotificationsEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prayerNotifKey, val);
    notifyListeners();
  }

  Future<void> setDailyAyahNotification(bool val) async {
    _dailyAyahNotificationEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyAyahNotifKey, val);
    notifyListeners();
  }

  Future<void> setDailyHadithNotification(bool val) async {
    _dailyHadithNotificationEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyHadithNotifKey, val);
    notifyListeners();
  }

  void setArabicFontSizeTemp(double size) {
    _arabicFontSize = size.clamp(16.0, 52.0);
    notifyListeners();
  }

  Future<void> setArabicFontSize(double size) async {
    _arabicFontSize = size.clamp(16.0, 52.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, _arabicFontSize);
    notifyListeners();
  }

  Future<void> setHideTranslation(bool val) async {
    _hideTranslation = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hideTranslationKey, val);
    notifyListeners();
  }
}

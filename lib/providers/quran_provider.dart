import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/surah_model.dart';

class QuranProvider extends ChangeNotifier {
  List<SurahModel> _surahs = [];
  Map<String, List<String>> _arabicCache = {};
  Map<String, List<String>> _englishCache = {};
  Map<String, List<String>> _hausaCache = {};
  Map<String, List<String>> _yorubaCache = {};
  bool _isLoading = true;
  String? _error;

  List<SurahModel> get surahs => _surahs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<SurahModel> searchSurahs(String query) {
    if (query.isEmpty) return _surahs;
    final q = query.toLowerCase();
    return _surahs.where((s) =>
      s.nameEn.toLowerCase().contains(q) ||
      s.meaning.toLowerCase().contains(q) ||
      s.number.toString() == q
    ).toList();
  }

  Future<void> loadSurahs() async {
    try {
      final data = await rootBundle.loadString('assets/data/surahs.json');
      final list = jsonDecode(data) as List;
      _surahs = list.map((j) => SurahModel.fromJson(j as Map<String, dynamic>)).toList();
      _error = null;
      _isLoading = false;
      notifyListeners();
      // Preload the two most-used JSON files in background so home screen is instant
      Future.wait([_loadArabicData(), _loadEnglishData()]);
    } catch (e) {
      _error = 'Failed to load Quran data. Please reinstall the app.\n($e)';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> getArabicAyahs(int surahNumber) async {
    final key = surahNumber.toString();
    if (_arabicCache.containsKey(key)) return _arabicCache[key]!;
    await _loadArabicData();
    return _arabicCache[key] ?? [];
  }

  Future<List<String>> getEnglishAyahs(int surahNumber) async {
    final key = surahNumber.toString();
    if (_englishCache.containsKey(key)) return _englishCache[key]!;
    await _loadEnglishData();
    return _englishCache[key] ?? [];
  }

  Future<List<String>> getHausaAyahs(int surahNumber) async {
    final key = surahNumber.toString();
    if (_hausaCache.containsKey(key)) return _hausaCache[key]!;
    await _loadHausaData();
    return _hausaCache[key] ?? [];
  }

  Future<List<String>> getYorubaAyahs(int surahNumber) async {
    final key = surahNumber.toString();
    if (_yorubaCache.containsKey(key)) return _yorubaCache[key]!;
    await _loadYorubaData();
    return _yorubaCache[key] ?? [];
  }

  Future<void> _loadArabicData() async {
    if (_arabicCache.isNotEmpty) return;
    final data = await rootBundle.loadString('assets/data/quran_arabic.json');
    final map = jsonDecode(data) as Map<String, dynamic>;
    _arabicCache = map.map((k, v) => MapEntry(k, List<String>.from(v as List)));
  }

  Future<void> _loadEnglishData() async {
    if (_englishCache.isNotEmpty) return;
    final data = await rootBundle.loadString('assets/data/quran_english.json');
    final map = jsonDecode(data) as Map<String, dynamic>;
    _englishCache = map.map((k, v) => MapEntry(k, List<String>.from(v as List)));
  }

  Future<void> _loadHausaData() async {
    if (_hausaCache.isNotEmpty) return;
    final data = await rootBundle.loadString('assets/data/quran_hausa.json');
    final map = jsonDecode(data) as Map<String, dynamic>;
    _hausaCache = map.map((k, v) => MapEntry(k, List<String>.from(v as List)));
  }

  Future<void> _loadYorubaData() async {
    if (_yorubaCache.isNotEmpty) return;
    final data = await rootBundle.loadString('assets/data/quran_yoruba.json');
    final map = jsonDecode(data) as Map<String, dynamic>;
    _yorubaCache = map.map((k, v) => MapEntry(k, List<String>.from(v as List)));
  }

  SurahModel? getSurah(int number) {
    if (number < 1 || number > _surahs.length) return null;
    return _surahs[number - 1];
  }
}

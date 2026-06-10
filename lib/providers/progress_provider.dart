import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NoteRecord {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final DateTime createdAt;

  const NoteRecord({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    required this.createdAt,
  });
}

class ReadProgress {
  final int surahNumber;
  final int ayahsRead;
  final int totalAyahs;
  final DateTime lastRead;

  const ReadProgress({
    required this.surahNumber,
    required this.ayahsRead,
    required this.totalAyahs,
    required this.lastRead,
  });

  double get percent => totalAyahs > 0 ? ayahsRead / totalAyahs : 0;
  bool get completed => ayahsRead >= totalAyahs;
}

class FastRecord {
  final int id;
  final DateTime date;
  final String type; // 'ramadan' | 'monday' | 'thursday' | 'voluntary'
  final String? notes;

  const FastRecord({required this.id, required this.date, required this.type, this.notes});
}

class ProgressProvider extends ChangeNotifier {
  Database? _db;

  // Progress data
  final Map<int, ReadProgress> _surahProgress = {};
  int _totalAyahsRead = 0;
  int _readingStreak = 0;
  static const _totalQuranAyahs = 6236;

  // Fasting data
  final List<FastRecord> _fasts = [];

  // Notes data
  final List<NoteRecord> _notes = [];

  Map<int, ReadProgress> get surahProgress => Map.unmodifiable(_surahProgress);
  int get totalAyahsRead => _totalAyahsRead;
  int get readingStreak => _readingStreak;
  double get quranProgressPercent => _totalAyahsRead / _totalQuranAyahs;
  int get surahsCompleted => _surahProgress.values.where((p) => p.completed).length;
  List<FastRecord> get fasts => List.unmodifiable(_fasts);
  List<NoteRecord> get notes => List.unmodifiable(_notes);

  Future<void> init() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'quran_progress.db'),
      version: 2,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE surah_progress (
            surah_number INTEGER PRIMARY KEY,
            ayahs_read INTEGER NOT NULL DEFAULT 0,
            total_ayahs INTEGER NOT NULL,
            last_read TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE fasting_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL UNIQUE,
            type TEXT NOT NULL,
            notes TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE reading_days (
            date TEXT PRIMARY KEY
          )
        ''');
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            surah_number INTEGER NOT NULL,
            ayah_number INTEGER NOT NULL,
            text TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS notes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              surah_number INTEGER NOT NULL,
              ayah_number INTEGER NOT NULL,
              text TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
        }
      },
    );
    await _load();
  }

  Future<void> _load() async {
    final db = _db;
    if (db == null) return;

    final rows = await db.query('surah_progress');
    _surahProgress.clear();
    _totalAyahsRead = 0;
    for (final row in rows) {
      final sn = row['surah_number'] as int;
      final ar = row['ayahs_read'] as int;
      final ta = row['total_ayahs'] as int;
      final lr = DateTime.parse(row['last_read'] as String);
      _surahProgress[sn] = ReadProgress(
        surahNumber: sn, ayahsRead: ar, totalAyahs: ta, lastRead: lr,
      );
      _totalAyahsRead += ar;
    }

    // Calculate reading streak
    final days = (await db.query('reading_days', orderBy: 'date DESC'))
        .map((r) => DateTime.parse(r['date'] as String))
        .toList();
    _readingStreak = _calculateStreak(days);

    // Load fasts
    final fastRows = await db.query('fasting_log', orderBy: 'date DESC');
    _fasts.clear();
    for (final row in fastRows) {
      _fasts.add(FastRecord(
        id: row['id'] as int,
        date: DateTime.parse(row['date'] as String),
        type: row['type'] as String,
        notes: row['notes'] as String?,
      ));
    }

    // Load notes
    final noteRows = await db.query('notes', orderBy: 'created_at DESC');
    _notes.clear();
    for (final row in noteRows) {
      _notes.add(NoteRecord(
        id: row['id'] as int,
        surahNumber: row['surah_number'] as int,
        ayahNumber: row['ayah_number'] as int,
        text: row['text'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
      ));
    }

    notifyListeners();
  }

  int _calculateStreak(List<DateTime> days) {
    if (days.isEmpty) return 0;
    final today = DateTime.now();
    final todayStr = _dateStr(today);
    int streak = 0;
    DateTime cursor = today;

    for (final d in days) {
      final dStr = _dateStr(d);
      final cursorStr = _dateStr(cursor);
      if (dStr == cursorStr || dStr == todayStr) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  String _dateStr(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  Future<void> markSurahRead(int surahNumber, int totalAyahs) async {
    final db = _db;
    if (db == null) return;
    final now = DateTime.now();
    final existing = _surahProgress[surahNumber];
    final newCount = existing != null ? totalAyahs : totalAyahs;

    await db.insert(
      'surah_progress',
      {
        'surah_number': surahNumber,
        'ayahs_read': newCount,
        'total_ayahs': totalAyahs,
        'last_read': now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Mark today as a reading day
    await db.insert('reading_days', {'date': _dateStr(now)},
        conflictAlgorithm: ConflictAlgorithm.ignore);

    await _load();
  }

  Future<void> updateSurahProgress(int surahNumber, int ayahsRead, int totalAyahs) async {
    final db = _db;
    if (db == null) return;
    final now = DateTime.now();
    final existing = _surahProgress[surahNumber];
    // Only update if reading more
    final best = existing != null && existing.ayahsRead > ayahsRead ? existing.ayahsRead : ayahsRead;

    await db.insert(
      'surah_progress',
      {
        'surah_number': surahNumber,
        'ayahs_read': best,
        'total_ayahs': totalAyahs,
        'last_read': now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert('reading_days', {'date': _dateStr(now)},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await _load();
  }

  // Records today as an active day (call on app open)
  Future<void> recordAppOpen() async {
    final db = _db;
    if (db == null) return;
    final today = _dateStr(DateTime.now());
    final existing = await db.query('reading_days', where: 'date = ?', whereArgs: [today]);
    if (existing.isNotEmpty) return; // Already recorded today
    await db.insert('reading_days', {'date': today}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await _load();
  }

  Future<void> resetProgress() async {
    final db = _db;
    if (db == null) return;
    await db.delete('surah_progress');
    await db.delete('reading_days');
    await _load();
  }

  // ── Fasting ──

  Future<void> logFast({required DateTime date, required String type, String? notes}) async {
    final db = _db;
    if (db == null) return;
    await db.insert(
      'fasting_log',
      {'date': _dateStr(date), 'type': type, 'notes': notes},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _load();
  }

  Future<void> deleteFast(int id) async {
    await _db?.delete('fasting_log', where: 'id = ?', whereArgs: [id]);
    await _load();
  }

  bool hasFasted(DateTime date) {
    final ds = _dateStr(date);
    return _fasts.any((f) => _dateStr(f.date) == ds);
  }

  int get fastingStreak {
    if (_fasts.isEmpty) return 0;
    final sorted = [..._fasts]..sort((a, b) => b.date.compareTo(a.date));
    int streak = 0;
    DateTime cursor = DateTime.now();
    for (final f in sorted) {
      final diff = cursor.difference(f.date).inDays;
      if (diff <= 1) {
        streak++;
        cursor = f.date.subtract(const Duration(days: 1));
      } else { break; }
    }
    return streak;
  }

  int get totalFasts => _fasts.length;

  // ── Notes ──

  NoteRecord? getNoteForAyah(int surahNumber, int ayahNumber) {
    try {
      return _notes.firstWhere(
        (n) => n.surahNumber == surahNumber && n.ayahNumber == ayahNumber,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveNote(int surahNumber, int ayahNumber, String text) async {
    final db = _db;
    if (db == null) return;
    final existing = getNoteForAyah(surahNumber, ayahNumber);
    if (existing != null) {
      await db.update(
        'notes',
        {'text': text, 'created_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    } else {
      await db.insert('notes', {
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
        'text': text,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    await _load();
  }

  Future<void> deleteNote(int id) async {
    await _db?.delete('notes', where: 'id = ?', whereArgs: [id]);
    await _load();
  }
}

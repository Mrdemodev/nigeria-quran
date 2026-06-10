import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bookmark_model.dart';

class BookmarkProvider extends ChangeNotifier {
  Database? _db;
  List<BookmarkModel> _bookmarks = [];

  List<BookmarkModel> get bookmarks => _bookmarks;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'quran_bookmarks.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE bookmarks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            surah_number INTEGER NOT NULL,
            ayah_number INTEGER NOT NULL,
            surah_name TEXT NOT NULL,
            ayah_text TEXT NOT NULL,
            note TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },
      version: 1,
    );
    await _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final maps = await _db!.query('bookmarks', orderBy: 'created_at DESC');
    _bookmarks = maps.map((m) => BookmarkModel.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addBookmark({
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    required String ayahText,
    String? note,
  }) async {
    final bookmark = BookmarkModel(
      id: 0,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      surahName: surahName,
      ayahText: ayahText,
      note: note,
      createdAt: DateTime.now(),
    );
    await _db!.insert('bookmarks', bookmark.toMap());
    await _loadBookmarks();
  }

  Future<void> removeBookmark(int id) async {
    await _db!.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
    await _loadBookmarks();
  }

  bool isBookmarked(int surahNumber, int ayahNumber) {
    return _bookmarks.any(
      (b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber,
    );
  }

  BookmarkModel? getBookmark(int surahNumber, int ayahNumber) {
    try {
      return _bookmarks.firstWhere(
        (b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _db!.delete('bookmarks');
    _bookmarks = [];
    notifyListeners();
  }
}

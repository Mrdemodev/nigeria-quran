class BookmarkModel {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String ayahText;
  final String? note;
  final DateTime createdAt;

  const BookmarkModel({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.ayahText,
    this.note,
    required this.createdAt,
  });

  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      id: map['id'] as int,
      surahNumber: map['surah_number'] as int,
      ayahNumber: map['ayah_number'] as int,
      surahName: map['surah_name'] as String,
      ayahText: map['ayah_text'] as String,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'surah_name': surahName,
      'ayah_text': ayahText,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

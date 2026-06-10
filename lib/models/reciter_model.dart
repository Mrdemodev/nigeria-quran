class ReciterModel {
  final String id;
  final String name;
  final String arabicName;
  final String origin;
  final String description;
  final String cdnIdentifier;
  final bool isFeatured;
  /// If set, overrides the quranicaudio.com CDN base.
  /// Full URL will be: $audioBaseUrl/${surah_3digit}.mp3
  final String? audioBaseUrl;
  /// everyayah.com folder name for per-ayah audio (enables exact highlighting).
  /// URL: https://everyayah.com/data/$everyAyahPath/${surah_3digit}${ayah_3digit}.mp3
  final String? everyAyahPath;

  const ReciterModel({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.origin,
    required this.description,
    required this.cdnIdentifier,
    this.isFeatured = false,
    this.audioBaseUrl,
    this.everyAyahPath,
  });

  String audioUrl(int surahNumber) {
    final padded = surahNumber.toString().padLeft(3, '0');
    if (audioBaseUrl != null) return '$audioBaseUrl/$padded.mp3';
    return 'https://download.quranicaudio.com/quran/$cdnIdentifier/$padded.mp3';
  }

  String perAyahAudioUrl(int surahNumber, int ayahNumber) {
    final surah = surahNumber.toString().padLeft(3, '0');
    final ayah = ayahNumber.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$everyAyahPath/$surah$ayah.mp3';
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name.isNotEmpty ? name[0] : 'R';
  }
}

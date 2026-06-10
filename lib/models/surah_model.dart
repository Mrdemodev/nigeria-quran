class SurahModel {
  final int number;
  final String nameAr;
  final String nameEn;
  final String meaning;
  final int ayahCount;
  final String type;

  const SurahModel({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.meaning,
    required this.ayahCount,
    required this.type,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: json['number'] as int,
      nameAr: json['nameAr'] as String,
      nameEn: json['nameEn'] as String,
      meaning: json['meaning'] as String,
      ayahCount: (json['ayahCount'] as int?) ?? 0,
      type: json['type'] as String,
    );
  }

  bool get isMeccan => type == 'Meccan';
}

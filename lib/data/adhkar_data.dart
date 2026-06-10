class DhikrItem {
  final String arabic;
  final String transliteration;
  final String english;
  final String hausa;
  final int defaultCount;
  final String? category;

  const DhikrItem({
    required this.arabic,
    required this.transliteration,
    required this.english,
    required this.hausa,
    this.defaultCount = 33,
    this.category,
  });
}

const List<DhikrItem> kMorningAdhkar = [
  DhikrItem(
    arabic: 'سُبْحَانَ اللَّهِ',
    transliteration: 'Subhaan Allah',
    english: 'Glory be to Allah',
    hausa: 'Tsarki ya tabbata ga Allah',
    defaultCount: 33,
    category: 'morning',
  ),
  DhikrItem(
    arabic: 'الْحَمْدُ لِلَّهِ',
    transliteration: 'Alhamdulillah',
    english: 'All praise is due to Allah',
    hausa: 'Dukkan yabo na Allah',
    defaultCount: 33,
    category: 'morning',
  ),
  DhikrItem(
    arabic: 'اللَّهُ أَكْبَرُ',
    transliteration: 'Allahu Akbar',
    english: 'Allah is the Greatest',
    hausa: 'Allah ya fi girma',
    defaultCount: 34,
    category: 'morning',
  ),
  DhikrItem(
    arabic: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    transliteration: 'La ilaha illallahu wahdahu la sharika lah, lahul mulku walahul hamdu wahuwa ala kulli shay\'in qadir',
    english: 'There is no deity except Allah alone, with no partner. To Him belongs the dominion and to Him belongs all praise, and He is over all things Capable.',
    hausa: 'Babu abin bauta sai Allah shi kaɗai, babu abokin tarayya da shi...',
    defaultCount: 100,
    category: 'morning',
  ),
];

const List<DhikrItem> kEveningAdhkar = [
  DhikrItem(
    arabic: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
    transliteration: 'A\'udhu billahi minash shaytanir rajim',
    english: 'I seek refuge in Allah from the outcast Shaytan',
    hausa: 'Ina neman tsari daga Allah daga shaidan mai korarwa',
    defaultCount: 1,
    category: 'evening',
  ),
  DhikrItem(
    arabic: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
    transliteration: 'Bismillahir Rahmanir Rahim',
    english: 'In the name of Allah, the Most Gracious, the Most Merciful',
    hausa: 'Da sunan Allah, Mai rahama, Mai jin kai',
    defaultCount: 1,
    category: 'evening',
  ),
  DhikrItem(
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    transliteration: 'Subhaan Allahi wa bihamdih',
    english: 'Glory and praise be to Allah',
    hausa: 'Tsarki da yabo ya tabbata ga Allah',
    defaultCount: 100,
    category: 'evening',
  ),
];

const List<DhikrItem> kGeneralDhikr = [
  DhikrItem(
    arabic: 'سُبْحَانَ اللَّهِ',
    transliteration: 'SubhanAllah',
    english: 'Glory be to Allah',
    hausa: 'Tsarki ya tabbata ga Allah',
    defaultCount: 33,
  ),
  DhikrItem(
    arabic: 'الْحَمْدُ لِلَّهِ',
    transliteration: 'Alhamdulillah',
    english: 'Praise be to Allah',
    hausa: 'Godiya ta tabbata ga Allah',
    defaultCount: 33,
  ),
  DhikrItem(
    arabic: 'اللَّهُ أَكْبَرُ',
    transliteration: 'Allahu Akbar',
    english: 'Allah is the Greatest',
    hausa: 'Allah ya fi girma',
    defaultCount: 34,
  ),
  DhikrItem(
    arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    transliteration: 'La hawla wa la quwwata illa billah',
    english: 'There is no power and no strength except with Allah',
    hausa: 'Babu ƙarfi kuma babu iko sai da Allah',
    defaultCount: 10,
  ),
  DhikrItem(
    arabic: 'أَسْتَغْفِرُ اللَّهَ',
    transliteration: 'Astaghfirullah',
    english: 'I seek forgiveness from Allah',
    hausa: 'Ina neman gafara daga Allah',
    defaultCount: 100,
  ),
  DhikrItem(
    arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
    transliteration: 'Allahumma salli ala Muhammad',
    english: 'O Allah, send blessings upon Muhammad',
    hausa: 'Ya Allah ka yi salati ga Annabi Muhammad',
    defaultCount: 10,
  ),
];

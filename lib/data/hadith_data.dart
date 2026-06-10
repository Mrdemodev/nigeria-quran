class HadithModel {
  final String category;
  final String arabic;
  final String translation;
  final String narrator;
  final String source;
  const HadithModel({
    required this.category,
    required this.arabic,
    required this.translation,
    required this.narrator,
    required this.source,
  });
}

const List<HadithModel> kHadiths = [
  // ── Faith (Iman) ──────────────────────────────────────
  HadithModel(
    category: 'Faith',
    arabic: 'الْإِيمَانُ أَنْ تُؤْمِنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ وَالْيَوْمِ الْآخِرِ وَتُؤْمِنَ بِالْقَدَرِ خَيْرِهِ وَشَرِّهِ',
    translation: 'Faith is to believe in Allah, His angels, His books, His messengers, the Last Day, and to believe in divine decree — both its good and its bad.',
    narrator: 'Umar ibn al-Khattab (رضي الله عنه)',
    source: 'Muslim 8',
  ),
  HadithModel(
    category: 'Faith',
    arabic: 'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
    translation: 'None of you truly believes until he loves for his brother what he loves for himself.',
    narrator: 'Anas ibn Malik (رضي الله عنه)',
    source: 'Bukhari 13 · Muslim 45',
  ),
  HadithModel(
    category: 'Faith',
    arabic: 'مَنْ كَانَ آخِرُ كَلَامِهِ لَا إِلَهَ إِلَّا اللَّهُ دَخَلَ الْجَنَّةَ',
    translation: 'Whoever\'s last words are "La ilaha illallah" will enter Paradise.',
    narrator: 'Mu\'adh ibn Jabal (رضي الله عنه)',
    source: 'Abu Dawud 3116',
  ),
  // ── Prayer ────────────────────────────────────────────
  HadithModel(
    category: 'Prayer',
    arabic: 'الصَّلَاةُ عِمَادُ الدِّينِ فَمَنْ أَقَامَهَا فَقَدْ أَقَامَ الدِّينَ وَمَنْ هَدَمَهَا فَقَدْ هَدَمَ الدِّينَ',
    translation: 'Prayer is the pillar of the religion. Whoever establishes it has established the religion, and whoever destroys it has destroyed the religion.',
    narrator: 'Mu\'adh ibn Jabal (رضي الله عنه)',
    source: 'Bayhaqi',
  ),
  HadithModel(
    category: 'Prayer',
    arabic: 'أَقْرَبُ مَا يَكُونُ الْعَبْدُ مِنْ رَبِّهِ وَهُوَ سَاجِدٌ',
    translation: 'The closest a servant comes to his Lord is when he is in prostration (sujood).',
    narrator: 'Abu Hurayrah (رضي الله عنه)',
    source: 'Muslim 482',
  ),
  HadithModel(
    category: 'Prayer',
    arabic: 'صَلِّ قَائِماً فَإِنْ لَمْ تَسْتَطِعْ فَقَاعِداً فَإِنْ لَمْ تَسْتَطِعْ فَعَلَى جَنْبٍ',
    translation: 'Pray standing; if you are unable, then sitting; if you are unable, then on your side.',
    narrator: 'Imran ibn Husayn (رضي الله عنه)',
    source: 'Bukhari 1117',
  ),
  // ── Quran ─────────────────────────────────────────────
  HadithModel(
    category: 'Quran',
    arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
    translation: 'The best of you are those who learn the Quran and teach it.',
    narrator: 'Uthman ibn Affan (رضي الله عنه)',
    source: 'Bukhari 5027',
  ),
  HadithModel(
    category: 'Quran',
    arabic: 'اقْرَءُوا الْقُرْآنَ فَإِنَّهُ يَأْتِي يَوْمَ الْقِيَامَةِ شَفِيعاً لِأَصْحَابِهِ',
    translation: 'Recite the Quran, for it will come on the Day of Resurrection as an intercessor for its companions.',
    narrator: 'Abu Umamah (رضي الله عنه)',
    source: 'Muslim 804',
  ),
  HadithModel(
    category: 'Quran',
    arabic: 'الَّذِي يَقْرَأُ الْقُرْآنَ وَهُوَ مَاهِرٌ بِهِ مَعَ السَّفَرَةِ الْكِرَامِ الْبَرَرَةِ وَالَّذِي يَقْرَأُ الْقُرْآنَ وَيَتَتَعْتَعُ فِيهِ وَهُوَ عَلَيْهِ شَاقٌّ لَهُ أَجْرَانِ',
    translation: 'The one who is skilled in reciting the Quran is with the noble and obedient angels. And the one who recites with difficulty, stumbling through it, will have TWO rewards.',
    narrator: 'Aisha (رضي الله عنها)',
    source: 'Bukhari 4937 · Muslim 798',
  ),
  // ── Character ─────────────────────────────────────────
  HadithModel(
    category: 'Character',
    arabic: 'إِنَّمَا بُعِثْتُ لِأُتَمِّمَ صَالِحَ الْأَخْلَاقِ',
    translation: 'I was sent only to perfect good character.',
    narrator: 'Abu Hurayrah (رضي الله عنه)',
    source: 'Ahmad 8952',
  ),
  HadithModel(
    category: 'Character',
    arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْراً أَوْ لِيَصْمُتْ',
    translation: 'Whoever believes in Allah and the Last Day, let him speak good or remain silent.',
    narrator: 'Abu Hurayrah (رضي الله عنه)',
    source: 'Bukhari 6018 · Muslim 47',
  ),
  HadithModel(
    category: 'Character',
    arabic: 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
    translation: 'A Muslim is the one from whose tongue and hands other Muslims are safe.',
    narrator: 'Abdullah ibn Amr (رضي الله عنه)',
    source: 'Bukhari 10',
  ),
  // ── Knowledge ─────────────────────────────────────────
  HadithModel(
    category: 'Knowledge',
    arabic: 'طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ',
    translation: 'Seeking knowledge is an obligation upon every Muslim.',
    narrator: 'Anas ibn Malik (رضي الله عنه)',
    source: 'Ibn Majah 224',
  ),
  HadithModel(
    category: 'Knowledge',
    arabic: 'مَنْ سَلَكَ طَرِيقاً يَلْتَمِسُ فِيهِ عِلْماً سَهَّلَ اللَّهُ لَهُ طَرِيقاً إِلَى الْجَنَّةِ',
    translation: 'Whoever travels a path seeking knowledge, Allah will ease for him a path to Paradise.',
    narrator: 'Abu Hurayrah (رضي الله عنه)',
    source: 'Muslim 2699',
  ),
  // ── Charity ───────────────────────────────────────────
  HadithModel(
    category: 'Charity',
    arabic: 'مَا نَقَصَتْ صَدَقَةٌ مِنْ مَالٍ',
    translation: 'Charity never decreases wealth.',
    narrator: 'Abu Hurayrah (رضي الله عنه)',
    source: 'Muslim 2588',
  ),
  HadithModel(
    category: 'Charity',
    arabic: 'اتَّقُوا النَّارَ وَلَوْ بِشِقِّ تَمْرَةٍ',
    translation: 'Protect yourself from the Fire even if it is with half a date (in charity).',
    narrator: 'Adiyy ibn Hatim (رضي الله عنه)',
    source: 'Bukhari 1413',
  ),
  // ── Family ────────────────────────────────────────────
  HadithModel(
    category: 'Family',
    arabic: 'خَيْرُكُمْ خَيْرُكُمْ لِأَهْلِهِ وَأَنَا خَيْرُكُمْ لِأَهْلِي',
    translation: 'The best of you are those who are best to their family, and I am the best of you to my family.',
    narrator: 'Aisha (رضي الله عنها)',
    source: 'Tirmidhi 3895',
  ),
  HadithModel(
    category: 'Family',
    arabic: 'الْجَنَّةُ تَحْتَ أَقْدَامِ الْأُمَّهَاتِ',
    translation: 'Paradise lies beneath the feet of mothers.',
    narrator: 'Various',
    source: 'Ahmad & Nasa\'i',
  ),
];

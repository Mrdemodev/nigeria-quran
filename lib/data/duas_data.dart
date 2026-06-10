class DuaModel {
  final String category;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;
  const DuaModel({
    required this.category,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
  });
}

const List<DuaModel> kDuas = [
  // ── Morning ──────────────────────────────────────────────────────────
  DuaModel(
    category: 'Morning',
    title: 'Waking Up',
    arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
    transliteration: 'Alhamdu lillahil-ladhi ahyana ba\'da ma amatana wa-ilayhin-nushur',
    translation: 'All praise is for Allah who gave us life after death and to Him is the resurrection.',
    reference: 'Bukhari 6312',
  ),
  DuaModel(
    category: 'Morning',
    title: 'Morning Remembrance',
    arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    transliteration: 'Asbahna wa asbahal mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la sharika lah',
    translation: 'We have reached the morning and at this very time the whole kingdom belongs to Allah. All praise is for Allah. There is none worthy of worship except Allah, alone without partner.',
    reference: 'Abu Dawud 5078',
  ),
  DuaModel(
    category: 'Morning',
    title: 'Morning Dua',
    arabic: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
    transliteration: 'Allahumma bika asbahna wa bika amsayna wa bika nahya wa bika namutu wa ilaykan-nushur',
    translation: 'O Allah, by You we have entered the morning, by You we enter the evening, by You we live and by You we die, and to You is the resurrection.',
    reference: 'Tirmidhi 3391',
  ),
  // ── Evening ───────────────────────────────────────────────────────────
  DuaModel(
    category: 'Evening',
    title: 'Evening Remembrance',
    arabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    transliteration: 'Amsayna wa amsal mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la sharika lah',
    translation: 'We have reached the evening and at this very time the whole kingdom belongs to Allah. All praise is for Allah.',
    reference: 'Abu Dawud 5078',
  ),
  DuaModel(
    category: 'Evening',
    title: 'Protection at Evening',
    arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
    transliteration: 'A\'udhu bikalimAtillahit-tammati min sharri ma khalaq',
    translation: 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
    reference: 'Muslim 2709',
  ),
  DuaModel(
    category: 'Evening',
    title: 'Before Sleep',
    arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    transliteration: 'Bismika Allahumma amutu wa ahya',
    translation: 'In Your name, O Allah, I die and I live.',
    reference: 'Bukhari 6324',
  ),
  // ── After Prayer ─────────────────────────────────────────────────────
  DuaModel(
    category: 'After Prayer',
    title: 'Seeking Forgiveness',
    arabic: 'أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ',
    transliteration: 'Astaghfirullah, Astaghfirullah, Astaghfirullah',
    translation: 'I seek forgiveness from Allah (×3).',
    reference: 'Muslim 591',
  ),
  DuaModel(
    category: 'After Prayer',
    title: 'Salam of Allah',
    arabic: 'اللَّهُمَّ أَنْتَ السَّلَامُ، وَمِنْكَ السَّلَامُ، تَبَارَكْتَ ذَا الْجَلَالِ وَالْإِكْرَامِ',
    transliteration: 'Allahumma antas-salam wa minkas-salam, tabarakta zal-jalali wal-ikram',
    translation: 'O Allah, You are Peace and from You comes peace. Blessed are You, O Owner of Glory and Honour.',
    reference: 'Muslim 592',
  ),
  DuaModel(
    category: 'After Prayer',
    title: 'Tasbih After Salah',
    arabic: 'سُبْحَانَ اللَّهِ (٣٣) الْحَمْدُ لِلَّهِ (٣٣) اللَّهُ أَكْبَرُ (٣٣)',
    transliteration: 'Subhanallah (33) · Alhamdulillah (33) · Allahu Akbar (33)',
    translation: 'Glory be to Allah (33) · Praise be to Allah (33) · Allah is the Greatest (33)',
    reference: 'Muslim 597',
  ),
  // ── Travel ───────────────────────────────────────────────────────────
  DuaModel(
    category: 'Travel',
    title: 'Journey Dua',
    arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
    transliteration: 'Subhanal-ladhi sakhkhara lana hadha wa ma kunna lahu muqrinin, wa inna ila rabbina lamunqalibun',
    translation: 'Glory be to Him who has subjected this to us, for we were unable to do it ourselves. And indeed, to our Lord we are returning.',
    reference: 'Quran 43:13-14',
  ),
  DuaModel(
    category: 'Travel',
    title: 'Entering a Vehicle',
    arabic: 'بِسْمِ اللَّهِ، الْحَمْدُ لِلَّهِ، سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا',
    transliteration: 'Bismillah, alhamdulillah, subhanal-ladhi sakhkhara lana hadha',
    translation: 'In the name of Allah. Praise be to Allah. Glory be to Him who has subjected this to us.',
    reference: 'Tirmidhi 3446',
  ),
  // ── Food ─────────────────────────────────────────────────────────────
  DuaModel(
    category: 'Food',
    title: 'Before Eating',
    arabic: 'بِسْمِ اللَّهِ',
    transliteration: 'Bismillah',
    translation: 'In the name of Allah.',
    reference: 'Abu Dawud 3767',
  ),
  DuaModel(
    category: 'Food',
    title: 'After Eating',
    arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
    transliteration: 'Alhamdu lillahil-ladhi at\'amana wa saqana wa ja\'alana muslimin',
    translation: 'Praise be to Allah who fed us and gave us drink and made us Muslims.',
    reference: 'Abu Dawud 3850',
  ),
  // ── General ──────────────────────────────────────────────────────────
  DuaModel(
    category: 'General',
    title: 'Entering Home',
    arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ',
    transliteration: 'Allahumma inni as\'aluka khayral-mawliji wa khayral-makhraji',
    translation: 'O Allah, I ask You for the good of entering and the good of leaving.',
    reference: 'Abu Dawud 5096',
  ),
  DuaModel(
    category: 'General',
    title: 'Leaving Home',
    arabic: 'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    transliteration: 'Bismillah, tawakkaltu \'alallah, wa la hawla wa la quwwata illa billah',
    translation: 'In the name of Allah, I put my trust in Allah, and there is no power or might except with Allah.',
    reference: 'Tirmidhi 3426',
  ),
  DuaModel(
    category: 'General',
    title: 'Entering Mosque',
    arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
    transliteration: 'Allahumm-aftah li abwaba rahmatik',
    translation: 'O Allah, open for me the gates of Your mercy.',
    reference: 'Muslim 713',
  ),
  DuaModel(
    category: 'General',
    title: 'Leaving Mosque',
    arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
    transliteration: 'Allahumma inni as\'aluka min fadlik',
    translation: 'O Allah, I ask You from Your bounty.',
    reference: 'Muslim 713',
  ),
  DuaModel(
    category: 'General',
    title: 'Protection from Evil',
    arabic: 'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
    transliteration: 'Hasbiyallahu la ilaha illa huwa \'alayhi tawakkaltu wa huwa rabbul-\'arshil-\'azim',
    translation: 'Allah is sufficient for me. There is no god but Him. I have put my trust in Him, and He is the Lord of the Magnificent Throne.',
    reference: 'Quran 9:129',
  ),
  // ── Sickness ─────────────────────────────────────────────────────────
  DuaModel(
    category: 'Sickness',
    title: 'When Ill',
    arabic: 'اللَّهُمَّ رَبَّ النَّاسِ، أَذْهِبِ الْبَأْسَ، اشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ',
    transliteration: 'Allahumma rabban-nas, adhhibil-ba\'sa, ishfi antash-shafi, la shifa\'a illa shifa\'uk',
    translation: 'O Allah, Lord of mankind, remove the harm and cure him/her. You are the Curer and there is no cure except Your cure.',
    reference: 'Bukhari 5743',
  ),
  DuaModel(
    category: 'Sickness',
    title: 'Visiting the Sick',
    arabic: 'لَا بَأْسَ طَهُورٌ إِنْ شَاءَ اللَّهُ',
    transliteration: 'La ba\'sa tahurun insha\'Allah',
    translation: 'Do not worry, it is a purification, Allah willing.',
    reference: 'Bukhari 3616',
  ),
];

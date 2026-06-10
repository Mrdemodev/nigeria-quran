class TajweedRule {
  final String category;
  final String name;
  final String arabicName;
  final String arabicLetters;
  final String arabicExample;
  final String exampleTranslation;
  final String explanation;
  final int colorHex;
  // Surah & ayah for audio example (Al-Husary via everyayah.com)
  final int? audioSurah;
  final int? audioAyah;
  const TajweedRule({
    required this.category,
    required this.name,
    required this.arabicName,
    required this.arabicLetters,
    required this.arabicExample,
    required this.exampleTranslation,
    required this.explanation,
    required this.colorHex,
    this.audioSurah,
    this.audioAyah,
  });

  String? get audioUrl {
    if (audioSurah == null || audioAyah == null) return null;
    final s = audioSurah!.toString().padLeft(3, '0');
    final a = audioAyah!.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/Husary_64kbps/$s$a.mp3';
  }
}

const List<TajweedRule> kTajweedRules = [
  // ── Noon Sakinah ──────────────────────────────────────
  TajweedRule(
    category: 'Noon Sakinah',
    name: 'Izhar (Clear)',
    arabicName: 'إظهار',
    arabicLetters: 'أ ه ع ح غ خ',
    arabicExample: 'مِنْ هَادٍ',
    exampleTranslation: 'from a guide (Ar-Ra\'d 7)',
    explanation: 'Pronounce Noon clearly without merging or hiding when followed by one of the six throat letters (ء ه ع ح غ خ). The sound of Noon must be fully heard.',
    colorHex: 0xFF1565C0,
    audioSurah: 13, audioAyah: 7,
  ),
  TajweedRule(
    category: 'Noon Sakinah',
    name: 'Idgham with Ghunnah',
    arabicName: 'إدغام بغنة',
    arabicLetters: 'ي ن م و',
    arabicExample: 'مَنْ يَعْمَلْ',
    exampleTranslation: 'whoever does (Az-Zalzalah 7)',
    explanation: 'Merge the Noon into the following letter with a nasal sound (Ghunnah) of 2 counts. Letters: ي ن م و. This occurs only when the Noon is at the END of a word.',
    colorHex: 0xFF2E7D32,
    audioSurah: 99, audioAyah: 7,
  ),
  TajweedRule(
    category: 'Noon Sakinah',
    name: 'Idgham without Ghunnah',
    arabicName: 'إدغام بلا غنة',
    arabicLetters: 'ل ر',
    arabicExample: 'مِنْ رَبِّهِمْ',
    exampleTranslation: 'from their Lord (Al-Baqarah 5)',
    explanation: 'Merge the Noon completely into ل or ر with NO nasal sound. The Noon disappears entirely into the following letter.',
    colorHex: 0xFF00695C,
    audioSurah: 2, audioAyah: 5,
  ),
  TajweedRule(
    category: 'Noon Sakinah',
    name: 'Iqlab (Convert)',
    arabicName: 'إقلاب',
    arabicLetters: 'ب',
    arabicExample: 'مِنْ بَعْدِ',
    exampleTranslation: 'after (Al-Baqarah 27)',
    explanation: 'Convert the Noon into a Meem sound with Ghunnah of 2 counts when followed by ب. The Noon becomes a nasal Meem without touching lips fully.',
    colorHex: 0xFFE65100,
    audioSurah: 2, audioAyah: 27,
  ),
  TajweedRule(
    category: 'Noon Sakinah',
    name: 'Ikhfa (Hide)',
    arabicName: 'إخفاء',
    arabicLetters: 'ت ث ج د ذ ز س ش ص ض ط ظ ف ق ك',
    arabicExample: 'إِنْ كُنْتُمْ',
    exampleTranslation: 'if you are (Al-Baqarah 23)',
    explanation: 'Hide the Noon between clear pronunciation and complete merging. Produce a nasal sound (Ghunnah) for 2 counts. The tongue does NOT fully touch its makhraj for Noon.',
    colorHex: 0xFF6A1B9A,
    audioSurah: 2, audioAyah: 23,
  ),

  // ── Meem Sakinah ──────────────────────────────────────
  TajweedRule(
    category: 'Meem Sakinah',
    name: 'Ikhfa Shafawi',
    arabicName: 'إخفاء شفوي',
    arabicLetters: 'ب',
    arabicExample: 'هُمْ بِالْآخِرَةِ',
    exampleTranslation: 'they in the Hereafter (Al-Baqarah 4)',
    explanation: 'When a Meem Sakinah is followed by ب, hide the Meem with a nasal sound (Ghunnah) for 2 counts while lips remain slightly open.',
    colorHex: 0xFFBF360C,
    audioSurah: 2, audioAyah: 4,
  ),
  TajweedRule(
    category: 'Meem Sakinah',
    name: 'Idgham Shafawi',
    arabicName: 'إدغام شفوي',
    arabicLetters: 'م',
    arabicExample: 'لَهُمْ مَا',
    exampleTranslation: 'for them what (An-Nahl 31)',
    explanation: 'When Meem Sakinah is followed by another Meem, merge them into one heavy Meem with Ghunnah of 2 counts. Only one Meem is heard.',
    colorHex: 0xFF4A148C,
    audioSurah: 16, audioAyah: 31,
  ),
  TajweedRule(
    category: 'Meem Sakinah',
    name: 'Izhar Shafawi',
    arabicName: 'إظهار شفوي',
    arabicLetters: 'All except ب and م',
    arabicExample: 'أَنْعَمْتَ عَلَيْهِمْ',
    exampleTranslation: 'You have bestowed upon them (Al-Fatihah 7)',
    explanation: 'When Meem Sakinah is followed by any letter OTHER than ب or م, pronounce the Meem clearly without merging or ghunnah.',
    colorHex: 0xFF1565C0,
    audioSurah: 1, audioAyah: 7,
  ),

  // ── Madd (Prolongation) ───────────────────────────────
  TajweedRule(
    category: 'Madd',
    name: 'Madd Tabee\'i (Natural)',
    arabicName: 'مد طبيعي',
    arabicLetters: 'ا و ي',
    arabicExample: 'قَالَ — نُوحٌ — فِي',
    exampleTranslation: 'said / Nuh / in',
    explanation: 'The natural elongation of 2 counts (harakaat). Occurs when a Madd letter (ا و ي) is not followed by Hamza or Sukoon. It is the foundation of all Madd rules.',
    colorHex: 0xFF0277BD,
    audioSurah: 2, audioAyah: 30,
  ),
  TajweedRule(
    category: 'Madd',
    name: 'Madd Wajib Mutasil',
    arabicName: 'مد واجب متصل',
    arabicLetters: 'ء after ا و ي (same word)',
    arabicExample: 'جَاءَ — السَّمَاءَ',
    exampleTranslation: 'he came / the sky',
    explanation: 'When a Madd letter and Hamza occur in THE SAME word, elongate for 4-5 counts (obligatory). This is the strongest of the connected Madd types.',
    colorHex: 0xFF006064,
    audioSurah: 2, audioAyah: 22,
  ),
  TajweedRule(
    category: 'Madd',
    name: 'Madd Jaiz Munfasil',
    arabicName: 'مد جائز منفصل',
    arabicLetters: 'ء in following word',
    arabicExample: 'إِنَّا أَنْزَلْنَا',
    exampleTranslation: 'Indeed We sent down (Al-Qadr 1)',
    explanation: 'When a Madd letter ends a word and the NEXT word begins with Hamza, elongate 2-5 counts. Permissible — the reciter may choose length (with consistency).',
    colorHex: 0xFF4527A0,
    audioSurah: 97, audioAyah: 1,
  ),
  TajweedRule(
    category: 'Madd',
    name: 'Madd \'Aarid Lissukoon',
    arabicName: 'مد عارض للسكون',
    arabicLetters: 'Stopping at end of verse',
    arabicExample: 'نَسْتَعِينُ',
    exampleTranslation: 'we seek help (Al-Fatihah 5)',
    explanation: 'When you stop at a word ending with a Madd letter followed by a voweled letter, elongate 2, 4, or 6 counts. This Madd only applies when STOPPING.',
    colorHex: 0xFF558B2F,
    audioSurah: 1, audioAyah: 5,
  ),

  // ── Ghunnah ───────────────────────────────────────────
  TajweedRule(
    category: 'Ghunnah',
    name: 'Ghunnah (Nasal Sound)',
    arabicName: 'غنة',
    arabicLetters: 'ن م (with shaddah)',
    arabicExample: 'إِنَّ — ثُمَّ',
    exampleTranslation: 'Indeed / Then',
    explanation: 'A nasal resonance produced from the nose lasting 2 counts. Ghunnah is intrinsic to Noon and Meem. It is heaviest with shaddah and present in Idgham, Ikhfa and Iqlab.',
    colorHex: 0xFFC62828,
    audioSurah: 2, audioAyah: 6,
  ),
  TajweedRule(
    category: 'Ghunnah',
    name: 'Ghunnah Levels',
    arabicName: 'مراتب الغنة',
    arabicLetters: 'ن م',
    arabicExample: 'إِنَّ → أَنْعَمْ → مِنْ هَادٍ',
    exampleTranslation: 'Levels: highest → middle → none',
    explanation: 'Level 1 (highest): Noon/Meem with shaddah. Level 2: Ikhfa & Iqlab & Ikhfa Shafawi. Level 3: Idgham with Ghunnah. Level 4 (none): Izhar & Izhar Shafawi.',
    colorHex: 0xFFAD1457,
    audioSurah: 1, audioAyah: 1,
  ),

  // ── Qalqalah ──────────────────────────────────────────
  TajweedRule(
    category: 'Qalqalah',
    name: 'Qalqalah Sughra (Minor)',
    arabicName: 'قلقلة صغرى',
    arabicLetters: 'ق ط ب ج د',
    arabicExample: 'يَقْطَعُونَ',
    exampleTranslation: 'they sever (Al-Baqarah 27)',
    explanation: 'A slight echo/bounce on the Qalqalah letter (ق ط ب ج د) when it has a Sukoon in the MIDDLE of speech. The bounce is subtle — the letter echoes softly.',
    colorHex: 0xFFE65100,
    audioSurah: 2, audioAyah: 27,
  ),
  TajweedRule(
    category: 'Qalqalah',
    name: 'Qalqalah Kubra (Major)',
    arabicName: 'قلقلة كبرى',
    arabicLetters: 'ق ط ب ج د (at stop)',
    arabicExample: 'وَمِنْ شَرِّ مَا خَلَقَ',
    exampleTranslation: 'from the evil of what He created (Al-Falaq 2)',
    explanation: 'A strong echo/bounce when STOPPING on a Qalqalah letter at the end of a word. The bounce is much stronger than Sughra — a clear, resonant echo is produced.',
    colorHex: 0xFFBF360C,
    audioSurah: 113, audioAyah: 2,
  ),

  // ── Tafkheem & Tarqeeq ────────────────────────────────
  TajweedRule(
    category: 'Heavy & Light',
    name: 'Tafkheem (Heavy Letters)',
    arabicName: 'تفخيم',
    arabicLetters: 'خ ص ض غ ط ق ظ',
    arabicExample: 'الصِّرَاطَ',
    exampleTranslation: 'the straight path (Al-Fatihah 6)',
    explanation: 'Always pronounce these 7 letters with a full mouth (heavy/thick). Raise the back of the tongue toward the roof of the mouth. Remember: خُصَّ ضَغْطٍ قِظْ',
    colorHex: 0xFF4E342E,
    audioSurah: 1, audioAyah: 6,
  ),
  TajweedRule(
    category: 'Heavy & Light',
    name: 'Tarqeeq (Light Letters)',
    arabicName: 'ترقيق',
    arabicLetters: 'Most Arabic letters',
    arabicExample: 'بِسْمِ اللَّهِ',
    exampleTranslation: 'In the name of Allah (Al-Fatihah 1)',
    explanation: 'Most Arabic letters are pronounced light (thin). Keep the tongue flat and low. Only the 7 Tafkheem letters and occasionally ر and ل are heavy.',
    colorHex: 0xFF37474F,
    audioSurah: 1, audioAyah: 1,
  ),
  TajweedRule(
    category: 'Heavy & Light',
    name: 'Lam in Allah\'s Name',
    arabicName: 'لام الجلالة',
    arabicLetters: 'ل in اللَّه',
    arabicExample: 'بِسْمِ اللَّهِ — لِلَّهِ',
    exampleTranslation: 'Bismillah (heavy) / Lillah (light)',
    explanation: 'The Lam in "Allah" (اللَّه) is heavy (Tafkheem) when preceded by a Fathah or Dammah, and light (Tarqeeq) when preceded by Kasrah. This is a unique rule only for Allah\'s name.',
    colorHex: 0xFF1A237E,
    audioSurah: 1, audioAyah: 1,
  ),

  // ── Waqf & Ibtida ─────────────────────────────────────
  TajweedRule(
    category: 'Stopping & Starting',
    name: 'Waqf Signs',
    arabicName: 'علامات الوقف',
    arabicLetters: 'م — ط — ج — ز — ص',
    arabicExample: 'ۛ وَقَالَتِ ۛيَهُودُ',
    exampleTranslation: 'Signs in mushaf',
    explanation: 'م = Must stop. ط = Absolute stop preferred. ج = Permissible stop. ز = Stopping is better. ص = Continue preferred. لا = Do not stop here. ق = Stopping acceptable but continue better.',
    colorHex: 0xFF004D40,
    audioSurah: 2, audioAyah: 113,
  ),
  TajweedRule(
    category: 'Stopping & Starting',
    name: 'Rules of Stopping',
    arabicName: 'أحكام الوقف',
    arabicLetters: '',
    arabicExample: 'نَسْتَعِينُ → نَسْتَعِين',
    exampleTranslation: 'vowel dropped at stop',
    explanation: 'When stopping mid-recitation: 1) Drop the final vowel (Fathah/Kasrah/Dammah). 2) Apply Madd \'Aarid if applicable. 3) Never stop mid-word. 4) Always start from a complete word.',
    colorHex: 0xFF37474F,
    audioSurah: 1, audioAyah: 5,
  ),
];

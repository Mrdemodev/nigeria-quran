class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String category;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
  });
}

const List<QuizQuestion> kQuizQuestions = [
  QuizQuestion(
    question: 'How many surahs are in the Holy Quran?',
    options: ['112', '113', '114', '116'],
    correctIndex: 2,
    explanation: 'The Holy Quran contains 114 surahs.',
    category: 'Quran',
  ),
  QuizQuestion(
    question: 'Which surah is known as the "Heart of the Quran"?',
    options: ['Al-Fatiha', 'Ya-Sin', 'Al-Baqarah', 'Al-Kahf'],
    correctIndex: 1,
    explanation: 'Ya-Sin (Surah 36) is known as the heart of the Quran.',
    category: 'Quran',
  ),
  QuizQuestion(
    question: 'Which surah has the most ayahs?',
    options: ['Al-Imran', 'An-Nisa', 'Al-Baqarah', 'Al-Anfal'],
    correctIndex: 2,
    explanation: 'Al-Baqarah (Surah 2) has 286 ayahs, the most of any surah.',
    category: 'Quran',
  ),
  QuizQuestion(
    question: 'Which surah is the shortest in the Quran?',
    options: ['Al-Kawthar', 'Al-Asr', 'Al-Ikhlas', 'Al-Falaq'],
    correctIndex: 0,
    explanation: 'Al-Kawthar (Surah 108) has only 3 ayahs.',
    category: 'Quran',
  ),
  QuizQuestion(
    question: 'How many pillars of Islam are there?',
    options: ['3', '4', '5', '6'],
    correctIndex: 2,
    explanation: 'There are 5 pillars: Shahada, Salah, Zakat, Sawm, Hajj.',
    category: 'Pillars',
  ),
  QuizQuestion(
    question: 'What is the first pillar of Islam?',
    options: ['Salah', 'Zakat', 'Shahada', 'Sawm'],
    correctIndex: 2,
    explanation: 'The Shahada (declaration of faith) is the first pillar.',
    category: 'Pillars',
  ),
  QuizQuestion(
    question: 'In which month is fasting (Sawm) obligatory?',
    options: ['Muharram', 'Ramadan', 'Shaban', 'Dhul Hijjah'],
    correctIndex: 1,
    explanation: 'Fasting is obligatory in the month of Ramadan.',
    category: 'Pillars',
  ),
  QuizQuestion(
    question: 'How many times is Salah (prayer) performed daily?',
    options: ['3', '4', '5', '7'],
    correctIndex: 2,
    explanation: 'Muslims pray 5 times daily: Fajr, Dhuhr, Asr, Maghrib, Isha.',
    category: 'Pillars',
  ),
  QuizQuestion(
    question: 'Which prophet built the Kaaba?',
    options: ['Prophet Muhammad (SAW)', 'Prophet Ibrahim (AS)', 'Prophet Ismail (AS)', 'Both Ibrahim and Ismail'],
    correctIndex: 3,
    explanation: 'Both Prophet Ibrahim (AS) and his son Ismail (AS) built the Kaaba.',
    category: 'History',
  ),
  QuizQuestion(
    question: 'In which city was Prophet Muhammad (SAW) born?',
    options: ['Madinah', 'Makkah', 'Jerusalem', 'Ta\'if'],
    correctIndex: 1,
    explanation: 'Prophet Muhammad (SAW) was born in Makkah.',
    category: 'History',
  ),
  QuizQuestion(
    question: 'How many prophets are mentioned by name in the Quran?',
    options: ['20', '25', '30', '40'],
    correctIndex: 1,
    explanation: '25 prophets are mentioned by name in the Quran.',
    category: 'Prophets',
  ),
  QuizQuestion(
    question: 'Which prophet was known as "Khalilullah" (Friend of Allah)?',
    options: ['Prophet Musa (AS)', 'Prophet Isa (AS)', 'Prophet Ibrahim (AS)', 'Prophet Muhammad (SAW)'],
    correctIndex: 2,
    explanation: 'Prophet Ibrahim (AS) was given the title Khalilullah.',
    category: 'Prophets',
  ),
  QuizQuestion(
    question: 'What is the meaning of "Alhamdulillah"?',
    options: ['Allah is Great', 'All praise be to Allah', 'Glory be to Allah', 'There is no god but Allah'],
    correctIndex: 1,
    explanation: '"Alhamdulillah" means "All praise and thanks be to Allah".',
    category: 'Arabic',
  ),
  QuizQuestion(
    question: 'Which angel brought revelation to Prophet Muhammad (SAW)?',
    options: ['Mikail', 'Israfil', 'Jibrail', 'Azrael'],
    correctIndex: 2,
    explanation: 'Angel Jibrail (Gabriel) brought the revelation of the Quran.',
    category: 'Angels',
  ),
  QuizQuestion(
    question: 'What is the Quran\'s first surah called?',
    options: ['Al-Baqarah', 'Al-Fatiha', 'Al-Ikhlas', 'An-Nas'],
    correctIndex: 1,
    explanation: 'Al-Fatiha (The Opening) is the first surah of the Quran.',
    category: 'Quran',
  ),
  QuizQuestion(
    question: 'Which direction do Muslims face during prayer?',
    options: ['North', 'East', 'Towards Makkah (Qibla)', 'Towards Madinah'],
    correctIndex: 2,
    explanation: 'Muslims face the Qibla direction, which is towards the Kaaba in Makkah.',
    category: 'Prayer',
  ),
  QuizQuestion(
    question: 'What does "Bismillah" mean?',
    options: ['In the name of Allah', 'Praise be to Allah', 'Allah is enough', 'May Allah bless you'],
    correctIndex: 0,
    explanation: '"Bismillah" means "In the name of Allah".',
    category: 'Arabic',
  ),
  QuizQuestion(
    question: 'How many rakats does the Fajr prayer have?',
    options: ['2', '3', '4', '5'],
    correctIndex: 0,
    explanation: 'Fajr prayer has 2 obligatory (fard) rakats.',
    category: 'Prayer',
  ),
  QuizQuestion(
    question: 'Which surah contains Ayat al-Kursi?',
    options: ['Al-Fatiha', 'Al-Baqarah', 'Al-Imran', 'An-Nisa'],
    correctIndex: 1,
    explanation: 'Ayat al-Kursi is verse 255 of Surah Al-Baqarah.',
    category: 'Quran',
  ),
  QuizQuestion(
    question: 'What is the Night of Power called?',
    options: ['Laylat al-Bara\'ah', 'Laylat al-Qadr', 'Laylat al-Miraj', 'Laylat al-Isra'],
    correctIndex: 1,
    explanation: 'Laylat al-Qadr is the Night of Power, better than 1000 months.',
    category: 'Ramadan',
  ),
];

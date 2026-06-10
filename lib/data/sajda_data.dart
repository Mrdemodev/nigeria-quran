/// The 15 ayahs of obligatory/recommended sajda tilawa (prostration on recitation).
/// Each entry is (surah number, ayah number) — both 1-based.
const Set<(int, int)> kSajdaAyahs = {
  (7, 206),
  (13, 15),
  (16, 50),
  (17, 109),
  (19, 58),
  (22, 18),
  (22, 77),  // second sajda in Al-Hajj (Shafi'i / Hanbali)
  (25, 60),
  (27, 26),
  (32, 15),
  (38, 24),
  (41, 38),
  (53, 62),
  (84, 21),
  (96, 19),
};

bool isSajdaAyah(int surah, int ayah) => kSajdaAyahs.contains((surah, ayah));

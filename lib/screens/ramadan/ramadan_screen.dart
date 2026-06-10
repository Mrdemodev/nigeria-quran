import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/hijri_utils.dart';
import '../../theme/app_theme.dart';

class RamadanScreen extends StatelessWidget {
  const RamadanScreen({super.key});

  static const List<_DuaItem> _suhoorDuas = [
    _DuaItem(
      arabic: 'نَوَيْتُ صَوْمَ غَدٍ عَنْ أَدَاءِ فَرِيضَةِ رَمَضَانَ هَذِهِ السَّنَةِ لِلَّهِ تَعَالَى',
      english: 'I intend to fast tomorrow to fulfil the obligatory fast of Ramadan this year for Allah the Exalted.',
      hausa: 'Na niyati azumin gobe don cika wajibin Ramadan wannan shekara saboda Allah.',
      label: 'Niyyah (Intention)',
    ),
  ];

  static const List<_DuaItem> _iftarDuas = [
    _DuaItem(
      arabic: 'اللَّهُمَّ لَكَ صُمْتُ وَبِكَ آمَنْتُ وَعَلَيْكَ تَوَكَّلْتُ وَعَلَى رِزْقِكَ أَفْطَرْتُ',
      english: 'O Allah! For You I have fasted, in You I have believed, on You I rely, and with Your provision I break my fast.',
      hausa: 'Ya Allah! Saboda Kai na azumta, da Kai na yi imani, a Kai na dogara, da abincin Kai na karya azumi.',
      label: "Iftar Du'a",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final prayer = context.watch<PrayerProvider>();
    final hijri = HijriDate.fromGregorian(DateTime.now());
    final isRamadan = hijri.month == 9;
    final pt = prayer.prayerTimes;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.cream,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                          const Expanded(
                            child: Column(
                              children: [
                                Text('Ramadan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                                Text('رمضان المبارك', style: TextStyle(color: Colors.white60, fontSize: 12, fontFamily: AppTheme.arabicFontFamily)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 36),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            const Text('☽', style: TextStyle(fontSize: 40, color: AppTheme.gold)),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${hijri.day} ${hijri.monthName} ${hijri.year} AH',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isRamadan
                                        ? AppTheme.gold.withValues(alpha: 0.3)
                                        : Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isRamadan ? '🌙 Ramadan is here!' : 'Not Ramadan yet',
                                    style: TextStyle(
                                      color: isRamadan ? AppTheme.lightGold : Colors.white60,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (pt != null) ...[
                  _SectionTitle(title: "Today's Times", isDark: isDark),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _TimeCard(
                        label: 'Suhoor ends',
                        time: DateFormat('h:mm a').format(pt.fajr),
                        emoji: '🌅',
                        color: const Color(0xFF5C6BC0),
                        isDark: isDark,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _TimeCard(
                        label: 'Iftar starts',
                        time: DateFormat('h:mm a').format(pt.maghrib),
                        emoji: '🌇',
                        color: AppTheme.gold,
                        isDark: isDark,
                      )),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                _SectionTitle(title: 'Suhoor', isDark: isDark),
                const SizedBox(height: 10),
                ..._suhoorDuas.map((d) => _DuaCard(item: d, isDark: isDark)),

                const SizedBox(height: 20),
                _SectionTitle(title: 'Iftar', isDark: isDark),
                const SizedBox(height: 10),
                ..._iftarDuas.map((d) => _DuaCard(item: d, isDark: isDark)),

                const SizedBox(height: 20),
                _SectionTitle(title: 'Ramadan Guidance', isDark: isDark),
                const SizedBox(height: 10),
                ..._tips(isDark),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _tips(bool isDark) {
    const items = [
      ('🕌', 'Pray Tarawih', 'Perform extra night prayers for additional reward'),
      ('📖', 'Increase Quran', 'Aim to recite at least one Juz per day'),
      ('🤲', "Make Du'a", 'Du\'a at suhoor and iftar are accepted'),
      ('💰', 'Give Sadaqah', 'Charity in Ramadan is multiplied 700x'),
      ('🌙', 'Laylatul Qadr', 'Seek it in the last 10 nights, especially 27th'),
    ];
    return items.map((t) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Text(t.$1, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.$2, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1A1A1A), fontSize: 13)),
                Text(t.$3, style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    )).toList();
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final String label;
  final String time;
  final String emoji;
  final Color color;
  final bool isDark;

  const _TimeCard({required this.label, required this.time, required this.emoji, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isDark ? Colors.white60 : Colors.black45, fontSize: 11)),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
        ],
      ),
    );
  }
}

class _DuaCard extends StatelessWidget {
  final _DuaItem item;
  final bool isDark;
  const _DuaCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: isDark ? 0.1 : 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Text(item.label, style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.arabic,
                  style: const TextStyle(fontSize: 18, fontFamily: AppTheme.arabicFontFamily, height: 2.0, color: AppTheme.primaryGreen),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 10),
                Text(item.english, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12, height: 1.5), textAlign: TextAlign.left),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(item.hausa, style: const TextStyle(color: AppTheme.darkGold, fontSize: 11), textAlign: TextAlign.left),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DuaItem {
  final String arabic;
  final String english;
  final String hausa;
  final String label;
  const _DuaItem({required this.arabic, required this.english, required this.hausa, required this.label});
}

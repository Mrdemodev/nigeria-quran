import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:share_plus/share_plus.dart';
import '../../utils/hijri_utils.dart';
import '../../providers/settings_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/audio_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mini_player.dart';
import '../../services/remote_config_service.dart';
import '../quran/surah_list_screen.dart';
import '../prayer/prayer_times_screen.dart';
import '../qibla/qibla_screen.dart';
import '../dhikr/dhikr_screen.dart';
import '../names/names_screen.dart';
import '../quiz/quiz_screen.dart';
import '../ramadan/ramadan_screen.dart';
import '../settings/settings_screen.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../duas/duas_screen.dart';
import '../tajweed/tajweed_screen.dart';
import '../hadith/hadith_screen.dart';
import '../zakat/zakat_screen.dart';
import '../search/search_screen.dart';
import '../calendar/calendar_screen.dart';
import '../quran/juz_screen.dart';
import '../progress/progress_screen.dart';
import '../fasting/fasting_screen.dart';
import '../notes/notes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _dailyArabic = '';
  String _dailyTranslation = '';
  String _dailySurahName = '';
  int _dailyAyahNumber = 1;
  bool _dailyLoading = true;
  VoidCallback? _quranListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().recordAppOpen();
      _tryLoadDailyAyah();
    });
  }

  void _tryLoadDailyAyah() {
    final quran = context.read<QuranProvider>();
    if (quran.surahs.isNotEmpty) {
      _loadDailyAyah();
    } else {
      _quranListener = () {
        if (!mounted) return;
        final q = context.read<QuranProvider>();
        if (q.surahs.isNotEmpty) {
          q.removeListener(_quranListener!);
          _quranListener = null;
          _loadDailyAyah();
        }
      };
      quran.addListener(_quranListener!);
    }
  }

  @override
  void dispose() {
    if (_quranListener != null) {
      try { context.read<QuranProvider>().removeListener(_quranListener!); } catch (_) {}
      _quranListener = null;
    }
    super.dispose();
  }

  Future<void> _loadDailyAyah() async {
    final quran = context.read<QuranProvider>();
    final settings = context.read<SettingsProvider>();
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final surahNum = (dayOfYear % 114) + 1;
    final surahs = quran.surahs;
    if (surahs.isEmpty) return;
    final surah = surahs.firstWhere((s) => s.number == surahNum,
        orElse: () => surahs.first);
    final ayahPick = (dayOfYear ~/ 7) % surah.ayahCount;

    final translationFuture = settings.translationLanguage == TranslationLanguage.hausa
        ? quran.getHausaAyahs(surahNum)
        : settings.translationLanguage == TranslationLanguage.yoruba
            ? quran.getYorubaAyahs(surahNum)
            : quran.getEnglishAyahs(surahNum);
    final results = await Future.wait([quran.getArabicAyahs(surahNum), translationFuture]);
    final arabic = results[0];
    final translation = results[1];

    if (!mounted) return;
    final ayahArabic = arabic.isNotEmpty ? arabic[ayahPick.clamp(0, arabic.length - 1)] : '';
    final ayahTranslation = translation.isNotEmpty ? translation[ayahPick.clamp(0, translation.length - 1)] : '';
    setState(() {
      _dailyArabic = ayahArabic;
      _dailyTranslation = ayahTranslation;
      _dailySurahName = surah.nameEn;
      _dailyAyahNumber = ayahPick + 1;
      _dailyLoading = false;
    });

    // Reschedule daily notification with actual verse content
    if (settings.dailyAyahNotificationEnabled && ayahArabic.isNotEmpty) {
      NotificationService().scheduleDailyAyah(
        enabled: true,
        ayahArabic: ayahArabic,
        ayahTranslation: ayahTranslation,
        surahInfo: '${surah.nameEn} · ${ayahPick + 1}',
      );
    }
  }

  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Good Night';
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    if (h < 21) return 'Good Evening';
    return 'Good Night';
  }

  @override
  Widget build(BuildContext context) {
    final prayer = context.watch<PrayerProvider>();
    final settings = context.watch<SettingsProvider>();
    final quran = context.watch<QuranProvider>();
    final audio = context.watch<AudioProvider>();
    final progress = context.watch<ProgressProvider>();
    final isDark = settings.isDarkMode;
    final now = DateTime.now();
    final hijri = HijriDate.now();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.cream,
      bottomNavigationBar: audio.hasAudio ? const MiniPlayer() : null,
      body: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_greeting(),
                                    style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        fontSize: 12)),
                                const SizedBox(height: 2),
                                const Text('Assalamu Alaikum',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _HdrBtn(
                                  icon: Icons.bookmarks_rounded,
                                  onTap: () => _push(const BookmarksScreen())),
                              const SizedBox(width: 8),
                              _HdrBtn(
                                  icon: isDark
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_rounded,
                                  onTap: settings.toggleTheme),
                              const SizedBox(width: 8),
                              _HdrBtn(
                                  icon: Icons.settings_rounded,
                                  onTap: () => _push(const SettingsScreen())),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Date chips
                      Wrap(spacing: 8, runSpacing: 6, children: [
                        _DateChip(DateFormat('EEE, d MMM yyyy').format(now)),
                        _DateChip(hijri.formatted(), isGold: true),
                      ]),
                      const SizedBox(height: 16),
                      // Prayer countdown
                      _PrayerCountdown(prayer: prayer, onRefreshLocation: prayer.loadWithGPS),
                      if (prayer.prayerTimes != null) ...[
                        const SizedBox(height: 10),
                        _PrayerRoad(prayer: prayer),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Al-Quran Banner ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => _push(const SurahListScreen()),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.quranGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.quranBlue.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                          right: -15, top: -15,
                          child: Container(width: 110, height: 110,
                              decoration: BoxDecoration(shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.05)))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Al-Quran',
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 3),
                                  Text(
                                    settings.lastReadSurah > 0 && quran.surahs.isNotEmpty
                                        ? 'Continue: ${quran.surahs[settings.lastReadSurah - 1].nameEn} · Ayah ${settings.lastReadAyah}'
                                        : '114 Surahs · Tap to read',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () { HapticFeedback.lightImpact(); _push(const SearchScreen()); },
                              child: Container(
                                width: 34, height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.search_rounded, color: Colors.white, size: 18),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 15),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Announcement banner (remote-config controlled) ──
          if (RemoteConfigService.instance.announcementEnabled &&
              RemoteConfigService.instance.announcementText.isNotEmpty)
            SliverToBoxAdapter(
              child: _AnnouncementBanner(
                text: RemoteConfigService.instance.announcementText,
                url: RemoteConfigService.instance.announcementUrl,
                bgColor: RemoteConfigService.instance.announcementBgColor,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Daily Streak ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _StreakCard(streak: progress.readingStreak, isDark: isDark),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 22)),

          // ── Quick Access (compact 4-icon row) ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.bolt_rounded, color: AppTheme.gold, size: 14),
                    const SizedBox(width: 5),
                    Text('Quick Access',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white60 : const Color(0xFF666666))),
                  ]),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QuickIcon(icon: Icons.menu_book_rounded,  label: "Qur'an",          color: AppTheme.quranBlue,     isDark: isDark, onTap: () => _push(const SurahListScreen())),
                      _QuickIcon(icon: Icons.mosque_rounded,     label: 'Prayer\nTimes',   color: const Color(0xFF2196F3), isDark: isDark, onTap: () => _push(const PrayerTimesScreen())),
                      _QuickIcon(icon: Icons.explore_rounded,    label: 'Qibla',           color: const Color(0xFF009688), isDark: isDark, onTap: () => _push(const QiblaScreen())),
                      _QuickIcon(icon: Icons.touch_app_rounded,  label: 'Dhikr',           color: const Color(0xFF7B1FA2), isDark: isDark, onTap: () => _push(const DhikrScreen())),
                      _QuickIcon(icon: Icons.volunteer_activism_rounded, label: 'Duas',   color: const Color(0xFF00897B), isDark: isDark, onTap: () => _push(const DuasScreen())),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── More Tools (wrapped grid) ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.grid_view_rounded, size: 14, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 5),
                    Text('More Tools',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white60 : const Color(0xFF666666))),
                  ]),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.88,
                    children: [
                      _GridTile(icon: Icons.looks_one_rounded,            label: 'Juz',       color: AppTheme.quranBlue,      isDark: isDark, onTap: () => _push(const JuzScreen())),
                      _GridTile(icon: Icons.record_voice_over_rounded,   label: 'Tajweed',   color: const Color(0xFF673AB7), isDark: isDark, onTap: () => _push(const TajweedScreen())),
                      _GridTile(icon: Icons.library_books_rounded,        label: 'Hadith',    color: const Color(0xFF5D4037), isDark: isDark, onTap: () => _push(const HadithScreen())),
                      _GridTile(icon: Icons.calculate_rounded,            label: 'Zakat',     color: const Color(0xFFF57F17), isDark: isDark, onTap: () => _push(const ZakatScreen())),
                      _GridTile(icon: Icons.calendar_month_rounded,       label: 'Calendar',  color: AppTheme.quranBlue,      isDark: isDark, onTap: () => _push(const CalendarScreen())),
                      _GridTile(icon: Icons.trending_up_rounded,          label: 'Progress',  color: const Color(0xFF2E7D32), isDark: isDark, onTap: () => _push(const ProgressScreen())),
                      _GridTile(icon: Icons.restaurant_menu_rounded,      label: 'Fasting',   color: const Color(0xFF7B1FA2), isDark: isDark, onTap: () => _push(const FastingScreen())),
                      _GridTile(icon: Icons.format_list_bulleted_rounded, label: '99 Names',  color: const Color(0xFFE64A19), isDark: isDark, onTap: () => _push(const NamesScreen())),
                      _GridTile(icon: Icons.nightlight_round,             label: 'Ramadan',   color: const Color(0xFF6A1B9A), isDark: isDark, onTap: () => _push(const RamadanScreen())),
                      _GridTile(icon: Icons.quiz_rounded,                 label: 'Quiz',      color: const Color(0xFFEF6C00), isDark: isDark, onTap: () => _push(const QuizScreen())),
                      _GridTile(icon: Icons.bookmarks_rounded,            label: 'Bookmarks', color: AppTheme.quranBlue,      isDark: isDark, onTap: () => _push(const BookmarksScreen())),
                      _GridTile(icon: Icons.sticky_note_2_rounded,        label: 'Notes',     color: const Color(0xFFFF8F00), isDark: isDark, onTap: () => _push(const NotesScreen())),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 22)),

          // ── Today's Ayah (compact) ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.format_quote_rounded, color: AppTheme.gold, size: 15),
                    const SizedBox(width: 5),
                    Text("Today's Ayah",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white60 : const Color(0xFF666666))),
                  ]),
                  const SizedBox(height: 10),
                  _DailyAyahCard(
                    isDark: isDark,
                    arabic: _dailyArabic,
                    translation: _dailyTranslation,
                    surahName: _dailySurahName,
                    ayahNumber: _dailyAyahNumber,
                    isLoading: _dailyLoading,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── Daily Ayah Card (compact) ─────────────────────────

class _DailyAyahCard extends StatelessWidget {
  final bool isDark;
  final String arabic;
  final String translation;
  final String surahName;
  final int ayahNumber;
  final bool isLoading;
  const _DailyAyahCard({
    required this.isDark,
    required this.arabic,
    required this.translation,
    required this.surahName,
    required this.ayahNumber,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: isDark ? 0.18 : 0.14)),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.07), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: CircularProgressIndicator(color: AppTheme.gold, strokeWidth: 2)),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tag + share
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 10),
                          const SizedBox(width: 3),
                          Text('$surahName · $ayahNumber',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Share.share('$arabic\n\n$translation\n\n— $surahName, Ayah $ayahNumber\n\nQur\'an NG App');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withValues(alpha: isDark ? 0.12 : 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.share_rounded,
                              color: AppTheme.gold.withValues(alpha: 0.7), size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Arabic — compact, max 3 lines
                  Text(
                    arabic,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.justify,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.arabicStyle(
                      fontSize: 19,
                      height: 1.85,
                      color: isDark ? AppTheme.arabicTextDark : AppTheme.arabicTextLight,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(height: 1, color: AppTheme.gold.withValues(alpha: isDark ? 0.12 : 0.08)),
                  const SizedBox(height: 10),
                  // Translation — 2 lines max
                  Text(
                    translation,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: isDark ? Colors.white60 : const Color(0xFF666666),
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Quick icon button ─────────────────────────────────

class _QuickIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _QuickIcon({required this.icon, required this.label, required this.color, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () { HapticFeedback.lightImpact(); onTap(); },
        child: Column(children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.09),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: isDark ? 0.22 : 0.14), width: 1),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
            style: TextStyle(fontSize: 10, height: 1.2,
                color: isDark ? Colors.white60 : const Color(0xFF555555),
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ]),
      ),
    );
  }
}

// ── Grid tile (More Tools) ────────────────────────────

class _GridTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  const _GridTile({required this.icon, required this.label, required this.color, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 7),
            Text(label,
              style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : const Color(0xFF555555), fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────

class _HdrBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HdrBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      );
}

class _DateChip extends StatelessWidget {
  final String text;
  final bool isGold;
  const _DateChip(this.text, {this.isGold = false});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isGold
              ? AppTheme.gold.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: isGold ? Border.all(color: AppTheme.gold.withValues(alpha: 0.4)) : null,
        ),
        child: Text(text,
            style: TextStyle(
                color: isGold ? AppTheme.gold : Colors.white,
                fontSize: 11,
                fontWeight: isGold ? FontWeight.w600 : FontWeight.w400)),
      );
}

class _PrayerCountdown extends StatefulWidget {
  final PrayerProvider prayer;
  final VoidCallback? onRefreshLocation;
  const _PrayerCountdown({required this.prayer, this.onRefreshLocation});
  @override
  State<_PrayerCountdown> createState() => _PrayerCountdownState();
}

class _PrayerCountdownState extends State<_PrayerCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayer = widget.prayer;
    if (prayer.prayerTimes == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(children: [
          const Icon(Icons.location_searching_rounded, color: Colors.white54, size: 16),
          const SizedBox(width: 10),
          const Expanded(child: Text('Loading prayer times…', style: TextStyle(color: Colors.white70, fontSize: 13))),
          if (widget.onRefreshLocation != null)
            GestureDetector(
              onTap: widget.onRefreshLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ),
        ]),
      );
    }
    final tl = prayer.timeToNextPrayer;
    final h = tl.inHours.toString().padLeft(2, '0');
    final m = tl.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = tl.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Next Prayer',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 10)),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.mosque_rounded, color: AppTheme.gold, size: 15),
                const SizedBox(width: 6),
                Text(prayer.nextPrayerName,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: widget.onRefreshLocation,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.location_on_rounded, color: Colors.white.withValues(alpha: 0.5), size: 10),
                  const SizedBox(width: 3),
                  Text(prayer.prayerTimes!.locationName,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
                  const SizedBox(width: 3),
                  Icon(Icons.refresh_rounded, color: Colors.white.withValues(alpha: 0.35), size: 10),
                ]),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Text('$h:$m:$s',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
            Text('remaining',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 8)),
          ]),
        ),
      ]),
    );
  }
}

// ── Prayer Road (progress between prayers) ───────────

class _PrayerRoad extends StatefulWidget {
  final PrayerProvider prayer;
  const _PrayerRoad({required this.prayer});
  @override
  State<_PrayerRoad> createState() => _PrayerRoadState();
}

class _PrayerRoadState extends State<_PrayerRoad> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pt = widget.prayer.prayerTimes!;
    final now = DateTime.now();
    final nextName = widget.prayer.nextPrayerName;

    final prayers = [
      ('Fajr', pt.fajr),
      ('Dhuhr', pt.dhuhr),
      ('Asr', pt.asr),
      ('Maghrib', pt.maghrib),
      ('Isha', pt.isha),
    ];

    String prevName = 'Isha';
    DateTime prevTime = pt.isha.subtract(const Duration(hours: 24));
    DateTime nextTime = pt.fajr;

    for (int i = 0; i < prayers.length; i++) {
      if (prayers[i].$1 == nextName) {
        nextTime = prayers[i].$2;
        if (i == 0) {
          prevName = prayers.last.$1;
          prevTime = prayers.last.$2.subtract(const Duration(hours: 24));
        } else {
          prevName = prayers[i - 1].$1;
          prevTime = prayers[i - 1].$2;
        }
        break;
      }
    }

    final totalSecs = nextTime.difference(prevTime).inSeconds;
    final elapsedSecs = now.difference(prevTime).inSeconds;
    final progress = totalSecs > 0 ? (elapsedSecs / totalSecs).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: prayers.map((p) {
              final isPast = now.isAfter(p.$2);
              final isNext = nextName == p.$1;
              return Expanded(
                child: Column(children: [
                  Text(p.$1,
                      style: TextStyle(
                          color: isNext ? AppTheme.gold : Colors.white.withValues(alpha: isPast ? 0.4 : 0.65),
                          fontSize: 9,
                          fontWeight: isNext ? FontWeight.w700 : FontWeight.normal),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(DateFormat('h:mm').format(p.$2),
                      style: TextStyle(
                          color: isNext ? Colors.white : Colors.white.withValues(alpha: isPast ? 0.4 : 0.85),
                          fontSize: 9.5,
                          fontWeight: isNext ? FontWeight.w700 : FontWeight.normal)),
                ]),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Text(prevName,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(AppTheme.gold),
                    minHeight: 5,
                  ),
                ),
              ),
            ),
            Text(nextName,
                style: const TextStyle(color: AppTheme.gold, fontSize: 9, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 3),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).toStringAsFixed(0)}% towards $nextName',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  final bool isDark;
  const _StreakCard({required this.streak, required this.isDark});

  String get _milestone {
    if (streak >= 365) return "One full year! Masha'Allah!";
    if (streak >= 100) return 'Incredible dedication!';
    if (streak >= 30) return '30-day champion!';
    if (streak >= 14) return 'Two weeks strong!';
    if (streak >= 7) return 'One week streak!';
    if (streak >= 3) return 'Keep it going!';
    if (streak == 1) return 'Great start!';
    return 'Open the app daily to build your streak';
  }

  Color get _flameColor {
    if (streak >= 30) return const Color(0xFFFF6F00);
    if (streak >= 7) return const Color(0xFFFF8F00);
    return const Color(0xFFFFB300);
  }

  @override
  Widget build(BuildContext context) {
    final hasStreak = streak > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: hasStreak
            ? Border.all(color: _flameColor.withValues(alpha: 0.3))
            : Border.all(color: Colors.transparent),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasStreak
                    ? [_flameColor, _flameColor.withValues(alpha: 0.7)]
                    : [Colors.grey.shade300, Colors.grey.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: hasStreak ? Colors.white : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$streak',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: hasStreak ? _flameColor : (isDark ? Colors.white38 : Colors.black26),
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Day Streak',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white60 : const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _milestone,
                  style: TextStyle(
                    fontSize: 11,
                    color: hasStreak
                        ? _flameColor.withValues(alpha: 0.8)
                        : (isDark ? Colors.white38 : Colors.black38),
                  ),
                ),
              ],
            ),
          ),
          _StreakDots(streak: streak, color: _flameColor, isDark: isDark),
        ],
      ),
    );
  }
}

class _StreakDots extends StatelessWidget {
  final int streak;
  final Color color;
  final bool isDark;
  const _StreakDots({required this.streak, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('Last 7 days',
            style: TextStyle(fontSize: 9, color: isDark ? Colors.white38 : Colors.black38)),
        const SizedBox(height: 6),
        Row(
          children: List.generate(7, (i) {
            final filled = i < streak.clamp(0, 7);
            return Container(
              width: 10, height: 10,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: filled ? color : (isDark ? Colors.white12 : Colors.black12),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _AnnouncementBanner extends StatelessWidget {
  final String text;
  final String url;
  final String bgColor;
  const _AnnouncementBanner({required this.text, required this.url, required this.bgColor});

  Color _parseColor(String hex) {
    try {
      final h = hex.replaceFirst('#', '');
      return Color(int.parse(h.length == 6 ? 'FF$h' : h, radix: 16));
    } catch (_) {
      return const Color(0xFF1A6B3A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _parseColor(bgColor);
    Widget content = Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.campaign_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
          ),
          if (url.isNotEmpty)
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 13),
        ],
      ),
    );
    if (url.isNotEmpty) {
      content = GestureDetector(
        onTap: () {
          // Open URL — simple launch via url_launcher if available, else ignore
        },
        child: content,
      );
    }
    return content;
  }
}

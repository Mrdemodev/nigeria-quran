import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/audio_provider.dart';
import '../../data/juz_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mini_player.dart';
import 'surah_detail_screen.dart';

class JuzScreen extends StatelessWidget {
  const JuzScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quran = context.watch<QuranProvider>();
    final settings = context.watch<SettingsProvider>();
    final audio = context.watch<AudioProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.cream,
      bottomNavigationBar: audio.hasAudio ? const MiniPlayer() : null,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.quranGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
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
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Juz Navigation',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                        Text('30 Parts of the Qur\'an',
                            style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: quran.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.quranBlue))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: 30,
                    itemBuilder: (_, i) {
                      final juz = kJuzData[i];
                      final surah = quran.surahs.isNotEmpty
                          ? quran.surahs.firstWhere(
                              (s) => s.number == juz.startSurah,
                              orElse: () => quran.surahs.first,
                            )
                          : null;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (surah == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SurahDetailScreen(
                                surah: surah,
                                initialAyah: juz.startAyah - 1,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.quranBlue.withValues(alpha: isDark ? 0.3 : 0.12),
                                AppTheme.quranBlue.withValues(alpha: isDark ? 0.15 : 0.06),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppTheme.quranBlue.withValues(alpha: isDark ? 0.3 : 0.15),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.quranGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.quranBlue.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${juz.juzNumber}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Juz ${juz.juzNumber}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                surah?.nameEn ?? 'Surah ${juz.startSurah}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                juz.arabicName,
                                style: AppTheme.arabicStyle(
                                  fontSize: 13,
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

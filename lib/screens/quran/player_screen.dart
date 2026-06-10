import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/audio_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/quran_provider.dart';
import '../../data/reciters_data.dart';
import '../../theme/app_theme.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final settings = context.watch<SettingsProvider>();
    final quranSurahs = context.read<QuranProvider>().surahs;
    String surahName(int n) => quranSurahs.isNotEmpty && n >= 1 && n <= quranSurahs.length
        ? quranSurahs[n - 1].nameEn
        : 'Surah $n';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                    const Column(
                      children: [
                        Text('Now Playing',
                            style: TextStyle(color: Colors.white60, fontSize: 12)),
                        Text("Qur'an NG",
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showSleepTimer(context, audio),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: audio.isSleepTimerActive
                              ? AppTheme.gold.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.timer_rounded,
                            color: audio.isSleepTimerActive ? AppTheme.gold : Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // ── Artwork ──
              _ArtworkWidget(surahName: audio.currentSurahName),

              const Spacer(),

              // ── Surah Info ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      audio.currentSurahName ?? '—',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 26,
                          fontWeight: FontWeight.w800, letterSpacing: 0.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Reciter chip — tap to change
                    GestureDetector(
                      onTap: () => _showReciterPicker(context, settings),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.mic_rounded, color: Colors.white70, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              audio.currentReciter?.name ?? 'Select Reciter',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.white60, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Progress ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.gold,
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withValues(alpha: 0.1),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      ),
                      child: Slider(
                        value: audio.duration.inMilliseconds > 0
                            ? (audio.position.inMilliseconds / audio.duration.inMilliseconds).clamp(0.0, 1.0)
                            : 0,
                        onChanged: (v) => audio.seek(
                          Duration(milliseconds: (v * audio.duration.inMilliseconds).round()),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_fmt(audio.position),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                          Text(_fmt(audio.duration),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Speed ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [0.75, 1.0, 1.25, 1.5].map((speed) {
                  final isSelected = audio.speed == speed;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      audio.setSpeed(speed);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.goldGradient : null,
                        color: isSelected ? null : Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${speed}x',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white60,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                          )),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // ── Controls ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Repeat
                    _ControlBtn(
                      icon: Icons.repeat_one_rounded,
                      isActive: audio.isRepeat,
                      onTap: audio.toggleRepeat,
                    ),
                    // Skip back 10s
                    _ControlBtn(
                      icon: Icons.replay_10_rounded,
                      isActive: false,
                      onTap: audio.skipBackward,
                    ),
                    // Play / Pause
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        audio.playPause();
                      },
                      child: Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.gold.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: audio.isLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                ),
                              )
                            : Icon(
                                audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white, size: 36,
                              ),
                      ),
                    ),
                    // Skip forward 10s
                    _ControlBtn(
                      icon: Icons.forward_10_rounded,
                      isActive: false,
                      onTap: audio.skipForward,
                    ),
                    // Stop
                    _ControlBtn(
                      icon: Icons.stop_rounded,
                      isActive: false,
                      onTap: () {
                        audio.stop();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),

              // ── Repeat Ayah (per-ayah mode only) ──
              if (audio.isPerAyahMode) ...[
                const SizedBox(height: 14),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      audio.toggleRepeatAyah();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: audio.isRepeatAyah
                            ? AppTheme.gold.withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: audio.isRepeatAyah
                              ? AppTheme.gold.withValues(alpha: 0.7)
                              : Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.repeat_one_rounded,
                              color: audio.isRepeatAyah ? AppTheme.gold : Colors.white54,
                              size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Repeat Ayah',
                            style: TextStyle(
                              color: audio.isRepeatAyah ? AppTheme.gold : Colors.white54,
                              fontSize: 12,
                              fontWeight: audio.isRepeatAyah ? FontWeight.w700 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Previous / Next Surah ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SurahNavBtn(
                    icon: Icons.skip_previous_rounded,
                    label: 'Previous',
                    enabled: audio.canPlayPrev,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      audio.playPrevSurah(surahName);
                    },
                  ),
                  const SizedBox(width: 40),
                  _SurahNavBtn(
                    icon: Icons.skip_next_rounded,
                    label: 'Next',
                    enabled: audio.canPlayNext,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      audio.playNextSurah(surahName);
                    },
                    iconOnRight: true,
                  ),
                ],
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showReciterPicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: settings.isDarkMode ? AppTheme.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.mic_rounded, color: AppTheme.primaryGreen, size: 24),
                  const SizedBox(width: 10),
                  Text('Select Reciter',
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                      )),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: kReciters.asMap().entries.map((entry) {
                  final r = entry.value;
                  final reciterNumber = entry.key + 1;
                  final isSelected = settings.selectedReciterId == r.id;
                  return GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      await settings.setSelectedReciter(r.id);
                      if (!context.mounted) return;
                      final audio = context.read<AudioProvider>();
                      if (audio.hasAudio && audio.currentSurahNumber != null) {
                        audio.playSurah(
                          surahNumber: audio.currentSurahNumber!,
                          surahName: audio.currentSurahName ?? '',
                          reciterId: r.id,
                        );
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryGreen.withValues(alpha: settings.isDarkMode ? 0.2 : 0.08)
                            : (settings.isDarkMode ? AppTheme.darkCard2 : const Color(0xFFF8F8F8)),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected ? Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.5)) : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppTheme.primaryGradient : null,
                              color: isSelected ? null : Colors.grey.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$reciterNumber',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.name,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 14,
                                      color: settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                                    )),
                                Text(r.origin,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: settings.isDarkMode ? Colors.white38 : Colors.black38,
                                    )),
                              ],
                            ),
                          ),
                          if (r.isFeatured)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('★',
                                  style: TextStyle(color: AppTheme.gold, fontSize: 10)),
                            ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 20),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSleepTimer(BuildContext context, AudioProvider audio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.timer_rounded, color: AppTheme.gold),
                SizedBox(width: 10),
                Text('Sleep Timer',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            if (audio.isSleepTimerActive)
              TextButton.icon(
                onPressed: () { audio.cancelSleepTimer(); Navigator.pop(context); },
                icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                label: const Text('Cancel Timer', style: TextStyle(color: Colors.redAccent)),
              ),
            ...[15, 30, 45, 60].map((m) => ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.timer_rounded, color: Colors.white, size: 20),
              ),
              title: Text('$m minutes',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38),
              onTap: () {
                audio.startSleepTimer(m);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Sleep timer set for $m minutes'),
                  backgroundColor: AppTheme.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ArtworkWidget extends StatelessWidget {
  final String? surahName;
  const _ArtworkWidget({this.surahName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220, height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          Colors.white.withValues(alpha: 0.2),
          Colors.white.withValues(alpha: 0.05),
        ]),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(color: AppTheme.gold.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 10),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
            ),
          ),
          Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2), width: 1),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book_rounded, size: 52, color: AppTheme.gold),
              const SizedBox(height: 8),
              Text(
                'قرآن كريم',
                style: AppTheme.arabicStyle(fontSize: 20, color: Colors.white, height: 1.4),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SurahNavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final bool iconOnRight;
  final VoidCallback onTap;
  const _SurahNavBtn({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.iconOnRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Colors.white : Colors.white24;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!iconOnRight) Icon(icon, color: color, size: 22),
          if (!iconOnRight) const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
          if (iconOnRight) const SizedBox(width: 6),
          if (iconOnRight) Icon(icon, color: color, size: 22),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  const _ControlBtn({required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.gold.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: isActive ? Border.all(color: AppTheme.gold.withValues(alpha: 0.4)) : null,
        ),
        child: Icon(icon, color: isActive ? AppTheme.gold : Colors.white60, size: 22),
      ),
    );
  }
}

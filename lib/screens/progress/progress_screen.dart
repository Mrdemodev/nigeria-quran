import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final quran = context.watch<QuranProvider>();
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final pct = progress.quranProgressPercent;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // ── Header ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A1E44), Color(0xFF1565C0), Color(0xFF1976D2)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Reading Progress', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                              Text('Track your Quran journey', style: TextStyle(color: Colors.white60, fontSize: 11)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _confirmReset(context, progress),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Reset', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Overall ring / bar
                    Row(
                      children: [
                        // Stats
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${(pct * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, height: 1)),
                              const SizedBox(height: 2),
                              Text('of Qur\'an read',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: pct.clamp(0.0, 1.0),
                                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                                  valueColor: const AlwaysStoppedAnimation(AppTheme.gold),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text('${progress.totalAyahsRead} / 6,236 ayahs',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Mini stats
                        Column(
                          children: [
                            _StatBadge(value: '${progress.surahsCompleted}', label: 'Surahs\nComplete', icon: Icons.check_circle_rounded),
                            const SizedBox(height: 10),
                            _StatBadge(value: '${progress.readingStreak}', label: 'Day\nStreak', icon: Icons.local_fire_department_rounded, color: const Color(0xFFFF6D00)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Surah list ──
          Expanded(
            child: quran.surahs.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppTheme.quranBlue))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: quran.surahs.length,
                    itemBuilder: (_, i) {
                      final s = quran.surahs[i];
                      final p = progress.surahProgress[s.number];
                      final pct = p?.percent ?? 0.0;
                      final completed = p?.completed ?? false;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (p == null) {
                            progress.markSurahRead(s.number, s.ayahCount);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${s.nameEn} marked as read'),
                                backgroundColor: AppTheme.quranBlue,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: completed ? Border.all(color: AppTheme.quranBlue.withValues(alpha: 0.3)) : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  gradient: completed ? AppTheme.quranGradient : null,
                                  color: completed ? null : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: completed
                                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                                      : Text('${s.number}', style: TextStyle(
                                          fontSize: 10, fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white54 : Colors.black45)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.nameEn,
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                                            color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                                    if (p != null && !completed)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(3),
                                          child: LinearProgressIndicator(
                                            value: pct,
                                            backgroundColor: isDark ? Colors.white12 : Colors.black12,
                                            valueColor: AlwaysStoppedAnimation(AppTheme.quranBlue),
                                            minHeight: 3,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                completed ? 'Done' : (p != null ? '${(pct * 100).toInt()}%' : 'Tap'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: completed ? AppTheme.quranBlue : (isDark ? Colors.white38 : Colors.black38),
                                  fontWeight: completed ? FontWeight.w700 : FontWeight.w400,
                                ),
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

  void _confirmReset(BuildContext context, ProgressProvider p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text('This will clear all reading progress. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () { Navigator.pop(context); p.resetProgress(); },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatBadge({required this.value, required this.label, required this.icon, this.color = AppTheme.gold});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 8), textAlign: TextAlign.center),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../quran/surah_detail_screen.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final quran = context.watch<QuranProvider>();
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;
    final notes = progress.notes;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.cream,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                          Text('My Notes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          Text('ملاحظاتي', style: TextStyle(color: Colors.white60, fontSize: 12, fontFamily: AppTheme.arabicFontFamily)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${notes.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: notes.isEmpty
                ? _EmptyState(isDark: isDark)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: notes.length,
                    itemBuilder: (ctx, i) {
                      final note = notes[i];
                      final surah = quran.surahs.length >= note.surahNumber
                          ? quran.surahs[note.surahNumber - 1]
                          : null;
                      return _NoteCard(
                        note: note,
                        surahName: surah?.nameEn ?? 'Surah ${note.surahNumber}',
                        isDark: isDark,
                        onTap: surah == null
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => SurahDetailScreen(surah: surah)),
                                ),
                        onDelete: () => _confirmDelete(context, progress, note.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProgressProvider progress, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('This note will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              progress.deleteNote(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteRecord note;
  final String surahName;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.surahName,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = note.createdAt;
    final dateStr = '${date.day}/${date.month}/${date.year}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
          ),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$surahName · Ayah ${note.ayahNumber}',
                    style: const TextStyle(color: AppTheme.gold, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, size: 14, color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              note.text,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: isDark ? Colors.white.withValues(alpha: 0.87) : const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dateStr,
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_outlined, size: 64, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 16),
          Text('No notes yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.white54 : Colors.black45)),
          const SizedBox(height: 8),
          Text('Tap the note icon on any ayah to add a note', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.black38)),
        ],
      ),
    );
  }
}

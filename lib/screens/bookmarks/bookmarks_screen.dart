import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../quran/surah_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarks = context.watch<BookmarkProvider>();
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final items = bookmarks.bookmarks;

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
                          Text('Bookmarks', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          Text('المفضلة', style: TextStyle(color: Colors.white60, fontSize: 12, fontFamily: AppTheme.arabicFontFamily)),
                        ],
                      ),
                    ),
                    if (items.isNotEmpty)
                      GestureDetector(
                        onTap: () => _confirmClearAll(context, bookmarks),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                        ),
                      )
                    else
                      const SizedBox(width: 36),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: items.isEmpty
                ? _EmptyState(isDark: isDark)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final bm = items[i];
                      return _BookmarkCard(
                        isDark: isDark,
                        surahName: bm.surahName,
                        surahNumber: bm.surahNumber,
                        ayahNumber: bm.ayahNumber,
                        ayahText: bm.ayahText,
                        onDelete: () => bookmarks.removeBookmark(bm.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, BookmarkProvider bookmarks) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101810),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Bookmarks', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text('Remove all saved ayahs?', style: TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              bookmarks.clearAll();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final bool isDark;
  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final String ayahText;
  final VoidCallback onDelete;

  const _BookmarkCard({
    required this.isDark,
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahText,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final quran = context.read<QuranProvider>();
        try {
          final surah = quran.surahs.firstWhere((s) => s.number == surahNumber);
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => SurahDetailScreen(surah: surah, initialAyah: ayahNumber - 1),
          ));
        } catch (_) {}
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.lightGreen]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(surahName,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Ayah $ayahNumber',
                      style: const TextStyle(color: AppTheme.darkGold, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.bookmark_remove_rounded, color: Colors.redAccent.withValues(alpha: 0.7), size: 20),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Text(
              ayahText,
              style: TextStyle(
                fontSize: 18,
                fontFamily: AppTheme.arabicFontFamily,
                height: 2.0,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
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
          const Text('🔖', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('No Bookmarks Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              )),
          const SizedBox(height: 8),
          Text(
            'Tap the bookmark icon while reading\nto save your favourite ayahs',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, height: 1.5),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/hadith_data.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});
  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  String _selected = 'All';

  static const List<String> _cats = [
    'All', 'Faith', 'Prayer', 'Quran', 'Character', 'Knowledge', 'Charity', 'Family',
  ];

  static const Map<String, IconData> _catIcons = {
    'All': Icons.format_list_bulleted_rounded,
    'Faith': Icons.star_rounded,
    'Prayer': Icons.mosque_rounded,
    'Quran': Icons.menu_book_rounded,
    'Character': Icons.favorite_rounded,
    'Knowledge': Icons.school_rounded,
    'Charity': Icons.volunteer_activism_rounded,
    'Family': Icons.group_rounded,
  };

  static const Map<String, Color> _catColors = {
    'All': Color(0xFF5D4037),
    'Faith': Color(0xFF1565C0),
    'Prayer': Color(0xFF2E7D32),
    'Quran': Color(0xFF4527A0),
    'Character': Color(0xFFC62828),
    'Knowledge': Color(0xFF00695C),
    'Charity': Color(0xFFE65100),
    'Family': Color(0xFF880E4F),
  };

  List<HadithModel> get _filtered =>
      _selected == 'All' ? kHadiths : kHadiths.where((h) => h.category == _selected).toList();

  // Show a random hadith as "Daily Hadith"
  HadithModel get _daily {
    final day = DateTime.now().day;
    return kHadiths[day % kHadiths.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF9F5F0),
      body: Column(
        children: [
          // ── Header ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E1503), Color(0xFF5D4037), Color(0xFF795548)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hadith Collection',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                              Text('${_filtered.length} hadiths · ${_cats.length - 1} topics',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.library_books_rounded, color: AppTheme.gold, size: 14),
                            const SizedBox(width: 4),
                            Text('${kHadiths.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Category chips
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _cats.length,
                      itemBuilder: (_, i) {
                        final cat = _cats[i];
                        final sel = cat == _selected;
                        return GestureDetector(
                          onTap: () { HapticFeedback.selectionClick(); setState(() => _selected = cat); },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: sel ? Colors.white : Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(_catIcons[cat] ?? Icons.circle, size: 12,
                                  color: sel ? (_catColors[cat] ?? const Color(0xFF5D4037)) : Colors.white.withValues(alpha: 0.8)),
                              const SizedBox(width: 5),
                              Text(cat,
                                  style: TextStyle(
                                      color: sel ? (_catColors[cat] ?? const Color(0xFF5D4037)) : Colors.white.withValues(alpha: 0.9),
                                      fontSize: 11,
                                      fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // ── Body ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: _filtered.length + (_selected == 'All' ? 1 : 0),
              itemBuilder: (_, i) {
                if (_selected == 'All' && i == 0) {
                  return _DailyHadithCard(hadith: _daily, isDark: isDark);
                }
                final idx = _selected == 'All' ? i - 1 : i;
                final h = _filtered[idx];
                return _HadithCard(hadith: h, isDark: isDark, color: _catColors[h.category] ?? const Color(0xFF5D4037));
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily featured hadith card ────────────────────────

class _DailyHadithCard extends StatelessWidget {
  final HadithModel hadith;
  final bool isDark;
  const _DailyHadithCard({required this.hadith, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1503), Color(0xFF5D4037), Color(0xFF8D6E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF5D4037).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 5))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.wb_sunny_rounded, color: AppTheme.gold, size: 12),
                  SizedBox(width: 4),
                  Text('Hadith of the Day', style: TextStyle(color: AppTheme.gold, fontSize: 10, fontWeight: FontWeight.w700)),
                ]),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(hadith.category,
                    style: const TextStyle(color: Colors.white70, fontSize: 10)),
              ),
            ]),
            const SizedBox(height: 14),
            Text(
              hadith.arabic,
              textDirection: TextDirection.rtl,
              style: AppTheme.arabicStyle(
                  fontSize: 20, height: 1.9, color: const Color(0xFFFFECB3)),
            ),
            const SizedBox(height: 10),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 10),
            Text(
              hadith.translation,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.person_rounded, color: Colors.white38, size: 12),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${hadith.narrator} · ${hadith.source}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => Share.share('${hadith.arabic}\n\n${hadith.translation}\n\n— ${hadith.narrator}, ${hadith.source}\n\nQur\'an NG App'),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.share_rounded, color: Colors.white60, size: 14),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Regular hadith card ───────────────────────────────

class _HadithCard extends StatefulWidget {
  final HadithModel hadith;
  final bool isDark;
  final Color color;
  const _HadithCard({required this.hadith, required this.isDark, required this.color});
  @override
  State<_HadithCard> createState() => _HadithCardState();
}

class _HadithCardState extends State<_HadithCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final color = widget.color;
    final h = widget.hadith;

    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _expanded = !_expanded); },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.10)),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.12 : 0.06),
                borderRadius: _expanded
                    ? const BorderRadius.vertical(top: Radius.circular(18))
                    : BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.format_quote_rounded, color: color, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(h.category,
                              style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          h.translation,
                          style: TextStyle(fontSize: 12, height: 1.4,
                              color: isDark ? Colors.white70 : const Color(0xFF333333)),
                          maxLines: _expanded ? 100 : 2,
                          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: color, size: 20),
                ],
              ),
            ),

            // Expanded: Arabic + source
            if (_expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D1520) : const Color(0xFFF5F0E8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        h.arabic,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.justify,
                        style: AppTheme.arabicStyle(
                          fontSize: 20, height: 1.9,
                          color: isDark ? AppTheme.arabicTextDark : AppTheme.arabicTextLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      const Icon(Icons.person_rounded, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${h.narrator} · ${h.source}',
                          style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Share.share('${h.arabic}\n\n${h.translation}\n\n— ${h.narrator}, ${h.source}\n\nQur\'an NG App'),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.share_rounded, color: color, size: 14),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

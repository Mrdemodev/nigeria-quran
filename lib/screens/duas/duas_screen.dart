import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/duas_data.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class DuasScreen extends StatefulWidget {
  const DuasScreen({super.key});

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All', 'Morning', 'Evening', 'After Prayer', 'General', 'Travel', 'Food', 'Sickness',
  ];

  List<DuaModel> get _filtered => _selectedCategory == 'All'
      ? kDuas
      : kDuas.where((d) => d.category == _selectedCategory).toList();

  static const Map<String, IconData> _catIcons = {
    'All': Icons.auto_awesome_rounded,
    'Morning': Icons.wb_sunny_rounded,
    'Evening': Icons.nights_stay_rounded,
    'After Prayer': Icons.mosque_rounded,
    'General': Icons.menu_book_rounded,
    'Travel': Icons.directions_car_rounded,
    'Food': Icons.restaurant_rounded,
    'Sickness': Icons.favorite_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF0F6F5),
      body: Column(
        children: [
          // ── Header ──
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.duasGradient),
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
                              const Text(
                                'Duas & Supplications',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '${_filtered.length} duas',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: AppTheme.gold, size: 14),
                              const SizedBox(width: 4),
                              Text('${kDuas.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Category chips
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        final isSelected = cat == _selectedCategory;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedCategory = cat);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _catIcons[cat] ?? Icons.circle,
                                  size: 13,
                                  color: isSelected ? AppTheme.duasTeal : Colors.white.withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  cat,
                                  style: TextStyle(
                                    color: isSelected ? AppTheme.duasTeal : Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Dua list ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => _DuaCard(dua: _filtered[i], isDark: isDark, screenWidth: size.width),
            ),
          ),
        ],
      ),
    );
  }
}

class _DuaCard extends StatefulWidget {
  final DuaModel dua;
  final bool isDark;
  final double screenWidth;
  const _DuaCard({required this.dua, required this.isDark, required this.screenWidth});

  @override
  State<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<_DuaCard> {
  bool _showTranslit = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Card header ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            decoration: BoxDecoration(
              color: AppTheme.duasTeal.withValues(alpha: isDark ? 0.12 : 0.07),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: AppTheme.duasGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.dua.category,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.dua.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(
                      text: '${widget.dua.arabic}\n\n${widget.dua.translation}\n\n— ${widget.dua.reference}',
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Dua copied to clipboard'),
                        backgroundColor: AppTheme.duasTeal,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.copy_rounded,
                      size: 15,
                      color: isDark ? Colors.white54 : Colors.black38,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Arabic text ──
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 14, 12, 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF001F1A) : const Color(0xFFF5F9F8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.duasTeal.withValues(alpha: 0.12)),
            ),
            child: Text(
              widget.dua.arabic,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontFamily: AppTheme.arabicFontFamily,
                fontSize: 22,
                height: 2.0,
                color: isDark ? const Color(0xFFB2DFDB) : const Color(0xFF004D40),
                letterSpacing: 0.3,
              ),
            ),
          ),

          // ── Transliteration toggle ──
          GestureDetector(
            onTap: () => setState(() => _showTranslit = !_showTranslit),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Icon(
                    _showTranslit ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 16,
                    color: AppTheme.duasTeal,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showTranslit ? 'Hide transliteration' : 'Show transliteration',
                    style: const TextStyle(color: AppTheme.duasTeal, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          if (_showTranslit)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                widget.dua.transliteration,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: isDark ? Colors.white54 : const Color(0xFF555555),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // ── Translation ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              widget.dua.translation,
              style: TextStyle(
                fontSize: 13,
                height: 1.65,
                color: isDark ? Colors.white70 : const Color(0xFF333333),
              ),
            ),
          ),

          // ── Reference ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 12, color: AppTheme.gold),
                const SizedBox(width: 4),
                Text(
                  widget.dua.reference,
                  style: const TextStyle(fontSize: 10, color: AppTheme.gold, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

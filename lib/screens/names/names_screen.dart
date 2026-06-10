import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/names_of_allah.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class NamesScreen extends StatefulWidget {
  const NamesScreen({super.key});

  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends State<NamesScreen> {
  String _query = '';
  final _ctrl = TextEditingController();
  int? _expandedIndex;

  List<NameOfAllah> get _filtered => kNamesOfAllah
      .where((n) =>
          n.transliteration.toLowerCase().contains(_query.toLowerCase()) ||
          n.english.toLowerCase().contains(_query.toLowerCase()) ||
          n.hausa.toLowerCase().contains(_query.toLowerCase()) ||
          n.number.toString() == _query)
      .toList();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final names = _filtered;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.cream,
      body: CustomScrollView(
        slivers: [
          // Header
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
                                Text('99 Names of Allah', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                                Text('أسماء الله الحسنى', style: TextStyle(color: Colors.white60, fontSize: 12, fontFamily: AppTheme.arabicFontFamily)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 36),
                        ],
                      ),
                    ),
                    // Search
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: TextField(
                        controller: _ctrl,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Search by name or meaning...',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white60),
                          suffixIcon: _query.isNotEmpty
                              ? GestureDetector(
                                  onTap: () { _ctrl.clear(); setState(() => _query = ''); },
                                  child: const Icon(Icons.close_rounded, color: Colors.white60, size: 18),
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.12),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Count chip
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${names.length} names', style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),

          // Grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _NameCard(
                  name: names[i],
                  isDark: isDark,
                  isExpanded: _expandedIndex == i,
                  onTap: () => setState(() => _expandedIndex = _expandedIndex == i ? null : i),
                ),
                childCount: names.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  final NameOfAllah name;
  final bool isDark;
  final bool isExpanded;
  final VoidCallback onTap;

  const _NameCard({
    required this.name,
    required this.isDark,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isExpanded
              ? AppTheme.primaryGreen
              : (isDark ? AppTheme.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isExpanded
                ? AppTheme.primaryGreen
                : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
          ),
          boxShadow: isExpanded
              ? [BoxShadow(color: AppTheme.primaryGreen.withValues(alpha: 0.3), blurRadius: 16)]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number badge
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: isExpanded
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppTheme.primaryGreen.withValues(alpha: isDark ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${name.number}',
                  style: TextStyle(
                    color: isExpanded ? Colors.white : AppTheme.primaryGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Arabic
            Text(
              name.arabic,
              style: TextStyle(
                fontSize: 22,
                fontFamily: AppTheme.arabicFontFamily,
                color: isExpanded ? Colors.white : AppTheme.primaryGreen,
                height: 1.4,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 4),
            // Transliteration
            Text(
              name.transliteration,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isExpanded ? Colors.white.withValues(alpha: 0.9) : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // English
            Text(
              name.english,
              style: TextStyle(
                fontSize: 11,
                color: isExpanded ? Colors.white70 : (isDark ? Colors.white54 : Colors.black45),
              ),
              maxLines: isExpanded ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isExpanded) ...[
              const SizedBox(height: 4),
              Text(
                name.hausa,
                style: const TextStyle(fontSize: 10, color: AppTheme.lightGold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

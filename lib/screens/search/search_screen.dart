import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/surah_model.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../quran/surah_detail_screen.dart';

class _SearchResult {
  final SurahModel surah;
  final int ayahIndex; // -1 = surah match
  final String snippet;
  const _SearchResult({required this.surah, required this.ayahIndex, required this.snippet});
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  List<_SearchResult> _results = [];
  bool _searching = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q == _lastQuery) return;
    _lastQuery = q;

    if (q.isEmpty) {
      setState(() { _results = []; _searching = false; });
      return;
    }

    setState(() => _searching = true);

    final quran = context.read<QuranProvider>();
    final settings = context.read<SettingsProvider>();
    final ql = q.toLowerCase();
    final results = <_SearchResult>[];

    // 1. Surah name matches (instant)
    for (final s in quran.surahs) {
      if (s.nameEn.toLowerCase().contains(ql) ||
          s.meaning.toLowerCase().contains(ql) ||
          s.number.toString() == ql) {
        results.add(_SearchResult(
          surah: s, ayahIndex: -1,
          snippet: '${s.nameEn} · ${s.ayahCount} ayahs · ${s.meaning}',
        ));
      }
    }

    // 2. Translation content search (load all English data)
    if (q.length >= 3) {
      final lang = settings.translationLanguage;
      for (final s in quran.surahs) {
        final List<String> ayahs = lang == TranslationLanguage.hausa
            ? await quran.getHausaAyahs(s.number)
            : lang == TranslationLanguage.yoruba
                ? await quran.getYorubaAyahs(s.number)
                : await quran.getEnglishAyahs(s.number);

        // Stop if query changed while loading
        if (_lastQuery != q) return;

        for (int i = 0; i < ayahs.length; i++) {
          if (ayahs[i].toLowerCase().contains(ql)) {
            // Snippet: trim to 80 chars around match
            final text = ayahs[i];
            final idx = text.toLowerCase().indexOf(ql);
            final start = (idx - 30).clamp(0, text.length);
            final end = (idx + 60).clamp(0, text.length);
            final snippet = (start > 0 ? '…' : '') +
                text.substring(start, end) +
                (end < text.length ? '…' : '');

            results.add(_SearchResult(surah: s, ayahIndex: i, snippet: snippet));
            if (results.length >= 100) break;
          }
        }
        if (results.length >= 100) break;
      }
    }

    if (_lastQuery == q) {
      setState(() { _results = results; _searching = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.cream,
      body: Column(
        children: [
          // ── Search bar header ──
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.quranGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _ctrl,
                          focusNode: _focusNode,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          cursorColor: AppTheme.gold,
                          decoration: InputDecoration(
                            hintText: 'Search surahs, ayahs, topics…',
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13),
                            prefixIcon: const Icon(Icons.search_rounded, color: Colors.white60, size: 18),
                            suffixIcon: _ctrl.text.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      _ctrl.clear();
                                      _search('');
                                    },
                                    child: const Icon(Icons.close_rounded, color: Colors.white60, size: 18),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: _search,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Results ──
          Expanded(
            child: _ctrl.text.isEmpty
                ? _buildEmpty(isDark)
                : _searching
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.quranBlue))
                    : _results.isEmpty
                        ? _buildNoResults(isDark)
                        : _buildResults(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_rounded, size: 56, color: isDark ? Colors.white12 : Colors.black12),
          const SizedBox(height: 12),
          Text('Search the Qur\'an',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white38 : Colors.black38)),
          const SizedBox(height: 6),
          Text('By surah name, meaning, or translation text',
              style: TextStyle(fontSize: 12,
                  color: isDark ? Colors.white24 : Colors.black26)),
        ],
      ),
    );
  }

  Widget _buildNoResults(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sentiment_dissatisfied_rounded, size: 48, color: isDark ? Colors.white12 : Colors.black12),
          const SizedBox(height: 12),
          Text('No results for "${_ctrl.text}"',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.black38)),
        ],
      ),
    );
  }

  Widget _buildResults(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: _results.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text('${_results.length} results',
                style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
          );
        }
        final r = _results[i - 1];
        return _ResultCard(result: r, query: _ctrl.text, isDark: isDark);
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  final _SearchResult result;
  final String query;
  final bool isDark;
  const _ResultCard({required this.result, required this.query, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isSurahMatch = result.ayahIndex == -1;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => SurahDetailScreen(
            surah: result.surah,
            initialAyah: result.ayahIndex >= 0 ? result.ayahIndex : null,
          ),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                gradient: isSurahMatch ? AppTheme.quranGradient : null,
                color: isSurahMatch ? null : AppTheme.quranBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  isSurahMatch ? '${result.surah.number}' : '${result.ayahIndex + 1}',
                  style: TextStyle(
                    color: isSurahMatch ? Colors.white : AppTheme.quranBlue,
                    fontWeight: FontWeight.w800, fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(result.surah.nameEn,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                    if (!isSurahMatch) ...[
                      Text(' · Ayah ${result.ayahIndex + 1}',
                          style: TextStyle(fontSize: 11,
                              color: isDark ? Colors.white38 : Colors.black38)),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  _HighlightedText(
                    text: result.snippet,
                    query: query,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text, query;
  final bool isDark;
  const _HighlightedText({required this.text, required this.query, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis);
    }
    final lower = text.toLowerCase();
    final qLower = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    int idx;
    while ((idx = lower.indexOf(qLower, start)) != -1) {
      if (idx > start) spans.add(TextSpan(text: text.substring(start, idx)));
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: TextStyle(
          backgroundColor: AppTheme.gold.withValues(alpha: 0.25),
          color: AppTheme.quranBlue, fontWeight: FontWeight.w700,
        ),
      ));
      start = idx + query.length;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
        children: spans,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

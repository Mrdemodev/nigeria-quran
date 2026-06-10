import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/bookmark_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import '../services/share_image_service.dart';
import '../data/sajda_data.dart';

class AyahCard extends StatefulWidget {
  final int surahNumber;
  final int ayahIndex;
  final String arabicText;
  final String translationText;
  final String? secondTranslationText;
  final String surahName;
  final bool isMemorizationMode;
  final bool isRevealed;
  final VoidCallback? onReveal;
  final bool isHighlighted;

  const AyahCard({
    super.key,
    required this.surahNumber,
    required this.ayahIndex,
    required this.arabicText,
    required this.translationText,
    this.secondTranslationText,
    required this.surahName,
    this.isMemorizationMode = false,
    this.isRevealed = true,
    this.onReveal,
    this.isHighlighted = false,
  });

  @override
  State<AyahCard> createState() => _AyahCardState();
}

class _AyahCardState extends State<AyahCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000));
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    if (widget.isHighlighted) _glowCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(AyahCard old) {
    super.didUpdateWidget(old);
    if (widget.isHighlighted && !old.isHighlighted) {
      _glowCtrl.repeat(reverse: true);
    } else if (!widget.isHighlighted && old.isHighlighted) {
      _glowCtrl.stop();
      _glowCtrl.value = 0;
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = context.watch<BookmarkProvider>();
    final settings = context.watch<SettingsProvider>();
    final progress = context.watch<ProgressProvider>();
    final isDark = settings.isDarkMode;
    final ayahNumber = widget.ayahIndex + 1;
    final isBookmarked = bookmarks.isBookmarked(widget.surahNumber, ayahNumber);
    final hasNote = progress.getNoteForAyah(widget.surahNumber, ayahNumber) != null;
    final hi = widget.isHighlighted;

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, child) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: hi
              ? (isDark
                  ? const Color(0xFF0C1528)
                  : const Color(0xFFF0F5FB))
              : (isDark ? AppTheme.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hi
                ? AppTheme.quranBlue
                    .withValues(alpha: _glowAnim.value * 0.9)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04)),
            width: hi ? 2.0 : 1.0,
          ),
          boxShadow: hi
              ? [
                  BoxShadow(
                    color: AppTheme.quranBlue
                        .withValues(alpha: _glowAnim.value * 0.22),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  )
                ]
              : (isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ]),
        ),
        child: child,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header row ──
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: hi
                  ? AppTheme.quranBlue
                      .withValues(alpha: isDark ? 0.20 : 0.09)
                  : AppTheme.quranBlue
                      .withValues(alpha: isDark ? 0.12 : 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                // Ayah number badge
                Container(
                  width: 30, height: 30,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('$ayahNumber',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                // Sajda indicator
                if (isSajdaAyah(widget.surahNumber, ayahNumber)) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'سجدة',
                      style: AppTheme.arabicStyle(
                        fontSize: 11,
                        color: AppTheme.gold,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
                // Playing indicator
                if (hi) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.graphic_eq_rounded,
                      color: AppTheme.quranBlue, size: 16),
                ],
                const Spacer(),
                _AyahAction(
                  icon: isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: isBookmarked ? AppTheme.gold : Colors.grey,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _toggleBookmark(context, ayahNumber, isBookmarked);
                  },
                ),
                const SizedBox(width: 4),
                _AyahAction(
                  icon: hasNote ? Icons.sticky_note_2_rounded : Icons.sticky_note_2_outlined,
                  color: hasNote ? AppTheme.gold : Colors.grey,
                  onTap: () => _showNoteSheet(context, ayahNumber, progress),
                ),
                const SizedBox(width: 4),
                _AyahAction(
                  icon: Icons.share_rounded,
                  color: Colors.grey,
                  onTap: () => _showShareSheet(context, ayahNumber, isDark),
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
              color: isDark ? AppTheme.arabicBgDark : AppTheme.arabicBgLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.gold.withValues(alpha: isDark ? 0.10 : 0.22),
              ),
            ),
            child: widget.isMemorizationMode && !widget.isRevealed
                ? GestureDetector(
                    onTap: widget.onReveal,
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppTheme.quranBlue
                              .withValues(alpha: 0.12),
                          AppTheme.quranBlue
                              .withValues(alpha: 0.06),
                        ]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.quranBlue
                                .withValues(alpha: 0.2)),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility_outlined,
                                color: AppTheme.quranBlue,
                                size: 18),
                            SizedBox(width: 8),
                            Text('Tap to reveal',
                                style: TextStyle(
                                    color: AppTheme.quranBlue,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  )
                : _TajweedText(
                    text: widget.arabicText,
                    fontSize: settings.arabicFontSize,
                    isDark: isDark,
                  ),
          ),

          // ── Translation (hidden when Arabic-only mode is on) ──
          if (!settings.hideTranslation) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, widget.secondTranslationText != null ? 8 : 16),
              child: Text(
                widget.translationText,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.65,
                  color: isDark ? Colors.white60 : const Color(0xFF555555),
                ),
              ),
            ),
            // ── Second translation (dual-language mode) ──
            if (widget.secondTranslationText != null && widget.secondTranslationText!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(right: 8, top: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('HA', style: TextStyle(fontSize: 9, color: AppTheme.primaryGreen, fontWeight: FontWeight.w700)),
                    ),
                    Expanded(
                      child: Text(
                        widget.secondTranslationText!,
                        style: TextStyle(fontSize: 13, height: 1.6, color: isDark ? Colors.white54 : const Color(0xFF666666), fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else
            const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _toggleBookmark(
      BuildContext context, int ayahNumber, bool isBookmarked) async {
    final bookmarks = context.read<BookmarkProvider>();
    if (isBookmarked) {
      final bm =
          bookmarks.getBookmark(widget.surahNumber, ayahNumber);
      if (bm != null) bookmarks.removeBookmark(bm.id);
    } else {
      await bookmarks.addBookmark(
        surahNumber: widget.surahNumber,
        ayahNumber: ayahNumber,
        surahName: widget.surahName,
        ayahText: widget.arabicText,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ayah bookmarked'),
            backgroundColor: AppTheme.quranBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showNoteSheet(BuildContext context, int ayahNumber, ProgressProvider progress) {
    final existing = progress.getNoteForAyah(widget.surahNumber, ayahNumber);
    final ctrl = TextEditingController(text: existing?.text ?? '');
    final isDark = context.read<SettingsProvider>().isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.sticky_note_2_rounded, color: AppTheme.gold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.surahName} · Ayah $ayahNumber',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                  ),
                  if (existing != null) ...[
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        progress.deleteNote(existing.id);
                      },
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                autofocus: true,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Write your note, reflection, or tafsir here...',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(14),
                ),
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A1A), height: 1.6),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final text = ctrl.text.trim();
                    if (text.isNotEmpty) {
                      progress.saveNote(widget.surahNumber, ayahNumber, text);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save Note', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context, int ayahNumber, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Share Ayah', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Share.share('${widget.arabicText}\n\n${widget.translationText}\n\n— ${widget.surahName}, Ayah $ayahNumber\n\nQur\'an NG App');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.quranBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.quranBlue.withValues(alpha: 0.2)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.text_fields_rounded, color: AppTheme.quranBlue, size: 28),
                          SizedBox(height: 6),
                          Text('Share Text', style: TextStyle(color: AppTheme.quranBlue, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await ShareImageService.shareAyahAsImage(
                        surahName: widget.surahName,
                        ayahNumber: ayahNumber,
                        arabicText: widget.arabicText,
                        translationText: widget.translationText,
                        isDark: isDark,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.image_rounded, color: AppTheme.gold, size: 28),
                          SizedBox(height: 6),
                          Text('Share Image', style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Tajweed coloring ──────────────────────────────────

// ── Tajweed token (letter + its diacritics) ───────────

class _TToken {
  final String letter;
  final List<String> diacritics;
  _TToken(this.letter, this.diacritics);
  bool get hasSukoon => diacritics.contains('ْ');
  bool get hasShadda => diacritics.contains('ّ');
}

class _TajweedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool isDark;
  const _TajweedText(
      {required this.text, required this.fontSize, required this.isDark});

  // Diacritic codepoint ranges
  static bool _isDiacritic(String ch) {
    final c = ch.codeUnitAt(0);
    return (c >= 0x064B && c <= 0x065F) ||
        c == 0x0670 ||
        (c >= 0x06D6 && c <= 0x06DC) ||
        (c >= 0x06DF && c <= 0x06E4) ||
        (c >= 0x06E7 && c <= 0x06E8) ||
        (c >= 0x06EA && c <= 0x06ED);
  }

  static bool _isArabicLetter(String ch) {
    final c = ch.codeUnitAt(0);
    return (c >= 0x0621 && c <= 0x064A) || c == 0x0671;
  }

  // Noon Sakinah rule letter sets
  static const _ikhfaSet = {
    'ت', 'ث', 'ج', 'د', 'ذ', 'ز', 'س', 'ش',
    'ص', 'ض', 'ط', 'ظ', 'ف', 'ق', 'ك'
  };
  static const _idghamGhunnaSet = {'ي', 'ن', 'م', 'و'};
  static const _idghamNoGhunnaSet = {'ل', 'ر'};
  static const _qalqalaSet = {'ق', 'ط', 'ب', 'ج', 'د'};

  // Colors match tajweed_data.dart colorHex values
  static const _harakatColor      = Color(0xFFC62828); // red — diacritics
  static const _qalqalaColor      = Color(0xFFE65100); // deep orange
  static const _ghunnaColor       = Color(0xFFAD1457); // magenta — ن/م + shadda
  static const _ikhfaColor        = Color(0xFF6A1B9A); // purple
  static const _idghamGhunnaColor = Color(0xFF2E7D32); // green
  static const _idghamNoGhunnaColor = Color(0xFF00695C); // teal
  static const _iqlabColor        = Color(0xFFBF360C); // brown-red — ن before ب

  // Tokenise: group each Arabic base letter with its following diacritics
  static List<_TToken> _tokenise(String text) {
    final tokens = <_TToken>[];
    String? cur;
    final diacs = <String>[];
    for (final ch in text.characters) {
      if (_isDiacritic(ch)) {
        diacs.add(ch);
      } else {
        if (cur != null) tokens.add(_TToken(cur, List.from(diacs)));
        cur = ch;
        diacs.clear();
      }
    }
    if (cur != null) tokens.add(_TToken(cur, diacs));
    return tokens;
  }

  Color _colorForToken(List<_TToken> tokens, int idx, Color mainColor) {
    final t = tokens[idx];
    if (!_isArabicLetter(t.letter)) return mainColor;

    // Qalqala: qalqala letter with sukoon
    if (_qalqalaSet.contains(t.letter) && t.hasSukoon) return _qalqalaColor;

    // Ghunna: ن or م with shadda
    if ((t.letter == 'ن' || t.letter == 'م') && t.hasShadda) return _ghunnaColor;

    // Nun/Meem Sakinah contextual rules — look at next Arabic letter
    if ((t.letter == 'ن' || t.letter == 'م') && t.hasSukoon) {
      String? nextLetter;
      for (int j = idx + 1; j < tokens.length; j++) {
        if (_isArabicLetter(tokens[j].letter)) { nextLetter = tokens[j].letter; break; }
      }
      if (nextLetter != null) {
        if (t.letter == 'ن') {
          if (nextLetter == 'ب')                          return _iqlabColor;
          if (_idghamGhunnaSet.contains(nextLetter))     return _idghamGhunnaColor;
          if (_idghamNoGhunnaSet.contains(nextLetter))   return _idghamNoGhunnaColor;
          if (_ikhfaSet.contains(nextLetter))            return _ikhfaColor;
        } else { // م
          if (nextLetter == 'ب')  return _iqlabColor;       // Ikhfa Shafawi
          if (nextLetter == 'م')  return _idghamGhunnaColor; // Idgham Shafawi
        }
      }
    }

    return mainColor;
  }

  // Special Qur'anic characters that should always be gold
  static bool _isQuranicSpecial(String ch) {
    final c = ch.codeUnitAt(0);
    return c == 0x06DD || // ۝ end of ayah
        c == 0x06DE ||    // ۞ rub el-hizb
        c == 0x06E9 ||    // ۩ sajda
        c == 0xFDFD;      // ﷽ bismillah ligature
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = isDark ? AppTheme.arabicTextDark : AppTheme.arabicTextLight;
    final tokens = _tokenise(text);
    final spans = <TextSpan>[];

    for (int i = 0; i < tokens.length; i++) {
      final t = tokens[i];

      // Special Qur'anic characters → gold, no rule override
      if (_isQuranicSpecial(t.letter)) {
        spans.add(TextSpan(
            text: t.letter,
            style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w600)));
        for (final d in t.diacritics) {
          spans.add(TextSpan(text: d, style: const TextStyle(color: _harakatColor)));
        }
        continue;
      }

      final letterColor = _colorForToken(tokens, i, mainColor);
      spans.add(TextSpan(text: t.letter, style: TextStyle(color: letterColor)));
      for (final d in t.diacritics) {
        spans.add(TextSpan(text: d, style: const TextStyle(color: _harakatColor)));
      }
    }

    return RichText(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: AppTheme.arabicStyle(fontSize: fontSize),
        children: spans,
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────

class _AyahAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AyahAction(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

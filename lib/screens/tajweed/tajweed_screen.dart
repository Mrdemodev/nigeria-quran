import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../../data/tajweed_data.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class TajweedScreen extends StatefulWidget {
  const TajweedScreen({super.key});
  @override
  State<TajweedScreen> createState() => _TajweedScreenState();
}

class _TajweedScreenState extends State<TajweedScreen> {
  String _selected = 'All';

  static const List<String> _cats = [
    'All', 'Noon Sakinah', 'Meem Sakinah', 'Madd', 'Ghunnah', 'Qalqalah', 'Heavy & Light', 'Stopping & Starting',
  ];

  static const Map<String, IconData> _catIcons = {
    'All': Icons.auto_awesome_rounded,
    'Noon Sakinah': Icons.radio_button_checked_rounded,
    'Meem Sakinah': Icons.lens_rounded,
    'Madd': Icons.linear_scale_rounded,
    'Ghunnah': Icons.graphic_eq_rounded,
    'Qalqalah': Icons.vibration_rounded,
    'Heavy & Light': Icons.balance_rounded,
    'Stopping & Starting': Icons.stop_circle_rounded,
  };

  List<TajweedRule> get _filtered =>
      _selected == 'All' ? kTajweedRules : kTajweedRules.where((r) => r.category == _selected).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF5F3FF),
      body: Column(
        children: [
          // ── Header ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0050), Color(0xFF4527A0), Color(0xFF673AB7)],
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
                              const Text('Learn Tajweed',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                              Text('${_filtered.length} rules',
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
                            const Icon(Icons.menu_book_rounded, color: AppTheme.gold, size: 14),
                            const SizedBox(width: 4),
                            Text('${kTajweedRules.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
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
                                  color: sel ? const Color(0xFF4527A0) : Colors.white.withValues(alpha: 0.8)),
                              const SizedBox(width: 5),
                              Text(cat,
                                  style: TextStyle(
                                      color: sel ? const Color(0xFF4527A0) : Colors.white.withValues(alpha: 0.9),
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

          // ── Rules list ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => _RuleCard(rule: _filtered[i], isDark: isDark, screenWidth: size.width),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleCard extends StatefulWidget {
  final TajweedRule rule;
  final bool isDark;
  final double screenWidth;
  const _RuleCard({required this.rule, required this.isDark, required this.screenWidth});
  @override
  State<_RuleCard> createState() => _RuleCardState();
}

class _RuleCardState extends State<_RuleCard> {
  bool _expanded = false;
  AudioPlayer? _player;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final url = widget.rule.audioUrl;
    if (url == null) return;
    HapticFeedback.lightImpact();

    if (_isPlaying) {
      await _player?.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      _player ??= AudioPlayer();
      await _player!.setUrl(url);
      if (!mounted) return;
      setState(() { _isLoading = false; _isPlaying = true; });
      await _player!.play();
      if (mounted) setState(() => _isPlaying = false);
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _isPlaying = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final color = Color(widget.rule.colorHex);

    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _expanded = !_expanded); },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.12)),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
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
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        widget.rule.arabicName.characters.first,
                        style: AppTheme.arabicStyle(fontSize: 16, color: color, fontWeight: FontWeight.w700),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                            child: Text(widget.rule.category,
                                style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                        const SizedBox(height: 3),
                        Text(widget.rule.name,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                        Text(widget.rule.arabicName,
                            style: AppTheme.arabicStyle(fontSize: 13,
                                color: isDark ? Colors.white54 : Colors.black38),
                            textDirection: TextDirection.rtl),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: color, size: 20),
                ],
              ),
            ),

            // ── Expanded content ──
            if (_expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Letters
                    if (widget.rule.arabicLetters.isNotEmpty) ...[
                      Text('Letters / Trigger',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white54 : Colors.black45)),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isDark ? 0.10 : 0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.rule.arabicLetters,
                          textDirection: TextDirection.rtl,
                          style: AppTheme.arabicStyle(
                            fontSize: 20, color: color,
                            fontWeight: FontWeight.w700,
                            height: 1.8, letterSpacing: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Example
                    Row(
                      children: [
                        Text('Example',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white54 : Colors.black45)),
                        const Spacer(),
                        if (widget.rule.audioUrl != null)
                          GestureDetector(
                            onTap: _togglePlay,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _isPlaying
                                    ? color.withValues(alpha: 0.2)
                                    : color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: color.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isLoading)
                                    SizedBox(
                                      width: 12, height: 12,
                                      child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
                                    )
                                  else
                                    Icon(
                                      _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                                      size: 13, color: color,
                                    ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isPlaying ? 'Stop' : 'Hear',
                                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.arabicBgDark : AppTheme.arabicBgLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.gold.withValues(alpha: isDark ? 0.10 : 0.20)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(widget.rule.arabicExample,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: AppTheme.arabicStyle(fontSize: 24, height: 1.8,
                                  color: isDark ? AppTheme.arabicTextDark : AppTheme.arabicTextLight)),
                          const SizedBox(height: 6),
                          Text(widget.rule.exampleTranslation,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38,
                                  fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Explanation
                    Text('Explanation',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white54 : Colors.black45)),
                    const SizedBox(height: 5),
                    Text(widget.rule.explanation,
                        style: TextStyle(fontSize: 12.5, height: 1.65,
                            color: isDark ? Colors.white70 : const Color(0xFF333333))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

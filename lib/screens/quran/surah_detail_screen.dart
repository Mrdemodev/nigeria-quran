import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/ads_service.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../models/surah_model.dart';
import '../../providers/quran_provider.dart';
import '../../providers/audio_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/download_provider.dart';
import '../../data/reciters_data.dart';
import '../../data/juz_data.dart';
import '../../app.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ayah_card.dart';
import 'player_screen.dart';

class SurahDetailScreen extends StatefulWidget {
  final SurahModel surah;
  /// 0-based ayah index to scroll to on open. Defaults to last-read position.
  final int? initialAyah;
  const SurahDetailScreen({super.key, required this.surah, this.initialAyah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> with RouteAware {
  List<String> _arabicAyahs = [];
  List<String> _translationAyahs = [];
  List<String> _secondTranslationAyahs = [];
  bool _isLoading = true;
  bool _isMemorizationMode = false;
  bool _isFullscreen = false;
  bool _showBothTranslations = false;
  final Set<int> _revealedAyahs = {};

  // Scroll-by-index controller — works even when the target item isn't rendered
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  Timer? _savePositionTimer;

  // Audio ayah tracking
  int _lastHighlightedIndex = -1;
  // Hybrid timing weights: blend of char-count and linear to handle short/long ayahs
  List<double> _ayahWeights = [];

  // Pinch-to-zoom
  double _pinchFontBase = 26.0;

  // Auto-advance navigation
  AudioProvider? _audioProvider;
  bool _trackingAudio = false;

  bool get _hasBismillah => widget.surah.number != 9 && widget.surah.number != 1;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_onPositionsChanged);
    _loadAyahs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioProvider?.removeListener(_onAudioChanged);
    _audioProvider = context.read<AudioProvider>();
    _audioProvider!.addListener(_onAudioChanged);
    final route = ModalRoute.of(context);
    if (route != null) appRouteObserver.subscribe(this, route);
  }

  @override
  void didPopNext() {
    // Returned to this screen — force scroll to current ayah
    setState(() => _lastHighlightedIndex = -1);
  }

  void _onAudioChanged() {
    if (!mounted) return;
    final audio = _audioProvider;
    if (audio == null) return;
    final playing = audio.currentSurahNumber;
    // Start tracking once this surah is the one playing
    if (playing == widget.surah.number) {
      _trackingAudio = true;
      return;
    }
    // Auto-advance: audio moved to a different surah while we were tracking
    if (_trackingAudio && playing != null && playing != widget.surah.number) {
      _trackingAudio = false;
      final quran = context.read<QuranProvider>();
      final nextSurah = quran.getSurah(playing);
      if (nextSurah != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SurahDetailScreen(surah: nextSurah),
            ),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _savePositionTimer?.cancel();
    _itemPositionsListener.itemPositions.removeListener(_onPositionsChanged);
    appRouteObserver.unsubscribe(this);
    _audioProvider?.removeListener(_onAudioChanged);
    super.dispose();
  }

  void _onPositionsChanged() {
    _savePositionTimer?.cancel();
    _savePositionTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final positions = _itemPositionsListener.itemPositions.value;
      if (positions.isEmpty) return;
      final top = positions.reduce((a, b) => a.index < b.index ? a : b);
      final ayahIdx = top.index;
      if (ayahIdx >= 0 && ayahIdx < _arabicAyahs.length) {
        context.read<SettingsProvider>().saveLastRead(widget.surah.number, ayahIdx + 1);
      }
    });
  }

  Future<void> _loadAyahs() async {
    final quran = context.read<QuranProvider>();
    final settings = context.read<SettingsProvider>();
    // Make a mutable copy so we can strip the bismillah prefix
    final arabic = List<String>.from(await quran.getArabicAyahs(widget.surah.number));
    // The data stores bismillah fused into ayah 1 of each surah (except 1 and 9).
    // Strip it so the header widget doesn't duplicate it, and char-weight is accurate.
    if (_hasBismillah && arabic.isNotEmpty) {
      final fatiha = await quran.getArabicAyahs(1);
      if (fatiha.isNotEmpty) {
        final f0 = fatiha[0];
        final bismillah = (f0.startsWith('﻿') ? f0.substring(1) : f0).trim();
        if (bismillah.isNotEmpty && arabic[0].startsWith(bismillah)) {
          arabic[0] = arabic[0].substring(bismillah.length).trimLeft();
        }
      }
    }
    final translation = settings.translationLanguage == TranslationLanguage.hausa
        ? await quran.getHausaAyahs(widget.surah.number)
        : settings.translationLanguage == TranslationLanguage.yoruba
            ? await quran.getYorubaAyahs(widget.surah.number)
            : await quran.getEnglishAyahs(widget.surah.number);
    List<String> second = [];
    if (_showBothTranslations) {
      // Show English as second when primary is Hausa or Yoruba, else show Hausa
      second = settings.translationLanguage == TranslationLanguage.english
          ? await quran.getHausaAyahs(widget.surah.number)
          : await quran.getEnglishAyahs(widget.surah.number);
    }
    // Char-weight with minimum floor: each ayah gets at least 1/(2*N) share.
    // Prevents very short ayahs (like "الم") from being skipped after just 500 ms.
    final totalChars = arabic.fold(0, (sum, a) => sum + a.length);
    final weights = <double>[];
    if (totalChars > 0 && arabic.isNotEmpty) {
      final minShare = 1.0 / (2 * arabic.length);
      double rawTotal = 0;
      final raw = arabic.map((a) {
        final w = (a.length / totalChars).clamp(minShare, 1.0);
        rawTotal += w;
        return w;
      }).toList();
      double cumulative = 0;
      for (final w in raw) {
        cumulative += w / rawTotal;
        weights.add(cumulative.clamp(0.0, 1.0));
      }
    }

    if (!mounted) return;
    setState(() {
      _arabicAyahs = arabic;
      _translationAyahs = translation;
      _secondTranslationAyahs = second;
      _ayahWeights = weights;
      _isLoading = false;
    });
    // Determine target ayah: explicit > per-ayah index > char-weight > last-read > start
    final audio = context.read<AudioProvider>();
    final int targetAyah;
    if (widget.initialAyah != null) {
      targetAyah = widget.initialAyah!;
    } else if (audio.currentSurahNumber == widget.surah.number && audio.isPerAyahMode) {
      targetAyah = audio.currentAyahIndex.clamp(0, arabic.length - 1);
    } else if (audio.currentSurahNumber == widget.surah.number &&
               audio.duration.inMilliseconds > 0 &&
               arabic.isNotEmpty) {
      final fraction = (audio.position.inMilliseconds / audio.duration.inMilliseconds).clamp(0.0, 1.0);
      if (weights.isNotEmpty) {
        final idx = weights.indexWhere((w) => fraction <= w);
        targetAyah = idx < 0 ? arabic.length - 1 : idx;
      } else {
        targetAyah = (fraction * arabic.length).floor().clamp(0, arabic.length - 1);
      }
    } else {
      targetAyah = settings.lastReadSurah == widget.surah.number
          ? settings.lastReadAyah - 1
          : 0;
    }
    context.read<SettingsProvider>().saveLastRead(widget.surah.number, targetAyah + 1);
    // Track progress
    context.read<ProgressProvider>().updateSurahProgress(widget.surah.number, targetAyah + 1, arabic.length);
    // If audio is playing this surah, build() drives the scroll via _lastHighlightedIndex.
    final audioPlayingThis = audio.currentSurahNumber == widget.surah.number &&
        (audio.isPerAyahMode || audio.duration.inMilliseconds > 0);
    if (!audioPlayingThis && targetAyah > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToAyah(targetAyah, animate: false);
      });
    }
  }

  Widget _buildDownloadBtn(BuildContext context, SettingsProvider settings) {
    final downloads = context.watch<DownloadProvider>();
    final surahNum = widget.surah.number;
    final reciterId = settings.selectedReciterId;
    final isDownloading = downloads.isDownloading(surahNum);
    final isDownloaded = downloads.isDownloaded(surahNum, reciterId);
    final progress = downloads.progress[surahNum] ?? 0.0;

    return GestureDetector(
      onTap: () {
        if (isDownloading) {
          downloads.cancelDownload(surahNum);
        } else if (isDownloaded) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Delete Download?'),
              content: const Text('Remove downloaded audio for this surah?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(
                  onPressed: () { Navigator.pop(context); downloads.deleteDownload(surahNum, reciterId); },
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        } else {
          final reciter = kReciters.firstWhere((r) => r.id == reciterId, orElse: () => kReciters.first);
          downloads.download(surahNum, reciterId, reciter.audioUrl(surahNum));
        }
      },
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: isDownloaded
              ? AppTheme.primaryGreen.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: isDownloading
            ? Padding(
                padding: const EdgeInsets.all(8),
                child: CircularProgressIndicator(value: progress, strokeWidth: 2, color: AppTheme.gold),
              )
            : Icon(
                isDownloaded ? Icons.download_done_rounded : Icons.download_rounded,
                color: isDownloaded ? AppTheme.gold : Colors.white,
                size: 18,
              ),
      ),
    );
  }

  void _scrollToAyah(int ayahIndex, {bool animate = true}) {
    if (!mounted || ayahIndex < 0 || ayahIndex >= _arabicAyahs.length) return;
    if (!_itemScrollController.isAttached) return;
    if (animate) {
      // Don't scroll if the ayah is already fully visible — avoids constant jitter
      final positions = _itemPositionsListener.itemPositions.value;
      final alreadyVisible = positions.any((p) =>
          p.index == ayahIndex &&
          p.itemLeadingEdge >= 0.0 &&
          p.itemTrailingEdge <= 1.0);
      if (alreadyVisible) return;
      _itemScrollController.scrollTo(
        index: ayahIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
    } else {
      _itemScrollController.jumpTo(index: ayahIndex, alignment: 0.15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;
    final isPlayingThis = audio.currentSurahNumber == widget.surah.number;

    // Highlight current ayah — per-ayah index when available, char-weight fallback
    int highlightedAyahIndex = -1;
    if (isPlayingThis && _arabicAyahs.isNotEmpty) {
      if (audio.isPerAyahMode) {
        highlightedAyahIndex = audio.currentAyahIndex.clamp(0, _arabicAyahs.length - 1);
      } else if (audio.duration.inMilliseconds > 0) {
        final fraction = (audio.position.inMilliseconds / audio.duration.inMilliseconds).clamp(0.0, 1.0);
        if (_ayahWeights.isNotEmpty) {
          highlightedAyahIndex = _ayahWeights.indexWhere((w) => fraction <= w);
          if (highlightedAyahIndex < 0) highlightedAyahIndex = _arabicAyahs.length - 1;
        } else {
          highlightedAyahIndex = (fraction * _arabicAyahs.length).floor().clamp(0, _arabicAyahs.length - 1);
        }
      }
    }
    // Auto-scroll to newly highlighted ayah
    if (highlightedAyahIndex >= 0 && highlightedAyahIndex != _lastHighlightedIndex) {
      _lastHighlightedIndex = highlightedAyahIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToAyah(highlightedAyahIndex);
      });
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.cream,
      body: Stack(
        children: [
        Column(
        children: [
          // ── Status bar padding in fullscreen ──
          if (_isFullscreen) SizedBox(height: MediaQuery.of(context).padding.top),
          // ── Header (hidden in fullscreen) ──
          if (!_isFullscreen) Container(
            decoration: const BoxDecoration(gradient: AppTheme.quranGradient),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            AdsService.instance.showInterstitial();
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(widget.surah.nameEn,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700)),
                              Text(widget.surah.nameAr,
                                  style: AppTheme.arabicStyle(
                                      fontSize: 15, color: Colors.white70),
                                  textDirection: TextDirection.rtl),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isMemorizationMode = !_isMemorizationMode;
                                  _revealedAyahs.clear();
                                });
                              },
                              child: Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: _isMemorizationMode
                                      ? AppTheme.gold.withValues(alpha: 0.3)
                                      : Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _isMemorizationMode
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: _isMemorizationMode
                                      ? AppTheme.gold
                                      : Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Download audio
                            _buildDownloadBtn(context, settings),
                            const SizedBox(width: 8),
                            // Translation / display options
                            GestureDetector(
                              onTap: () => _showTranslationOptions(context, settings),
                              child: Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: (settings.hideTranslation || _showBothTranslations)
                                      ? AppTheme.primaryGreen.withValues(alpha: 0.35)
                                      : Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.translate_rounded,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Fullscreen toggle
                            GestureDetector(
                              onTap: () => setState(() => _isFullscreen = true),
                              child: Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.fullscreen_rounded,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Open full player
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      const PlayerScreen(),
                                  transitionsBuilder: (_, anim, __, child) =>
                                      SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 1),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                        parent: anim,
                                        curve: Curves.easeOutCubic)),
                                    child: child,
                                  ),
                                ),
                              ),
                              child: Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.queue_music_rounded,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Info strip
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _InfoChip(label: '${widget.surah.ayahCount} Ayahs'),
                        const SizedBox(width: 8),
                        _InfoChip(label: widget.surah.type),
                        const SizedBox(width: 8),
                        _InfoChip(label: 'Surah ${widget.surah.number}'),
                        if (isPlayingThis) ...[
                          const SizedBox(width: 8),
                          _NowPlayingChip(audio: audio),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bismillah header (free header — not part of the ayah list) ──
          if (!_isLoading && _hasBismillah)
            _BismillahHeader(isDark: isDark),

          // ── Ayah list ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.quranBlue))
                : GestureDetector(
                    onScaleStart: (_) {
                      _pinchFontBase = settings.arabicFontSize;
                    },
                    onScaleUpdate: (details) {
                      if (details.pointerCount < 2) return;
                      context.read<SettingsProvider>()
                          .setArabicFontSizeTemp(_pinchFontBase * details.scale);
                    },
                    onScaleEnd: (_) {
                      context.read<SettingsProvider>()
                          .setArabicFontSize(settings.arabicFontSize);
                    },
                    child: ScrollablePositionedList.builder(
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: _itemPositionsListener,
                      padding: const EdgeInsets.only(bottom: 120),
                      itemCount: _arabicAyahs.length,
                      itemBuilder: (ctx, i) {
                        final ayahNumber = i + 1;
                        final juz = kJuzData.where((j) =>
                          j.startSurah == widget.surah.number &&
                          j.startAyah == ayahNumber).firstOrNull;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (juz != null) _JuzBanner(
                              juzNumber: juz.juzNumber,
                              arabicName: juz.arabicName,
                              isDark: settings.isDarkMode,
                            ),
                            AyahCard(
                              surahNumber: widget.surah.number,
                              ayahIndex: i,
                              arabicText: _arabicAyahs[i],
                              translationText: i < _translationAyahs.length
                                  ? _translationAyahs[i]
                                  : '',
                              secondTranslationText: _showBothTranslations && i < _secondTranslationAyahs.length
                                  ? _secondTranslationAyahs[i]
                                  : null,
                              surahName: widget.surah.nameEn,
                              isMemorizationMode: _isMemorizationMode,
                              isRevealed: _revealedAyahs.contains(i),
                              onReveal: () =>
                                  setState(() => _revealedAyahs.add(i)),
                              isHighlighted: i == highlightedAyahIndex,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),

      // ── Fullscreen exit button ──
      if (_isFullscreen)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 12,
          child: GestureDetector(
            onTap: () => setState(() => _isFullscreen = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.quranBlue.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fullscreen_exit_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('Exit', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ],
      ),

      // ── Play / Pause FAB ──
      floatingActionButton: _isFullscreen ? null : FloatingActionButton.extended(
        onPressed: () => _handlePlay(context, settings, audio),
        backgroundColor: isPlayingThis && audio.isPlaying
            ? Colors.red.shade700
            : AppTheme.quranBlue,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: audio.isLoading && isPlayingThis
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Icon(
                isPlayingThis && audio.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 26,
              ),
        label: Text(
          audio.isLoading && isPlayingThis
              ? 'Loading...'
              : isPlayingThis
                  ? (audio.isPlaying ? 'Pause' : 'Resume')
                  : 'Play',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _handlePlay(
      BuildContext context, SettingsProvider settings, AudioProvider audio) async {
    final isPlayingThis = audio.currentSurahNumber == widget.surah.number;
    if (isPlayingThis) {
      await audio.playPause();
    } else {
      // Use local file if downloaded (instant playback, no buffering)
      final downloads = context.read<DownloadProvider>();
      final quran = context.read<QuranProvider>();
      final local = await downloads.localPath(widget.surah.number, settings.selectedReciterId);
      await audio.playSurah(
        surahNumber: widget.surah.number,
        surahName: widget.surah.nameEn,
        reciterId: settings.selectedReciterId,
        localPath: local,
        ayahCount: _arabicAyahs.length,
        surahNameFn: (n) => quran.getSurah(n)?.nameEn ?? 'Surah $n',
        surahAyahCountFn: (n) => quran.getSurah(n)?.ayahCount,
      );
    }
  }

  void _showTranslationOptions(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: BoxDecoration(
            color: settings.isDarkMode ? AppTheme.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Display Options',
                  style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16,
                    color: settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  )),
              const SizedBox(height: 16),
              // Arabic Only toggle
              _OptionRow(
                label: 'Arabic Only',
                subtitle: 'Hide translation text',
                isDark: settings.isDarkMode,
                trailing: Switch(
                  value: settings.hideTranslation,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (v) {
                    setSheetState(() {});
                    settings.setHideTranslation(v);
                  },
                ),
              ),
              // Dual Translation toggle
              _OptionRow(
                label: 'Show Both Translations',
                subtitle: 'Display a second translation',
                isDark: settings.isDarkMode,
                trailing: Switch(
                  value: _showBothTranslations,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: settings.hideTranslation ? null : (v) {
                    setSheetState(() {});
                    setState(() => _showBothTranslations = v);
                    _loadAyahs();
                  },
                ),
              ),
              if (!settings.hideTranslation) ...[
                Divider(color: Colors.grey.withValues(alpha: 0.15), height: 24),
                Text('Translation Language',
                    style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13,
                      color: settings.isDarkMode ? Colors.white60 : Colors.black54,
                    )),
                const SizedBox(height: 8),
                ...[
                  ('English', TranslationLanguage.english),
                  ('Hausa', TranslationLanguage.hausa),
                  ('Yoruba', TranslationLanguage.yoruba),
                ].map((e) {
                  final selected = settings.translationLanguage == e.$2;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.$1,
                        style: TextStyle(
                          color: selected
                              ? AppTheme.primaryGreen
                              : (settings.isDarkMode ? Colors.white : const Color(0xFF1A1A1A)),
                          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                        )),
                    trailing: selected
                        ? const Icon(Icons.check_rounded, color: AppTheme.primaryGreen, size: 18)
                        : null,
                    onTap: () {
                      setSheetState(() {});
                      settings.setTranslation(e.$2);
                      _loadAyahs();
                    },
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isDark;
  final Widget trailing;
  const _OptionRow({
    required this.label,
    required this.subtitle,
    required this.isDark,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    )),
                Text(subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black38,
                    )),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ── Now Playing chip shown in header ──────────────────

class _NowPlayingChip extends StatefulWidget {
  final AudioProvider audio;
  const _NowPlayingChip({required this.audio});
  @override
  State<_NowPlayingChip> createState() => _NowPlayingChipState();
}

class _NowPlayingChipState extends State<_NowPlayingChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }
  @override
  void dispose() { _pulse.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.6, end: 1.0).animate(_pulse),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.gold.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.graphic_eq_rounded, color: AppTheme.gold, size: 12),
          const SizedBox(width: 4),
          const Text('Playing',
              style: TextStyle(color: AppTheme.gold, fontSize: 10, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────

class _BismillahHeader extends StatelessWidget {
  final bool isDark;
  const _BismillahHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppTheme.primaryGreen.withValues(alpha: isDark ? 0.12 : 0.06),
          AppTheme.gold.withValues(alpha: isDark ? 0.06 : 0.03),
        ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (r) => const LinearGradient(
              colors: [AppTheme.gold, AppTheme.lightGold, AppTheme.gold],
            ).createShader(r),
            child: Text('﷽',
                style: AppTheme.arabicStyle(
                    fontSize: 36, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 4),
          Text(
            'In the name of Allah, the Most Gracious, the Most Merciful',
            style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 11)),
    );
  }
}

// ── AudioFolderSetupScreen (kept for settings import compatibility) ──────────

class AudioFolderSetupScreen extends StatelessWidget {
  const AudioFolderSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Info'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_rounded, size: 60, color: AppTheme.primaryGreen),
              SizedBox(height: 16),
              Text('Streaming Audio',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text(
                'Audio is streamed directly from the internet.\nSelect a reciter from the Quran screen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JuzBanner extends StatelessWidget {
  final int juzNumber;
  final String arabicName;
  final bool isDark;

  const _JuzBanner({
    required this.juzNumber,
    required this.arabicName,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.quranBlue.withValues(alpha: isDark ? 0.35 : 0.12),
            AppTheme.quranBlue.withValues(alpha: isDark ? 0.15 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.quranBlue.withValues(alpha: isDark ? 0.35 : 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 26, height: 26,
            decoration: const BoxDecoration(
              gradient: AppTheme.quranGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$juzNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Juz $juzNumber',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isDark ? Colors.white70 : AppTheme.quranBlue,
            ),
          ),
          const Spacer(),
          Text(
            arabicName,
            style: AppTheme.arabicStyle(
              fontSize: 15,
              color: AppTheme.gold,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

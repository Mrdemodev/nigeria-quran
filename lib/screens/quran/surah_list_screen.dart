import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/ad_banner.dart';
import '../../providers/audio_provider.dart';
import '../../providers/download_provider.dart';
import '../../data/reciters_data.dart';
import '../../models/reciter_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mini_player.dart';
import 'surah_detail_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _query = '';
  bool _showSearch = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quran = context.watch<QuranProvider>();
    final settings = context.watch<SettingsProvider>();
    final audio = context.watch<AudioProvider>();
    final download = context.watch<DownloadProvider>();
    final isDark = settings.isDarkMode;
    final surahs = quran.searchSurahs(_query);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.cream,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBanner(),
          if (audio.hasAudio) const MiniPlayer(),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: _showSearch ? 130 : 110,
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: AppTheme.quranBlue,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.quranGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _HdrBtn(
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  onTap: () => Navigator.pop(context),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Al-Quran',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      '${surahs.length} Surahs',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _HdrBtn(
                                  icon: _showSearch
                                      ? Icons.close_rounded
                                      : Icons.search_rounded,
                                  onTap: () => setState(() {
                                    _showSearch = !_showSearch;
                                    if (!_showSearch) {
                                      _searchCtrl.clear();
                                      _query = '';
                                    }
                                  }),
                                ),
                                const SizedBox(width: 8),
                                _HdrBtn(
                                  icon: Icons.mic_rounded,
                                  onTap: () => _showReciterSheet(context, settings),
                                ),
                                const SizedBox(width: 8),
                                _HdrBtn(
                                  icon: download.isBulkDownloading
                                      ? Icons.downloading_rounded
                                      : Icons.download_rounded,
                                  onTap: () => _showDownloadSheet(context, settings, download),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (_showSearch) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _searchCtrl,
                            autofocus: true,
                            onChanged: (v) => setState(() => _query = v),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search surah name or meaning...',
                              hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 13),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  size: 20),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: quran.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.quranBlue))
            : quran.error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 56, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(quran.error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  )
            : surahs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text('No surah found for "$_query"',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: surahs.length,
                    itemBuilder: (_, i) {
                      final s = surahs[i];
                      final isPlaying =
                          audio.currentSurahNumber == s.number;
                      final isPlayingNow = isPlaying && audio.isPlaying;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SurahDetailScreen(surah: s),
                              ));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isPlaying
                                ? AppTheme.quranBlue
                                    .withValues(alpha: isDark ? 0.15 : 0.07)
                                : (isDark
                                    ? AppTheme.darkCard
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: isPlaying
                                ? Border.all(
                                    color: AppTheme.quranBlue
                                        .withValues(alpha: 0.4))
                                : Border.all(color: Colors.transparent),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2))
                                  ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: isPlaying
                                      ? AppTheme.quranGradient
                                      : LinearGradient(colors: [
                                          AppTheme.quranBlue.withValues(
                                              alpha: isDark ? 0.3 : 0.12),
                                          AppTheme.quranBlue.withValues(
                                              alpha: isDark ? 0.15 : 0.06),
                                        ]),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: isPlayingNow
                                    ? const Icon(
                                        Icons.volume_up_rounded,
                                        color: Colors.white,
                                        size: 18)
                                    : Center(
                                        child: Text(
                                          '${s.number}',
                                          style: TextStyle(
                                            color: isPlaying
                                                ? Colors.white
                                                : AppTheme.quranBlue,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.nameEn,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    if (s.meaning.isNotEmpty) ...[
                                      const SizedBox(height: 1),
                                      Text(
                                        s.meaning,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.black38,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 3),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _SurahChip(
                                            '${s.ayahCount} ayahs',
                                            isDark: isDark),
                                        const SizedBox(width: 6),
                                        _SurahChip(s.type,
                                            isDark: isDark,
                                            isType: true),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 72,
                                child: Text(
                                  s.nameAr,
                                  style: AppTheme.arabicStyle(
                                    fontSize: 17, height: 1.4,
                                    color: isPlaying ? AppTheme.quranBlue : AppTheme.gold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.right,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  void _showReciterSheet(
      BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReciterSheet(settings: settings),
    );
  }

  void _showDownloadSheet(
      BuildContext context, SettingsProvider settings, DownloadProvider download) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DownloadSheet(settings: settings, download: download),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────

class _SurahChip extends StatelessWidget {
  final String text;
  final bool isDark;
  final bool isType;
  const _SurahChip(this.text,
      {required this.isDark, this.isType = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isType
            ? AppTheme.gold.withValues(alpha: isDark ? 0.2 : 0.1)
            : (isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFF0F4F0)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: isType
              ? AppTheme.gold
              : (isDark ? Colors.white54 : Colors.black45),
          fontWeight: isType ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _ReciterSheet extends StatelessWidget {
  final SettingsProvider settings;
  const _ReciterSheet({required this.settings});

  @override
  Widget build(BuildContext context) {
    final isDark = settings.isDarkMode;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.mic_rounded,
                    color: AppTheme.quranBlue, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Select Reciter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _ReciterSection('Featured Reciters', isDark),
                ...kReciters
                    .where((r) => r.isFeatured)
                    .map((r) => _ReciterTile(
                        r: r, settings: settings, isDark: isDark)),
                _ReciterSection('More Reciters', isDark),
                ...kReciters
                    .where((r) => !r.isFeatured)
                    .map((r) => _ReciterTile(
                        r: r, settings: settings, isDark: isDark)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReciterSection extends StatelessWidget {
  final String title;
  final bool isDark;
  const _ReciterSection(this.title, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(title,
          style: const TextStyle(
              color: AppTheme.quranBlue,
              fontWeight: FontWeight.w700,
              fontSize: 12)),
    );
  }
}

class _ReciterTile extends StatelessWidget {
  final ReciterModel r;
  final SettingsProvider settings;
  final bool isDark;
  const _ReciterTile(
      {required this.r, required this.settings, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isSelected = settings.selectedReciterId == r.id;
    return GestureDetector(
      onTap: () async {
        await settings.setSelectedReciter(r.id);
        if (!context.mounted) return;
        final audio = context.read<AudioProvider>();
        if (audio.hasAudio && audio.currentSurahNumber != null) {
          audio.playSurah(
            surahNumber: audio.currentSurahNumber!,
            surahName: audio.currentSurahName ?? '',
            reciterId: r.id,
          );
        }
        if (context.mounted) Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.quranBlue
                  .withValues(alpha: isDark ? 0.2 : 0.08)
              : (isDark
                  ? AppTheme.darkCard2
                  : const Color(0xFFF8F8F8)),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(
                  color:
                      AppTheme.quranBlue.withValues(alpha: 0.5))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient:
                    isSelected ? AppTheme.primaryGradient : null,
                color: isSelected
                    ? null
                    : (isDark
                        ? AppTheme.darkCard
                        : const Color(0xFFEEEEEE)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                r.isFeatured
                    ? Icons.star_rounded
                    : Icons.person_rounded,
                color: isSelected ? Colors.white : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name,
                      style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A1A))),
                  Text(r.origin,
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white38
                              : Colors.black38)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.quranBlue, size: 20),
          ],
        ),
      ),
    );
  }
}

class _HdrBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HdrBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      );
}

class _DownloadSheet extends StatelessWidget {
  final SettingsProvider settings;
  final DownloadProvider download;
  const _DownloadSheet({required this.settings, required this.download});

  @override
  Widget build(BuildContext context) {
    final isDark = settings.isDarkMode;
    final reciterId = settings.selectedReciterId;
    final reciter = kReciters.firstWhere(
      (r) => r.id == reciterId,
      orElse: () => kReciters.first,
    );
    final downloaded = List.generate(114, (i) => download.isDownloaded(i + 1, reciterId))
        .where((v) => v)
        .length;
    final downloading = download.progress.length;
    final remaining = 114 - downloaded - downloading;

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.quranBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.download_rounded, color: AppTheme.quranBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Download Surahs',
                          style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          )),
                      Text(reciter.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _StatBadge(label: 'Downloaded', value: '$downloaded', color: AppTheme.primaryGreen, isDark: isDark),
                const SizedBox(width: 10),
                _StatBadge(label: 'In Progress', value: '$downloading', color: AppTheme.quranBlue, isDark: isDark),
                const SizedBox(width: 10),
                _StatBadge(label: 'Remaining', value: '$remaining', color: AppTheme.gold, isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (downloading > 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: downloaded / 114,
                  backgroundColor: isDark ? Colors.white12 : Colors.black12,
                  color: AppTheme.quranBlue,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Downloading $downloading surah${downloading > 1 ? 's' : ''}...',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              children: [
                if (downloading > 0)
                  _ActionBtn(
                    label: 'Cancel All Downloads',
                    icon: Icons.cancel_rounded,
                    color: Colors.red,
                    onTap: () {
                      download.cancelAll();
                      Navigator.pop(context);
                    },
                  )
                else if (remaining > 0)
                  _ActionBtn(
                    label: 'Download All 114 Surahs',
                    icon: Icons.download_for_offline_rounded,
                    color: AppTheme.quranBlue,
                    onTap: () {
                      download.downloadAll(reciterId);
                      Navigator.pop(context);
                    },
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 20),
                        SizedBox(width: 8),
                        Text('All surahs downloaded',
                            style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                if (downloaded > 0) ...[
                  const SizedBox(height: 10),
                  _ActionBtn(
                    label: 'Delete All Downloads',
                    icon: Icons.delete_outline_rounded,
                    color: Colors.red.shade700,
                    onTap: () {
                      download.deleteAll(reciterId);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool isDark;
  const _StatBadge({required this.label, required this.value, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../providers/prayer_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../data/nigerian_cities.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  void _showCityPicker(BuildContext context, PrayerProvider prayer) {
    final isDark = context.read<SettingsProvider>().isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  children: [
                    Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_city_rounded, color: AppTheme.primaryGreen, size: 20),
                        const SizedBox(width: 10),
                        Text('Select City',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            )),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Choose your city for accurate prayer times',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: kNigerianCities.length,
                  itemBuilder: (_, i) {
                    final city = kNigerianCities[i];
                    final isSelected = prayer.selectedCityName == city.name;
                    return ListTile(
                      leading: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryGreen.withValues(alpha: 0.15)
                              : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF5F5F5)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: isSelected ? AppTheme.primaryGreen : Colors.grey,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        city.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppTheme.primaryGreen
                              : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        city.state,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 20)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        prayer.loadFromCity(city);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prayer = context.watch<PrayerProvider>();
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;
    final nextName = prayer.nextPrayerName;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.cream,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Prayer Times',
                                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                              Text('اوقات الصلاة',
                                  style: TextStyle(color: Colors.white60, fontSize: 14, fontFamily: AppTheme.arabicFontFamily)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => prayer.loadWithGPS(),
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                      if (prayer.error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.white70, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(prayer.error!,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (prayer.prayerTimes != null) ...[
                        const SizedBox(height: 20),
                        _BigCountdownCard(prayer: prayer),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (prayer.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
            )
          else if (prayer.prayerTimes == null)
            SliverFillRemaining(
              child: _EmptyState(
                onGps: prayer.loadWithGPS,
                onPickCity: () => _showCityPicker(context, prayer),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Location row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          prayer.usingGps ? Icons.gps_fixed_rounded : Icons.location_on_rounded,
                          color: AppTheme.primaryGreen, size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            prayer.prayerTimes!.locationName,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : const Color(0xFF333333),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showCityPicker(context, prayer),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Change',
                                style: TextStyle(color: AppTheme.primaryGreen, fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Prayer cards — 5 salah only
                  ...[
                    ('Fajr', prayer.prayerTimes!.fajr, Icons.bedtime_rounded, 'Dawn Prayer'),
                    ('Dhuhr', prayer.prayerTimes!.dhuhr, Icons.wb_sunny_rounded, 'Midday Prayer'),
                    ('Asr', prayer.prayerTimes!.asr, Icons.wb_cloudy_rounded, 'Afternoon Prayer'),
                    ('Maghrib', prayer.prayerTimes!.maghrib, Icons.wb_twilight_rounded, 'Sunset Prayer'),
                    ('Isha', prayer.prayerTimes!.isha, Icons.nightlight_round, 'Night Prayer'),
                  ].map((p) {
                    final now = DateTime.now();
                    final isPast = p.$2.isBefore(now);
                    final isNext = p.$1 == nextName;
                    return _PrayerCard(
                      name: p.$1,
                      time: p.$2,
                      icon: p.$3,
                      sub: p.$4,
                      isPast: isPast,
                      isNext: isNext,
                      isDark: isDark,
                    );
                  }),

                  // Sunrise info row (not a salah, shown dimmer)
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wb_sunny_outlined,
                            color: AppTheme.gold.withValues(alpha: 0.7), size: 22),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sunrise',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: isDark ? Colors.white38 : Colors.black38)),
                              Text('No prayer at sunrise',
                                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white24 : Colors.black26)),
                            ],
                          ),
                        ),
                        Text(
                          DateFormat('hh:mm a').format(prayer.prayerTimes!.sunrise),
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: isDark ? Colors.white38 : Colors.black38),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _BigCountdownCard extends StatefulWidget {
  final PrayerProvider prayer;
  const _BigCountdownCard({required this.prayer});
  @override
  State<_BigCountdownCard> createState() => _BigCountdownCardState();
}

class _BigCountdownCardState extends State<_BigCountdownCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayer = widget.prayer;
    final timeLeft = prayer.timeToNextPrayer;
    final next = prayer.nextPrayerName;
    final h = timeLeft.inHours.toString().padLeft(2, '0');
    final m = timeLeft.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = timeLeft.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.mosque_rounded, color: AppTheme.gold, size: 16),
                    const SizedBox(width: 6),
                    Text('Next Prayer',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(next,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                Text(
                  DateFormat('hh:mm a').format(prayer.nextPrayerTime),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text('$h:$m:$s',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                Text('remaining',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final String name;
  final DateTime time;
  final IconData icon;
  final String sub;
  final bool isPast;
  final bool isNext;
  final bool isDark;

  const _PrayerCard({
    required this.name,
    required this.time,
    required this.icon,
    required this.sub,
    required this.isPast,
    required this.isNext,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isNext
            ? AppTheme.primaryGreen.withValues(alpha: isDark ? 0.18 : 0.08)
            : (isDark ? AppTheme.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: isNext
            ? Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.5), width: 1.5)
            : Border.all(color: Colors.transparent),
        boxShadow: isDark || !isNext
            ? []
            : [BoxShadow(color: AppTheme.primaryGreen.withValues(alpha: 0.15), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: isNext
                  ? AppTheme.primaryGreen.withValues(alpha: 0.15)
                  : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0F4F0)),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: isNext ? AppTheme.primaryGreen : (isPast ? Colors.grey : AppTheme.gold),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isNext
                        ? AppTheme.primaryGreen
                        : (isPast ? Colors.grey : (isDark ? Colors.white : const Color(0xFF1A1A1A))),
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('hh:mm a').format(time),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isPast
                      ? Colors.grey
                      : isNext
                          ? AppTheme.primaryGreen
                          : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                ),
              ),
              if (isPast)
                const Text('Passed', style: TextStyle(fontSize: 10, color: Colors.grey))
              else if (isNext)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('NEXT',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onGps;
  final VoidCallback onPickCity;
  const _EmptyState({required this.onGps, required this.onPickCity});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off_rounded, size: 36, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text('Prayer times not set',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Select your city or use GPS for accurate prayer times',
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onPickCity,
              icon: const Icon(Icons.location_city_rounded),
              label: const Text('Select Your City'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onGps,
              icon: const Icon(Icons.my_location_rounded, size: 16),
              label: const Text('Use GPS Instead'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
                side: const BorderSide(color: AppTheme.primaryGreen),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

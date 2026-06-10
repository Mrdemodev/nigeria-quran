import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/hijri_utils.dart';

class FastingScreen extends StatefulWidget {
  const FastingScreen({super.key});
  @override
  State<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends State<FastingScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  DateTime _calendarMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final today = DateTime.now();
    final hijri = HijriDate.now();
    final isRamadan = hijri.month == 9;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFFFF8E1),
      body: Column(
        children: [
          // ── Header ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0050), Color(0xFF4527A0), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
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
                              const Text('Fasting Tracker', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                              Text(isRamadan ? 'Ramadan ${hijri.year} AH' : hijri.formatted(),
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                            ],
                          ),
                        ),
                        // Today fast toggle
                        GestureDetector(
                          onTap: () => _toggleToday(context, progress, today, isRamadan),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: progress.hasFasted(today)
                                  ? AppTheme.gold
                                  : Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(progress.hasFasted(today) ? Icons.check_rounded : Icons.add_rounded,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(progress.hasFasted(today) ? 'Fasted' : 'Log Today',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Stats row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _StatChip(
                          value: '${progress.totalFasts}',
                          label: 'Total Fasts',
                          icon: Icons.restaurant_menu_rounded,
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          value: '${progress.fastingStreak}',
                          label: 'Day Streak',
                          icon: Icons.local_fire_department_rounded,
                          highlight: progress.fastingStreak > 0,
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          value: isRamadan ? '30' : '—',
                          label: 'Ramadan',
                          icon: Icons.nightlight_round,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabs,
                    indicatorColor: AppTheme.gold,
                    indicatorWeight: 2,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: const TextStyle(fontSize: 13),
                    tabs: const [Tab(text: 'Calendar'), Tab(text: 'History')],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildCalendar(context, progress, isDark),
                _buildHistory(context, progress, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, ProgressProvider progress, bool isDark) {
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final startWeekday = firstDay.weekday % 7;
    final daysInMonth = DateUtils.getDaysInMonth(_calendarMonth.year, _calendarMonth.month);
    final today = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          // Month nav
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1, 1)),
                icon: const Icon(Icons.chevron_left_rounded),
                color: const Color(0xFF7B1FA2),
              ),
              Expanded(
                child: Text(DateFormat('MMMM yyyy').format(_calendarMonth),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
              ),
              IconButton(
                onPressed: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 1)),
                icon: const Icon(Icons.chevron_right_rounded),
                color: const Color(0xFF7B1FA2),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Weekday headers
          Row(
            children: ['S','M','T','W','T','F','S'].map((d) =>
              Expanded(child: Center(
                child: Text(d, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white38 : Colors.black38)),
              )),
            ).toList(),
          ),
          const SizedBox(height: 6),
          // Days grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (_, i) {
              if (i < startWeekday) return const SizedBox.shrink();
              final day = i - startWeekday + 1;
              final date = DateTime(_calendarMonth.year, _calendarMonth.month, day);
              final fasted = progress.hasFasted(date);
              final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
              final isFuture = date.isAfter(today);

              return GestureDetector(
                onTap: isFuture ? null : () {
                  HapticFeedback.selectionClick();
                  _toggleDay(context, progress, date, HijriDate.fromGregorian(date).month == 9);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: fasted
                        ? const Color(0xFF7B1FA2)
                        : isToday
                            ? const Color(0xFF7B1FA2).withValues(alpha: 0.15)
                            : isFuture
                                ? Colors.transparent
                                : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
                    shape: BoxShape.circle,
                    border: isToday && !fasted ? Border.all(color: const Color(0xFF7B1FA2), width: 1.5) : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday || fasted ? FontWeight.w800 : FontWeight.w400,
                        color: fasted ? Colors.white
                            : isFuture ? (isDark ? Colors.white12 : Colors.black12)
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Legend
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _LegendDot(color: const Color(0xFF7B1FA2), label: 'Fasted'),
            const SizedBox(width: 16),
            _LegendDot(color: Colors.grey, label: 'Not fasted'),
          ]),
          const SizedBox(height: 20),
          // Sunnah fast reminders
          _SunnahCard(isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildHistory(BuildContext context, ProgressProvider progress, bool isDark) {
    if (progress.fasts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu_rounded, size: 56, color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 12),
            Text('No fasts logged yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white38 : Colors.black38)),
            const SizedBox(height: 6),
            Text('Tap "Log Today" to record a fast',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white24 : Colors.black26)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: progress.fasts.length,
      itemBuilder: (_, i) {
        final f = progress.fasts[i];
        final typeColor = _typeColor(f.type);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(Icons.check_rounded, color: typeColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_typeLabel(f.type),
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                    Text(DateFormat('EEEE, d MMMM yyyy').format(f.date),
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => progress.deleteFast(f.id),
                child: Icon(Icons.delete_outline_rounded, color: isDark ? Colors.white24 : Colors.black26, size: 18),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _typeColor(String t) {
    switch (t) {
      case 'ramadan': return const Color(0xFFF57F17);
      case 'monday':
      case 'thursday': return const Color(0xFF2E7D32);
      default: return const Color(0xFF7B1FA2);
    }
  }

  String _typeLabel(String t) {
    switch (t) {
      case 'ramadan': return 'Ramadan Fast';
      case 'monday': return 'Monday Sunnah Fast';
      case 'thursday': return 'Thursday Sunnah Fast';
      default: return 'Voluntary Fast';
    }
  }

  void _toggleToday(BuildContext ctx, ProgressProvider p, DateTime today, bool isRamadan) {
    if (p.hasFasted(today)) {
      final f = p.fasts.firstWhere((f) {
        final d = f.date;
        return d.year == today.year && d.month == today.month && d.day == today.day;
      }, orElse: () => FastRecord(id: -1, date: today, type: ''));
      if (f.id != -1) p.deleteFast(f.id);
    } else {
      final type = isRamadan ? 'ramadan'
          : today.weekday == DateTime.monday ? 'monday'
          : today.weekday == DateTime.thursday ? 'thursday'
          : 'voluntary';
      p.logFast(date: today, type: type);
      HapticFeedback.mediumImpact();
    }
  }

  void _toggleDay(BuildContext ctx, ProgressProvider p, DateTime date, bool isRamadan) {
    if (p.hasFasted(date)) {
      final f = p.fasts.firstWhere((f) {
        final d = f.date;
        return d.year == date.year && d.month == date.month && d.day == date.day;
      }, orElse: () => FastRecord(id: -1, date: date, type: ''));
      if (f.id != -1) p.deleteFast(f.id);
    } else {
      final type = isRamadan ? 'ramadan'
          : date.weekday == DateTime.monday ? 'monday'
          : date.weekday == DateTime.thursday ? 'thursday'
          : 'voluntary';
      p.logFast(date: date, type: type);
      HapticFeedback.lightImpact();
    }
  }
}

class _StatChip extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final bool highlight;
  const _StatChip({required this.value, required this.label, required this.icon, this.highlight = false});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: highlight ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Icon(icon, color: highlight ? AppTheme.gold : Colors.white60, size: 16),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 8), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ]);
  }
}

class _SunnahCard extends StatelessWidget {
  final bool isDark;
  const _SunnahCard({required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF7B1FA2).withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF7B1FA2).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.info_outline_rounded, color: Color(0xFF7B1FA2), size: 14),
            SizedBox(width: 6),
            Text('Sunnah Fasting', style: TextStyle(color: Color(0xFF7B1FA2), fontWeight: FontWeight.w700, fontSize: 12)),
          ]),
          const SizedBox(height: 8),
          _sunnahRow('Every Monday & Thursday', 'The Prophet ﷺ used to fast on these days regularly'),
          _sunnahRow('Shawwal (6 days)', '6 days after Eid al-Fitr = full year of reward'),
          _sunnahRow('Day of Arafah', '9th Dhul Hijjah — expiates sins of two years'),
          _sunnahRow('Day of Ashura', '10th Muharram — expiates sins of last year'),
          _sunnahRow('Three White Days', '13th, 14th, 15th of each Hijri month'),
        ],
      ),
    );
  }

  Widget _sunnahRow(String title, String sub) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('• ', style: TextStyle(color: Color(0xFF7B1FA2), fontWeight: FontWeight.w700)),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
        Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey, height: 1.4)),
      ])),
    ]),
  );
}

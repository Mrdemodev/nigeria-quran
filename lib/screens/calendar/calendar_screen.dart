import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/hijri_utils.dart';

class _IslamicEvent {
  final int hijriMonth;
  final int hijriDay;
  final String name;
  final String arabicName;
  final Color color;
  const _IslamicEvent(this.hijriMonth, this.hijriDay, this.name, this.arabicName, this.color);
}

const _events = <_IslamicEvent>[
  _IslamicEvent(1, 1, 'Islamic New Year', 'رأس السنة الهجرية', Color(0xFF1565C0)),
  _IslamicEvent(1, 10, 'Day of Ashura', 'يوم عاشوراء', Color(0xFF7B1FA2)),
  _IslamicEvent(3, 12, 'Mawlid al-Nabi', 'المولد النبوي', Color(0xFF2E7D32)),
  _IslamicEvent(7, 27, 'Isra & Mi\'raj', 'الإسراء والمعراج', Color(0xFF0277BD)),
  _IslamicEvent(8, 15, 'Sha\'ban 15 (Nisfu Sha\'ban)', 'نصف شعبان', Color(0xFF558B2F)),
  _IslamicEvent(9, 1, 'Ramadan Begins', 'بداية رمضان', Color(0xFFF57F17)),
  _IslamicEvent(9, 27, 'Laylatul Qadr (27th)', 'ليلة القدر', Color(0xFFAD1457)),
  _IslamicEvent(10, 1, 'Eid al-Fitr', 'عيد الفطر', Color(0xFF2E7D32)),
  _IslamicEvent(12, 8, 'Day of Arafah', 'يوم عرفة', Color(0xFFC62828)),
  _IslamicEvent(12, 10, 'Eid al-Adha', 'عيد الأضحى', Color(0xFF2E7D32)),
];

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late HijriDate _viewHijri;
  late DateTime _viewGregorian;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _viewHijri = HijriDate.now();
    _viewGregorian = DateTime.now();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _prevMonth() {
    setState(() {
      int m = _viewHijri.month - 1;
      int y = _viewHijri.year;
      if (m < 1) { m = 12; y--; }
      _viewHijri = HijriDate(y, m, 1);
      _viewGregorian = DateTime(_viewGregorian.year, _viewGregorian.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      int m = _viewHijri.month + 1;
      int y = _viewHijri.year;
      if (m > 12) { m = 1; y++; }
      _viewHijri = HijriDate(y, m, 1);
      _viewGregorian = DateTime(_viewGregorian.year, _viewGregorian.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final todayHijri = HijriDate.now();
    final todayGregorian = DateTime.now();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // ── Header ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A1E44), Color(0xFF1565C0), Color(0xFF1976D2)],
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
                              const Text('Islamic Calendar',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                              Text(todayHijri.formatted(),
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
                          child: Text(
                            DateFormat('d MMM yyyy').format(todayGregorian),
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
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
                    tabs: const [Tab(text: 'Calendar'), Tab(text: 'Events')],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildCalendar(isDark, todayHijri),
                _buildEvents(isDark, todayHijri),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(bool isDark, HijriDate todayHijri) {
    final eventsThisMonth = _events.where((e) => e.hijriMonth == _viewHijri.month).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          // Month navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () { HapticFeedback.selectionClick(); _prevMonth(); },
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: AppTheme.quranBlue,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(_viewHijri.monthName,
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                      Text('${_viewHijri.year} AH · ${DateFormat('MMMM yyyy').format(_viewGregorian)}',
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () { HapticFeedback.selectionClick(); _nextMonth(); },
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: AppTheme.quranBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Weekday headers
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) =>
                Expanded(child: Center(
                  child: Text(d,
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: d == 'Fri' ? AppTheme.quranBlue : (isDark ? Colors.white38 : Colors.black38)),
                  ),
                )),
              ).toList(),
            ),
          ),

          // Calendar grid — using Gregorian grid with Hijri overlay
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
            ),
            child: _buildGridCells(isDark, todayHijri),
          ),

          // Events in this month
          if (eventsThisMonth.isNotEmpty) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Events this month',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white60 : const Color(0xFF666666))),
            ),
            const SizedBox(height: 8),
            ...eventsThisMonth.map((e) => _EventChip(event: e, isDark: isDark)),
          ],
        ],
      ),
    );
  }

  Widget _buildGridCells(bool isDark, HijriDate todayHijri) {
    final firstDay = DateTime(_viewGregorian.year, _viewGregorian.month, 1);
    final startWeekday = firstDay.weekday % 7; // Sun=0..Sat=6
    final daysInMonth = DateUtils.getDaysInMonth(_viewGregorian.year, _viewGregorian.month);
    final todayGreg = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.75,
      ),
      itemCount: startWeekday + daysInMonth,
      itemBuilder: (_, i) {
        if (i < startWeekday) return const SizedBox.shrink();
        final day = i - startWeekday + 1;
        final date = DateTime(_viewGregorian.year, _viewGregorian.month, day);
        final hijri = HijriDate.fromGregorian(date);
        final isToday = date.year == todayGreg.year && date.month == todayGreg.month && date.day == todayGreg.day;
        final isFriday = date.weekday == DateTime.friday;
        final event = _events.firstWhere(
          (e) => e.hijriMonth == hijri.month && e.hijriDay == hijri.day,
          orElse: () => const _IslamicEvent(0, 0, '', '', Colors.transparent),
        );
        final hasEvent = event.hijriMonth != 0;

        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: isToday
                ? AppTheme.quranBlue
                : hasEvent
                    ? event.color.withValues(alpha: isDark ? 0.18 : 0.10)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 12, fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                  color: isToday ? Colors.white
                      : isFriday ? AppTheme.quranBlue
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
              Text(
                '${hijri.day}',
                style: TextStyle(
                  fontSize: 8,
                  color: isToday ? Colors.white70
                      : hasEvent ? event.color
                      : (isDark ? Colors.white30 : Colors.black38),
                ),
              ),
              if (hasEvent)
                Container(
                  width: 4, height: 4,
                  decoration: BoxDecoration(color: event.color, shape: BoxShape.circle),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEvents(bool isDark, HijriDate todayHijri) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Today's Hijri info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A1E44), Color(0xFF1565C0)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today', style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11)),
                    Text(todayHijri.formatted(),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    Text(DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                  ],
                ),
              ),
              const Text('📅', style: TextStyle(fontSize: 32)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Important Islamic Dates',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white60 : const Color(0xFF666666))),
        const SizedBox(height: 10),
        ..._events.map((e) {
          final isPast = e.hijriMonth < todayHijri.month ||
              (e.hijriMonth == todayHijri.month && e.hijriDay < todayHijri.day);
          final isToday = e.hijriMonth == todayHijri.month && e.hijriDay == todayHijri.day;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isToday ? Border.all(color: e.color, width: 2) : null,
              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
            ),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: e.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${e.hijriDay}',
                          style: TextStyle(color: e.color, fontWeight: FontWeight.w800, fontSize: 14)),
                      Text(e.hijriMonth.toString().padLeft(2, '0'),
                          style: TextStyle(color: e.color.withValues(alpha: 0.6), fontSize: 8)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(e.name,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A)))),
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: e.color, borderRadius: BorderRadius.circular(6)),
                            child: const Text('Today', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                          ),
                      ]),
                      Text(e.arabicName,
                          style: TextStyle(fontFamily: AppTheme.arabicFontFamily, fontSize: 12,
                              color: isPast ? Colors.grey : e.color),
                          textDirection: TextDirection.rtl),
                      Text('${e.hijriDay} ${HijriDate(1445, e.hijriMonth, e.hijriDay).monthName}',
                          style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _EventChip extends StatelessWidget {
  final _IslamicEvent event;
  final bool isDark;
  const _EventChip({required this.event, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: event.color.withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: event.color.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: event.color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('${event.hijriDay} · ', style: TextStyle(color: event.color, fontWeight: FontWeight.w700, fontSize: 11)),
        Expanded(child: Text(event.name, style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : const Color(0xFF333333)))),
      ]),
    );
  }
}

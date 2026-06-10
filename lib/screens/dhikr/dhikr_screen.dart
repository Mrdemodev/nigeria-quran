import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/adhkar_data.dart';
import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';

class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  int _dhikrIndex = 0;
  int _count = 0;
  int _totalCount = 0;
  late AnimationController _tapCtrl;
  late Animation<double> _tapScale;

  List<DhikrItem> get _currentList =>
      [kGeneralDhikr, kMorningAdhkar, kEveningAdhkar][_selectedTab];

  DhikrItem get _currentItem => _currentList[_dhikrIndex];

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _tapScale = Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: _tapCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  void _increment() async {
    HapticFeedback.lightImpact();
    await _tapCtrl.forward();
    await _tapCtrl.reverse();
    setState(() {
      _count++;
      _totalCount++;
      if (_count >= _currentItem.defaultCount) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() {
              _count = 0;
              if (_dhikrIndex < _currentList.length - 1) _dhikrIndex++;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final progress = _count / _currentItem.defaultCount;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.cream,
      body: Column(
        children: [
          // Header
          Container(
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
                              Text('Dhikr Counter', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                              Text('عداد الأذكار', style: TextStyle(color: Colors.white60, fontSize: 12, fontFamily: AppTheme.arabicFontFamily)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() { _count = 0; _totalCount = 0; }),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tabs
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: ['General', 'Morning', 'Evening'].asMap().entries.map((e) {
                          final isSelected = _selectedTab == e.key;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _selectedTab = e.key;
                                _dhikrIndex = 0;
                                _count = 0;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  e.value,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected ? AppTheme.primaryGreen : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Dhikr text card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16)],
                    ),
                    child: Column(
                      children: [
                        Text(
                          _currentItem.arabic,
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: AppTheme.arabicFontFamily,
                            height: 2.0,
                            color: AppTheme.primaryGreen,
                          ),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _currentItem.transliteration,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentItem.english,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black45,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _currentItem.hausa,
                            style: const TextStyle(color: AppTheme.darkGold, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Circular progress ring + tap button
                  ScaleTransition(
                    scale: _tapScale,
                    child: GestureDetector(
                      onTap: _increment,
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background ring
                            SizedBox(
                              width: 220, height: 220,
                              child: CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 12,
                                color: isDark ? Colors.white12 : Colors.black12,
                              ),
                            ),
                            // Progress ring
                            SizedBox(
                              width: 220, height: 220,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 12,
                                strokeCap: StrokeCap.round,
                                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGreen),
                              ),
                            ),
                            // Inner content
                            Container(
                              width: 170, height: 170,
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.darkCard : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$_count',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                      height: 1.0,
                                    ),
                                  ),
                                  Text(
                                    '/ ${_currentItem.defaultCount}',
                                    style: TextStyle(
                                      color: isDark ? Colors.white38 : Colors.black38,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'TAP',
                                      style: TextStyle(
                                        color: AppTheme.primaryGreen,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total today: $_totalCount',
                    style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12),
                  ),

                  const SizedBox(height: 28),

                  // Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _NavBtn(
                        icon: Icons.arrow_back_ios_rounded,
                        enabled: _dhikrIndex > 0,
                        onTap: () => setState(() { _dhikrIndex--; _count = 0; }),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_dhikrIndex + 1} / ${_currentList.length}',
                          style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 20),
                      _NavBtn(
                        icon: Icons.arrow_forward_ios_rounded,
                        enabled: _dhikrIndex < _currentList.length - 1,
                        onTap: () => setState(() { _dhikrIndex++; _count = 0; }),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool isDark;
  const _NavBtn({required this.icon, required this.enabled, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.primaryGreen.withValues(alpha: isDark ? 0.2 : 0.1)
              : (isDark ? Colors.white12 : Colors.black12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: enabled ? AppTheme.primaryGreen : Colors.grey, size: 20),
      ),
    );
  }
}


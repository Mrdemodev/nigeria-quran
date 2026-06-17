import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/settings_provider.dart';
import '../../providers/prayer_provider.dart';
import '../../utils/prayer_calculator.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.cream,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          Text('الإعدادات', style: AppTheme.arabicStyle(color: Colors.white60, fontSize: 12, height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              children: [
                _SectionHeader(title: 'Appearance', isDark: isDark),
                const SizedBox(height: 8),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    _SwitchTile(
                      isDark: isDark,
                      icon: Icons.dark_mode_rounded,
                      iconColor: const Color(0xFF7986CB),
                      title: 'Dark Mode',
                      subtitle: 'AMOLED black theme',
                      value: isDark,
                      onChanged: (_) => context.read<SettingsProvider>().toggleTheme(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _SectionHeader(title: 'Reading', isDark: isDark),
                const SizedBox(height: 8),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.format_size_rounded, color: AppTheme.primaryGreen, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Arabic Font Size',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                      )),
                                  Text('${settings.arabicFontSize.toInt()} px',
                                      style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: AppTheme.primaryGreen,
                              thumbColor: AppTheme.primaryGreen,
                              inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
                              overlayColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                            ),
                            child: Slider(
                              value: settings.arabicFontSize,
                              min: 18,
                              max: 40,
                              divisions: 11,
                              onChanged: (v) => context.read<SettingsProvider>().setArabicFontSize(v),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                              style: AppTheme.arabicStyle(
                                fontSize: settings.arabicFontSize,
                                color: isDark ? AppTheme.arabicTextDark : AppTheme.arabicTextLight,
                                height: 1.8,
                              ),
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _SectionHeader(title: 'Prayer Calculation', isDark: isDark),
                const SizedBox(height: 8),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    _TapTile(
                      isDark: isDark,
                      icon: Icons.calculate_rounded,
                      iconColor: const Color(0xFF1565C0),
                      title: 'Calculation Method',
                      subtitle: _methodLabel(context.watch<PrayerProvider>().calculationMethod),
                      onTap: () => _showMethodPicker(context),
                    ),
                    _Divider(isDark: isDark),
                    _TapTile(
                      isDark: isDark,
                      icon: Icons.access_time_rounded,
                      iconColor: const Color(0xFF00897B),
                      title: 'Asr Juristic School',
                      subtitle: context.watch<PrayerProvider>().asrJuristic == AsrJuristic.hanafi
                          ? 'Hanafi'
                          : 'Standard (Shafi / Maliki / Hanbali)',
                      onTap: () => _showAsrPicker(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _SectionHeader(title: 'Notifications', isDark: isDark),
                const SizedBox(height: 8),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    _TapTile(
                      isDark: isDark,
                      icon: Icons.notifications_active_rounded,
                      iconColor: AppTheme.primaryGreen,
                      title: 'Notification Permission',
                      subtitle: 'Tap to enable notifications in system settings',
                      onTap: () async {
                        final granted = await Permission.notification.isGranted;
                        if (!granted) {
                          await openAppSettings();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifications are enabled'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                    _Divider(isDark: isDark),
                    _SwitchTile(
                      isDark: isDark,
                      icon: Icons.mosque_rounded,
                      iconColor: const Color(0xFF1565C0),
                      title: 'Prayer Time Alerts',
                      subtitle: 'Athan notification for each prayer',
                      value: settings.prayerNotificationsEnabled,
                      onChanged: (v) async {
                        await context.read<SettingsProvider>().setPrayerNotifications(v);
                        if (!v) await NotificationService().schedulePrayerNotifications(null, enabled: false);
                        // If enabling, PrayerProvider reschedules on next prayer time load
                      },
                    ),
                    _Divider(isDark: isDark),
                    _SwitchTile(
                      isDark: isDark,
                      icon: Icons.format_quote_rounded,
                      iconColor: AppTheme.gold,
                      title: 'Daily Ayah (7 AM)',
                      subtitle: 'Morning reminder to read Qur\'an',
                      value: settings.dailyAyahNotificationEnabled,
                      onChanged: (v) async {
                        await context.read<SettingsProvider>().setDailyAyahNotification(v);
                        await NotificationService().scheduleDailyAyah(enabled: v);
                      },
                    ),
                    _Divider(isDark: isDark),
                    _SwitchTile(
                      isDark: isDark,
                      icon: Icons.library_books_rounded,
                      iconColor: const Color(0xFF5D4037),
                      title: 'Daily Hadith (6 PM)',
                      subtitle: 'Evening hadith reminder',
                      value: settings.dailyHadithNotificationEnabled,
                      onChanged: (v) async {
                        await context.read<SettingsProvider>().setDailyHadithNotification(v);
                        await NotificationService().scheduleDailyHadith(enabled: v);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _SectionHeader(title: 'Audio', isDark: isDark),
                const SizedBox(height: 8),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    _InfoTile(
                      isDark: isDark,
                      icon: Icons.wifi_rounded,
                      iconColor: const Color(0xFF0288D1),
                      title: 'Streaming Audio',
                      subtitle: 'Online reciters via Islamic Network API',
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _SectionHeader(title: 'About', isDark: isDark),
                const SizedBox(height: 8),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (_, snap) => _InfoTile(
                        isDark: isDark,
                        icon: Icons.info_outline_rounded,
                        iconColor: AppTheme.primaryGreen,
                        title: "Qur'an NG",
                        subtitle: snap.hasData
                            ? 'Version ${snap.data!.version} (build ${snap.data!.buildNumber})'
                            : 'Version 1.0.0',
                      ),
                    ),
                    Divider(height: 1, indent: 64, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                    _TapTile(
                      isDark: isDark,
                      icon: Icons.star_rounded,
                      iconColor: AppTheme.gold,
                      title: 'Rate this App',
                      subtitle: 'Enjoying the app? Leave a review',
                      onTap: () async {
                        final review = InAppReview.instance;
                        if (await review.isAvailable()) {
                          review.requestReview();
                        } else {
                          review.openStoreListing(appStoreId: 'com.nigeriaquran.nigeria_quran');
                        }
                      },
                    ),
                    Divider(height: 1, indent: 64, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                    _TapTile(
                      isDark: isDark,
                      icon: Icons.privacy_tip_outlined,
                      iconColor: const Color(0xFF0288D1),
                      title: 'Privacy Policy',
                      subtitle: 'How we handle your data',
                      onTap: () => _showLegalSheet(context, isDark, _kPrivacyPolicy, 'Privacy Policy'),
                    ),
                    Divider(height: 1, indent: 64, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                    _TapTile(
                      isDark: isDark,
                      icon: Icons.gavel_rounded,
                      iconColor: const Color(0xFF6A1B9A),
                      title: 'Terms & Conditions',
                      subtitle: 'Rules for using this app',
                      onTap: () => _showLegalSheet(context, isDark, _kTermsAndConditions, 'Terms & Conditions'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLegalSheet(BuildContext context, bool isDark, String content, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 14),
                    Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06)),
              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.75,
                        color: isDark ? Colors.white70 : const Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _methodLabel(CalculationMethod m) {
    const labels = {
      CalculationMethod.muslimWorldLeague: 'Muslim World League (MWL)',
      CalculationMethod.northAmerica: 'North America (ISNA)',
      CalculationMethod.egyptian: 'Egyptian General Authority',
      CalculationMethod.karachi: 'University of Islamic Sciences, Karachi',
      CalculationMethod.kuwait: 'Kuwait',
      CalculationMethod.qatar: 'Qatar',
      CalculationMethod.singapore: 'Majlis Ugama Islam Singapura',
      CalculationMethod.turkey: 'Turkey (Diyanet)',
      CalculationMethod.dubai: 'Dubai',
      CalculationMethod.tehran: 'Institute of Geophysics, Tehran',
    };
    return labels[m] ?? m.name;
  }

  void _showMethodPicker(BuildContext context) {
    final prayer = context.read<PrayerProvider>();
    final isDark = context.read<SettingsProvider>().isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 14),
                  Row(children: [
                    const Icon(Icons.calculate_rounded, color: Color(0xFF1565C0), size: 20),
                    const SizedBox(width: 8),
                    Text('Calculation Method', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
                  ]),
                  const SizedBox(height: 10),
                ]),
              ),
              Divider(height: 1, color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06)),
              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: CalculationMethod.values.map((m) {
                    final selected = prayer.calculationMethod == m;
                    return ListTile(
                      title: Text(_methodLabel(m),
                          style: TextStyle(
                            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                            color: selected ? const Color(0xFF1565C0) : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                            fontSize: 13,
                          )),
                      trailing: selected ? const Icon(Icons.check_rounded, color: Color(0xFF1565C0), size: 18) : null,
                      onTap: () {
                        Navigator.pop(context);
                        prayer.setCalculationMethod(m);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAsrPicker(BuildContext context) {
    final prayer = context.read<PrayerProvider>();
    final isDark = context.read<SettingsProvider>().isDarkMode;
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
            const SizedBox(height: 14),
            Row(children: [
              const Icon(Icons.access_time_rounded, color: Color(0xFF00897B), size: 20),
              const SizedBox(width: 8),
              Text('Asr Juristic School', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
            ]),
            const SizedBox(height: 12),
            ...[
              (AsrJuristic.standard, 'Standard', 'Shafi, Maliki, Hanbali — shadow length equal to object'),
              (AsrJuristic.hanafi,   'Hanafi',   'Hanafi — shadow length twice the object'),
            ].map((e) {
              final selected = prayer.asrJuristic == e.$1;
              return ListTile(
                title: Text(e.$2, style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.normal, color: selected ? const Color(0xFF00897B) : (isDark ? Colors.white : const Color(0xFF1A1A1A)))),
                subtitle: Text(e.$3, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
                trailing: selected ? const Icon(Icons.check_rounded, color: Color(0xFF00897B), size: 18) : null,
                onTap: () { Navigator.pop(context); prayer.setAsrJuristic(e.$1); },
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }


}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: isDark ? Colors.white38 : Colors.black38,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;
  const _SettingsCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.isDark, required this.icon, required this.iconColor,
    required this.title, required this.subtitle, required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A), fontSize: 14)),
                Text(subtitle, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value, onChanged: onChanged,
            activeColor: AppTheme.primaryGreen,
            activeTrackColor: AppTheme.primaryGreen.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _TapTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TapTile({
    required this.isDark, required this.icon, required this.iconColor,
    required this.title, required this.subtitle, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A), fontSize: 14)),
                  Text(subtitle, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : Colors.black26, size: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _InfoTile({required this.isDark, required this.icon, required this.iconColor, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A1A), fontSize: 14)),
                Text(subtitle, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64),
      child: Divider(
        height: 1,
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
      ),
    );
  }
}

const String _kPrivacyPolicy = '''
Last updated: June 2025

Qur'an NG ("the App") is developed to serve the Muslim community. This Privacy Policy explains how we collect, use, and protect your information.

1. INFORMATION WE COLLECT
The App does not collect any personal information. All data (bookmarks, notes, progress, settings) is stored locally on your device and is never transmitted to any server.

2. LOCATION DATA
The App requests location access solely to calculate accurate prayer times and Qibla direction for your area. Location data is processed on-device and is not stored or shared.

3. INTERNET ACCESS
The App uses the internet only to stream Qur'anic audio recitations from licensed CDN servers. No personal data is transmitted during this process.

4. NOTIFICATIONS
Daily ayah and prayer time notifications are scheduled locally on your device. We do not use push notification services or third-party messaging platforms.

5. THIRD-PARTY SERVICES
The App uses Google Fonts to render Arabic text. Font files are bundled within the App and no data is sent to Google during use.

6. DATA STORAGE
All user data remains exclusively on your device. Uninstalling the App removes all associated data permanently.

7. CHILDREN'S PRIVACY
The App is suitable for all ages. We do not knowingly collect information from children under 13.

8. CHANGES TO THIS POLICY
We may update this Privacy Policy from time to time. Updates will be reflected in new versions of the App.

9. CONTACT
For questions or concerns about this Privacy Policy, please contact us at quranng@gmail.com.
''';

const String _kTermsAndConditions = '''
Last updated: June 2025

By downloading or using Qur'an NG ("the App"), you agree to the following Terms and Conditions.

1. ACCEPTANCE OF TERMS
Your use of the App constitutes acceptance of these Terms. If you do not agree, please uninstall the App.

2. PERMITTED USE
The App is provided for personal, non-commercial use. You may not:
• Redistribute, sell, or sublicense the App or its content
• Reverse-engineer or modify the App
• Use the App for any unlawful purpose

3. QUR'ANIC CONTENT
All Qur'anic text and audio is used with respect for its sacred nature. The Arabic text follows the standard Uthmani script (Hafs 'an 'Asim). Translations are provided for educational purposes and should not be taken as a replacement for scholarly guidance.

4. AUDIO RECITATIONS
Audio recitations are streamed from third-party CDN servers. Availability depends on internet connectivity. Downloaded audio files are for personal offline use only and may not be redistributed.

5. ACCURACY
While every effort is made to ensure accuracy of Qur'anic text, translations, prayer times, and Islamic content, users should verify critical information with qualified scholars.

6. INTELLECTUAL PROPERTY
The App design, code, and non-Qur'anic content are the property of the Qur'an NG developers. The Qur'anic text itself belongs to the public domain of Islamic heritage.

7. DISCLAIMER OF WARRANTIES
The App is provided "as is" without warranties of any kind. We do not guarantee uninterrupted or error-free operation.

8. LIMITATION OF LIABILITY
The developers shall not be liable for any indirect, incidental, or consequential damages arising from the use of this App.

9. CHANGES TO TERMS
We reserve the right to modify these Terms at any time. Continued use of the App after changes constitutes acceptance of the updated Terms.

10. CONTACT
For questions about these Terms, contact us at quranng@gmail.com.
''';


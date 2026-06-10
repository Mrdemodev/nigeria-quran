import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_theme.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ShareImageService {
  static final _ctrl = ScreenshotController();

  static Future<void> shareAyahAsImage({
    required String surahName,
    required int ayahNumber,
    required String arabicText,
    required String translationText,
    required bool isDark,
  }) async {
    final bytes = await _ctrl.captureFromLongWidget(
      _AyahShareCard(
        surahName: surahName,
        ayahNumber: ayahNumber,
        arabicText: arabicText,
        translationText: translationText,
      ),
      pixelRatio: 3.0,
      context: null,
      constraints: const BoxConstraints(maxWidth: 400),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/ayah_share_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      text: '$surahName · Ayah $ayahNumber\n\nShared via Qur\'an NG',
    );
  }
}

class _AyahShareCard extends StatelessWidget {
  final String surahName;
  final int ayahNumber;
  final String arabicText;
  final String translationText;

  const _AyahShareCard({
    required this.surahName,
    required this.ayahNumber,
    required this.arabicText,
    required this.translationText,
  });

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);
    const gold = Color(0xFFC8960C);
    const cream = Color(0xFFFAF7F0);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: cream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text("Qur'an NG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text('Ayah $ayahNumber', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ),
                ],
              ),
            ),

            // Surah name
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: gold.withValues(alpha: 0.3))),
                    child: Text(surahName, style: const TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            // Arabic text
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.arabicBgLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: gold.withValues(alpha: 0.22)),
              ),
              child: Text(
                arabicText,
                style: AppTheme.arabicStyle(
                  fontSize: 26,
                  height: 2.0,
                  color: AppTheme.arabicTextLight,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
              ),
            ),

            // Decorative divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(child: Container(height: 1, color: gold.withValues(alpha: 0.2))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('❖', style: TextStyle(color: gold.withValues(alpha: 0.5), fontSize: 12)),
                  ),
                  Expanded(child: Container(height: 1, color: gold.withValues(alpha: 0.2))),
                ],
              ),
            ),

            // Translation
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                translationText,
                style: const TextStyle(fontSize: 13, height: 1.65, color: Color(0xFF444444)),
                textAlign: TextAlign.center,
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: primaryGreen.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(19)),
                border: Border(top: BorderSide(color: gold.withValues(alpha: 0.15))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book_rounded, size: 12, color: primaryGreen),
                  const SizedBox(width: 6),
                  Text("Read. In the name of your Lord. — 96:1", style: TextStyle(fontSize: 10, color: primaryGreen.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

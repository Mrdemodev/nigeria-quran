import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../theme/app_theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});
  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  double? _qiblaAngle;
  double? _smoothHeading;
  bool _isLoading = true;
  String? _error;
  late AnimationController _pulseCtrl;
  StreamSubscription? _compassSub;

  static const double _kaabaLat = 21.3891;
  static const double _kaabaLng = 39.8579;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initQibla();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _initQibla() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        setState(() { _error = 'Location permission denied'; _isLoading = false; });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      _qiblaAngle = _calcQibla(pos.latitude, pos.longitude);
      setState(() => _isLoading = false);

      _compassSub?.cancel();
      _compassSub = FlutterCompass.events?.listen((event) {
        if (!mounted || event.heading == null) return;
        final raw = event.heading!;
        double prev = _smoothHeading ?? raw;
        double diff = raw - prev;
        if (diff > 180) diff -= 360;
        if (diff < -180) diff += 360;
        _smoothHeading = (prev + 0.2 * diff + 360) % 360;
        setState(() {});
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  double _calcQibla(double lat, double lng) {
    final latR  = lat  * math.pi / 180;
    final lngR  = lng  * math.pi / 180;
    final kLatR = _kaabaLat * math.pi / 180;
    final kLngR = _kaabaLng * math.pi / 180;
    final dLng  = kLngR - lngR;
    final y = math.sin(dLng) * math.cos(kLatR);
    final x = math.cos(latR) * math.sin(kLatR) -
              math.sin(latR) * math.cos(kLatR) * math.cos(dLng);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    // How far the Qibla mark is from the top pointer
    final double? diff = (_qiblaAngle != null && _smoothHeading != null)
        ? ((_qiblaAngle! - _smoothHeading! + 360) % 360)
        : null;
    // Aligned when Qibla mark is within 5° of the top
    final bool isAligned = diff != null && (diff < 5 || diff > 355);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Qibla Direction',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                        Text('اتجاه القبلة',
                            style: TextStyle(color: Colors.white60, fontSize: 14, fontFamily: AppTheme.arabicFontFamily)),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () { HapticFeedback.lightImpact(); _initQibla(); },
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator(color: AppTheme.gold)))
              else if (_error != null)
                Expanded(child: _ErrorView(error: _error!, onRetry: _initQibla))
              else
                Expanded(
                  child: _QiblaView(
                    qiblaAngle: _qiblaAngle!,
                    heading: _smoothHeading,
                    isAligned: isAligned,
                    diff: diff,
                    pulseCtrl: _pulseCtrl,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main view
// ─────────────────────────────────────────────────────────────────────────────
class _QiblaView extends StatelessWidget {
  final double qiblaAngle;
  final double? heading;
  final bool isAligned;
  final double? diff;
  final AnimationController pulseCtrl;

  const _QiblaView({
    required this.qiblaAngle,
    required this.heading,
    required this.isAligned,
    required this.diff,
    required this.pulseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Status badge
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isAligned
                ? AppTheme.gold.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isAligned ? AppTheme.gold.withValues(alpha: 0.6) : Colors.white24,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAligned ? Icons.check_circle_rounded : Icons.rotate_right_rounded,
                color: isAligned ? AppTheme.gold : Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isAligned ? 'You are facing the Qibla!' : 'Rotate until 🕋 reaches the top',
                style: TextStyle(
                  color: isAligned ? AppTheme.gold : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // The compass widget
        SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse when aligned
              if (isAligned)
                AnimatedBuilder(
                  animation: pulseCtrl,
                  builder: (_, __) => Container(
                    width: 300, height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.gold.withValues(alpha: pulseCtrl.value * 0.5),
                        width: 2.5,
                      ),
                    ),
                  ),
                ),

              // ── ROTATING COMPASS RING ──
              // Rotates opposite to device heading so N always points true North.
              // The Qibla mark is painted on this ring at its bearing.
              // When the Qibla mark reaches the fixed top pointer, user faces Qibla.
              Transform.rotate(
                angle: heading != null ? -heading! * math.pi / 180 : 0.0,
                child: SizedBox(
                  width: 270, height: 270,
                  child: CustomPaint(
                    painter: _CompassRingPainter(
                      qiblaAngle: qiblaAngle,
                      isAligned: isAligned,
                    ),
                  ),
                ),
              ),

              // ── FIXED TOP POINTER ──
              // Always stays at 12 o'clock — represents the direction the device faces.
              Positioned(
                top: 0,
                child: Column(
                  children: [
                    // Triangle pointer
                    ClipPath(
                      clipper: _TriangleClipper(),
                      child: Container(
                        width: 20, height: 20,
                        color: isAligned ? AppTheme.gold : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Center dot
              Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  gradient: isAligned ? AppTheme.goldGradient : AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isAligned ? AppTheme.gold : AppTheme.primaryGreen)
                          .withValues(alpha: 0.6),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Info chips
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Chip(label: 'Qibla', value: '${qiblaAngle.toStringAsFixed(1)}°'),
            const SizedBox(width: 12),
            if (heading != null)
              _Chip(label: 'Heading', value: '${heading!.toStringAsFixed(1)}°'),
          ],
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Text(
            heading == null
                ? 'Hold your phone flat and steady for accurate readings'
                : 'Slowly rotate your body until 🕋 aligns with the top pointer ▲',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ),

        if (heading == null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Text(
              'If compass is not responding, wave your phone in a figure-8 pattern to calibrate',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.gold.withValues(alpha: 0.7),
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compass ring painter — draws the compass rose + Qibla mark
// ─────────────────────────────────────────────────────────────────────────────
class _CompassRingPainter extends CustomPainter {
  final double qiblaAngle;
  final bool isAligned;
  const _CompassRingPainter({required this.qiblaAngle, required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = cx;

    // Background circle
    canvas.drawCircle(
      Offset(cx, cy),
      r - 2,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r - 2,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Degree ticks
    final tickPaint = Paint()..style = PaintingStyle.stroke;
    for (int i = 0; i < 360; i += 5) {
      final angle = (i - 90) * math.pi / 180;
      final isMain = i % 90 == 0;
      final isMid  = i % 45 == 0;
      final outer = r - 4;
      final inner = isMain ? outer - 18 : (isMid ? outer - 12 : outer - 7);
      tickPaint
        ..color = Colors.white.withValues(alpha: isMain ? 0.7 : (isMid ? 0.4 : 0.2))
        ..strokeWidth = isMain ? 2.5 : (isMid ? 1.5 : 1);
      canvas.drawLine(
        Offset(cx + outer * math.cos(angle), cy + outer * math.sin(angle)),
        Offset(cx + inner * math.cos(angle), cy + inner * math.sin(angle)),
        tickPaint,
      );
    }

    // Cardinal labels N / E / S / W
    final cardinals = [
      ('N', 0.0,   const Color(0xFFFF5252)),  // Red North
      ('E', 90.0,  Colors.white70),
      ('S', 180.0, Colors.white70),
      ('W', 270.0, Colors.white70),
    ];
    for (final c in cardinals) {
      final angle = (c.$2 - 90) * math.pi / 180;
      final labelR = r - 32;
      final x = cx + labelR * math.cos(angle);
      final y = cy + labelR * math.sin(angle);
      final tp = TextPainter(
        text: TextSpan(
          text: c.$1,
          style: TextStyle(
            color: c.$3,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }

    // Intercardinal labels NE / SE / SW / NW
    final intercardinals = ['NE', 'SE', 'SW', 'NW'];
    for (int i = 0; i < 4; i++) {
      final angle = ((i * 90 + 45) - 90) * math.pi / 180;
      final labelR = r - 44;
      final x = cx + labelR * math.cos(angle);
      final y = cy + labelR * math.sin(angle);
      final tp = TextPainter(
        text: TextSpan(
          text: intercardinals[i],
          style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 9, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }

    // ── Qibla marker on the rotating ring ──
    // Painted at qiblaAngle degrees from North (0° = top/North)
    final qAngle = (qiblaAngle - 90) * math.pi / 180;
    final qColor = isAligned ? const Color(0xFFFFB300) : const Color(0xFF4CAF50);

    // Glow
    final qTip = Offset(cx + (r - 10) * math.cos(qAngle), cy + (r - 10) * math.sin(qAngle));
    canvas.drawCircle(qTip, 14, Paint()..color = qColor.withValues(alpha: 0.25)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Line from center to edge
    canvas.drawLine(
      Offset(cx, cy),
      qTip,
      Paint()
        ..color = qColor.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    // Kaaba emoji at the marker
    final kaabaTP = TextPainter(
      text: const TextSpan(text: '🕋', style: TextStyle(fontSize: 22)),
      textDirection: TextDirection.ltr,
    )..layout();
    final kaabaPos = Offset(
      cx + (r - 20) * math.cos(qAngle) - kaabaTP.width / 2,
      cy + (r - 20) * math.sin(qAngle) - kaabaTP.height / 2,
    );
    kaabaTP.paint(canvas, kaabaPos);

    // Highlighted arc showing distance to Qibla
    final diff = (qiblaAngle + 360) % 360;
    if (!isAligned && diff > 5) {
      final arcPaint = Paint()
        ..color = qColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6;
      final startAngle = -math.pi / 2;  // top = 0° (North)
      final sweepAngle = diff * math.pi / 180;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r - 2),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CompassRingPainter old) =>
      old.qiblaAngle != qiblaAngle || old.isAligned != isAligned;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width / 2, 0)
    ..lineTo(0, size.height)
    ..lineTo(size.width, size.height)
    ..close();
  @override
  bool shouldReclip(_) => false;
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  const _Chip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🧭', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text('Cannot access compass',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(error,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}

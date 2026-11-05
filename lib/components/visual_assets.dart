import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../types/godude.dart';
import '../theme/app_theme.dart';

class GoDudeBrandLogo extends StatelessWidget {
  final String size; // 'sm' | 'md' | 'lg'
  final bool isDarkBackground;

  const GoDudeBrandLogo({
    super.key,
    this.size = 'md',
    this.isDarkBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = size == 'lg'
        ? 30.0
        : size == 'sm'
            ? 18.0
            : 24.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'GO',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: AppTheme.skyBlue,
            shadows: [
              Shadow(
                color: AppTheme.skyBlue.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'dUDe',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: isDarkBackground ? Colors.white : AppTheme.darkNavy,
            shadows: isDarkBackground
                ? [
                    Shadow(
                      color: Colors.white.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }
}

class FoodIllustrationConfig {
  final List<Color> bgGradient;
  final Color plateColor;
  final Color accent1;
  final Color accent2;
  final String label;

  const FoodIllustrationConfig({
    required this.bgGradient,
    required this.plateColor,
    required this.accent1,
    required this.accent2,
    required this.label,
  });
}

class FoodIllustration extends StatelessWidget {
  final String type;
  final double? width;
  final double? height;

  const FoodIllustration({
    super.key,
    required this.type,
    this.width,
    this.height,
  });

  static final Map<String, FoodIllustrationConfig> _configs = {
    'kottu': const FoodIllustrationConfig(
      bgGradient: [Color(0xFF78350F), Color(0xFF9A3412), Color(0xFF1C1917)],
      plateColor: Color(0xFFFEF3C7),
      accent1: Color(0xFFEA580C),
      accent2: Color(0xFF16A34A),
      label: 'Griddle Chicken Kottu',
    ),
    'cheese_kottu': const FoodIllustrationConfig(
      bgGradient: [Color(0xFFB45309), Color(0xFFCA8A04), Color(0xFF7C2D12)],
      plateColor: Color(0xFFFFFBEB),
      accent1: Color(0xFFFACC15),
      accent2: Color(0xFFDC2626),
      label: 'Creamy Cheese Kottu',
    ),
    'biriyani': const FoodIllustrationConfig(
      bgGradient: [Color(0xFF7C2D12), Color(0xFF92400E), Color(0xFF450A0A)],
      plateColor: Color(0xFFFDE68A),
      accent1: Color(0xFFF59E0B),
      accent2: Color(0xFFB91C1C),
      label: 'Saffron Dhum Biriyani',
    ),
    'fried_rice': const FoodIllustrationConfig(
      bgGradient: [Color(0xFF064E3B), Color(0xFF115E59), Color(0xFF0F172A)],
      plateColor: Color(0xFFECFDF5),
      accent1: Color(0xFFEF4444),
      accent2: Color(0xFF10B981),
      label: 'Wok Devilled Fried Rice',
    ),
    'burger': const FoodIllustrationConfig(
      bgGradient: [Color(0xFF1C1917), Color(0xFF451A03), Color(0xFF7C2D12)],
      plateColor: Color(0xFFFED7AA),
      accent1: Color(0xFFF97316),
      accent2: Color(0xFFEAB308),
      label: 'Charcoal Smash Burger',
    ),
    'lamprais': const FoodIllustrationConfig(
      bgGradient: [Color(0xFF14532D), Color(0xFF065F46), Color(0xFF1C1917)],
      plateColor: Color(0xFFBBF7D0),
      accent1: Color(0xFF15803D),
      accent2: Color(0xFFB45309),
      label: 'Banana Leaf Lamprais',
    ),
    'hoppers': const FoodIllustrationConfig(
      bgGradient: [Color(0xFF9A3412), Color(0xFF7C2D12), Color(0xFF1C1917)],
      plateColor: Color(0xFFFFF7ED),
      accent1: Color(0xFFFBBF24),
      accent2: Color(0xFFDC2626),
      label: 'Crisp Egg Hoppers',
    ),
    'isso_wade': const FoodIllustrationConfig(
      bgGradient: [Color(0xFF7F1D1D), Color(0xFF9A3412), Color(0xFF451A03)],
      plateColor: Color(0xFFFFEDD5),
      accent1: Color(0xFFEF4444),
      accent2: Color(0xFFF97316),
      label: 'Galle Face Prawn Wade',
    ),
    'wattalappan': const FoodIllustrationConfig(
      bgGradient: [Color(0xFF451A03), Color(0xFF713F12), Color(0xFF1C1917)],
      plateColor: Color(0xFFFEF08A),
      accent1: Color(0xFFA16207),
      accent2: Color(0xFFD97706),
      label: 'Jaggery Wattalappan',
    ),
    'faluda': const FoodIllustrationConfig(
      bgGradient: [Color(0xFF831843), Color(0xFF9D174D), Color(0xFF1E1B4B)],
      plateColor: Color(0xFFFCE7F3),
      accent1: Color(0xFFEC4899),
      accent2: Color(0xFFF43F5E),
      label: 'Rose Sherbet Faluda',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final cfg = _configs[type] ?? _configs['kottu']!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cfg.bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CustomPaint(
        painter: _FoodPainter(cfg: cfg),
      ),
    );
  }
}

class _FoodPainter extends CustomPainter {
  final FoodIllustrationConfig cfg;
  _FoodPainter({required this.cfg});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Steam arcs
    final steamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final pathSteam1 = Path()
      ..moveTo(cx - 15, cy - 20)
      ..quadraticBezierTo(cx - 20, cy - 35, cx - 12, cy - 42);
    canvas.drawPath(pathSteam1, steamPaint);

    final pathSteam2 = Path()
      ..moveTo(cx + 8, cy - 22)
      ..quadraticBezierTo(cx + 15, cy - 36, cx + 5, cy - 44);
    canvas.drawPath(pathSteam2, steamPaint);

    // Plate shadow
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.35);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 8),
        width: size.width * 0.72,
        height: size.height * 0.42,
      ),
      shadowPaint,
    );

    // Plate base
    final platePaint = Paint()..color = cfg.plateColor;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 4),
        width: size.width * 0.68,
        height: size.height * 0.38,
      ),
      platePaint,
    );

    // Food mound
    final foodMoundPaint = Paint()..color = cfg.accent1;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 2),
        width: size.width * 0.52,
        height: size.height * 0.28,
      ),
      foodMoundPaint,
    );

    // Topping / Egg white highlight
    final eggWhitePaint = Paint()..color = Colors.white.withValues(alpha: 0.95);
    canvas.drawCircle(Offset(cx, cy - 2), size.width * 0.12, eggWhitePaint);

    // Yolk / Center spice
    final yolkPaint = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawCircle(Offset(cx, cy - 2), size.width * 0.06, yolkPaint);

    // Curry leaf & coriander flecks
    final herbGreen = Paint()..color = const Color(0xFF22C55E);
    final chiliRed = Paint()..color = const Color(0xFFEF4444);
    final goldCorn = Paint()..color = const Color(0xFFFBBF24);

    canvas.drawCircle(Offset(cx - 14, cy + 8), 3, herbGreen);
    canvas.drawCircle(Offset(cx + 16, cy + 6), 3, herbGreen);
    canvas.drawCircle(Offset(cx - 8, cy + 12), 2.5, chiliRed);
    canvas.drawCircle(Offset(cx + 10, cy - 10), 3, goldCorn);
  }

  @override
  bool shouldRepaint(covariant _FoodPainter oldDelegate) => false;
}

class VehicleIllustration extends StatelessWidget {
  final VehicleTypeId type;
  final double width;
  final double height;

  const VehicleIllustration({
    super.key,
    required this.type,
    this.width = 48,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _VehiclePainter(type: type),
      ),
    );
  }
}

class _VehiclePainter extends CustomPainter {
  final VehicleTypeId type;
  _VehiclePainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 64.0;
    final scaleY = size.height / 44.0;
    canvas.scale(scaleX, scaleY);

    if (type == VehicleTypeId.bike) {
      // Wheels
      final wheelPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill;
      final rimPaint = Paint()
        ..color = const Color(0xFF0284C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawCircle(const Offset(15, 33), 7, wheelPaint);
      canvas.drawCircle(const Offset(15, 33), 7, rimPaint);
      canvas.drawCircle(const Offset(49, 33), 7, wheelPaint);
      canvas.drawCircle(const Offset(49, 33), 7, rimPaint);

      // Body frame
      final bodyPaint = Paint()..color = const Color(0xFF0EA5E9);
      final bodyPath = Path()
        ..moveTo(15, 33)
        ..lineTo(26, 20)
        ..lineTo(38, 20)
        ..lineTo(45, 31)
        ..lineTo(24, 31)
        ..close();
      canvas.drawPath(bodyPath, bodyPaint);

      // Handlebar
      final barPaint = Paint()
        ..color = const Color(0xFF0284C7)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final barPath = Path()
        ..moveTo(40, 12)
        ..lineTo(46, 12)
        ..lineTo(49, 33);
      canvas.drawPath(barPath, barPaint);

      // Seat
      final seatPaint = Paint()..color = const Color(0xFF0F172A);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(20, 16, 14, 5),
          const Radius.circular(2.5),
        ),
        seatPaint,
      );
    } else if (type == VehicleTypeId.tuktuk) {
      // Wheels
      final wheelPaint = Paint()..color = const Color(0xFF1E293B);
      final rimPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawCircle(const Offset(15, 34), 6.5, wheelPaint);
      canvas.drawCircle(const Offset(15, 34), 6.5, rimPaint);
      canvas.drawCircle(const Offset(49, 34), 6.5, wheelPaint);
      canvas.drawCircle(const Offset(49, 34), 6.5, rimPaint);

      // Canopy
      final canopyPaint = Paint()..color = const Color(0xFFEAB308);
      final canopyPath = Path()
        ..moveTo(12, 12)
        ..quadraticBezierTo(32, 6, 48, 13)
        ..lineTo(52, 24)
        ..lineTo(12, 24)
        ..close();
      canvas.drawPath(canopyPath, canopyPaint);

      // Green body
      final bodyPaint = Paint()..color = const Color(0xFF16A34A);
      final bodyPath = Path()
        ..moveTo(10, 22)
        ..lineTo(53, 22)
        ..lineTo(55, 32)
        ..lineTo(10, 32)
        ..close();
      canvas.drawPath(bodyPath, bodyPaint);

      // Window / Windshield
      final windPaint = Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 0.9);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(33, 14, 12, 8),
          const Radius.circular(2),
        ),
        windPaint,
      );
    } else {
      // Car
      final bodyPaint = Paint()..color = const Color(0xFF2563EB);
      final bodyPath = Path()
        ..moveTo(8, 26)
        ..lineTo(16, 14)
        ..lineTo(44, 14)
        ..lineTo(54, 25)
        ..lineTo(58, 26)
        ..lineTo(58, 34)
        ..lineTo(6, 34)
        ..close();
      canvas.drawPath(bodyPath, bodyPaint);

      final glassPaint = Paint()..color = const Color(0xFFBAE6FD);
      final glassPath1 = Path()
        ..moveTo(18, 16)
        ..lineTo(30, 16)
        ..lineTo(30, 24)
        ..lineTo(14, 24)
        ..close();
      canvas.drawPath(glassPath1, glassPaint);

      final glassPath2 = Path()
        ..moveTo(33, 16)
        ..lineTo(43, 16)
        ..lineTo(49, 24)
        ..lineTo(33, 24)
        ..close();
      canvas.drawPath(glassPath2, glassPaint);

      final wheelPaint = Paint()..color = const Color(0xFF0F172A);
      final rimPaint = Paint()
        ..color = const Color(0xFF93C5FD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawCircle(const Offset(17, 34), 6.5, wheelPaint);
      canvas.drawCircle(const Offset(17, 34), 6.5, rimPaint);
      canvas.drawCircle(const Offset(47, 34), 6.5, wheelPaint);
      canvas.drawCircle(const Offset(47, 34), 6.5, rimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VehiclePainter oldDelegate) =>
      oldDelegate.type != type;
}

class LiveRouteMap extends StatelessWidget {
  final SriLankaLocation origin;
  final SriLankaLocation? destination;
  final VehicleTypeId vehicleType;
  final double distanceKm;
  final int etaMins;
  final bool isFlexibleMode;
  final bool isTripActive;
  final double progressPercent;

  const LiveRouteMap({
    super.key,
    required this.origin,
    this.destination,
    required this.vehicleType,
    required this.distanceKm,
    required this.etaMins,
    this.isFlexibleMode = false,
    this.isTripActive = false,
    this.progressPercent = 45.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFE5EEF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MapCanvasPainter(
                isFlexibleMode: isFlexibleMode,
                isTripActive: isTripActive,
                progressPercent: progressPercent,
              ),
            ),
          ),

          // Top left GPS badge
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.darkNavy.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Demo GPS',
                    style: TextStyle(
                      color: AppTheme.skyBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    ' · ',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  Text(
                    '${origin.city} Live Map',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Route Summary Bar
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.slate200),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${origin.name.split('·')[0].trim()} → ${isFlexibleMode ? (isTripActive ? "Metered Open Route" : "Flexible Open Destination") : (destination?.name.split('·')[0].trim() ?? "Destination")}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${distanceKm.toStringAsFixed(1)} km · $etaMins min',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  final bool isFlexibleMode;
  final bool isTripActive;
  final double progressPercent;

  _MapCanvasPainter({
    required this.isFlexibleMode,
    required this.isTripActive,
    required this.progressPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 400.0;
    final scaleY = size.height / 180.0;
    canvas.scale(scaleX, scaleY);

    // Ocean on left
    final oceanPaint = Paint()..color = const Color(0xFFBAE6FD);
    final oceanPath = Path()
      ..moveTo(0, 0)
      ..lineTo(68, 0)
      ..quadraticBezierTo(78, 90, 62, 180)
      ..lineTo(0, 180)
      ..close();
    canvas.drawPath(oceanPath, oceanPaint);

    // Parks (green areas)
    final parkPaint1 = Paint()
      ..color = const Color(0xFFBBF7D0).withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(70, 15, 42, 65),
        const Radius.circular(8),
      ),
      parkPaint1,
    );

    final parkPaint2 = Paint()
      ..color = const Color(0xFFDCFCE7).withValues(alpha: 0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(240, 105, 75, 55),
        const Radius.circular(12),
      ),
      parkPaint2,
    );

    // Lake (Beira Lake)
    final lakePaint = Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.75);
    final lakePath = Path()
      ..moveTo(135, 28)
      ..quadraticBezierTo(175, 20, 190, 48)
      ..quadraticBezierTo(165, 65, 135, 45)
      ..close();
    canvas.drawPath(lakePath, lakePaint);

    // Coastline Beach sand buffer
    final beachPaint = Paint()
      ..color = const Color(0xFFFEF3C7).withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final beachPath = Path()
      ..moveTo(68, 0)
      ..quadraticBezierTo(78, 90, 62, 180);
    canvas.drawPath(beachPath, beachPaint);

    // City Building Blocks (Subtle map texture)
    final blockPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.65);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(110, 52, 38, 32),
        const Radius.circular(4),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(195, 50, 48, 36),
        const Radius.circular(4),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(265, 46, 52, 42),
        const Radius.circular(4),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(115, 108, 45, 30),
        const Radius.circular(4),
      ),
      blockPaint,
    );

    // Primary Roads (White Avenues)
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Coastal Highway (Marine Drive curving naturally along coast, NO harsh vertical lines)
    final coastalHighway = Path()
      ..moveTo(70, 0)
      ..quadraticBezierTo(82, 90, 66, 180);
    canvas.drawPath(coastalHighway, roadPaint);

    // Inland Arterial Boulevard curving towards Kandy road
    final inlandArtery = Path()
      ..moveTo(140, 0)
      ..quadraticBezierTo(175, 75, 230, 180);
    canvas.drawPath(inlandArtery, roadPaint);

    // East-West Connecting Boulevards
    final eastWest1 = Path()
      ..moveTo(68, 42)
      ..quadraticBezierTo(200, 38, 400, 35);
    canvas.drawPath(eastWest1, roadPaint);

    final eastWest2 = Path()
      ..moveTo(78, 95)
      ..quadraticBezierTo(220, 92, 400, 105);
    canvas.drawPath(eastWest2, roadPaint);

    final eastWest3 = Path()
      ..moveTo(65, 145)
      ..quadraticBezierTo(210, 140, 400, 138);
    canvas.drawPath(eastWest3, roadPaint);

    // Roundabouts at city intersections
    final roundaboutPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(168, 95), 8, roundaboutPaint);
    canvas.drawCircle(const Offset(168, 95), 3, Paint()..color = const Color(0xFFBBF7D0));

    // Secondary connecting streets (Soft Slate)
    final secRoadPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(70, 68), const Offset(400, 68), secRoadPaint);
    canvas.drawLine(const Offset(68, 122), const Offset(400, 122), secRoadPaint);
    final diagonalSec = Path()
      ..moveTo(100, 180)
      ..quadraticBezierTo(190, 130, 320, 60);
    canvas.drawPath(diagonalSec, secRoadPaint);

    // Navigation Route Polyline
    final routeShadow = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.2)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final routePaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final routePath = Path()
      ..moveTo(96, 128)
      ..lineTo(138, 78)
      ..lineTo(168, 112)
      ..lineTo(222, 48)
      ..lineTo(308, 115);

    canvas.drawPath(routePath, routeShadow);
    canvas.drawPath(routePath, routePaint);

    // Origin Pin (Blue)
    _drawPin(canvas, const Offset(96, 128), const Color(0xFF0284C7));

    // Destination Pin (Orange)
    if (!isFlexibleMode) {
      _drawPin(canvas, const Offset(308, 115), const Color(0xFFEA580C));
    }

    // Moving Vehicle Marker
    final clamped = math.max(10.0, math.min(92.0, progressPercent));
    final riderX = 96.0 + (clamped / 100.0) * 200.0;
    final riderY = 115.0 - math.sin((clamped / 100.0) * math.pi) * 48.0;

    final pulsePaint = Paint()..color = const Color(0xFF2563EB).withValues(alpha: 0.25);
    canvas.drawCircle(Offset(riderX, riderY), 14, pulsePaint);

    final vehicleBase = Paint()..color = const Color(0xFF0F172A);
    final vehicleStroke = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(riderX, riderY), 9, vehicleBase);
    canvas.drawCircle(Offset(riderX, riderY), 9, vehicleStroke);

    final dotPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawCircle(Offset(riderX, riderY), 3.5, dotPaint);
  }

  void _drawPin(Canvas canvas, Offset pos, Color color) {
    final aura = Paint()..color = color.withValues(alpha: 0.22);
    canvas.drawCircle(pos, 11, aura);

    final pinPaint = Paint()..color = color;
    final path = Path()
      ..moveTo(pos.dx, pos.dy - 18)
      ..cubicTo(pos.dx - 7, pos.dy - 18, pos.dx - 12, pos.dy - 13, pos.dx - 12, pos.dy - 6)
      ..cubicTo(pos.dx - 12, pos.dy + 3, pos.dx, pos.dy + 14, pos.dx, pos.dy + 14)
      ..cubicTo(pos.dx, pos.dy + 14, pos.dx + 12, pos.dy + 3, pos.dx + 12, pos.dy - 6)
      ..cubicTo(pos.dx + 12, pos.dy - 13, pos.dx + 7, pos.dy - 18, pos.dx, pos.dy - 18)
      ..close();
    canvas.drawPath(path, pinPaint);

    final whiteHole = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(pos.dx, pos.dy - 7), 4, whiteHole);
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) =>
      oldDelegate.progressPercent != progressPercent ||
      oldDelegate.isTripActive != isTripActive ||
      oldDelegate.isFlexibleMode != isFlexibleMode;
}

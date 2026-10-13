import 'dart:math' as math;
import 'package:flutter/material.dart';

enum LogoVariant {
  compact, // 28-36dp: For AppBar
  hero,    // 56-80dp: For Dashboard HUD banner
  splash,  // 120-160dp: For initialization splash
}

/**
 * Animated DotLan Logo.
 * 
 * Implements the official DotNetwork / Jazdot brand design language:
 * - Dark squircle badge container (#05070B) with hairline gold/emerald border.
 * - Local subnet radar range rings with continuous 360-degree sweep fan.
 * - Discovered local IoT edge nodes pulsing in Emerald (#10B981) and Teal (#14B8A6).
 * - Signature Jazdot Gold Dot (#FBBF24 / #D97706) anchored at the central gateway hub.
 */
class DotLanAnimatedLogo extends StatefulWidget {
  final double size;
  final LogoVariant variant;
  final bool showWordmark;

  const DotLanAnimatedLogo({
    super.key,
    this.size = 32.0,
    this.variant = LogoVariant.compact,
    this.showWordmark = false,
  });

  @override
  State<DotLanAnimatedLogo> createState() => _DotLanAnimatedLogoState();
}

class _DotLanAnimatedLogoState extends State<DotLanAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoWidget = SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _DotLanLogoPainter(
              progress: _controller.value,
              variant: widget.variant,
            ),
          );
        },
      ),
    );

    if (!widget.showWordmark) {
      return logoWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoWidget,
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text(
                  'DOT',
                  style: TextStyle(
                    color: Color(0xFFFAFAFA),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'LAN',
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const Text(
              'LOCAL IOT & SUBNET RADAR',
              style: TextStyle(
                color: Color(0xFF71717A),
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DotLanLogoPainter extends CustomPainter {
  final double progress;
  final LogoVariant variant;

  _DotLanLogoPainter({
    required this.progress,
    required this.variant,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);

    // 1. Dark Squircle Container (rx = 22%)
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.22),
    );

    final bgPaint = Paint()
      ..color = const Color(0xFF05070B)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rect, bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0x3310B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rect, borderPaint);

    // 2. Concentric Subnet Range Rings
    final ringPaint1 = Paint()
      ..color = const Color(0xFF065F46).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, w * 0.38, ringPaint1);

    final ringPaint2 = Paint()
      ..color = const Color(0xFF047857).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, w * 0.25, ringPaint2);

    // 3. Rotating Radar Sweep Beam (360 degrees)
    final sweepAngle = progress * 2 * math.pi;
    final sweepLength = w * 0.38;
    final sweepEnd = Offset(
      center.dx + sweepLength * math.cos(sweepAngle),
      center.dy + sweepLength * math.sin(sweepAngle),
    );

    // Radar beam trail gradient arc
    final sweepTrailPaint = Paint()
      ..shader = SweepGradient(
        center: FractionalOffset.center,
        startAngle: sweepAngle - math.pi * 0.35,
        endAngle: sweepAngle,
        colors: [
          const Color(0x0010B981),
          const Color(0x3310B981),
          const Color(0x6634D399),
        ],
        transform: GradientRotation(sweepAngle - math.pi * 0.35),
      ).createShader(Rect.fromCircle(center: center, radius: sweepLength))
      ..style = PaintingStyle.fill;

    final sweepPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: sweepLength),
        sweepAngle - math.pi * 0.35,
        math.pi * 0.35,
        false,
      )
      ..close();
    canvas.drawPath(sweepPath, sweepTrailPaint);

    // Radar leading line
    final sweepLinePaint = Paint()
      ..color = const Color(0xFF34D399)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(center, sweepEnd, sweepLinePaint);

    // 4. Discovered Local Mesh Peripheral Nodes
    final nodeCoords = [
      Offset(center.dx - w * 0.24, center.dy - w * 0.22), // Camera node
      Offset(center.dx + w * 0.26, center.dy - w * 0.16), // Smart Edge node
      Offset(center.dx - w * 0.20, center.dy + w * 0.24), // Workstation node
    ];

    for (int i = 0; i < nodeCoords.length; i++) {
      final node = nodeCoords[i];
      // Node pulse phase offset
      final nodePhase = (progress * 2.0 + (i * 0.33)) % 1.0;
      final nodeAlpha = 0.4 + 0.6 * math.sin(nodePhase * math.pi);

      // Connection datapath vector to central hub
      final linkPaint = Paint()
        ..color = const Color(0xFF10B981).withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(center, node, linkPaint);

      // Outer node ring
      final nodeRingPaint = Paint()
        ..color = const Color(0xFF34D399).withOpacity(nodeAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(node, w * 0.045, nodeRingPaint);

      // Inner node dot
      final nodeDotPaint = Paint()
        ..color = const Color(0xFF10B981).withOpacity(nodeAlpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(node, w * 0.022, nodeDotPaint);
    }

    // 5. Signature Jazdot Pulsing Gold Dot (Central Gateway Anchor)
    final baseDotRadius = w * 0.085;
    final pulseScale = 1.0 + 0.16 * math.sin(progress * 2 * math.pi);
    final activeDotRadius = baseDotRadius * pulseScale;

    // Outer subtle gold glow
    final glowPaint = Paint()
      ..color = const Color(0xFFD97706).withOpacity(0.28)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, activeDotRadius * 1.8, glowPaint);

    // Inner vibrant gold gradient circle
    final dotPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: activeDotRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, activeDotRadius, dotPaint);

    final dotBorderPaint = Paint()
      ..color = const Color(0xFFFBBF24).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, activeDotRadius * 1.2, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _DotLanLogoPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

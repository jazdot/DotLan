import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/lan_device.dart';
import '../../../core/theme/obsidian_theme.dart';
import '../../../core/audio/field_feedback_engine.dart';

/**
 * 360-Degree Interactive Subnet Radar Topology Canvas.
 * 
 * Plots active local endpoints radially according to round-trip latency (ms).
 * Features rotating sweep beam and touch hit-testing for device inspection.
 */
class TopologyRadarCanvas extends StatefulWidget {
  final List<LanDevice> devices;
  final bool isScanning;
  final LanDevice? selectedDevice;
  final void Function(LanDevice device)? onDeviceSelected;

  const TopologyRadarCanvas({
    super.key,
    required this.devices,
    this.isScanning = false,
    this.selectedDevice,
    this.onDeviceSelected,
  });

  @override
  State<TopologyRadarCanvas> createState() => _TopologyRadarCanvasState();
}

class _TopologyRadarCanvasState extends State<TopologyRadarCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  void _handleTapUp(TapUpDetails details, Size size) {
    if (widget.devices.isEmpty || widget.onDeviceSelected == null) return;
    final center = Offset(size.width / 2, size.height / 2);
    final tapPos = details.localPosition;
    final maxRadius = math.min(size.width, size.height) * 0.44;

    LanDevice? closestDevice;
    double closestDist = 24.0; // Touch tolerance in dp

    for (int i = 0; i < widget.devices.length; i++) {
      final dev = widget.devices[i];
      final angle = (i * (2 * math.pi / widget.devices.length)) - (math.pi / 2);
      final normLat = (dev.pingLatencyMs / 50.0).clamp(0.18, 0.95);
      final r = normLat * maxRadius;
      final nodePos = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );

      final dist = (tapPos - nodePos).distance;
      if (dist < closestDist) {
        closestDist = dist;
        closestDevice = dev;
      }
    }

    if (closestDevice != null) {
      FieldFeedbackEngine.triggerSelectionClick();
      widget.onDeviceSelected!(closestDevice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onTapUp: (details) => _handleTapUp(details, size),
          child: AnimatedBuilder(
            animation: _sweepController,
            builder: (context, _) {
              return CustomPaint(
                size: size,
                painter: _RadarTopologyPainter(
                  devices: widget.devices,
                  sweepProgress: _sweepController.value,
                  isScanning: widget.isScanning,
                  selectedDevice: widget.selectedDevice,
                  isLight: ObsidianTheme.isLight,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _RadarTopologyPainter extends CustomPainter {
  final List<LanDevice> devices;
  final double sweepProgress;
  final bool isScanning;
  final LanDevice? selectedDevice;
  final bool isLight;

  _RadarTopologyPainter({
    required this.devices,
    required this.sweepProgress,
    required this.isScanning,
    required this.selectedDevice,
    required this.isLight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.44;

    // 1. Concentric Latency Rings (10ms, 25ms, 50ms)
    final ringPaints = [0.25, 0.50, 0.75, 1.0];
    for (int i = 0; i < ringPaints.length; i++) {
      final r = maxRadius * ringPaints[i];
      final paint = Paint()
        ..color = isLight
            ? const Color(0x1F0F172A)
            : const Color(0x1F10B981)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (i == ringPaints.length - 1) ? 1.5 : 1.0;
      canvas.drawCircle(center, r, paint);
    }

    // Crosshair reference axes
    final crossPaint = Paint()
      ..color = isLight ? const Color(0x140F172A) : const Color(0x1410B981)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), crossPaint);

    // 2. Rotating Radar Sweep Fan Beam (360 degrees)
    if (isScanning || devices.isNotEmpty) {
      final sweepAngle = sweepProgress * 2 * math.pi;
      final sweepTrailPaint = Paint()
        ..shader = SweepGradient(
          center: FractionalOffset.center,
          startAngle: sweepAngle - math.pi * 0.35,
          endAngle: sweepAngle,
          colors: [
            const Color(0x0010B981),
            const Color(0x2210B981),
            const Color(0x5534D399),
          ],
          transform: GradientRotation(sweepAngle - math.pi * 0.35),
        ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
        ..style = PaintingStyle.fill;

      final sweepPath = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: maxRadius),
          sweepAngle - math.pi * 0.35,
          math.pi * 0.35,
          false,
        )
        ..close();
      canvas.drawPath(sweepPath, sweepTrailPaint);

      final sweepLine = Paint()
        ..color = const Color(0xFF34D399)
        ..strokeWidth = 1.5;
      final sweepEnd = Offset(
        center.dx + maxRadius * math.cos(sweepAngle),
        center.dy + maxRadius * math.sin(sweepAngle),
      );
      canvas.drawLine(center, sweepEnd, sweepLine);
    }

    // 3. Render Discovered Endpoint Blips
    for (int i = 0; i < devices.length; i++) {
      final dev = devices[i];
      final angle = (i * (2 * math.pi / devices.length)) - (math.pi / 2);
      final normLat = (dev.pingLatencyMs / 50.0).clamp(0.18, 0.95);
      final r = normLat * maxRadius;
      final pos = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );

      final isSelected = selectedDevice?.ip == dev.ip;

      // Color coding: Crimson for confirmed cameras, Amber for gateway, Emerald for safe
      Color blipColor;
      if (dev.isConfirmedCamera) {
        blipColor = const Color(0xFFEF4444);
      } else if (dev.isCamera) {
        blipColor = const Color(0xFFF59E0B);
      } else if (dev.isGateway) {
        blipColor = const Color(0xFFFBBF24);
      } else {
        blipColor = const Color(0xFF10B981);
      }

      // Datapath link vector to central hub
      final linkPaint = Paint()
        ..color = blipColor.withOpacity(isSelected ? 0.6 : 0.2)
        ..strokeWidth = isSelected ? 1.5 : 0.8;
      canvas.drawLine(center, pos, linkPaint);

      // Node ring
      final ringPaint = Paint()
        ..color = blipColor.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.5 : 1.2;
      canvas.drawCircle(pos, isSelected ? 9.0 : 5.5, ringPaint);

      // Core dot
      final dotPaint = Paint()
        ..color = blipColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, isSelected ? 4.5 : 2.8, dotPaint);

      // Camera warning pulse halo
      if (dev.isConfirmedCamera) {
        final alertPaint = Paint()
          ..color = const Color(0xFFEF4444).withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(pos, 13.0, alertPaint);
      }
    }

    // 4. Central Gateway Anchor: Jazdot Pulsing Gold Dot
    final goldGlow = Paint()
      ..color = const Color(0xFFD97706).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14.0, goldGlow);

    final goldDot = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: 8.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8.0, goldDot);

    final goldBorder = Paint()
      ..color = const Color(0xFFFBBF24).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, 10.0, goldBorder);
  }

  @override
  bool shouldRepaint(covariant _RadarTopologyPainter oldDelegate) {
    return true; // Continuously animated sweep beam
  }
}

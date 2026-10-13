import 'package:flutter/services.dart';

/**
 * Field Feedback Engine for DotLan.
 * 
 * Delivers discrete tactile and acoustic alerts during radar sweeps
 * and surveillance sentry alarms in parity with DotSignal.
 */
class FieldFeedbackEngine {
  static int _lastTickTimeMs = 0;

  /**
   * Fires a light tactile tick as the radar sweep beam traverses an active host.
   * Throttled to max 10 ticks per second to prevent haptic coil fatigue.
   */
  static void triggerRadarTick() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastTickTimeMs < 100) return;
    _lastTickTimeMs = now;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /**
   * Fires an urgent double-impact pulse when a confirmed video camera is verified.
   */
  static void triggerCameraAlert() {
    try {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 140), () {
        HapticFeedback.heavyImpact();
      });
    } catch (_) {}
  }

  /**
   * Fires a selection click on user interaction.
   */
  static void triggerSelectionClick() {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /**
   * Fires a warning vibration when a new unrecognized host joins the subnet.
   */
  static void triggerRogueDeviceAlert() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}

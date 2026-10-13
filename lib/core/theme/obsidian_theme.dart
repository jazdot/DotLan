import 'package:flutter/material.dart';

/**
 * Jazdot Enterprises Obsidian Luxury CAD Design System.
 * 
 * Strict 8pt dynamic spacing tokens, deep OLED backdrops / clean high-contrast light mode,
 * tabular monospace figures, and gold-amber telemetry accents.
 */
class ObsidianTheme {
  // ── 8pt Spacing Grid Tokens ───────────────────────────────────────────────
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 20.0;
  static const double spaceXxl = 24.0;
  static const double spaceHero = 32.0;

  // ── Radius Tokens ────────────────────────────────────────────────────────
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusPill = 999.0;
  static const double radiusCard = 8.0;

  // ── Active Theme Controller & Detection ──────────────────────────────────
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

  static bool get isLight {
    final mode = themeModeNotifier.value;
    if (mode == ThemeMode.light) return true;
    if (mode == ThemeMode.dark) return false;
    try {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light;
    } catch (_) {
      return false;
    }
  }

  // ── Base Canvas Palette ──────────────────────────────────────────────────
  static const Color pureBlack = Color(0xFF000000);
  static Color get bgBase => isLight ? const Color(0xFFF1F5F9) : const Color(0xFF05070B);     // Slate 100 / Deep OLED
  static Color get bgSurface => isLight ? const Color(0xFFFFFFFF) : const Color(0xFF0E121A);  // Card / Telemetry panel
  static Color get bgElevated => isLight ? const Color(0xFFFFFFFF) : const Color(0xFF161B26); // Modals / Elevated panels
  static Color get bgSubtle => isLight ? const Color(0xFFE2E8F0) : const Color(0xFF1E2433);   // Track bars & subtle fills
  static Color get cardBackground => isLight ? const Color(0xFFFFFFFF) : const Color(0xFF0E121A);
  static Color get cardBackgroundLight => isLight ? const Color(0xFFF8FAFC) : const Color(0xFF161B26);
  static Color get surfaceElevated => isLight ? const Color(0xFFFFFFFF) : const Color(0xFF161B26);
  static Color get surfaceNavy => isLight ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  static Color get gaugeTrack => bgSubtle;

  // ── Hairline Border Tokens ───────────────────────────────────────────────
  static Color get borderSubtle => isLight ? const Color(0x1F0F172A) : const Color(0x14FFFFFF);
  static Color get borderActive => isLight ? const Color(0x3D0F172A) : const Color(0x33FFFFFF);
  static Color get borderStrong => borderActive;
  static Color get borderGold => isLight ? const Color(0x4DD97706) : const Color(0x33D97706);

  // ── Typography Colors ────────────────────────────────────────────────────
  static Color get textPrimary => isLight ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA);
  static Color get textSecondary => isLight ? const Color(0xFF475569) : const Color(0xFFA1A1AA);
  static Color get textTertiary => isLight ? const Color(0xFF64748B) : const Color(0xFF71717A);

  // ── Jazdot Brand Gold & Amber Accents ────────────────────────────────────
  static Color get accentGold => isLight ? const Color(0xFFD97706) : const Color(0xFFFBBF24);
  static Color get accentAmber => isLight ? const Color(0xFFB45309) : const Color(0xFFD97706);
  static Color get accentMuted => isLight ? const Color(0x1FE0A82E) : const Color(0x1FD97706);
  static Color get accentGlow => isLight ? const Color(0x1FD97706) : const Color(0x2EFBBF24);

  static LinearGradient get goldGradient => LinearGradient(
    colors: [accentGold, accentAmber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── 3GPP TS 38.133 Signal Quality Bins ───────────────────────────────────
  static Color get signalExcellent => isLight ? const Color(0xFF059669) : const Color(0xFF10B981);
  static Color get signalGood => isLight ? const Color(0xFF2563EB) : const Color(0xFF3B82F6);
  static Color get signalFair => isLight ? const Color(0xFFD97706) : const Color(0xFFF59E0B);
  static Color get signalCritical => isLight ? const Color(0xFFDC2626) : const Color(0xFFEF4444);
  static Color get signalPoor => signalCritical;

  // ── Connectivity Mode Indicators ─────────────────────────────────────────
  static Color get tddCyan => isLight ? const Color(0xFF0284C7) : const Color(0xFF06B6D4);
  static Color get fddPurple => isLight ? const Color(0xFF7C3AED) : const Color(0xFF8B5CF6);

  // ── Tabular Figures Monospace TextStyle Helper ───────────────────────────
  static TextStyle tabularNumberStyle({
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      fontFamily: 'monospace',
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: 0.5,
    );
  }

  static BoxDecoration cardDecoration({bool hasGoldBorder = false}) {
    return BoxDecoration(
      color: bgSurface,
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(
        color: hasGoldBorder ? borderGold : borderSubtle,
        width: 1.0,
      ),
    );
  }

  static ThemeData get themeData => isLight ? lightThemeData : darkThemeData;

  static ThemeData get darkThemeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF05070B),
      primaryColor: const Color(0xFFFBBF24),
      cardColor: const Color(0xFF0E121A),
      dividerColor: const Color(0x14FFFFFF),
      fontFamily: 'monospace',
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF0E121A),
        primary: Color(0xFFFBBF24),
        secondary: Color(0xFFD97706),
        error: Color(0xFFEF4444),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF05070B),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFFFAFAFA),
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          fontFamily: 'monospace',
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF0E121A),
      ),
    );
  }

  static ThemeData get lightThemeData {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      primaryColor: const Color(0xFFD97706),
      cardColor: const Color(0xFFFFFFFF),
      dividerColor: const Color(0x1F0F172A),
      fontFamily: 'monospace',
      colorScheme: const ColorScheme.light(
        surface: Color(0xFFFFFFFF),
        primary: Color(0xFFD97706),
        secondary: Color(0xFFB45309),
        error: Color(0xFFDC2626),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          fontFamily: 'monospace',
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFFFFFFFF),
      ),
    );
  }
}

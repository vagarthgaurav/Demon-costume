import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Visual identity for the demon board control panel.
///
/// Matched to the actual costume: sky blue into mint green, carried as a
/// gradient everywhere the accent appears (buttons, slider fills,
/// highlights). Dark, cool neutrals underneath; monospace for live readouts.
abstract final class AppColors {
  static const background = Color(0xFF0A0D10);
  static const surface = Color(0xFF12181B);
  static const surfaceRaised = Color(0xFF182124);
  static const border = Color(0xFF232D31);
  static const textPrimary = Color(0xFFF1F6F5);
  static const textSecondary = Color(0xFF8C9BA1);

  // Brand accent: sky blue into mint green. accentSolid is the flat
  // fallback for icons and small text where a gradient can't be painted.
  static const accentStart = Color(0xFF38BDF8);
  static const accentEnd = Color(0xFF34D399);
  static const accentSolid = Color(0xFF3FC9C0);
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentStart, accentEnd],
  );

  // Reserved for low-battery/danger states - the brand accent no longer
  // reads as "warning", so this needs to be its own color.
  static const warning = Color(0xFFF2545B);
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.background,
        primary: AppColors.accentSolid,
        onPrimary: AppColors.textPrimary,
        secondary: AppColors.accentSolid,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          letterSpacing: 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerColor: AppColors.border,
      sliderTheme: SliderThemeData(
        trackHeight: 3,
        trackShape: const _GradientTrackShape(),
        activeTrackColor: AppColors.accentSolid,
        inactiveTrackColor: AppColors.border,
        thumbShape: const _BarThumbShape(),
        thumbColor: AppColors.textPrimary,
        overlayColor: AppColors.accentSolid.withValues(alpha: 0.14),
        valueIndicatorColor: AppColors.surfaceRaised,
        valueIndicatorTextStyle: GoogleFonts.jetBrainsMono(
          color: AppColors.textPrimary,
          fontSize: 12,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static TextStyle mono({double size = 14, Color? color, FontWeight? weight}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      color: color ?? AppColors.textPrimary,
      fontWeight: weight ?? FontWeight.w500,
    );
  }
}

/// Paints the active portion of a slider track with the brand gradient
/// instead of a flat fill.
class _GradientTrackShape extends RoundedRectSliderTrackShape {
  const _GradientTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    required TextDirection textDirection,
    double additionalActiveTrackHeight = 0,
  }) {
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final canvas = context.canvas;
    final radius = Radius.circular(trackRect.height / 2);

    final inactiveRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(inactiveRect, radius),
      Paint()..color = sliderTheme.inactiveTrackColor ?? AppColors.border,
    );

    final activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );
    if (activeRect.width <= 0) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(activeRect, radius),
      Paint()..shader = AppColors.accentGradient.createShader(trackRect),
    );
  }
}

/// A thin vertical bar instead of Material's default fat circular thumb -
/// reads as an instrument fader, not a phone-settings slider.
class _BarThumbShape extends SliderComponentShape {
  const _BarThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(4, 22);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double textScaleFactor,
    required Size sizeWithOverflow,
    required double value,
  }) {
    final canvas = context.canvas;
    final rect = Rect.fromCenter(center: center, width: 4, height: 22);
    final paint = Paint()..color = sliderTheme.thumbColor ?? AppColors.textPrimary;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(1)), paint);
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Visual identity for the demon board control panel.
///
/// This is a single instrument, not a consumer app: dark-only, sharp edges,
/// one accent color, monospace for anything that's a live readout.
abstract final class AppColors {
  static const background = Color(0xFF0B0B0D);
  static const surface = Color(0xFF17171B);
  static const surfaceRaised = Color(0xFF1D1D22);
  static const border = Color(0xFF2C2C33);
  static const textPrimary = Color(0xFFF3F1EC);
  static const textSecondary = Color(0xFF8B8B93);
  static const accent = Color(0xFFE2483B);
  static const good = Color(0xFF4CAF6D);
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
        primary: AppColors.accent,
        onPrimary: AppColors.textPrimary,
        secondary: AppColors.accent,
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
        trackHeight: 2,
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.border,
        thumbShape: const _BarThumbShape(),
        thumbColor: AppColors.textPrimary,
        overlayColor: AppColors.accent.withValues(alpha: 0.12),
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
            borderRadius: BorderRadius.circular(2),
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

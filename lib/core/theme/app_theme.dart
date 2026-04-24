import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semua warna terpusat di sini.
/// Light = soft lavender-white palette
/// Dark  = deep midnight navy palette
abstract class AppColors {
  // ── Light ─────────────────────────────────────────────────────────────────
  static const lBg          = Color(0xFFF7F5FF); // Very soft lavender white
  static const lSurface     = Color(0xFFFFFFFF);
  static const lSurfaceVar  = Color(0xFFEFECFF); // Input fill / chip bg
  static const lPrimary     = Color(0xFF5B4FD4); // Calm indigo
  static const lPrimaryTint = Color(0xFFEBE8FF); // Badge / light accent
  static const lText        = Color(0xFF1C1A35); // Deep navy text
  static const lTextSub     = Color(0xFF706E8F); // Muted subtitle
  static const lBorder      = Color(0xFFE5E2F5); // Hairline border
  static const lGreen       = Color(0xFF3E9E78); // Exercise section
  static const lTeal        = Color(0xFF3F8FA0); // Activity section

  // ── Dark ──────────────────────────────────────────────────────────────────
  static const dBg          = Color(0xFF0D0C18); // Deep midnight
  static const dSurface     = Color(0xFF18172A); // Card surface
  static const dSurfaceVar  = Color(0xFF221F38); // Input fill
  static const dPrimary     = Color(0xFF9D95E8); // Lighter indigo
  static const dPrimaryDim  = Color(0xFF2A2755); // Badge in dark
  static const dText        = Color(0xFFEAE8F8); // Soft white
  static const dTextSub     = Color(0xFF7878A0); // Muted text
  static const dBorder      = Color(0xFF2E2C48); // Subtle border
  static const dGreen       = Color(0xFF52BE92); // Exercise dark
  static const dTeal        = Color(0xFF5AAFC0); // Activity dark
}

class AppTheme {
  AppTheme._();

  static ThemeData light = _build(Brightness.light);
  static ThemeData dark  = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final bg         = isLight ? AppColors.lBg         : AppColors.dBg;
    final surface    = isLight ? AppColors.lSurface     : AppColors.dSurface;
    final surfaceVar = isLight ? AppColors.lSurfaceVar  : AppColors.dSurfaceVar;
    final primary    = isLight ? AppColors.lPrimary     : AppColors.dPrimary;
    final text       = isLight ? AppColors.lText        : AppColors.dText;
    final textSub    = isLight ? AppColors.lTextSub     : AppColors.dTextSub;
    final border     = isLight ? AppColors.lBorder      : AppColors.dBorder;

    final colorScheme = ColorScheme(
      brightness:       brightness,
      primary:          primary,
      onPrimary:        Colors.white,
      primaryContainer: isLight ? AppColors.lPrimaryTint : AppColors.dPrimaryDim,
      onPrimaryContainer: primary,
      secondary:        isLight ? AppColors.lTeal : AppColors.dTeal,
      onSecondary:      Colors.white,
      secondaryContainer: surfaceVar,
      onSecondaryContainer: text,
      surface:          surface,
      onSurface:        text,
      surfaceContainerHighest: surfaceVar,
      error:            const Color(0xFFE05454),
      onError:          Colors.white,
      outline:          border,
      outlineVariant:   border,
      shadow:           Colors.black,
      scrim:            Colors.black,
      inverseSurface:   text,
      onInverseSurface: surface,
      inversePrimary:   primary,
    );

    // Poppins TextTheme
    final baseTextTheme = isLight
        ? GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme)
        : GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);

    final textTheme = baseTextTheme.copyWith(
      displayLarge:   baseTextTheme.displayLarge?.copyWith(color: text, fontWeight: FontWeight.w700),
      displayMedium:  baseTextTheme.displayMedium?.copyWith(color: text, fontWeight: FontWeight.w700),
      displaySmall:   baseTextTheme.displaySmall?.copyWith(color: text, fontWeight: FontWeight.w600),
      headlineLarge:  baseTextTheme.headlineLarge?.copyWith(color: text, fontWeight: FontWeight.w600),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: text, fontWeight: FontWeight.w600),
      headlineSmall:  baseTextTheme.headlineSmall?.copyWith(color: text, fontWeight: FontWeight.w600),
      titleLarge:     baseTextTheme.titleLarge?.copyWith(color: text, fontWeight: FontWeight.w600),
      titleMedium:    baseTextTheme.titleMedium?.copyWith(color: text, fontWeight: FontWeight.w500),
      titleSmall:     baseTextTheme.titleSmall?.copyWith(color: textSub),
      bodyLarge:      baseTextTheme.bodyLarge?.copyWith(color: text),
      bodyMedium:     baseTextTheme.bodyMedium?.copyWith(color: text),
      bodySmall:      baseTextTheme.bodySmall?.copyWith(color: textSub),
      labelLarge:     baseTextTheme.labelLarge?.copyWith(color: text, fontWeight: FontWeight.w600),
      labelMedium:    baseTextTheme.labelMedium?.copyWith(color: textSub),
    );

    return ThemeData(
      useMaterial3:           true,
      brightness:             brightness,
      colorScheme:            colorScheme,
      scaffoldBackgroundColor: bg,
      textTheme:              textTheme,

      appBarTheme: AppBarTheme(
        elevation:       0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: text,
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   surfaceVar,
        hintStyle:   GoogleFonts.poppins(color: textSub, fontSize: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:   BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE05454)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.4),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation:       6,
        shape:           const StadiumBorder(),
        extendedTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600, fontSize: 14,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor:   isLight ? AppColors.lPrimaryTint : AppColors.dPrimaryDim,
        selectedColor:     primary.withValues(alpha: 0.15),
        side:              BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.poppins(
          color: primary, fontWeight: FontWeight.w500, fontSize: 13,
        ),
      ),

      dividerTheme: DividerThemeData(color: border, space: 1, thickness: 1),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor:  Colors.transparent,
        modalBarrierColor: Color(0x66000000),
      ),
    );
  }
}
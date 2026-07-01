// Design tokens: colors, text styles, theme config
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const sand = Color(0xFFFBF3E2);
  static const sandDeep = Color(0xFFF3E6CB);
  static const ink = Color(0xFF22293D);
  static const inkSoft = Color(0xFF5B6178);
  static const coral = Color(0xFFFF6B4A);
  static const coralDark = Color(0xFFC2421F);
  static const coralLight = Color(0xFFFFE0D4);
  static const leaf = Color(0xFF3FA66B);
  static const leafDark = Color(0xFF266B43);
  static const leafLight = Color(0xFFDCF2E4);
  static const amber = Color(0xFFF2A93B);
  static const amberDark = Color(0xFF9A5F0D);
  static const teal = Color(0xFF2C8C8C);
  static const tealDark = Color(0xFF1C5C5C);
  static const purple = Color(0xFF8A63D2);
  static const purpleDark = Color(0xFF52369A);
  static const white = Color(0xFFFFFFFF);
}

// Preset avatar colors the user can pick from
const kAvatarColors = {
  'coral': AppColors.coral,
  'leaf': AppColors.leaf,
  'amber': AppColors.amber,
  'teal': AppColors.teal,
  'purple': AppColors.purple,
};

const kAvatarColorsDark = {
  'coral': AppColors.coralDark,
  'leaf': AppColors.leafDark,
  'amber': AppColors.amberDark,
  'teal': AppColors.tealDark,
  'purple': AppColors.purpleDark,
};

class AppText {
  static TextStyle fredoka(double size, Color color, {FontWeight weight = FontWeight.w600}) {
    return GoogleFonts.fredoka(fontSize: size, color: color, fontWeight: weight);
  }

  static TextStyle dmSans(double size, Color color, {FontWeight weight = FontWeight.w400}) {
    return GoogleFonts.dmSans(fontSize: size, color: color, fontWeight: weight);
  }
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.sand,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.coral,
        primary: AppColors.coral,
        secondary: AppColors.leaf,
        surface: AppColors.sand,
        onSurface: AppColors.ink,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(),
      cardTheme: const CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: AppColors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.sandDeep, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.coral, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected) ? AppColors.coralDark : AppColors.inkSoft,
          );
        }),
      ),
    );
  }
}

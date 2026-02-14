import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../design_system/tokens/design_tokens.dart';

class AppTheme {
  static ThemeData lightMaterial() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: StoicColors.deepBlue,
      onPrimary: Colors.white,
      primaryContainer: StoicColors.sand,
      onPrimaryContainer: StoicColors.obsidian,
      secondary: StoicColors.copper,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE8D4C6),
      onSecondaryContainer: StoicColors.obsidian,
      tertiary: StoicColors.stone,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFE7E1D6),
      onTertiaryContainer: StoicColors.obsidian,
      error: StoicColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: StoicColors.cardBackground,
      onSurface: StoicColors.textPrimary,
      onSurfaceVariant: StoicColors.textMuted,
      outline: StoicColors.border,
      outlineVariant: Color(0xFFE6DFD4),
      shadow: Color(0x26000000),
      scrim: Color(0x52000000),
      inverseSurface: StoicColors.obsidian,
      onInverseSurface: Colors.white,
      inversePrimary: StoicColors.sand,
      surfaceTint: StoicColors.deepBlue,
    );

    final baseText = Typography.material2021().black.apply(
      bodyColor: StoicColors.textPrimary,
      displayColor: StoicColors.textPrimary,
      fontFamily: 'Inter',
    );

    final textTheme = baseText.copyWith(
      displayLarge: baseText.displayLarge?.copyWith(
        fontFamily: 'Cormorant Garamond',
        fontSize: 48,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        height: 1.1,
      ),
      displayMedium: baseText.displayMedium?.copyWith(
        fontFamily: 'Cormorant Garamond',
        fontSize: 28,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      displaySmall: baseText.displaySmall?.copyWith(
        fontFamily: 'Cormorant Garamond',
        fontSize: 18,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        fontFamily: 'Inter',
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      headlineSmall: baseText.headlineSmall?.copyWith(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: baseText.bodyMedium?.copyWith(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: baseText.bodySmall?.copyWith(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      labelLarge: baseText.labelLarge?.copyWith(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
      ),
      labelSmall: baseText.labelSmall?.copyWith(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: StoicColors.screenBackground,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: StoicColors.screenBackground,
        foregroundColor: StoicColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: StoicColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StoicRadius.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StoicColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: StoicColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: StoicColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: StoicColors.deepBlue, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: StoicColors.chipBackground,
        selectedColor: StoicColors.chipBackground,
        side: const BorderSide(color: StoicColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StoicRadius.pill),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StoicRadius.md),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: StoicColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StoicRadius.md),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge?.copyWith(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: StoicColors.bottomBarBackground,
        indicatorColor: Color(0x1A2F4B66),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: const Color(0xFFE8D4C6),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: StoicColors.obsidian,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: StoicColors.stone,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }

  static CupertinoThemeData cupertino() {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: StoicColors.deepBlue,
      scaffoldBackgroundColor: StoicColors.ivory,
      barBackgroundColor: StoicColors.ivory,
      textTheme: CupertinoTextThemeData(
        primaryColor: StoicColors.textPrimary,
      ),
    );
  }
}

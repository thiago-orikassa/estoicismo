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
      titleLarge: baseText.titleLarge?.copyWith(
        fontFamily: 'Cormorant Garamond',
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        fontFamily: 'Cormorant Garamond',
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: baseText.headlineSmall?.copyWith(
        fontFamily: 'Cormorant Garamond',
        fontWeight: FontWeight.w600,
      ),
      labelLarge: baseText.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
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
          side: const BorderSide(color: StoicColors.cardOutline),
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
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: StoicColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
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

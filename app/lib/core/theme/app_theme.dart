import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../design_system/tokens/design_tokens.dart';

class AppTheme {
  static ThemeData lightMaterial() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AethorColors.deepBlue,
      onPrimary: Colors.white,
      primaryContainer: AethorColors.sand,
      onPrimaryContainer: AethorColors.obsidian,
      secondary: AethorColors.copper,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE8D4C6),
      onSecondaryContainer: AethorColors.obsidian,
      tertiary: AethorColors.stone,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFE7E1D6),
      onTertiaryContainer: AethorColors.obsidian,
      error: AethorColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: AethorColors.screenBackground,
      onSurface: AethorColors.textPrimary,
      onSurfaceVariant: AethorColors.textSubtle,
      outline: AethorColors.cardOutline,
      outlineVariant: AethorColors.bottomBarBorder,
      shadow: Color(0x26000000),
      scrim: Color(0x52000000),
      inverseSurface: AethorColors.obsidian,
      onInverseSurface: Colors.white,
      inversePrimary: AethorColors.sand,
      surfaceTint: AethorColors.deepBlue,
    );

    final baseText = Typography.material2021().black.apply(
          bodyColor: AethorColors.textPrimary,
          displayColor: AethorColors.textPrimary,
          fontFamily: 'Inter',
        );

    final textTheme = baseText.copyWith(
      displayLarge: baseText.displayLarge?.copyWith(
        fontFamily: 'Cormorant Garamond',
        fontSize: 56,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        height: 1.1,
      ),
      displayMedium: baseText.displayMedium?.copyWith(
        fontFamily: 'Cormorant Garamond',
        fontSize: 48,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        height: 1.1,
      ),
      displaySmall: baseText.displaySmall?.copyWith(
        fontFamily: 'Cormorant Garamond',
        fontSize: 32,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        height: 1.15,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        fontFamily: 'Inter',
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      headlineSmall: baseText.headlineSmall?.copyWith(
        fontFamily: 'Inter',
        fontSize: 22,
        fontWeight: FontWeight.w600,
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
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      labelSmall: baseText.labelSmall?.copyWith(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.9,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AethorColors.screenBackground,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: AethorColors.screenBackground,
        foregroundColor: AethorColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: AethorColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AethorRadius.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AethorRadius.md),
          borderSide: const BorderSide(color: AethorColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AethorRadius.md),
          borderSide: const BorderSide(color: AethorColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AethorRadius.md),
          borderSide: const BorderSide(color: AethorColors.deepBlue, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AethorColors.chipBackground,
        selectedColor: AethorColors.chipBackground,
        side:
            BorderSide(color: AethorColors.cardOutline.withValues(alpha: 0.45)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AethorRadius.pill),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AethorRadius.md),
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
          side: const BorderSide(color: AethorColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AethorRadius.md),
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
        backgroundColor: AethorColors.bottomBarBackground,
        indicatorColor: Color(0x1A2F4B66),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: const Color(0xFFE7DDD1),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AethorColors.obsidian,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AethorColors.deepBlue,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }

  static CupertinoThemeData cupertino() {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: AethorColors.deepBlue,
      scaffoldBackgroundColor: AethorColors.screenBackground,
      barBackgroundColor: AethorColors.screenBackground,
      textTheme: CupertinoTextThemeData(
        primaryColor: AethorColors.textPrimary,
      ),
    );
  }
}

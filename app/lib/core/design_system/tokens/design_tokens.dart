import 'package:flutter/material.dart';

class StoicColors {
  // Primitive palette
  static const obsidian = Color(0xFF111315);
  static const stone = Color(0xFF2C3136);
  static const sand = Color(0xFFD9D0C3);
  static const ivory = Color(0xFFF6F2EA);
  static const parchment = Color(0xFFE8E1D5);
  static const mist = Color(0xFFF3F4F6);
  static const copper = Color(0xFFB87444);
  static const deepBlue = Color(0xFF2F4B66);

  // Semantic colors
  static const appChrome = obsidian;
  static const screenBackground = parchment;
  static const cardBackground = ivory;
  static const bottomBarBackground = stone;
  static const chipBackground = Color(0x1A2F4B66);
  static const chipText = deepBlue;
  static const divider = Color(0x80D9D0C3);
  static const rowDivider = Color(0x4DD9D0C3);
  static const mutedButtonBackground = Color(0x66D9D0C3);
  static const cardOutline = Color(0xB8D9D0C3);
  static const avatarBackground = mist;
  static const onDark = ivory;

  // Backward-compatible aliases
  static const surface = cardBackground;
  static const border = sand;
  static const textPrimary = obsidian;
  static const textSecondary = stone;
  static const textMuted = Color(0x992C3136);
  static const textSubtle = Color(0x662C3136);
  static const textSecondarySoft = Color(0xCC2C3136);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFB26A00);
  static const error = Color(0xFFB3261E);
  static const info = deepBlue;
}

class StoicSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class StoicRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const pill = 999.0;
}

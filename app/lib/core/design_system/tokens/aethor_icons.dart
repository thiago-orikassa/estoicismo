import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Semantic icon mapping for the Aethor design system.
///
/// Primary library: Phosphor Icons (Light weight, 1.5px stroke).
/// Accent states: Duotone or Fill for active/selected contexts.
///
/// Architecture:
///   Cross-platform: Phosphor Icons (this file)
///   iOS supplement:  SF Symbols (semantic equivalents via platform adapters)
///   Android supplement: Material Symbols Sharp (via platform adapters)
class AethorIcons {
  AethorIcons._();

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------
  static const home = PhosphorIconsLight.house;
  static const homeFill = PhosphorIconsDuotone.house;
  static const history = PhosphorIconsLight.clockCounterClockwise;
  static const historyFill = PhosphorIconsDuotone.clockCounterClockwise;
  static const favorites = PhosphorIconsLight.star;
  static const favoritesFill = PhosphorIconsDuotone.star;
  static const settings = PhosphorIconsLight.gear;
  static const settingsFill = PhosphorIconsDuotone.gear;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------
  static const close = PhosphorIconsLight.x;
  static const back = PhosphorIconsLight.arrowLeft;
  static const chevronLeft = PhosphorIconsLight.caretLeft;
  static const chevronRight = PhosphorIconsLight.caretRight;
  static const refresh = PhosphorIconsLight.arrowsClockwise;
  static const edit = PhosphorIconsLight.pencilSimple;

  // ---------------------------------------------------------------------------
  // Status & Feedback
  // ---------------------------------------------------------------------------
  static const check = PhosphorIconsLight.check;
  static const checkBold = PhosphorIconsBold.check;
  static const checkCircle = PhosphorIconsLight.checkCircle;
  static const checkCircleFill = PhosphorIconsFill.checkCircle;
  static const error = PhosphorIconsLight.warningCircle;
  static const warning = PhosphorIconsLight.warning;
  static const info = PhosphorIconsLight.info;
  static const wifiOff = PhosphorIconsLight.wifiSlash;

  // ---------------------------------------------------------------------------
  // Content
  // ---------------------------------------------------------------------------
  static const heart = PhosphorIconsLight.heart;
  static const heartFill = PhosphorIconsFill.heart;
  static const heartOutline = PhosphorIconsLight.heart;
  static const book = PhosphorIconsLight.bookOpen;
  static const mail = PhosphorIconsLight.envelope;
  static const lock = PhosphorIconsLight.lock;

  // ---------------------------------------------------------------------------
  // Settings-specific
  // ---------------------------------------------------------------------------
  static const globe = PhosphorIconsLight.globe;
  static const user = PhosphorIconsLight.user;
  static const calendar = PhosphorIconsLight.calendarBlank;
  static const verified = PhosphorIconsLight.sealCheck;
  static const bell = PhosphorIconsLight.bell;
  static const bellFill = PhosphorIconsFill.bell;
}

/// Icon size tokens aligned with the Aethor typographic scale.
///
/// Rule: icon height matches the line-height of adjacent text.
///   bodyM (14/20) → iconSm (20)
///   bodyL (16/24) → iconMd (24)
///   titleS (18/24) → iconLg (28)
class AethorIconSize {
  AethorIconSize._();

  static const double xs = 16;
  static const double sm = 20;
  static const double md = 24;
  static const double lg = 28;
  static const double xl = 32;
}

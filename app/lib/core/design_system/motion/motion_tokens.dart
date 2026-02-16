import 'package:flutter/material.dart';

class MotionTokens {
  static const micro = Duration(milliseconds: 120);
  static const standard = Duration(milliseconds: 200);
  static const entry = Duration(milliseconds: 260);
  static const heroEntry = Duration(milliseconds: 340);

  static const curveEntry = Curves.easeOut;
  static const curveTransition = Curves.easeInOut;
  static const curveHeroEntry = Cubic(0.25, 1.0, 0.5, 1.0); // easeOutCubic
  static const curveContemplative = Cubic(0.25, 0.1, 0.25, 1.0); // bezier contemplativo

  static const moveXs = 4.0;
  static const moveSm = 8.0;
  static const moveMd = 12.0;
  static const moveLg = 16.0;

  static const pressScale = 0.98;
  static const emphasisScale = 0.96;

  static bool reduceMotionOf(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    if (media == null) return false;
    return media.accessibleNavigation;
  }

  static Duration durationOrZero(BuildContext context, Duration duration) {
    return reduceMotionOf(context) ? Duration.zero : duration;
  }
}

import 'package:flutter/material.dart';

import 'motion_tokens.dart';

class StoicPressScale extends StatefulWidget {
  const StoicPressScale({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<StoicPressScale> createState() => _StoicPressScaleState();
}

class _StoicPressScaleState extends State<StoicPressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MotionTokens.reduceMotionOf(context);
    final scale = (!widget.enabled || reduceMotion)
        ? 1.0
        : (_pressed ? MotionTokens.pressScale : 1.0);

    return Listener(
      onPointerDown: widget.enabled ? (_) => _setPressed(true) : null,
      onPointerUp: widget.enabled ? (_) => _setPressed(false) : null,
      onPointerCancel: widget.enabled ? (_) => _setPressed(false) : null,
      child: AnimatedScale(
        scale: scale,
        duration: MotionTokens.durationOrZero(context, MotionTokens.micro),
        curve: MotionTokens.curveTransition,
        child: widget.child,
      ),
    );
  }
}

class StoicFadeIn extends StatelessWidget {
  const StoicFadeIn({
    super.key,
    required this.child,
    this.duration,
    this.curve,
  });

  final Widget child;
  final Duration? duration;
  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MotionTokens.reduceMotionOf(context);
    final resolvedDuration =
        reduceMotion ? Duration.zero : (duration ?? MotionTokens.standard);
    final resolvedCurve = curve ?? MotionTokens.curveEntry;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: reduceMotion ? 1.0 : 0.0, end: 1.0),
      duration: resolvedDuration,
      curve: resolvedCurve,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
    );
  }
}

class StoicFadeSlideIn extends StatelessWidget {
  const StoicFadeSlideIn({
    super.key,
    required this.child,
    this.offsetY = MotionTokens.moveSm,
    this.duration,
    this.curve,
  });

  final Widget child;
  final double offsetY;
  final Duration? duration;
  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MotionTokens.reduceMotionOf(context);
    final resolvedDuration =
        reduceMotion ? Duration.zero : (duration ?? MotionTokens.entry);
    final resolvedCurve = curve ?? MotionTokens.curveEntry;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: reduceMotion ? 1.0 : 0.0, end: 1.0),
      duration: resolvedDuration,
      curve: resolvedCurve,
      child: child,
      builder: (context, value, child) {
        final translate = reduceMotion ? 0.0 : offsetY * (1 - value);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, translate),
            child: child,
          ),
        );
      },
    );
  }
}

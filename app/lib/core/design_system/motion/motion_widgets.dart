import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'motion_tokens.dart';

class AethorPressScale extends StatefulWidget {
  const AethorPressScale({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<AethorPressScale> createState() => _AethorPressScaleState();
}

class _AethorPressScaleState extends State<AethorPressScale> {
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

class AethorFadeIn extends StatelessWidget {
  const AethorFadeIn({
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

class AethorFadeSlideIn extends StatelessWidget {
  const AethorFadeSlideIn({
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

// ---------------------------------------------------------------------------
// Delayed fade in — fade puro com delay para coreografia sequencial
// Spec: Usado para headers/texto leve que não precisam de translação
// Padrão: TweenAnimationBuilder (mesmo de AethorStaggeredEntry)
// ---------------------------------------------------------------------------

class AethorDelayedFadeIn extends StatelessWidget {
  const AethorDelayedFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration,
    this.curve,
  });

  final Widget child;
  final Duration delay;
  final Duration? duration;
  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MotionTokens.reduceMotionOf(context);
    if (reduceMotion) return child;

    final resolvedDuration = duration ?? MotionTokens.entry;
    final resolvedCurve = curve ?? MotionTokens.curveEntry;
    final totalDuration = delay + resolvedDuration;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: totalDuration,
      curve: Curves.linear,
      child: child,
      builder: (context, raw, child) {
        final delayFraction = totalDuration.inMicroseconds == 0
            ? 1.0
            : delay.inMicroseconds / totalDuration.inMicroseconds;
        final double t;
        if (raw <= delayFraction) {
          t = 0.0;
        } else {
          t = resolvedCurve.transform(
            ((raw - delayFraction) / (1.0 - delayFraction)).clamp(0.0, 1.0),
          );
        }
        return Opacity(
          opacity: t,
          child: child,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Hero slide in — fade + slide com delay para entrada hero de cards
// Spec: Desaceleração easeOutCubic, deslocamento configurável
// Padrão: TweenAnimationBuilder (mesmo de AethorStaggeredEntry)
// ---------------------------------------------------------------------------

class AethorHeroSlideIn extends StatelessWidget {
  const AethorHeroSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration,
    this.curve,
    this.offsetY = MotionTokens.moveMd,
  });

  final Widget child;
  final Duration delay;
  final Duration? duration;
  final Curve? curve;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MotionTokens.reduceMotionOf(context);
    if (reduceMotion) return child;

    final resolvedDuration = duration ?? MotionTokens.heroEntry;
    final resolvedCurve = curve ?? MotionTokens.curveHeroEntry;
    final totalDuration = delay + resolvedDuration;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: totalDuration,
      curve: Curves.linear,
      child: child,
      builder: (context, raw, child) {
        final delayFraction = totalDuration.inMicroseconds == 0
            ? 1.0
            : delay.inMicroseconds / totalDuration.inMicroseconds;
        final double t;
        if (raw <= delayFraction) {
          t = 0.0;
        } else {
          t = resolvedCurve.transform(
            ((raw - delayFraction) / (1.0 - delayFraction)).clamp(0.0, 1.0),
          );
        }
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, offsetY * (1.0 - t)),
            child: child,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Favorite toggle — micro escala + opacidade, sem overshoot
// Spec: scale 0.96 quando inativo, opacidade 0.85 → 1.0
// ---------------------------------------------------------------------------

class AethorFavoriteToggle extends StatelessWidget {
  const AethorFavoriteToggle({
    super.key,
    required this.isFavorited,
    required this.child,
  });

  final bool isFavorited;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MotionTokens.reduceMotionOf(context);
    final duration =
        reduceMotion ? Duration.zero : MotionTokens.micro;

    return AnimatedScale(
      scale: (reduceMotion || isFavorited)
          ? 1.0
          : MotionTokens.emphasisScale,
      duration: duration,
      curve: MotionTokens.curveTransition,
      child: AnimatedOpacity(
        opacity: (reduceMotion || isFavorited) ? 1.0 : 0.85,
        duration: duration,
        curve: MotionTokens.curveTransition,
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fade Through switcher — NavigationBar destination switching
// Spec: PageTransitionSwitcher + FadeThroughTransition, entry duration
// ---------------------------------------------------------------------------

class AethorFadeThroughSwitcher extends StatelessWidget {
  const AethorFadeThroughSwitcher({
    super.key,
    required this.child,
    this.duration,
    this.fillColor = Colors.transparent,
  });

  final Widget child;
  final Duration? duration;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MotionTokens.reduceMotionOf(context);
    final resolvedDuration =
        reduceMotion ? Duration.zero : (duration ?? MotionTokens.entry);

    return PageTransitionSwitcher(
      duration: resolvedDuration,
      transitionBuilder: (child, primary, secondary) {
        return FadeThroughTransition(
          animation: primary,
          secondaryAnimation: secondary,
          fillColor: fillColor,
          child: child,
        );
      },
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Staggered entry — entrada em cascata com delay entre itens
// Spec: TagGroup/Cards com delay 60-80ms, move.xs/sm + fade
// ---------------------------------------------------------------------------

class AethorStaggeredEntry extends StatelessWidget {
  const AethorStaggeredEntry({
    super.key,
    required this.index,
    required this.child,
    this.staggerDelay = const Duration(milliseconds: 60),
    this.offsetY = MotionTokens.moveXs,
    this.duration,
    this.curve,
  });

  final int index;
  final Widget child;
  final Duration staggerDelay;
  final double offsetY;
  final Duration? duration;
  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MotionTokens.reduceMotionOf(context);
    if (reduceMotion) return child;

    final resolvedDuration = duration ?? MotionTokens.entry;
    final resolvedCurve = curve ?? MotionTokens.curveEntry;
    final delay = staggerDelay * index;
    final totalDuration = delay + resolvedDuration;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: totalDuration,
      curve: Curves.linear,
      child: child,
      builder: (context, raw, child) {
        final delayFraction =
            totalDuration.inMicroseconds == 0
                ? 1.0
                : delay.inMicroseconds / totalDuration.inMicroseconds;
        final double t;
        if (raw <= delayFraction) {
          t = 0.0;
        } else {
          t = resolvedCurve.transform(
            ((raw - delayFraction) / (1.0 - delayFraction)).clamp(0.0, 1.0),
          );
        }
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, offsetY * (1.0 - t)),
            child: child,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// FeedbackBar — entrada fade + move.sm da base, saída fade simples
// Spec: entrada 200ms, saída 160ms
// ---------------------------------------------------------------------------

class AethorFeedbackBar extends StatelessWidget {
  const AethorFeedbackBar({
    super.key,
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  static const _entryDuration = MotionTokens.standard; // 200ms
  static const _exitDuration = Duration(milliseconds: 160);

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MotionTokens.reduceMotionOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : (visible ? _entryDuration : _exitDuration);

    return AnimatedSlide(
      offset: (reduceMotion || visible) ? Offset.zero : const Offset(0, 0.5),
      duration: duration,
      curve: MotionTokens.curveEntry,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: duration,
        curve: MotionTokens.curveEntry,
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Button state — idle → loading → success com transições animadas
// Spec: texto fade out → spinner fade in (largura constante),
//       spinner fade out → "Feito" fade + move.xs
// ---------------------------------------------------------------------------

enum AethorButtonPhase { idle, loading, success }

class AethorButtonStateTransition extends StatelessWidget {
  const AethorButtonStateTransition({
    super.key,
    required this.phase,
    required this.idleChild,
    this.loadingChild,
    this.successChild,
    this.width,
  });

  final AethorButtonPhase phase;
  final Widget idleChild;
  final Widget? loadingChild;
  final Widget? successChild;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MotionTokens.reduceMotionOf(context);
    final duration =
        reduceMotion ? Duration.zero : MotionTokens.standard;

    final Widget content;
    switch (phase) {
      case AethorButtonPhase.idle:
        content = KeyedSubtree(
          key: const ValueKey(AethorButtonPhase.idle),
          child: idleChild,
        );
      case AethorButtonPhase.loading:
        content = KeyedSubtree(
          key: const ValueKey(AethorButtonPhase.loading),
          child: loadingChild ??
              const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
        );
      case AethorButtonPhase.success:
        content = KeyedSubtree(
          key: const ValueKey(AethorButtonPhase.success),
          child: successChild ??
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: reduceMotion ? 1.0 : 0.0,
                  end: 1.0,
                ),
                duration: duration,
                curve: MotionTokens.curveEntry,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        reduceMotion
                            ? 0
                            : MotionTokens.moveXs * (1 - value),
                      ),
                      child: child,
                    ),
                  );
                },
                child: const Text('Feito'),
              ),
        );
    }

    return SizedBox(
      width: width,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: MotionTokens.curveEntry,
        switchOutCurve: MotionTokens.curveEntry,
        child: content,
      ),
    );
  }
}

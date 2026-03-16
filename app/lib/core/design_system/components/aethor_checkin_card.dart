import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../motion/motion.dart';
import '../tokens/design_tokens.dart';
import 'aethor_buttons.dart';
import 'aethor_card.dart';

enum AethorCheckinStatus {
  pending,
  applied,
  notApplied,
}

// ---------------------------------------------------------------------------
// Card principal
// ---------------------------------------------------------------------------

class AethorCheckinCard extends StatefulWidget {
  const AethorCheckinCard({
    super.key,
    required this.reflectionPrompt,
    required this.noteController,
    required this.status,
    required this.isSubmitting,
    required this.onApplied,
    required this.onNotApplied,
    this.savedNote,
  });

  final String reflectionPrompt;
  final TextEditingController noteController;
  final AethorCheckinStatus status;
  final bool isSubmitting;
  final VoidCallback onApplied;
  final VoidCallback onNotApplied;
  final String? savedNote;

  @override
  State<AethorCheckinCard> createState() => _AethorCheckinCardState();
}

class _AethorCheckinCardState extends State<AethorCheckinCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _hapticFired = false;

  // Curva easeOutBack — leve overshoot, como um carimbo pousando
  static const _easeOutBack = Cubic(0.34, 1.56, 0.64, 1.0);

  // ---------------------------------------------------------------------------
  // Animações derivadas de _ctrl por Interval
  // ---------------------------------------------------------------------------
  late final Animation<double> _containerFade;
  late final Animation<double> _containerSlide;
  late final Animation<double> _checkDraw;
  late final Animation<double> _checkScale;
  late final Animation<double> _ripple;
  late final Animation<double> _titleFade;
  late final Animation<double> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _setupAnimations();

    // Se já chegou no estado completado (ex: reinício do app), pula para o fim.
    if (widget.status != AethorCheckinStatus.pending) {
      _ctrl.value = 1.0;
      _hapticFired = true;
    }
  }

  void _setupAnimations() {
    _containerFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
    );
    _containerSlide = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.38, curve: Cubic(0.25, 1.0, 0.5, 1.0)),
    );
    // Checkmark se desenha progresivamente (0 → 1)
    _checkDraw = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.44, curve: Cubic(0.25, 1.0, 0.5, 1.0)),
    );
    // Círculo escala com overshoot — o "carimbo"
    _checkScale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.50, curve: _easeOutBack),
    );
    // Anel expande e desfade — pedra na água
    _ripple = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.30, 0.75, curve: Curves.easeOut),
    );
    _titleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.38, 0.65, curve: Curves.easeOut),
    );
    _titleSlide = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.38, 0.65, curve: Cubic(0.25, 1.0, 0.5, 1.0)),
    );
    _subtitleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.52, 0.78, curve: Curves.easeOut),
    );
    _footerFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.65, 0.90, curve: Curves.easeOut),
    );

    // Dispara heavyImpact quando o checkmark termina de se desenhar (~44%).
    _ctrl.addListener(() {
      if (!_hapticFired && _ctrl.value >= 0.44) {
        _hapticFired = true;
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  void didUpdateWidget(AethorCheckinCard old) {
    super.didUpdateWidget(old);
    // Transição pending → applied/notApplied: dispara a animação de celebração.
    if (old.status == AethorCheckinStatus.pending &&
        widget.status != AethorCheckinStatus.pending) {
      _hapticFired = false;
      if (MotionTokens.reduceMotionOf(context)) {
        _ctrl.value = 1.0;
        _hapticFired = true;
      } else {
        _ctrl.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedNote = widget.savedNote?.trim() ?? '';
    return AethorCard(
      variant: AethorCardVariant.defaultCard,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).checkinTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
          ),
          const SizedBox(height: 20),
          if (widget.status == AethorCheckinStatus.pending) ...[
            // ----------------------------------------------------------------
            // Estado pendente — dois botões lado a lado
            // ----------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: AethorPressScale(
                    enabled: !widget.isSubmitting,
                    child: AethorPrimaryButton(
                      onPressed: widget.isSubmitting
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              widget.onApplied();
                            },
                      size: AethorButtonSize.medium,
                      fullWidth: true,
                      child: AnimatedSwitcher(
                        duration: MotionTokens.standard,
                        switchInCurve: MotionTokens.curveEntry,
                        switchOutCurve: MotionTokens.curveTransition,
                        child: widget.isSubmitting
                            ? Row(
                                key: const ValueKey('loading'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AethorColors.ivory,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(AppLocalizations.of(context).checkinSaving),
                                ],
                              )
                            : Text(
                                AppLocalizations.of(context).checkinAppliedBtn,
                                key: const ValueKey('label'),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AethorPressScale(
                    enabled: !widget.isSubmitting,
                    child: AethorSecondaryButton(
                      onPressed: widget.isSubmitting
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              widget.onNotApplied();
                            },
                      size: AethorButtonSize.medium,
                      fullWidth: true,
                      child: Text(AppLocalizations.of(context).checkinNotAppliedBtn),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // ----------------------------------------------------------------
            // Estado completado — coreografia "O Selo"
            // ----------------------------------------------------------------
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) => _buildCompletedState(context, resolvedNote),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context, String resolvedNote) {
    final isApplied = widget.status == AethorCheckinStatus.applied;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Bloco principal: ícone + textos
        Opacity(
          opacity: _containerFade.value,
          child: Transform.translate(
            offset: Offset(0, 12.0 * (1.0 - _containerSlide.value)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: AethorColors.deepBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AethorRadius.md),
                border: Border.all(
                  color: AethorColors.deepBlue.withValues(alpha: 0.18),
                ),
              ),
              child: Column(
                children: [
                  // Ícone animado: ripple + círculo + checkmark desenhado
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ripple — anel que expande e desfade
                        CustomPaint(
                          size: const Size(56, 56),
                          painter: _RipplePainter(
                            progress: _ripple.value,
                            color: AethorColors.deepBlue,
                          ),
                        ),
                        // Círculo de fundo com overshoot
                        Transform.scale(
                          scale: _checkScale.value.clamp(0.0, 1.08),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AethorColors.deepBlue.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Checkmark que se desenha progressivamente
                        Transform.scale(
                          scale: _checkScale.value.clamp(0.0, 1.08),
                          child: CustomPaint(
                            size: const Size(22, 22),
                            painter: _CheckmarkPainter(
                              progress: _checkDraw.value,
                              color: AethorColors.deepBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Título desliza para cima
                  Opacity(
                    opacity: _titleFade.value,
                    child: Transform.translate(
                      offset: Offset(0, 8.0 * (1.0 - _titleSlide.value)),
                      child: Text(
                        l10n.checkinRegisteredTitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              color: AethorColors.deepBlue,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Subtítulo
                  Opacity(
                    opacity: _subtitleFade.value,
                    child: Text(
                      isApplied
                          ? l10n.checkinAppliedMessage
                          : l10n.checkinNotAppliedMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: AethorColors.textSecondarySoft,
                            height: 1.5,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Nota de reflexão (se houver), sem animação extra
        if (resolvedNote.isNotEmpty) ...[
          const SizedBox(height: 12),
          Opacity(
            opacity: _footerFade.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AethorRadius.md),
                border: Border.all(
                  color: AethorColors.sand.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.checkinReflectionLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          letterSpacing: 0.8,
                          color: AethorColors.textSubtle,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    resolvedNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.5,
                          color: AethorColors.obsidian,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
        // Footer
        const SizedBox(height: 12),
        Opacity(
          opacity: _footerFade.value,
          child: Center(
            child: Text(
              l10n.checkinFooterMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: AethorColors.textMuted,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CustomPainter — desenha o checkmark progressivamente
// ---------------------------------------------------------------------------

class _CheckmarkPainter extends CustomPainter {
  const _CheckmarkPainter({required this.progress, required this.color});

  final double progress; // 0.0 → 1.0
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Checkmark: (15%, 50%) → (40%, 76%) → (85%, 24%)
    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.50)
      ..lineTo(size.width * 0.40, size.height * 0.76)
      ..lineTo(size.width * 0.85, size.height * 0.24);

    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(drawn, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter old) => old.progress != progress;
}

// ---------------------------------------------------------------------------
// CustomPainter — anel expansivo (pedra na água)
// ---------------------------------------------------------------------------

class _RipplePainter extends CustomPainter {
  const _RipplePainter({required this.progress, required this.color});

  final double progress; // 0.0 → 1.0
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final center = Offset(size.width / 2, size.height / 2);
    const minRadius = 18.0;
    const maxRadius = 34.0;
    final radius = minRadius + (maxRadius - minRadius) * progress;
    final opacity = (1.0 - progress) * 0.30;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter old) => old.progress != progress;
}

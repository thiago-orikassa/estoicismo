import 'package:flutter/material.dart';

import '../../domain/context_labels.dart';
import '../motion/motion.dart';
import '../tokens/aethor_icons.dart';
import '../tokens/design_tokens.dart';
import 'aethor_card.dart';

class SourceMeta extends StatelessWidget {
  const SourceMeta({
    super.key,
    required this.sourceWork,
    required this.sourceRef,
  });

  final String sourceWork;
  final String sourceRef;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${sourceWork.toUpperCase()} / ${sourceRef.toUpperCase()}',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AethorColors.textSubtle,
            fontSize: 11,
            letterSpacing: 0.7,
            fontWeight: FontWeight.w400,
          ),
    );
  }
}

class TagGroup extends StatelessWidget {
  const TagGroup({
    super.key,
    required this.tags,
  });

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AethorSpacing.xs,
      runSpacing: AethorSpacing.xs,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AethorColors.deepBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AethorRadius.pill),
              ),
              child: Text(
                contextLabel(tag).toLowerCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AethorColors.deepBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// QuoteCard — Camada 2 da hierarquia contemplativa
//
// Orquestra a revelação progressiva dos elementos internos:
//   0ms        → Label "Citação do Dia" (fade 400ms)
//   250ms      → Typewriter inicia (30ms por caractere, fade individual)
//   tw+300ms   → Avatar + Autor (fade+slide 500ms)
//   tw+600ms   → Intenção (fade+slide 500ms)
//   tw+900ms   → Tags (stagger 50ms, fade+scale 300ms cada)
//
// Usa um único AnimationController com duração calculada dinamicamente
// baseada no comprimento do texto e número de tags.
// ---------------------------------------------------------------------------

class QuoteCard extends StatefulWidget {
  const QuoteCard({
    super.key,
    required this.quoteText,
    required this.author,
    required this.sourceWork,
    required this.sourceRef,
    required this.behaviorIntent,
    required this.contextTags,
    required this.favorite,
    required this.favoriteLoading,
    required this.onToggleFavorite,
    this.animate = false,
    this.completed = false,
    this.onAnimationsComplete,
  });

  final String quoteText;
  final String author;
  final String sourceWork;
  final String sourceRef;
  final String behaviorIntent;
  final List<String> contextTags;
  final bool favorite;
  final bool favoriteLoading;
  final VoidCallback onToggleFavorite;

  /// Quando true, inicia a coreografia interna (typewriter + reveals).
  final bool animate;

  /// Quando true, pula toda animação e mostra conteúdo estático.
  /// O parent seta após o QuoteCard completar, evitando replay no scroll.
  final bool completed;

  /// Chamado quando TODAS as animações internas completam.
  /// O parent usa para agendar os cards seguintes (PracticeCard etc.).
  final VoidCallback? onAnimationsComplete;

  /// Calcula a duração total das animações internas para agendamento externo.
  static Duration computeTotalDuration(int textLength, int tagCount) {
    final typewriterEndMs = _typewriterStartMs + (textLength * _msPerChar);
    final tagsEndMs = typewriterEndMs + 900 + (tagCount * 50) + 300;
    return Duration(milliseconds: tagsEndMs.clamp(1500, 20000));
  }

  static const _typewriterStartMs = 250;
  static const _msPerChar = 30;

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _started = false;
  bool _completed = false;

  // Timeline milestones (ms)
  late int _typewriterEndMs;
  late int _authorStartMs;
  late int _intentStartMs;
  late int _tagsStartMs;
  late int _totalMs;

  // Curva contemplativa: cubic-bezier(0.25, 0.1, 0.25, 1)
  static const _curve = MotionTokens.curveContemplative;

  @override
  void initState() {
    super.initState();
    _computeTimings();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalMs),
    )..addStatusListener(_onStatus);
    if (widget.animate && !widget.completed) _start();
  }

  void _computeTimings() {
    final len = widget.quoteText.length;
    final tags = widget.contextTags.length;
    _typewriterEndMs =
        QuoteCard._typewriterStartMs + (len * QuoteCard._msPerChar);
    _authorStartMs = _typewriterEndMs + 300;
    _intentStartMs = _typewriterEndMs + 600;
    _tagsStartMs = _typewriterEndMs + 900;
    final tagsEndMs = _tagsStartMs + (tags * 50) + 300;
    _totalMs = tagsEndMs.clamp(1500, 20000);
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_completed) {
      _completed = true;
      widget.onAnimationsComplete?.call();
    }
  }

  void _start() {
    if (_started) return;
    _started = true;
    _controller.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(QuoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset interno quando saindo de completed (replay após lifecycle/nav)
    if (oldWidget.completed && !widget.completed) {
      _started = false;
      _completed = false;
      _controller.reset();
    }
    if (widget.animate && !oldWidget.animate && !widget.completed) {
      _start();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers de timing — mapeia o progresso do controller para cada fase
  // ---------------------------------------------------------------------------

  double _progress(int startMs, int durationMs) {
    if (_totalMs == 0) return 1.0;
    final currentMs = _controller.value * _totalMs;
    if (currentMs < startMs) return 0.0;
    if (currentMs >= startMs + durationMs) return 1.0;
    return ((currentMs - startMs) / durationMs).clamp(0.0, 1.0);
  }

  double _eased(int startMs, int durationMs) =>
      _curve.transform(_progress(startMs, durationMs));

  int get _visibleCharCount {
    if (_totalMs == 0) return widget.quoteText.length;
    final currentMs = _controller.value * _totalMs;
    if (currentMs < QuoteCard._typewriterStartMs) return 0;
    return ((currentMs - QuoteCard._typewriterStartMs) / QuoteCard._msPerChar)
        .floor()
        .clamp(0, widget.quoteText.length);
  }

  String _authorInitials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1 || parts.last.isEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MotionTokens.reduceMotionOf(context);

    if (!widget.animate || widget.completed || reduceMotion) {
      return _buildCard(context, isStatic: true);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => _buildCard(context, isStatic: false),
    );
  }

  Widget _buildCard(BuildContext context, {required bool isStatic}) {
    final double labelOpacity;
    final int visibleChars;
    final double authorT;
    final double intentT;

    if (isStatic) {
      labelOpacity = 1.0;
      visibleChars = widget.quoteText.length;
      authorT = 1.0;
      intentT = 1.0;
    } else {
      labelOpacity = _eased(0, 400);
      visibleChars = _visibleCharCount;
      authorT = _eased(_authorStartMs, 500);
      intentT = _eased(_intentStartMs, 500);
    }

    final quoteStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontFamily: 'Cormorant Garamond',
          fontSize: 28,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w400,
          height: 1.4,
        );

    final text = widget.quoteText;
    final allVisible = visibleChars >= text.length;

    return AethorCard(
      variant: AethorCardVariant.defaultCard,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Label "CITAÇÃO DO DIA" + Favorite ---
          Opacity(
            opacity: labelOpacity,
            child: Row(
              children: [
                Container(width: 2, height: 16.5, color: AethorColors.copper),
                const SizedBox(width: 12),
                Text(
                  'CITAÇÃO DO DIA',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        letterSpacing: 0.55,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const Spacer(),
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    onPressed:
                        widget.favoriteLoading ? null : widget.onToggleFavorite,
                    tooltip: widget.favorite
                        ? 'Remover dos favoritos'
                        : 'Salvar nos favoritos',
                    iconSize: 24,
                    icon: AnimatedScale(
                      scale:
                          widget.favorite ? 1.0 : MotionTokens.emphasisScale,
                      duration: MotionTokens.micro,
                      curve: MotionTokens.curveTransition,
                      child: AnimatedOpacity(
                        opacity: widget.favorite ? 1.0 : 0.85,
                        duration: MotionTokens.micro,
                        curve: MotionTokens.curveTransition,
                        child: Icon(
                          widget.favorite
                              ? AethorIcons.heartFill
                              : AethorIcons.heartOutline,
                          color: widget.favorite
                              ? AethorColors.copper
                              : AethorColors.stone,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- Typewriter: texto revelado caractere por caractere ---
          // Layout estável: texto oculto renderizado em transparente reserva espaço
          Text.rich(
            TextSpan(
              style: quoteStyle,
              children: [
                // Aspas de abertura + caracteres visíveis
                if (visibleChars > 0)
                  TextSpan(text: '"${text.substring(0, visibleChars)}'),
                // Quando nenhum caractere visível, aspas transparentes reservam layout
                if (visibleChars == 0)
                  TextSpan(
                    text: '"',
                    style: quoteStyle?.copyWith(color: Colors.transparent),
                  ),
                // Caracteres ocultos + aspas de fechamento (transparentes)
                if (!allVisible)
                  TextSpan(
                    text: '${text.substring(visibleChars)}"',
                    style: quoteStyle?.copyWith(color: Colors.transparent),
                  ),
                // Aspas de fechamento visíveis quando tudo revelado
                if (allVisible) const TextSpan(text: '"'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- Avatar + Autor: fade+slide após typewriter ---
          Opacity(
            opacity: authorT,
            child: Transform.translate(
              offset: Offset(0, 10.0 * (1.0 - authorT)),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AethorColors.avatarBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: AethorColors.border),
                    ),
                    child: Text(
                      _authorInitials(widget.author),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AethorColors.stone,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.author,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        SourceMeta(
                          sourceWork: widget.sourceWork,
                          sourceRef: widget.sourceRef,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),

          // --- Divider: aparece com a intenção ---
          Opacity(
            opacity: intentT,
            child: const Divider(height: 1, color: AethorColors.divider),
          ),
          const SizedBox(height: 9),

          // --- Intenção: fade+slide após autor ---
          Opacity(
            opacity: intentT,
            child: Transform.translate(
              offset: Offset(0, 10.0 * (1.0 - intentT)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INTENÇÃO:',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.55,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.behaviorIntent,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          height: 1.6,
                          color: AethorColors.stone,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // --- Tags: stagger 50ms, fade+scale 0.9→1.0 ---
          _buildTags(context, isStatic: isStatic),
        ],
      ),
    );
  }

  Widget _buildTags(BuildContext context, {required bool isStatic}) {
    final tags = widget.contextTags;
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AethorSpacing.xs,
      runSpacing: AethorSpacing.xs,
      children: List.generate(tags.length, (i) {
        final double t;
        final double scale;
        if (isStatic) {
          t = 1.0;
          scale = 1.0;
        } else {
          final tagStartMs = _tagsStartMs + (i * 50);
          t = _eased(tagStartMs, 300);
          scale = 0.9 + (0.1 * t);
        }

        return Opacity(
          opacity: t,
          child: Transform.scale(
            scale: scale,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AethorColors.deepBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AethorRadius.pill),
              ),
              child: Text(
                contextLabel(tags[i]).toLowerCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AethorColors.deepBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

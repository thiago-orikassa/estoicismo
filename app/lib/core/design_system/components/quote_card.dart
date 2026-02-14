import 'package:flutter/material.dart';

import '../../domain/context_labels.dart';
import '../motion/motion.dart';
import '../tokens/design_tokens.dart';
import 'stoic_card.dart';

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
            color: StoicColors.textSubtle,
            fontSize: 11,
            letterSpacing: 0.55,
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
      spacing: StoicSpacing.xs,
      runSpacing: StoicSpacing.xs,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              constraints: const BoxConstraints(minHeight: 30),
              decoration: BoxDecoration(
                color: StoicColors.chipBackground,
                borderRadius: BorderRadius.circular(StoicRadius.pill),
              ),
              child: Text(
                contextLabel(tag).toLowerCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: StoicColors.chipText,
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

class QuoteCard extends StatelessWidget {
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

  String _authorInitials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1 || parts.last.isEmpty) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return StoicCard(
      variant: StoicCardVariant.defaultCard,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 2, height: 16.5, color: StoicColors.copper),
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
                  onPressed: favoriteLoading ? null : onToggleFavorite,
                  tooltip: favorite ? 'Remover dos favoritos' : 'Salvar nos favoritos',
                  iconSize: 24,
                  icon: AnimatedScale(
                    scale: favorite ? 1.0 : MotionTokens.emphasisScale,
                    duration: MotionTokens.micro,
                    curve: MotionTokens.curveTransition,
                    child: AnimatedOpacity(
                      opacity: favorite ? 1.0 : 0.85,
                      duration: MotionTokens.micro,
                      curve: MotionTokens.curveTransition,
                      child: Icon(
                        favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: favorite ? StoicColors.copper : StoicColors.stone,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '"$quoteText"',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 28,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: StoicColors.avatarBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: StoicColors.border),
                ),
                child: Text(
                  _authorInitials(author),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: StoicColors.stone,
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
                      author,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                          ),
                    ),
                    const SizedBox(height: 2),
                    SourceMeta(sourceWork: sourceWork, sourceRef: sourceRef),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Divider(height: 1, color: StoicColors.divider),
          const SizedBox(height: 9),
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
            behaviorIntent,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  height: 1.6,
                  color: StoicColors.stone,
                ),
          ),
          const SizedBox(height: 12),
          TagGroup(tags: contextTags),
        ],
      ),
    );
  }
}

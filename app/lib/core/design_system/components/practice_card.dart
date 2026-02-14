import 'package:flutter/material.dart';

import '../../domain/context_labels.dart';
import '../tokens/design_tokens.dart';
import 'stoic_card.dart';

class PracticeCard extends StatelessWidget {
  const PracticeCard({
    super.key,
    required this.title,
    required this.quoteLinkExplanation,
    required this.practiceContext,
    required this.minutes,
    required this.steps,
    required this.expectedOutcome,
    required this.completionCriteria,
    required this.journalPrompt,
  });

  final String title;
  final String quoteLinkExplanation;
  final String practiceContext;
  final int minutes;
  final List<String> steps;
  final String expectedOutcome;
  final String completionCriteria;
  final String journalPrompt;

  @override
  Widget build(BuildContext context) {
    return StoicCard(
      variant: StoicCardVariant.subtle,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            quoteLinkExplanation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  fontSize: 14,
                  color: StoicColors.textSecondarySoft,
                ),
          ),
          const SizedBox(height: 12),
          _BulletInfo(
            label: 'Situação',
            value: contextLabel(practiceContext),
            bulletSize: const Size(5, 8),
            bulletRadius: 99,
          ),
          const SizedBox(height: 12),
          _BulletInfo(
            label: 'Tempo previsto',
            value: '$minutes min',
            bulletSize: const Size(8, 8),
            bulletRadius: 99,
          ),
          const SizedBox(height: 12),
          Text(
            'Como aplicar hoje'.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.65,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: const BoxDecoration(
                          color: StoicColors.deepBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: StoicColors.ivory,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.6,
                                fontSize: 14,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const Divider(height: 1, color: StoicColors.divider),
          const SizedBox(height: 12),
          if (expectedOutcome.isNotEmpty)
            Text.rich(
              TextSpan(
                text: 'Impacto esperado: ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: StoicColors.obsidian,
                    ),
                children: [
                  TextSpan(
                    text: expectedOutcome,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: StoicColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
          if (expectedOutcome.isNotEmpty && completionCriteria.isNotEmpty)
            const SizedBox(height: 12),
          if (completionCriteria.isNotEmpty)
            Text.rich(
              TextSpan(
                text: 'Sinal de conclusão: ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: StoicColors.obsidian,
                    ),
                children: [
                  TextSpan(
                    text: completionCriteria,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: StoicColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
          if (journalPrompt.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: StoicColors.divider),
            const SizedBox(height: 12),
            Text(
              'Reflexão do dia: $journalPrompt',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Cormorant Garamond',
                    fontStyle: FontStyle.italic,
                    fontSize: 18,
                    color: StoicColors.stone,
                    height: 1.5,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BulletInfo extends StatelessWidget {
  const _BulletInfo({
    required this.label,
    required this.value,
    required this.bulletSize,
    required this.bulletRadius,
  });

  final String label;
  final String value;
  final Size bulletSize;
  final double bulletRadius;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: StoicColors.copper,
            borderRadius: BorderRadius.circular(bulletRadius),
          ),
          child: SizedBox(width: bulletSize.width, height: bulletSize.height),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: '$label: ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: StoicColors.obsidian,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
              children: [
                TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: StoicColors.textMuted,
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

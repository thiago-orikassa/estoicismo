import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../tokens/design_tokens.dart';
import 'stoic_buttons.dart';
import 'stoic_card.dart';

enum StoicCheckinStatus {
  pending,
  applied,
  notApplied,
}

class StoicCheckinCard extends StatelessWidget {
  const StoicCheckinCard({
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
  final StoicCheckinStatus status;
  final bool isSubmitting;
  final VoidCallback onApplied;
  final VoidCallback onNotApplied;
  final String? savedNote;

  @override
  Widget build(BuildContext context) {
    final resolvedNote = savedNote?.trim() ?? '';
    return StoicCard(
      variant: StoicCardVariant.defaultCard,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check-in Diário',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 20),
          if (status == StoicCheckinStatus.pending) ...[
            Text(
              reflectionPrompt,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: StoicColors.obsidian,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(StoicRadius.md),
                border: Border.all(color: StoicColors.sand),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: TextField(
                controller: noteController,
                enabled: !isSubmitting,
                minLines: 3,
                maxLines: 5,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      height: 1.5,
                      color: StoicColors.obsidian,
                    ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Opcional: registre suas reflexões aqui...',
                  hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: StoicColors.textSubtle,
                        fontSize: 14,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StoicPressScale(
                    enabled: !isSubmitting,
                    child: StoicPrimaryButton(
                      onPressed: isSubmitting ? null : onApplied,
                      size: StoicButtonSize.medium,
                      fullWidth: true,
                      child: AnimatedSwitcher(
                        duration: MotionTokens.standard,
                        switchInCurve: MotionTokens.curveEntry,
                        switchOutCurve: MotionTokens.curveTransition,
                        child: isSubmitting
                            ? const Row(
                                key: ValueKey('loading'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        StoicColors.ivory,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Salvando...'),
                                ],
                              )
                            : const Text(
                                'Apliquei hoje',
                                key: ValueKey('label'),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StoicPressScale(
                    enabled: !isSubmitting,
                    child: StoicSecondaryButton(
                      onPressed: isSubmitting ? null : onNotApplied,
                      size: StoicButtonSize.medium,
                      fullWidth: true,
                      child: const Text('Não apliquei'),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: StoicColors.deepBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(StoicRadius.md),
                border: Border.all(
                  color: StoicColors.deepBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: StoicColors.deepBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Check-in registrado',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                              color: StoicColors.deepBlue,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status == StoicCheckinStatus.applied
                        ? 'Você aplicou a prática de hoje.'
                        : 'Registrado. Tente novamente amanhã.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: StoicColors.textSecondarySoft,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
            if (resolvedNote.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(StoicRadius.md),
                  border: Border.all(
                    color: StoicColors.sand.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sua reflexão'.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 11,
                            letterSpacing: 0.8,
                            color: StoicColors.textSubtle,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      resolvedNote,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.5,
                            color: StoicColors.obsidian,
                          ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Retorne amanhã para nova prática.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: StoicColors.textMuted,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

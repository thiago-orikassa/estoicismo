import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../tokens/aethor_icons.dart';
import '../tokens/design_tokens.dart';
import 'aethor_buttons.dart';
import 'aethor_card.dart';

enum AethorCheckinStatus {
  pending,
  applied,
  notApplied,
}

class AethorCheckinCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final resolvedNote = savedNote?.trim() ?? '';
    return AethorCard(
      variant: AethorCardVariant.defaultCard,
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
          if (status == AethorCheckinStatus.pending) ...[
            Text(
              reflectionPrompt,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AethorColors.obsidian,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AethorRadius.md),
                border: Border.all(color: AethorColors.sand),
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
                      color: AethorColors.obsidian,
                    ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Opcional: registre suas reflexões aqui...',
                  hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AethorColors.textSubtle,
                        fontSize: 14,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AethorPressScale(
                    enabled: !isSubmitting,
                    child: AethorPrimaryButton(
                      onPressed: isSubmitting ? null : onApplied,
                      size: AethorButtonSize.medium,
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
                                        AethorColors.ivory,
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
                  child: AethorPressScale(
                    enabled: !isSubmitting,
                    child: AethorSecondaryButton(
                      onPressed: isSubmitting ? null : onNotApplied,
                      size: AethorButtonSize.medium,
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
                color: AethorColors.deepBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AethorRadius.md),
                border: Border.all(
                  color: AethorColors.deepBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        AethorIcons.check,
                        size: 20,
                        color: AethorColors.deepBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Check-in registrado',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                              color: AethorColors.deepBlue,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status == AethorCheckinStatus.applied
                        ? 'Você aplicou a prática de hoje.'
                        : 'Registrado. Amanhã há nova prática.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: AethorColors.textSecondarySoft,
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
                  borderRadius: BorderRadius.circular(AethorRadius.md),
                  border: Border.all(
                    color: AethorColors.sand.withValues(alpha: 0.5),
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
            ],
            const SizedBox(height: 12),
            Text(
              'Retorne amanhã para nova prática.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: AethorColors.textMuted,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens/aethor_icons.dart';
import '../tokens/design_tokens.dart';
import 'history_types.dart';

class DayDetailSheet extends StatelessWidget {
  const DayDetailSheet({
    super.key,
    required this.date,
    required this.quoteText,
    required this.author,
    required this.work,
    required this.reference,
    required this.practiceTitle,
    required this.practiceDescription,
    required this.status,
    this.checkInNote,
    required this.onClose,
  });

  final DateTime date;
  final String quoteText;
  final String author;
  final String work;
  final String reference;
  final String practiceTitle;
  final String practiceDescription;
  final HistoryCheckinStatus status;
  final String? checkInNote;
  final VoidCallback onClose;

  String _formatLongDate(DateTime value, AppLocalizations l10n) {
    final weekdays = <String>[
      l10n.weekdayMonday,
      l10n.weekdayTuesday,
      l10n.weekdayWednesday,
      l10n.weekdayThursday,
      l10n.weekdayFriday,
      l10n.weekdaySaturday,
      l10n.weekdaySunday,
    ];
    final months = <String>[
      l10n.monthJanuary,
      l10n.monthFebruary,
      l10n.monthMarch,
      l10n.monthApril,
      l10n.monthMay,
      l10n.monthJune,
      l10n.monthJuly,
      l10n.monthAugust,
      l10n.monthSeptember,
      l10n.monthOctober,
      l10n.monthNovember,
      l10n.monthDecember,
    ];

    final weekday = weekdays[value.weekday - 1];
    final month = months[value.month - 1];
    return '$weekday, ${value.day} de $month de ${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final note = checkInNote?.trim() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AethorColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AethorColors.textSubtle.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Text(
                _formatLongDate(date, l10n).toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      letterSpacing: 0.6,
                      color: AethorColors.stone.withValues(alpha: 0.5),
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.dayDetailPracticeLabel,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 32,
                      fontStyle: FontStyle.italic,
                      color: AethorColors.obsidian,
                      height: 1.1,
                    ),
              ),
              if (status != HistoryCheckinStatus.none) ...[
                const SizedBox(height: 12),
                _StatusBadge(status: status),
              ],
              const SizedBox(height: 20),
              Text(
                l10n.dayDetailQuoteLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1,
                      fontSize: 10,
                      color: AethorColors.stone.withValues(alpha: 0.4),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '"$quoteText"',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: AethorColors.obsidian,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '$author • $work${reference.isNotEmpty ? ' • $reference' : ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AethorColors.textMuted,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.dayDetailPracticeAppliedLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1,
                      fontSize: 10,
                      color: AethorColors.stone.withValues(alpha: 0.4),
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AethorRadius.md),
                  border: Border.all(color: AethorColors.border.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      practiceTitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AethorColors.obsidian,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      practiceDescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AethorColors.textMuted,
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
              if (note.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  l10n.dayDetailReflectionLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1,
                        fontSize: 10,
                        color: AethorColors.textSubtle,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AethorRadius.md),
                    border: Border.all(color: AethorColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    note,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AethorColors.obsidian,
                          height: 1.5,
                        ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AethorColors.deepBlue,
                    foregroundColor: AethorColors.ivory,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AethorRadius.md),
                    ),
                  ),
                  onPressed: onClose,
                  child: Text(l10n.actionClose),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final HistoryCheckinStatus status;

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == HistoryCheckinStatus.completed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? AethorColors.deepBlue.withValues(alpha: 0.1)
            : AethorColors.stone.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AethorColors.deepBlue.withValues(alpha: 0.2)
              : AethorColors.stone.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCompleted)
            const Icon(
              AethorIcons.check,
              size: 16,
              color: AethorColors.deepBlue,
            ),
          if (isCompleted) const SizedBox(width: 6),
          Text(
            isCompleted ? AppLocalizations.of(context).dayDetailStatusCompleted : AppLocalizations.of(context).dayDetailStatusNotApplied,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? AethorColors.deepBlue
                      : AethorColors.textSubtle,
                ),
          ),
        ],
      ),
    );
  }
}

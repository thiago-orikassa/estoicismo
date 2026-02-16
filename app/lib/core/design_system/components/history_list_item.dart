import 'package:flutter/material.dart';

import '../tokens/aethor_icons.dart';
import '../tokens/design_tokens.dart';
import 'history_types.dart';

class HistoryListItem extends StatelessWidget {
  const HistoryListItem({
    super.key,
    required this.date,
    required this.author,
    required this.quotePreview,
    required this.status,
    this.hasNote = false,
    required this.onTap,
  });

  final DateTime date;
  final String author;
  final String quotePreview;
  final HistoryCheckinStatus status;
  final bool hasNote;
  final VoidCallback onTap;

  String _formatShortDate(DateTime value) {
    const weekdays = <String>[
      'seg',
      'ter',
      'qua',
      'qui',
      'sex',
      'sáb',
      'dom',
    ];
    const months = <String>[
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];

    final weekday = weekdays[value.weekday - 1];
    final month = months[value.month - 1];
    final day = value.day.toString().padLeft(2, '0');
    return '$weekday, $day $month';
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AethorColors.cardBackground,
        borderRadius: BorderRadius.circular(AethorRadius.md),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AethorRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AethorRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _formatShortDate(date).toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontSize: 11,
                                  letterSpacing: 0.4,
                                  color: AethorColors.textMuted,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          const SizedBox(width: 8),
                          if (status != HistoryCheckinStatus.none)
                            CheckinStatusChip(status: status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quotePreview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              color: AethorColors.obsidian,
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            author,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontSize: 12,
                                  color: AethorColors.textSecondarySoft,
                                ),
                          ),
                          if (hasNote) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              AethorIcons.edit,
                              size: 14,
                              color: AethorColors.copper,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  AethorIcons.chevronRight,
                  color: AethorColors.textSubtle,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CheckinStatusChip extends StatelessWidget {
  const CheckinStatusChip({super.key, required this.status});

  final HistoryCheckinStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case HistoryCheckinStatus.completed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AethorColors.deepBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                AethorIcons.check,
                size: 12,
                color: AethorColors.deepBlue,
              ),
              const SizedBox(width: 4),
              Text(
                'Feito',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: AethorColors.deepBlue,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        );
      case HistoryCheckinStatus.skipped:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AethorColors.stone.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Pulado',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: AethorColors.stone.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
          ),
        );
      case HistoryCheckinStatus.none:
        return const SizedBox.shrink();
    }
  }
}

import 'package:flutter/material.dart';

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
    return Material(
      color: StoicColors.cardBackground,
      borderRadius: BorderRadius.circular(StoicRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StoicRadius.md),
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
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                letterSpacing: 0.6,
                                color: StoicColors.stone.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500,
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
                            fontFamily: 'Cormorant Garamond',
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: StoicColors.obsidian,
                            height: 1.3,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          author,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 12,
                                color: StoicColors.textMuted,
                              ),
                        ),
                        if (hasNote) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: StoicColors.copper,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right_rounded,
                color: StoicColors.stone.withValues(alpha: 0.3),
                size: 20,
              ),
            ],
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
            color: StoicColors.deepBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_rounded,
                size: 12,
                color: StoicColors.deepBlue,
              ),
              const SizedBox(width: 4),
                Text(
                  'Feito',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: StoicColors.deepBlue,
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
            color: StoicColors.stone.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Pulado',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: StoicColors.stone.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
          ),
        );
      case HistoryCheckinStatus.none:
        return const SizedBox.shrink();
    }
  }
}

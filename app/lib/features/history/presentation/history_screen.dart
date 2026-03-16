import 'package:flutter/material.dart';

import '../../../app_state.dart';
import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/aethor_icons.dart';
import '../../../core/design_system/tokens/design_tokens.dart';
import '../../../core/paywall/paywall_flow.dart';
import '../../../l10n/app_localizations.dart';
import '../../daily_quote/domain/models.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.state});

  final AppState state;

  DateTime _parseDate(String dateLocal) {
    return DateTime.tryParse(dateLocal) ?? DateTime.now();
  }

  HistoryCheckinStatus _resolveStatus(CheckinRecord? record) {
    if (record == null) return HistoryCheckinStatus.none;
    return record.applied
        ? HistoryCheckinStatus.completed
        : HistoryCheckinStatus.skipped;
  }

  void _openDayDetailSheet(
    BuildContext context,
    DailyPackage item,
    CheckinRecord? record,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DayDetailSheet(
          date: _parseDate(item.dateLocal),
          quoteText: item.quote.text,
          author: item.quote.author,
          work: item.quote.sourceWork,
          reference: item.quote.sourceRef,
          practiceTitle: item.recommendation.title,
          practiceDescription: item.recommendation.quoteLinkExplanation,
          status: _resolveStatus(record),
          checkInNote: record?.note,
          onClose: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  Widget _buildUpsellCard(BuildContext context, AppState state) {
    final l10n = AppLocalizations.of(context);
    return AethorCard(
      variant: AethorCardVariant.subtle,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(AethorIcons.lock, color: AethorColors.copper),
          const SizedBox(height: 8),
          Text(
            l10n.historyProUpsellTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AethorColors.obsidian,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.historyProUpsellDesc,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AethorColors.textMuted,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AethorColors.deepBlue,
                foregroundColor: AethorColors.ivory,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => PaywallFlow.showPremiumBlock(
                context,
                state: state,
                feature: PremiumFeature.fullHistory,
              ),
              child: Text(l10n.historyProUpsellButton),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.historyTitle,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontFamily: 'Cormorant Garamond',
                fontSize: 48,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: AethorColors.obsidian,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 16),
      ],
    );

    if (state.loadingHistory && state.history.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          header,
          if (state.offline) ...[
            AethorOfflineBanner(onSync: state.bootstrap),
            const SizedBox(height: 12),
          ],
          const AethorLoadingState(),
        ],
      );
    }

    if (state.history.isEmpty) {
      final offline = state.offline;
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          header,
          if (offline) ...[
            AethorOfflineBanner(onSync: state.bootstrap),
            const SizedBox(height: 12),
          ],
          AethorEmptyState(
            title: offline ? l10n.historyEmptyOffline : l10n.historyEmptyOnline,
            description: offline
                ? l10n.historyEmptySync
                : l10n.historyEmptyFirstRecord,
            icon: Icon(
              offline ? AethorIcons.wifiOff : AethorIcons.history,
              size: 32,
              color: offline ? AethorColors.deepBlue : AethorColors.textSubtle,
            ),
            actionLabel: offline ? l10n.actionSync : null,
            onAction: offline ? state.bootstrap : null,
          ),
        ],
      );
    }

    const int freeLimit = 7;
    final isPro = state.isPro;
    final items =
        isPro ? state.history : state.history.take(freeLimit).toList(growable: false);
    final showUpsell = !isPro && state.history.length > items.length;

    final entries = <Widget>[
      header,
      // Indicador progressivo do limite free (A-05)
      if (!isPro && state.history.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:
                        (state.history.length / freeLimit).clamp(0.0, 1.0),
                    backgroundColor:
                        AethorColors.sand.withValues(alpha: 0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      state.history.length >= freeLimit
                          ? AethorColors.copper
                          : AethorColors.deepBlue,
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Semantics(
                label: l10n.historyLimitLabel(state.history.length, freeLimit),
                child: Text(
                  l10n.historyLimitLabel(state.history.length, freeLimit),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        color: state.history.length >= freeLimit
                            ? AethorColors.copper
                            : AethorColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      if (state.offline) AethorOfflineBanner(onSync: state.bootstrap),
      if (state.offline) const SizedBox(height: 4),
      ...items.map((item) {
        final record = state.checkinForDate(item.dateLocal);
        return AethorFadeSlideIn(
          child: HistoryListItem(
            date: _parseDate(item.dateLocal),
            author: item.quote.author,
            quotePreview: item.quote.text,
            status: _resolveStatus(record),
            hasNote: record?.note?.isNotEmpty ?? false,
            onTap: () => _openDayDetailSheet(context, item, record),
          ),
        );
      }),
      if (showUpsell) _buildUpsellCard(context, state),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => entries[index],
    );
  }
}

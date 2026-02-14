import 'package:flutter/material.dart';

import '../../../app_state.dart';
import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/design_tokens.dart';
import '../../../core/paywall/paywall_flow.dart';
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
    return StoicCard(
      variant: StoicCardVariant.subtle,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_rounded, color: StoicColors.copper),
          const SizedBox(height: 8),
          Text(
            'Histórico completo é Pro',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: StoicColors.obsidian,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Acesse todos os registros da sua jornada e veja sua evolução.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: StoicColors.textMuted,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: StoicColors.deepBlue,
                foregroundColor: StoicColors.ivory,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => PaywallFlow.showPremiumBlock(
                context,
                state: state,
                feature: PremiumFeature.fullHistory,
              ),
              child: const Text('Ver planos Pro'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (state.loadingHistory && state.history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: StoicLoadingState(),
        ),
      );
    }

    if (state.history.isEmpty) {
      final offline = state.offline;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StoicEmptyState(
            title: offline ? 'Você está offline.' : 'Nenhuma prática registrada',
            description: offline
                ? 'Conecte-se para sincronizar seu histórico.'
                : 'Complete sua primeira prática para ver o histórico.',
            actionLabel: offline ? 'Sincronizar' : null,
            onAction: offline ? state.bootstrap : null,
          ),
        ),
      );
    }

    final isPro = state.isPro;
    final items =
        isPro ? state.history : state.history.take(7).toList(growable: false);
    final showUpsell = !isPro && state.history.length > items.length;

    final entries = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Histórico',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 48,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: StoicColors.obsidian,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 16),
        ],
      ),
      if (state.offline) StoicOfflineBanner(onSync: state.bootstrap),
      if (state.offline) const SizedBox(height: 4),
      ...items.map((item) {
        final record = state.checkinForDate(item.dateLocal);
        return StoicFadeSlideIn(
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

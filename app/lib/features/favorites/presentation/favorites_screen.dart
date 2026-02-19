import 'package:flutter/material.dart';

import '../../../app_state.dart';
import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/aethor_icons.dart';
import '../../../core/design_system/tokens/design_tokens.dart';
import '../../../core/paywall/paywall_flow.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.state,
    this.onExploreToday,
  });

  final AppState state;
  final VoidCallback? onExploreToday;

  @override
  Widget build(BuildContext context) {
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favoritos',
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

    if (state.loadingFavorites && state.favorites.isEmpty) {
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

    if (state.favorites.isEmpty) {
      final offline = state.offline;
      final actionLabel = offline ? 'Sincronizar' : null;
      final onAction = offline ? state.bootstrap : onExploreToday;

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          header,
          if (offline) ...[
            AethorOfflineBanner(onSync: state.bootstrap),
            const SizedBox(height: 12),
          ],
          AethorEmptyState(
            title: offline
                ? 'Você está offline.'
                : 'As citações que ressoam com você aparecerão aqui.',
            description: offline
                ? 'Conecte-se para sincronizar seus favoritos.'
                : 'Salve a citação do dia para revisitar quando precisar.',
            icon: Icon(
              offline ? AethorIcons.wifiOff : AethorIcons.heartOutline,
              size: 32,
              color: offline ? AethorColors.deepBlue : AethorColors.textSubtle,
            ),
            actionLabel: actionLabel,
            onAction: onAction,
          ),
        ],
      );
    }

    final isPro = state.isPro;
    final favoritesToShow = isPro
        ? state.favorites
        : state.favorites.take(10).toList(growable: false);
    final showUpsell =
        !isPro && state.favorites.length > favoritesToShow.length;

    final entries = <Widget>[
      header,
      if (state.offline) AethorOfflineBanner(onSync: state.bootstrap),
      if (state.offline) const SizedBox(height: 4),
      ...favoritesToShow.map((favorite) {
        final quote = state.findQuoteById(favorite.quoteId);
        final card = Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: AethorColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quote != null
                    ? '"${quote.text}"'
                    : 'Citação #${favorite.quoteId}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: AethorColors.obsidian,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AethorColors.divider),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quote?.author ?? 'Autor não carregado',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AethorColors.obsidian,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          quote == null
                              ? 'ID: ${favorite.quoteId}'
                              : '${quote.sourceWork} / ${quote.sourceRef}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AethorColors.textSubtle,
                                    letterSpacing: 0.4,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await state.toggleFavorite(favorite.quoteId);
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                              content: Text('Removido dos favoritos.')),
                        );
                      } catch (_) {
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content:
                                Text('Não foi possível remover o favorito.'),
                          ),
                        );
                      }
                    },
                    tooltip: 'Remover dos favoritos',
                    icon: const Icon(AethorIcons.close,
                        color: AethorColors.copper),
                  ),
                ],
              ),
            ],
          ),
        );

        return AethorFadeSlideIn(child: card);
      }),
      if (showUpsell)
        AethorCard(
          variant: AethorCardVariant.subtle,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(AethorIcons.lock, color: AethorColors.copper),
              const SizedBox(height: 8),
              Text(
                'Favoritos ilimitados são Pro',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AethorColors.obsidian,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Salve cada citação para revisitar quando precisar.',
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
                    feature: PremiumFeature.favoritesLimit,
                  ),
                  child: const Text('Ver planos Pro'),
                ),
              ),
            ],
          ),
        ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => entries[index],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../app_state.dart';
import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/design_tokens.dart';
import '../../../core/paywall/paywall_flow.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    if (state.loadingFavorites && state.favorites.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: StoicLoadingState(),
        ),
      );
    }

    if (state.favorites.isEmpty) {
      final offline = state.offline;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StoicEmptyState(
            title:
                offline ? 'Você está offline.' : 'Nenhuma citação favoritada ainda.',
            description: offline
                ? 'Conecte-se para sincronizar seus favoritos.'
                : 'Toque no ícone de estrela da citação do dia para salvar.',
            actionLabel: offline ? 'Sincronizar' : null,
            onAction: offline ? state.bootstrap : null,
          ),
        ),
      );
    }

    final isPro = state.isPro;
    final favoritesToShow = isPro
        ? state.favorites
        : state.favorites.take(10).toList(growable: false);
    final showUpsell = !isPro && state.favorites.length > favoritesToShow.length;

    final entries = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favoritos',
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
      ...favoritesToShow.map((favorite) {
        final quote = state.findQuoteById(favorite.quoteId);
        final card = Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: StoicColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quote != null ? '"${quote.text}"' : 'Citação #${favorite.quoteId}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      color: StoicColors.obsidian,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: StoicColors.divider),
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: StoicColors.obsidian,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          quote == null
                              ? 'ID: ${favorite.quoteId}'
                              : '${quote.sourceWork} / ${quote.sourceRef}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: StoicColors.textSubtle,
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
                          const SnackBar(content: Text('Removido dos favoritos.')),
                        );
                      } catch (_) {
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Não foi possível remover o favorito.'),
                          ),
                        );
                      }
                    },
                    tooltip: 'Remover dos favoritos',
                    icon: const Icon(Icons.close_rounded, color: StoicColors.copper),
                  ),
                ],
              ),
            ],
          ),
        );

        return StoicFadeSlideIn(child: card);
      }),
      if (showUpsell)
        StoicCard(
          variant: StoicCardVariant.subtle,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_rounded, color: StoicColors.copper),
              const SizedBox(height: 8),
              Text(
                'Favoritos ilimitados são Pro',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: StoicColors.obsidian,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Guarde todas as citações que fazem sentido para você.',
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

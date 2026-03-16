import 'package:flutter/material.dart';

import '../../../app_state.dart';
import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/aethor_icons.dart';
import '../../../core/design_system/tokens/design_tokens.dart';
import '../../../core/paywall/paywall_flow.dart';
import '../../../l10n/app_localizations.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    required this.state,
    this.onExploreToday,
  });

  final AppState state;
  final VoidCallback? onExploreToday;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _searchQuery = '';

  static const int _freeLimit = 10;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final l10n = AppLocalizations.of(context);

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.favoritesTitle,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontFamily: 'Cormorant Garamond',
                fontSize: 48,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: AethorColors.obsidian,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 12),
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
                ? l10n.offlineTitle
                : l10n.favoritesEmptyOnline,
            description: offline
                ? l10n.favoritesEmptyHint
                : l10n.favoritesEmptyHint,
            icon: Icon(
              offline ? AethorIcons.wifiOff : AethorIcons.heartOutline,
              size: 32,
              color: offline ? AethorColors.deepBlue : AethorColors.textSubtle,
            ),
            // CTA sempre presente para conduzir o usuário à ação (M-07)
            actionLabel: offline ? l10n.actionSync : l10n.favoritesEmptyTodayCta,
            onAction: offline ? state.bootstrap : widget.onExploreToday,
          ),
        ],
      );
    }

    final isPro = state.isPro;
    final allFavorites = state.favorites;
    final favoritesToShow = isPro
        ? allFavorites
        : allFavorites.take(_freeLimit).toList(growable: false);
    final showUpsell = !isPro && allFavorites.length > favoritesToShow.length;

    // Filtra por busca (M-05)
    final filteredFavorites = _searchQuery.isEmpty
        ? favoritesToShow
        : favoritesToShow.where((fav) {
            final quote = state.findQuoteById(fav.quoteId);
            if (quote == null) return false;
            final q = _searchQuery.toLowerCase();
            return quote.text.toLowerCase().contains(q) ||
                quote.author.toLowerCase().contains(q);
          }).toList(growable: false);

    final entries = <Widget>[
      header,
      // Barra de busca (M-05)
      if (favoritesToShow.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontSize: 14, color: AethorColors.obsidian),
            decoration: InputDecoration(
              hintText: l10n.favoritesSearchHint,
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AethorColors.textSubtle,
                  ),
              prefixIcon: const Icon(
                  AethorIcons.search,
                  color: AethorColors.textSubtle,
                  size: 20),
              filled: true,
              fillColor: AethorColors.cardBackground,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AethorColors.cardOutline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AethorColors.cardOutline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AethorColors.deepBlue, width: 1.5),
              ),
            ),
          ),
        ),
      // Indicador progressivo do limite free (A-05)
      if (!isPro)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (allFavorites.length / _freeLimit).clamp(0.0, 1.0),
                    backgroundColor:
                        AethorColors.sand.withValues(alpha: 0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      allFavorites.length >= _freeLimit
                          ? AethorColors.copper
                          : AethorColors.deepBlue,
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Semantics(
                label: l10n.historyLimitLabel(allFavorites.length, _freeLimit),
                child: Text(
                  '${allFavorites.length}/$_freeLimit',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        color: allFavorites.length >= _freeLimit
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
      if (filteredFavorites.isEmpty && _searchQuery.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              l10n.favoritesSearchEmpty(_searchQuery),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AethorColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
        )
      else
        ...filteredFavorites.map((favorite) {
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
                            quote?.author ?? '',
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
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AethorColors.textSubtle,
                                  letterSpacing: 0.4,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: l10n.favoritesRemoveTooltip,
                      child: IconButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await state.toggleFavorite(favorite.quoteId);
                            if (!context.mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                  content: Text(l10n.favoritesRemoveSuccess)),
                            );
                          } catch (_) {
                            if (!context.mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(l10n.favoritesRemoveError),
                              ),
                            );
                          }
                        },
                        tooltip: l10n.favoritesRemoveTooltip,
                        icon: const Icon(AethorIcons.close,
                            color: AethorColors.copper),
                      ),
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
                l10n.favoritesProUpsellTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AethorColors.obsidian,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.favoritesProUpsellDesc,
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
                  child: Text(l10n.favoritesProUpsellButton),
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

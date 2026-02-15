import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app_state.dart';
import '../../../core/auth/auth_flow.dart';
import '../../../core/auth/auth_models.dart';
import '../../../core/design_system/components/components.dart';
import '../../../core/paywall/paywall_flow.dart';
import '../../../core/design_system/tokens/design_tokens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.state,
    required this.onNavigateToSettings,
  });

  final AppState state;
  final VoidCallback onNavigateToSettings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _isTogglingFavorite = false;
  bool _isSubmittingCheckin = false;
  StoicCheckinStatus _checkinStatus = StoicCheckinStatus.pending;
  bool _showNotificationNudge = false;
  NotificationResultType? _notificationResult;
  String? _savedCheckinNote;
  String? _currentDateLocal;
  String? _valuePaywallCheckedForDate;

  String _errorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return 'Não foi possível concluir a ação. Tente novamente.';
  }

  String _formatLongDate(String dateLocal) {
    final parsed = DateTime.tryParse(dateLocal);
    if (parsed == null) return dateLocal;

    const weekdays = <String>[
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];
    const months = <String>[
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    final weekday = weekdays[parsed.weekday - 1];
    final month = months[parsed.month - 1];
    return '$weekday, ${parsed.day} de $month';
  }

  NotificationPromptPlatform _resolvePromptPlatform(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return NotificationPromptPlatform.ios;
    }
    return NotificationPromptPlatform.android;
  }

  Future<NotificationPermissionStatus?> _showNotificationPrompt(
    BuildContext context,
  ) {
    final platform = _resolvePromptPlatform(context);
    return showGeneralDialog<NotificationPermissionStatus>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Notificações',
      barrierColor: platform == NotificationPromptPlatform.ios
          ? Colors.black38
          : Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return NotificationPromptDialog(
          platform: platform,
          onAllow: () =>
              Navigator.of(context).pop(NotificationPermissionStatus.granted),
          onDeny: () =>
              Navigator.of(context).pop(NotificationPermissionStatus.denied),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _handleEnableNotifications(AppState state) async {
    final result = await _showNotificationPrompt(context);
    if (!mounted || result == null) return;

    if (result == NotificationPermissionStatus.granted) {
      state.setNotificationPermission(NotificationPermissionStatus.granted);
      if (!state.remindersEnabled) {
        state.setRemindersEnabled(true);
      }
      if (state.reminderTime == null) {
        state.setReminderTime('08:00');
      }
      setState(() => _notificationResult = NotificationResultType.granted);
    } else {
      state.setNotificationPermission(NotificationPermissionStatus.denied);
      state.setRemindersEnabled(false);
      setState(() => _notificationResult = NotificationResultType.denied);
    }
  }

  Future<void> _maybePromptLoginAfterCheckin(AppState state) async {
    if (!state.shouldPromptAfterCheckin) return;
    state.markFirstCheckinCompleted();

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await AuthFlow.showLoginPrompt(
      context,
      state: state,
      contextType: AuthPromptContext.checkin,
    );
  }

  Future<void> _maybePromptLoginAfterFavorite(AppState state) async {
    if (!state.shouldPromptAfterFavorite) return;
    state.markFavoritePromptShown();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await AuthFlow.showLoginPrompt(
      context,
      state: state,
      contextType: AuthPromptContext.favorite,
    );
  }

  Future<void> _maybeShowValueBasedPaywall(AppState state) async {
    if (!state.canShowPaywallForTrigger(PaywallTrigger.valueBased)) return;
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    await PaywallFlow.showPaywall(
      context,
      state: state,
      trigger: PaywallTrigger.valueBased,
    );
  }

  Future<void> _maybeShowConsistencyPaywallOnDailyView(
    AppState state,
    String dateLocal,
    CheckinRecord? existingRecord,
  ) async {
    if (_valuePaywallCheckedForDate == dateLocal) return;
    _valuePaywallCheckedForDate = dateLocal;

    if (existingRecord != null) return;
    if (!state.hasValueBasedMilestone) return;

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted || _currentDateLocal != dateLocal) return;
    await PaywallFlow.showPaywall(
      context,
      state: state,
      trigger: PaywallTrigger.valueBased,
    );
  }

  Future<void> _toggleFavorite(
    AppState state,
    String quoteId,
    bool isFavorite,
  ) async {
    if (_isTogglingFavorite) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isTogglingFavorite = true);
    try {
      await state.toggleFavorite(quoteId);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? 'Removido dos favoritos.'
                : 'Adicionado aos favoritos.',
          ),
        ),
      );
      if (!isFavorite) {
        await _maybePromptLoginAfterFavorite(state);
      }
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_errorMessage(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _isTogglingFavorite = false);
      }
    }
  }

  Future<void> _submitCheckin(AppState state, {required bool applied}) async {
    if (_isSubmittingCheckin) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isSubmittingCheckin = true;
      _notificationResult = null;
    });
    try {
      await state.submitCheckin(
        applied: applied,
        note: _noteController.text.trim(),
      );
      await state.loadHistory();

      if (!mounted) return;
      setState(() {
        _checkinStatus = applied
            ? StoicCheckinStatus.applied
            : StoicCheckinStatus.notApplied;
        _savedCheckinNote = _noteController.text.trim();
        if (applied &&
            state.notificationPermission ==
                NotificationPermissionStatus.unknown) {
          _showNotificationNudge = true;
        } else {
          _showNotificationNudge = false;
        }
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            applied ? 'Prática registrada com sucesso.' : 'Check-in concluído.',
          ),
        ),
      );
      await _maybePromptLoginAfterCheckin(state);
      await _maybeShowValueBasedPaywall(state);
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_errorMessage(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmittingCheckin = false);
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    if (state.loadingDaily && state.daily == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: StoicLoadingState(),
        ),
      );
    }

    if (state.offline && state.daily == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StoicEmptyState(
            title: 'Você está offline.',
            description: 'Conecte-se para sincronizar o conteúdo diário.',
            icon: const Icon(
              Icons.wifi_off_rounded,
              size: 32,
              color: StoicColors.deepBlue,
            ),
            actionLabel: 'Sincronizar',
            onAction: state.bootstrap,
          ),
        ),
      );
    }

    if (state.error != null && state.daily == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StoicErrorState(
            message: 'Não foi possível carregar o conteúdo de hoje.',
            onRetry: state.bootstrap,
          ),
        ),
      );
    }

    final daily = state.daily;
    if (daily == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: StoicEmptyState(
            title: 'Sem conteúdo diário disponível.',
            description: 'Tente sincronizar novamente em instantes.',
            icon: Icon(
              Icons.auto_stories_rounded,
              size: 32,
              color: StoicColors.textSubtle,
            ),
          ),
        ),
      );
    }

    final existingRecord = state.checkinForDate(daily.dateLocal);
    if (_currentDateLocal != daily.dateLocal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _currentDateLocal = daily.dateLocal;
          if (existingRecord != null) {
            _checkinStatus = existingRecord.applied
                ? StoicCheckinStatus.applied
                : StoicCheckinStatus.notApplied;
            _savedCheckinNote = existingRecord.note;
            _noteController.text = existingRecord.note ?? '';
          } else {
            _checkinStatus = StoicCheckinStatus.pending;
            _savedCheckinNote = null;
            _noteController.clear();
          }
          _showNotificationNudge = false;
          _notificationResult = null;
          _valuePaywallCheckedForDate = null;
        });
        unawaited(
          _maybeShowConsistencyPaywallOnDailyView(
            state,
            daily.dateLocal,
            existingRecord,
          ),
        );
      });
    }

    final isFavorite = state.isFavorited(daily.quote.id);

    return RefreshIndicator(
      onRefresh: state.bootstrap,
      color: StoicColors.deepBlue,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text(
            'Hoje',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 48,
                  height: 1.1,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Cormorant Garamond',
                  fontWeight: FontWeight.w500,
                  color: StoicColors.obsidian,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatLongDate(daily.dateLocal).toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  color: StoicColors.textMuted,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w400,
                ),
          ),
          const SizedBox(height: 24),
          if (state.offline) ...[
            StoicOfflineBanner(onSync: state.bootstrap),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 2),
          QuoteCard(
            quoteText: daily.quote.text,
            author: daily.quote.author,
            sourceWork: daily.quote.sourceWork,
            sourceRef: daily.quote.sourceRef,
            behaviorIntent: daily.quote.behaviorIntent,
            contextTags: daily.quote.contextTags,
            favorite: isFavorite,
            favoriteLoading: _isTogglingFavorite,
            onToggleFavorite: () =>
                _toggleFavorite(state, daily.quote.id, isFavorite),
          ),
          const SizedBox(height: 24),
          PracticeCard(
            title: daily.recommendation.title,
            quoteLinkExplanation: daily.recommendation.quoteLinkExplanation,
            practiceContext: daily.recommendation.context,
            minutes: daily.recommendation.minutes,
            steps: daily.recommendation.steps,
            expectedOutcome: daily.recommendation.expectedOutcome,
            completionCriteria: daily.recommendation.completionCriteria,
            journalPrompt: daily.recommendation.journalPrompt,
          ),
          const SizedBox(height: 24),
          StoicCheckinCard(
            noteController: _noteController,
            reflectionPrompt: daily.recommendation.journalPrompt,
            status: _checkinStatus,
            isSubmitting: _isSubmittingCheckin,
            savedNote: _savedCheckinNote,
            onApplied: () => _submitCheckin(state, applied: true),
            onNotApplied: () => _submitCheckin(state, applied: false),
          ),
          if (_showNotificationNudge) ...[
            const SizedBox(height: 20),
            NotificationNudgeCard(
              onEnable: () async {
                setState(() => _showNotificationNudge = false);
                await _handleEnableNotifications(state);
              },
              onDismiss: () => setState(() => _showNotificationNudge = false),
            ),
          ],
          if (_notificationResult != null) ...[
            const SizedBox(height: 16),
            NotificationResultCard(
              type: _notificationResult!,
              onAdjustTime: widget.onNavigateToSettings,
              onGoToSettings: widget.onNavigateToSettings,
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

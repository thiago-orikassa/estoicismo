import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app_state.dart';
import '../../../core/auth/auth_flow.dart';
import '../../../core/auth/auth_models.dart';
import '../../../core/design_system/components/components.dart';
import '../../../core/paywall/paywall_flow.dart';
import '../../../core/design_system/tokens/aethor_icons.dart';
import '../../../core/design_system/tokens/design_tokens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.state,
    required this.onNavigateToSettings,
    this.focusCheckinNotifier,
  });

  final AppState state;
  final VoidCallback onNavigateToSettings;
  final ValueNotifier<int>? focusCheckinNotifier;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _noteController = TextEditingController();
  final GlobalKey _checkinCardKey = GlobalKey();
  bool _isTogglingFavorite = false;
  bool _isSubmittingCheckin = false;
  AethorCheckinStatus _checkinStatus = AethorCheckinStatus.pending;
  bool _showNotificationNudge = false;
  NotificationResultType? _notificationResult;
  String? _savedCheckinNote;
  String? _currentDateLocal;
  String? _valuePaywallCheckedForDate;

  // ---------------------------------------------------------------------------
  // Animação em duas fases — hierarquia temporal contemplativa
  //
  // Phase 1 (800ms): Header + data + QuoteCard container entry
  // Phase 2 (dinâmica): QuoteCard typewriter interno (gerido pelo QuoteCard)
  // Phase 3 (1400ms): PracticeCard + CheckinCard + Notification cards
  //                    acionado quando QuoteCard completa suas animações
  // ---------------------------------------------------------------------------

  late final AnimationController _phase1Controller;
  late final Animation<double> _headerFade;
  late final Animation<double> _dateFade;
  late final Animation<double> _quoteContainerFade;
  late final Animation<double> _quoteContainerSlide;

  late final AnimationController _phase3Controller;
  late final Animation<double> _practiceFade;
  late final Animation<double> _practiceSlide;
  late final Animation<double> _checkinFade;
  late final Animation<double> _checkinSlide;
  late final Animation<double> _notificationFade;
  late final Animation<double> _notificationSlide;

  bool _entryPlayed = false;
  bool _animateQuote = false;
  bool _quoteAnimationDone = false;

  void _setupPhase1() {
    _phase1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Header "Hoje": 0–260ms (fade)
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phase1Controller,
        curve: const Interval(0.0, 0.325, curve: Curves.easeOut),
      ),
    );

    // Data subtitle: 60–260ms (fade)
    _dateFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phase1Controller,
        curve: const Interval(0.075, 0.325, curve: Curves.easeOut),
      ),
    );

    // QuoteCard container: 200–800ms (fade + slide 20px)
    const quoteContainerCurve =
        Interval(0.25, 1.0, curve: Cubic(0.25, 0.1, 0.25, 1.0));
    _quoteContainerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _phase1Controller,
        curve: quoteContainerCurve,
      ),
    );
    _quoteContainerSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _phase1Controller,
        curve: quoteContainerCurve,
      ),
    );
  }

  void _setupPhase3() {
    _phase3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // PracticeCard: 0–600ms
    const practiceCurve =
        Interval(0.0, 0.429, curve: Cubic(0.25, 0.1, 0.25, 1.0));
    _practiceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _phase3Controller, curve: practiceCurve),
    );
    _practiceSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _phase3Controller, curve: practiceCurve),
    );

    // CheckinCard: 400–1000ms
    const checkinCurve =
        Interval(0.286, 0.714, curve: Cubic(0.25, 0.1, 0.25, 1.0));
    _checkinFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _phase3Controller, curve: checkinCurve),
    );
    _checkinSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _phase3Controller, curve: checkinCurve),
    );

    // Notification cards: 800–1400ms
    const notifCurve =
        Interval(0.571, 1.0, curve: Cubic(0.25, 0.1, 0.25, 1.0));
    _notificationFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _phase3Controller, curve: notifCurve),
    );
    _notificationSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _phase3Controller, curve: notifCurve),
    );
  }

  void _triggerEntryAnimation() {
    if (_entryPlayed) return;
    _entryPlayed = true;
    // Timer breve para permitir transição de tab FadeThrough estabilizar
    // quando o usuário retorna de outra página (260ms de duração).
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() => _animateQuote = true);
      _phase1Controller.forward();
    });
  }

  void _onQuoteAnimationsComplete() {
    if (!mounted) return;
    setState(() => _quoteAnimationDone = true);
    _phase3Controller.forward();
  }

  // ---------------------------------------------------------------------------
  // Lifecycle — replay animações ao retornar do background
  // ---------------------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.state.daily != null) {
      _resetAndReplayAnimations();
    }
  }

  void _resetAndReplayAnimations() {
    _phase1Controller.reset();
    _phase3Controller.reset();
    setState(() {
      _entryPlayed = false;
      _animateQuote = false;
      _quoteAnimationDone = false;
    });
    // O próximo build() chamará _triggerEntryAnimation() automaticamente
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupPhase1();
    _setupPhase3();
    widget.focusCheckinNotifier?.addListener(_onFocusCheckin);
  }

  void _onFocusCheckin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _checkinCardKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          alignment: 0.1,
        );
      }
    });
  }

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
            ? AethorCheckinStatus.applied
            : AethorCheckinStatus.notApplied;
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
    widget.focusCheckinNotifier?.removeListener(_onFocusCheckin);
    WidgetsBinding.instance.removeObserver(this);
    _phase1Controller.dispose();
    _phase3Controller.dispose();
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
          child: AethorLoadingState(),
        ),
      );
    }

    if (state.offline && state.daily == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AethorEmptyState(
            title: 'Você está offline.',
            description: 'Conecte-se para sincronizar o conteúdo diário.',
            icon: const Icon(
              AethorIcons.wifiOff,
              size: AethorIconSize.xl,
              color: AethorColors.deepBlue,
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
          child: AethorErrorState(
            message: 'O conteúdo de hoje não carregou. Tente novamente.',
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
          child: AethorEmptyState(
            title: 'Sem conteúdo diário disponível.',
            description: 'Tente sincronizar novamente em instantes.',
            icon: Icon(
              AethorIcons.book,
              size: AethorIconSize.xl,
              color: AethorColors.textSubtle,
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
                ? AethorCheckinStatus.applied
                : AethorCheckinStatus.notApplied;
            _savedCheckinNote = existingRecord.note;
            _noteController.text = existingRecord.note ?? '';
          } else {
            _checkinStatus = AethorCheckinStatus.pending;
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

    // Dispara a animação de entrada quando o conteúdo está pronto
    _triggerEntryAnimation();

    return RefreshIndicator(
      onRefresh: state.bootstrap,
      color: AethorColors.deepBlue,
      child: AnimatedBuilder(
        animation: Listenable.merge([_phase1Controller, _phase3Controller]),
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              // --- Header "Hoje": Phase 1, fade 0–260ms ---
              Opacity(
                opacity: _headerFade.value,
                child: Text(
                  'Hoje',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 48,
                        height: 1.1,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Cormorant Garamond',
                        fontWeight: FontWeight.w500,
                        color: AethorColors.obsidian,
                      ),
                ),
              ),
              const SizedBox(height: 4),
              // --- Data: Phase 1, fade 60–260ms ---
              Opacity(
                opacity: _dateFade.value,
                child: Text(
                  _formatLongDate(daily.dateLocal).toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        color: AethorColors.textMuted,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
              const SizedBox(height: 24),
              if (state.offline) ...[
                AethorOfflineBanner(onSync: state.bootstrap),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 2),
              // --- QuoteCard: Phase 1 container + Phase 2 internal typewriter ---
              Opacity(
                opacity: _quoteContainerFade.value,
                child: Transform.translate(
                  offset: Offset(0, _quoteContainerSlide.value),
                  child: QuoteCard(
                    key: ValueKey(daily.quote.id),
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
                    animate: _animateQuote,
                    completed: _quoteAnimationDone,
                    onAnimationsComplete: _onQuoteAnimationsComplete,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // --- PracticeCard: Phase 3, 0–600ms após QuoteCard completar ---
              Opacity(
                opacity: _practiceFade.value,
                child: Transform.translate(
                  offset: Offset(0, _practiceSlide.value),
                  child: PracticeCard(
                    title: daily.recommendation.title,
                    quoteLinkExplanation: daily.recommendation.quoteLinkExplanation,
                    practiceContext: daily.recommendation.context,
                    minutes: daily.recommendation.minutes,
                    steps: daily.recommendation.steps,
                    expectedOutcome: daily.recommendation.expectedOutcome,
                    completionCriteria: daily.recommendation.completionCriteria,
                    journalPrompt: daily.recommendation.journalPrompt,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // --- CheckinCard: Phase 3, 400–1000ms após QuoteCard completar ---
              Opacity(
                opacity: _checkinFade.value,
                child: Transform.translate(
                  offset: Offset(0, _checkinSlide.value),
                  child: AethorCheckinCard(
                    key: _checkinCardKey,
                    noteController: _noteController,
                    reflectionPrompt: daily.recommendation.journalPrompt,
                    status: _checkinStatus,
                    isSubmitting: _isSubmittingCheckin,
                    savedNote: _savedCheckinNote,
                    onApplied: () => _submitCheckin(state, applied: true),
                    onNotApplied: () => _submitCheckin(state, applied: false),
                  ),
                ),
              ),
              if (_showNotificationNudge) ...[
                const SizedBox(height: 20),
                Opacity(
                  opacity: _notificationFade.value,
                  child: Transform.translate(
                    offset: Offset(0, _notificationSlide.value),
                    child: NotificationNudgeCard(
                      onEnable: () async {
                        setState(() => _showNotificationNudge = false);
                        await _handleEnableNotifications(state);
                      },
                      onDismiss: () =>
                          setState(() => _showNotificationNudge = false),
                    ),
                  ),
                ),
              ],
              if (_notificationResult != null) ...[
                const SizedBox(height: 16),
                Opacity(
                  opacity: _notificationFade.value,
                  child: Transform.translate(
                    offset: Offset(0, _notificationSlide.value),
                    child: NotificationResultCard(
                      type: _notificationResult!,
                      onAdjustTime: widget.onNavigateToSettings,
                      onGoToSettings: widget.onNavigateToSettings,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

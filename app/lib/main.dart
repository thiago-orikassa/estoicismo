import 'dart:async';

import 'package:animations/animations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'app_state.dart';
import 'core/analytics/analytics_service.dart';
import 'firebase_options.dart';
import 'core/design_system/motion/motion.dart';
import 'core/design_system/tokens/design_tokens.dart';
import 'core/auth/session_service.dart';
import 'core/networking/api_client.dart';
import 'core/notifications/deep_link_intent.dart';
import 'core/notifications/in_app_notification.dart';
import 'core/notifications/push_service.dart';
import 'core/storage/secure_store.dart';
import 'core/paywall/purchase_service.dart';
import 'core/design_system/tokens/aethor_icons.dart';
import 'core/theme/app_theme.dart';
import 'features/daily_quote/data/daily_repository.dart';
import 'features/daily_quote/presentation/home_screen.dart';
import 'features/favorites/presentation/favorites_screen.dart';
import 'features/history/presentation/history_screen.dart';
import 'features/onboarding/presentation/onboarding_flow.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/auth/presentation/auth_splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final analytics = AnalyticsService(FirebaseAnalytics.instance);

  final api = ApiClient();
  final sessionService = SessionService(api, SecureStore());
  final repo = DailyRepository(api);
  final purchaseService = PurchaseService();
  await purchaseService.initialize();
  final state = AppState(repo, sessionService,
      purchaseService: purchaseService, analytics: analytics);
  await state.initialize();
  try {
    final deviceTimezone = await FlutterTimezone.getLocalTimezone();
    if (deviceTimezone.isNotEmpty) {
      state.setTimezone(deviceTimezone);
    }
  } catch (_) {
    // Keep default timezone fallback when device timezone lookup fails.
  }

  runApp(AethorApp(state: state));
}

class AethorApp extends StatelessWidget {
  const AethorApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightMaterial(),
          scrollBehavior: const _NoOverscrollIndicatorBehavior(),
          home: SplashGate(state: state),
        );
      },
    );
  }
}

class _NoOverscrollIndicatorBehavior extends MaterialScrollBehavior {
  const _NoOverscrollIndicatorBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key, required this.state});

  final AppState state;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _showSplash = true;
  bool _showLoading = false;
  Timer? _loadingTimer;
  Timer? _transitionTimer;
  final PushService _onboardingPushService = PushService();

  @override
  void initState() {
    super.initState();
    _loadingTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _showLoading = true);
    });
    _transitionTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _transitionTimer?.cancel();
    unawaited(_onboardingPushService.dispose());
    super.dispose();
  }

  Future<bool> _requestNotificationPermission() async {
    final granted = await _onboardingPushService.requestPermission();
    widget.state.setNotificationPermission(
      granted
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied,
    );
    widget.state.trackEvent(
      'push_permission_result',
      properties: {
        'granted': granted,
        'source': 'onboarding',
      },
    );
    return granted;
  }

  @override
  Widget build(BuildContext context) {
    final content = _showSplash
        ? AuthSplashScreen(showLoading: _showLoading)
        : (widget.state.onboardingComplete
            ? MainShell(state: widget.state)
            : OnboardingFlow(
                state: widget.state,
                onRequestNotificationPermission: _requestNotificationPermission,
              ));

    return AnimatedSwitcher(
      duration: MotionTokens.durationOrZero(context, MotionTokens.standard),
      child: KeyedSubtree(
        key: ValueKey<String>(_showSplash ? 'splash' : 'app'),
        child: content,
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.state});

  final AppState state;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final PushService _pushService = PushService();
  final ValueNotifier<int> _focusCheckinNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.state.bootstrap();
      unawaited(_initializePushAndDeepLinks());
    });
  }

  @override
  void dispose() {
    unawaited(_pushService.dispose());
    _focusCheckinNotifier.dispose();
    super.dispose();
  }

  /// Expose PushService so that other widgets (e.g. OnboardingFlow) can
  /// request notification permission without creating a second instance.
  PushService get pushService => _pushService;

  Future<void> _initializePushAndDeepLinks() async {
    if (!widget.state.pushNotificationsEnabled) {
      // Deeplinks via custom scheme (aethor://) must work even without push.
      await _pushService.initializeAppLinksOnly(
        onAppLink: _handleAppLinkIntent,
        onPushOpened: (properties) => widget.state.trackEvent(
          'push_opened',
          properties: properties,
        ),
      );
      return;
    }

    await _pushService.initialize(
      onAppLink: _handleAppLinkIntent,
      onPushReceived: (properties) async {
        widget.state.trackEvent('push_received', properties: properties);
        _showInAppNotification(properties);
      },
      onPushOpened: (properties) => widget.state.trackEvent(
        'push_opened',
        properties: properties,
      ),
      onTokenRefresh: _registerFcmToken,
    );

    // Do NOT auto-request permission here — respect Apple/Google guidelines.
    // Permission is requested during onboarding (step 4) or via nudge card.
    // Only retrieve token if permission was already granted in a previous session.
    if (widget.state.notificationPermission ==
        NotificationPermissionStatus.granted) {
      final token = await _pushService.getToken();
      if (token != null) {
        unawaited(_registerFcmToken(token));
      }
    }
  }

  void _showInAppNotification(Map<String, dynamic> properties) {
    if (!mounted) return;
    final title = properties['notification_title'] as String?;
    final body = properties['notification_body'] as String?;
    final deeplink = properties['deeplink'] as String?;

    VoidCallback? onTap;
    if (deeplink != null) {
      final uri = Uri.tryParse(deeplink);
      if (uri != null) {
        final intent = parseAppLinkIntent(uri, source: 'in_app_banner');
        if (intent != null) {
          onTap = () => _handleAppLinkIntent(intent);
        }
      }
    }

    InAppNotificationBanner.show(
      context,
      title: title,
      body: body,
      onTap: onTap,
    );
  }

  Future<void> _registerFcmToken(String token) async {
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await widget.state.api.post(
          '/v1/push-tokens',
          body: {
            'fcm_token': token,
            'platform': _currentPlatform(),
          },
        );
        debugPrint('[PushDebug] token registered OK (attempt $attempt)');
        return;
      } catch (e, st) {
        debugPrint(
            '[PushDebug] token registration FAILED attempt $attempt: $e\n$st');
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }
  }

  String _currentPlatform() {
    if (Theme.of(context).platform == TargetPlatform.iOS) return 'ios';
    return 'android';
  }

  Future<void> _handleAppLinkIntent(AppLinkIntent intent) async {
    if (!mounted) return;

    final nextIndex = switch (intent.target) {
      AppLinkTarget.today => 0,
      AppLinkTarget.history => 1,
      AppLinkTarget.favorites => 2,
      AppLinkTarget.settings => 3,
      AppLinkTarget.unknown => _index,
    };

    if (mounted && nextIndex != _index) {
      setState(() => _index = nextIndex);
    }

    if (intent.target == AppLinkTarget.today && intent.dateLocal != null) {
      await widget.state.loadDaily(dateLocal: intent.dateLocal);
    }

    if (intent.focusCheckin && intent.target == AppLinkTarget.today) {
      _focusCheckinNotifier.value += 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        state: widget.state,
        onNavigateToSettings: () => setState(() => _index = 3),
        focusCheckinNotifier: _focusCheckinNotifier,
      ),
      HistoryScreen(state: widget.state),
      FavoritesScreen(
        state: widget.state,
        onExploreToday: () => setState(() => _index = 0),
      ),
      SettingsScreen(state: widget.state),
    ];

    final tabs = <({
      IconData icon,
      String label,
    })>[
      (icon: AethorIcons.home, label: 'Hoje'),
      (icon: AethorIcons.history, label: 'Histórico'),
      (icon: AethorIcons.favorites, label: 'Favoritos'),
      (icon: AethorIcons.settings, label: 'Ajustes'),
    ];

    final reduceMotion = MotionTokens.reduceMotionOf(context);
    final transitionDuration =
        reduceMotion ? Duration.zero : MotionTokens.entry;

    final currentPage = KeyedSubtree(
      key: ValueKey<int>(_index),
      child: pages[_index],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AethorColors.screenBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              if (widget.state.error != null && !widget.state.offline)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AethorColors.copper.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AethorColors.copper.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.state.error!,
                              style: const TextStyle(
                                color: AethorColors.obsidian,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: widget.state.bootstrap,
                            child: const Text('Repetir'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: PageTransitionSwitcher(
                  duration: transitionDuration,
                  transitionBuilder: (child, primary, secondary) {
                    return FadeThroughTransition(
                      animation: primary,
                      secondaryAnimation: secondary,
                      child: child,
                    );
                  },
                  child: currentPage,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AethorColors.bottomBarBackground,
            border: Border(
              top: BorderSide(
                color: AethorColors.bottomBarBorder,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 80,
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final isSelected = i == _index;
                  final color = isSelected
                      ? AethorColors.deepBlue
                      : AethorColors.textSubtle;
                  return Expanded(
                    child: InkResponse(
                      onTap: () => setState(() => _index = i),
                      radius: 32,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tabs[i].icon,
                            size: 24,
                            color: color,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tabs[i].label,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.2,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

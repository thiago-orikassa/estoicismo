import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'app_state.dart';
import 'core/design_system/motion/motion.dart';
import 'core/design_system/tokens/design_tokens.dart';
import 'core/auth/session_service.dart';
import 'core/networking/api_client.dart';
import 'core/storage/secure_store.dart';
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

  final api = ApiClient();
  final sessionService = SessionService(api, SecureStore());
  final repo = DailyRepository(api);
  final state = AppState(repo, sessionService);
  await state.initialize();
  try {
    final deviceTimezone = await FlutterTimezone.getLocalTimezone();
    if (deviceTimezone.isNotEmpty) {
      state.setTimezone(deviceTimezone);
    }
  } catch (_) {
    // Keep default timezone fallback when device timezone lookup fails.
  }

  runApp(EstoicismoApp(state: state));
}

class EstoicismoApp extends StatelessWidget {
  const EstoicismoApp({super.key, required this.state});

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

  @override
  void initState() {
    super.initState();
    _loadingTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _showLoading = true);
    });
    _transitionTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _transitionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = _showSplash
        ? AuthSplashScreen(showLoading: _showLoading)
        : (widget.state.onboardingComplete
            ? MainShell(state: widget.state)
            : OnboardingFlow(state: widget.state));

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.state.bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        state: widget.state,
        onNavigateToSettings: () => setState(() => _index = 3),
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
      (icon: Icons.home_outlined, label: 'Hoje'),
      (icon: Icons.history, label: 'Histórico'),
      (icon: Icons.star_outline, label: 'Favoritos'),
      (icon: Icons.settings_outlined, label: 'Ajustes'),
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
        backgroundColor: StoicColors.screenBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              if (widget.state.error != null && !widget.state.offline)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: StoicColors.copper.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: StoicColors.copper.withValues(alpha: 0.25),
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
                                color: StoicColors.obsidian,
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
            color: StoicColors.bottomBarBackground,
            border: Border(
              top: BorderSide(
                color: StoicColors.bottomBarBorder,
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
                      ? StoicColors.deepBlue
                      : StoicColors.textSubtle;
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

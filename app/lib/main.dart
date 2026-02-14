import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'app_state.dart';
import 'core/design_system/motion/motion.dart';
import 'core/design_system/tokens/design_tokens.dart';
import 'core/networking/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/daily_quote/data/daily_repository.dart';
import 'features/daily_quote/presentation/home_screen.dart';
import 'features/favorites/presentation/favorites_screen.dart';
import 'features/history/presentation/history_screen.dart';
import 'features/onboarding/presentation/onboarding_flow.dart';
import 'features/settings/presentation/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final api = ApiClient();
  final repo = DailyRepository(api);
  final state = AppState(repo);
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
          home: state.onboardingComplete
              ? MainShell(state: state)
              : OnboardingFlow(state: state),
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
      FavoritesScreen(state: widget.state),
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

    return Scaffold(
      backgroundColor: StoicColors.obsidian,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (widget.state.error != null && !widget.state.offline)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: StoicColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: StoicColors.error.withValues(alpha: 0.25),
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
                              color: StoicColors.ivory,
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
              child: Container(
                color: StoicColors.screenBackground,
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: StoicColors.bottomBarBackground,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.75),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(tabs.length, (i) {
                      final isSelected = i == _index;
                      return SizedBox(
                        width: 60,
                        height: 44.5,
                        child: InkResponse(
                          onTap: () => setState(() => _index = i),
                          radius: 32,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                tabs[i].icon,
                                size: 24,
                                color: isSelected
                                    ? StoicColors.copper
                                    : StoicColors.sand,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tabs[i].label,
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1.2,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? StoicColors.copper
                                      : StoicColors.sand,
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
              Container(
                height: 20,
                alignment: Alignment.center,
                child: Container(
                  width: 128,
                  height: 4,
                  decoration: BoxDecoration(
                    color: StoicColors.ivory.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

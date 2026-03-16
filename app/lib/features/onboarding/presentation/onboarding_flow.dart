import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app_state.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/aethor_icons.dart';
import '../../../core/design_system/tokens/design_tokens.dart';
import '../../../core/domain/authors.dart';
import '../../../core/domain/context_labels.dart';
import '../../../l10n/app_localizations.dart';
import '../../daily_quote/domain/models.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    super.key,
    required this.state,
    this.onRequestNotificationPermission,
  });

  final AppState state;
  final Future<bool> Function()? onRequestNotificationPermission;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  // A-01: merged Reminder + Time into one step → 5 steps total
  static const int _totalSteps = 5;

  int _stepIndex = 0;
  String? _selectedContext;
  late Future<void> _previewFuture;
  late Set<String> _selectedAuthors;
  String _selectedVoiceId = 'mixed';
  String? _selectedTime;
  bool _remindersEnabled = false;

  // Contextos com chave — descrição resolvida via l10n em build
  static const List<String> _contextKeys = [
    'ansiedade',
    'foco',
    'trabalho',
    'relacionamentos',
    'decisao_dificil',
  ];

  // Voice option keys — subtítulo e label resolvidos via l10n em build
  static const List<String> _voiceIds = [
    'seneca',
    'epictetus',
    'marcus_aurelius',
    'mixed',
  ];

  // Time option values — labels resolvidos via l10n em build
  static const List<String> _timeValues = ['07:30', '12:30', '20:30', 'custom'];

  @override
  void initState() {
    super.initState();
    _selectedAuthors = kAethorAuthors.toSet();

    if (widget.state.daily != null) {
      // Dado já disponível — resolve instantâneo.
      _previewFuture = Future.value();
    } else {
      // Adia o fetch para depois do primeiro frame:
      // loadDaily() chama notifyListeners() (que dispara setState em outros
      // widgets) — chamá-lo dentro do initState causaria setState durante build.
      final completer = Completer<void>();
      _previewFuture = completer.future;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.state.loadDaily().then((_) {
          if (!completer.isCompleted) completer.complete();
        }).catchError((_) {
          if (!completer.isCompleted) completer.complete();
        });
      });
    }
  }

  void _goNext() {
    if (_stepIndex >= _totalSteps - 1) return;
    setState(() => _stepIndex += 1);
  }

  void _goBack() {
    if (_stepIndex == 0) return;
    setState(() => _stepIndex -= 1);
  }

  Future<void> _pickCustomTime() async {
    final initial =
        _parseTime(_selectedTime) ?? const TimeOfDay(hour: 7, minute: 30);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(primary: AethorColors.deepBlue),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null) return;
    setState(() => _selectedTime = _formatTime(picked));
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Set<String> _authorsForVoiceId(String id) {
    switch (id) {
      case 'seneca':
        return {'Sêneca'};
      case 'epictetus':
        return {'Epicteto'};
      case 'marcus_aurelius':
        return {'Marco Aurélio'};
      default:
        return kAethorAuthors.toSet();
    }
  }

  String _summaryVoice(AppLocalizations l10n) {
    return localizedAuthorName(context, _selectedVoiceId);
  }

  /// Converte timezone IANA para nome legível em português.
  String _readableTimezone(String tz) {
    const tzNames = <String, String>{
      'America/Sao_Paulo': 'Brasília (GMT−3)',
      'America/Manaus': 'Manaus (GMT−4)',
      'America/Belem': 'Belém (GMT−3)',
      'America/Fortaleza': 'Fortaleza (GMT−3)',
      'America/Recife': 'Recife (GMT−3)',
      'America/Cuiaba': 'Cuiabá (GMT−4)',
      'America/Porto_Velho': 'Porto Velho (GMT−4)',
      'America/Boa_Vista': 'Boa Vista (GMT−4)',
      'America/Rio_Branco': 'Rio Branco (GMT−5)',
      'America/Noronha': 'Fernando de Noronha (GMT−2)',
      'America/New_York': 'Nova York (GMT−5)',
      'America/Chicago': 'Chicago (GMT−6)',
      'America/Denver': 'Denver (GMT−7)',
      'America/Los_Angeles': 'Los Angeles (GMT−8)',
      'Europe/Lisbon': 'Lisboa (GMT+0)',
      'Europe/London': 'Londres (GMT+0)',
      'Europe/Madrid': 'Madri (GMT+1)',
      'Europe/Paris': 'Paris (GMT+1)',
      'Europe/Berlin': 'Berlim (GMT+1)',
    };
    return tzNames[tz] ?? tz.replaceAll('_', ' ');
  }

  Future<void> _completeOnboarding() async {
    if (_selectedContext != null) {
      await widget.state.setPreferredContext(_selectedContext!);
    }
    widget.state.setPreferredAuthors(_selectedAuthors);
    if (_selectedTime != null) {
      widget.state.setReminderTime(_selectedTime);
    }
    widget.state.setRemindersEnabled(_remindersEnabled);
    widget.state.completeOnboarding();
  }

  void _showHowItWorks() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AethorColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onboardingHowItWorksTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cormorant Garamond',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.onboardingHowItWorksSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AethorColors.textMuted,
                      ),
                ),
                const SizedBox(height: 16),
                _BulletItem(text: l10n.onboardingHowItWorksBullet1),
                _BulletItem(text: l10n.onboardingHowItWorksBullet2),
                _BulletItem(text: l10n.onboardingHowItWorksBullet3),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AethorSpacing.md),
                  decoration: BoxDecoration(
                    color: AethorColors.deepBlue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AethorRadius.md),
                    border: Border.all(
                      color: AethorColors.deepBlue.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    l10n.onboardingHowItWorksQuote,
                    style: const TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_stepIndex + 1) / _totalSteps;

    return _OnboardingScaffold(
      progress: progress,
      stepKey: ValueKey(_stepIndex),
      currentStep: _stepIndex + 1,
      totalSteps: _totalSteps,
      showBack: _stepIndex > 0,
      onBack: _goBack,
      onSkip: _stepIndex == 0 ? () => _completeOnboarding() : null,
      child: _buildStep(context),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_stepIndex) {
      case 0:
        return _buildIntro(context);
      case 1:
        return _buildContext(context);
      case 2:
        return _buildVoice(context);
      case 3:
        // A-01: Reminder + Time merged into one step
        return _buildReminderAndTime(context);
      default:
        return _buildDone(context);
    }
  }

  Widget _buildIntro(BuildContext context) {
    return _IntroStep(
      onBegin: _goNext,
      onHowItWorks: _showHowItWorks,
      previewFuture: _previewFuture,
      dailyProvider: () => widget.state.daily,
    );
  }

  Widget _buildContext(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasSelection = _selectedContext != null;

    final contextDescriptions = <String, String>{
      'ansiedade': l10n.onboardingContextAnxietyLabel,
      'foco': l10n.onboardingContextFocusLabel,
      'trabalho': l10n.onboardingContextWorkLabel,
      'relacionamentos': l10n.onboardingContextRelationshipsLabel,
      'decisao_dificil': l10n.onboardingContextHardDecisionLabel,
    };

    return _StepContent(
      title: l10n.onboardingContextQuestion,
      subtitle: l10n.onboardingContextSubtitle,
      helperText: hasSelection ? null : l10n.onboardingContextHelper,
      body: Column(
        children: _contextKeys.map((key) {
          final label = localizedContextLabel(context, key);
          final selected = _selectedContext == key;
          return Padding(
            padding: const EdgeInsets.only(bottom: AethorSpacing.md),
            child: _OptionCard(
              title: label,
              subtitle: contextDescriptions[key],
              selected: selected,
              onTap: () => setState(() => _selectedContext = key),
            ),
          );
        }).toList(),
      ),
      primaryAction: _PrimaryButton(
        label: l10n.actionContinue,
        enabled: hasSelection,
        onPressed: hasSelection ? _goNext : null,
      ),
      secondaryAction: _TextLink(
        label: l10n.onboardingContextSkip,
        onPressed: _goNext,
      ),
    );
  }

  Widget _buildVoice(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final voiceSubtitles = <String, String>{
      'seneca': l10n.onboardingVoiceSenecaSubtitle,
      'epictetus': l10n.onboardingVoiceEpictetusSubtitle,
      'marcus_aurelius': l10n.onboardingVoiceMarcusSubtitle,
      'mixed': l10n.onboardingVoiceMixedSubtitle,
    };

    return _StepContent(
      title: l10n.onboardingVoiceTitle,
      subtitle: l10n.onboardingVoiceSubtitle,
      body: Column(
        children: _voiceIds.map((id) {
          final selected = _selectedVoiceId == id;
          return Padding(
            padding: const EdgeInsets.only(bottom: AethorSpacing.md),
            child: _OptionCard(
              title: localizedAuthorName(context, id),
              subtitle: voiceSubtitles[id],
              selected: selected,
              onTap: () {
                setState(() {
                  _selectedVoiceId = id;
                  _selectedAuthors = _authorsForVoiceId(id);
                });
              },
            ),
          );
        }).toList(),
      ),
      primaryAction: _PrimaryButton(
        label: l10n.actionContinue,
        onPressed: _goNext,
      ),
      secondaryAction: _TextLink(
        label: l10n.onboardingVoiceSkip,
        onPressed: _goNext,
      ),
    );
  }

  // A-01: Steps 3 (Reminder) + 4 (Time) merged into one step.
  // O Switch substitui os dois CTAs separados: "Ativar lembretes" / "Agora não".
  // As opções de horário aparecem com AnimatedSize quando o lembrete é ativado.
  Widget _buildReminderAndTime(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final timeLabels = <String, String>{
      '07:30': l10n.onboardingTimeMorning,
      '12:30': l10n.onboardingTimeLunch,
      '20:30': l10n.onboardingTimeEvening,
      'custom': l10n.onboardingTimeCustom,
    };

    return _StepContent(
      leading: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: AethorColors.mist,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          AethorIcons.bell,
          color: AethorColors.deepBlue,
          size: 32,
        ),
      ),
      title: l10n.onboardingReminderTitle,
      subtitle: l10n.onboardingReminderSubtitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle de ativar/desativar lembrete
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AethorColors.cardBackground,
              borderRadius: BorderRadius.circular(AethorRadius.lg),
              border: Border.all(color: AethorColors.cardOutline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.onboardingReminderToggleLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AethorColors.obsidian,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                Switch(
                  value: _remindersEnabled,
                  activeThumbColor: AethorColors.deepBlue,
                  activeTrackColor:
                      AethorColors.deepBlue.withValues(alpha: 0.4),
                  onChanged: (value) async {
                    if (value) {
                      bool granted = true;
                      if (widget.onRequestNotificationPermission != null) {
                        granted =
                            await widget.onRequestNotificationPermission!();
                      }
                      if (!mounted) return;
                      if (granted) {
                        setState(() => _remindersEnabled = true);
                      }
                    } else {
                      setState(() {
                        _remindersEnabled = false;
                        _selectedTime = null;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          // Horário — expande com animação quando o lembrete é ativado
          AnimatedSize(
            duration: MotionTokens.standard,
            curve: Curves.easeInOut,
            child: _remindersEnabled
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AethorSpacing.md),
                      ..._timeValues.map((value) {
                        final isCustom = value == 'custom';
                        final selected = isCustom
                            ? _selectedTime != null && !_isPresetTime()
                            : _selectedTime == value;
                        final subtitle = isCustom
                            ? (_selectedTime != null && !_isPresetTime()
                                ? l10n.onboardingReminderTimeSelected(_selectedTime!)
                                : null)
                            : value;
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: AethorSpacing.md),
                          child: _OptionCard(
                            title: timeLabels[value] ?? value,
                            subtitle: subtitle,
                            selected: selected,
                            onTap: () async {
                              if (isCustom) {
                                await _pickCustomTime();
                              } else {
                                setState(
                                    () => _selectedTime = value);
                              }
                            },
                          ),
                        );
                      }),
                      Text(
                        l10n.onboardingReminderTimezoneLabel(_readableTimezone(widget.state.timezone)),
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AethorColors.textSubtle,
                                ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      primaryAction: _PrimaryButton(
        label: l10n.actionContinue,
        onPressed: _goNext,
      ),
    );
  }

  bool _isPresetTime() {
    return _timeValues
        .where((value) => value != 'custom')
        .any((value) => value == _selectedTime);
  }

  Widget _buildDone(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chips = <Widget>[
      if (_selectedContext != null)
        _SummaryChip(label: l10n.onboardingDoneContextChip(localizedContextLabel(context, _selectedContext!))),
      _SummaryChip(label: l10n.onboardingDoneVoiceChip(_summaryVoice(l10n))),
      if (_selectedTime != null)
        _SummaryChip(label: l10n.onboardingDoneTimeChip(_selectedTime!)),
      if (_remindersEnabled) _SummaryChip(label: l10n.onboardingDoneReminderChip),
    ];

    final hasChips = chips.isNotEmpty;

    return _StepContent(
      centered: true,
      leading: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AethorColors.deepBlue.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          AethorIcons.checkCircleFill,
          color: AethorColors.deepBlue,
          size: 32,
        ),
      ),
      title: l10n.onboardingDoneTitle,
      subtitle: l10n.onboardingDoneSubtitle,
      body: hasChips
          ? Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: chips,
            )
          : Text(
              l10n.onboardingDonePersonalizeHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AethorColors.textMuted,
                    height: 1.5,
                  ),
            ),
      primaryAction: _PrimaryButton(
        label: l10n.onboardingDoneButton,
        onPressed: _completeOnboarding,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scaffold
// ---------------------------------------------------------------------------

class _OnboardingScaffold extends StatelessWidget {
  const _OnboardingScaffold({
    required this.progress,
    required this.stepKey,
    required this.currentStep,
    required this.totalSteps,
    required this.child,
    this.showBack = true,
    this.onBack,
    this.onSkip,
  });

  final double progress;
  final Key stepKey;
  final int currentStep;
  final int totalSteps;
  final Widget child;
  final bool showBack;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AethorColors.screenBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AethorSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _ProgressBar(
                      value: progress,
                      currentStep: currentStep,
                      totalSteps: totalSteps,
                      showLabel: onSkip == null,
                    ),
                  ),
                  if (onSkip != null)
                    TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        padding: const EdgeInsets.only(left: 8),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppLocalizations.of(context).onboardingSkipButton,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AethorColors.textSubtle,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            // IconButton ocupa menos espaço vertical que TextButton.icon
            // e mantém target de toque adequado (48×48 mínimo)
            if (showBack)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 20, 0),
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(AethorIcons.back),
                  color: AethorColors.textPrimary,
                  tooltip: AppLocalizations.of(context).onboardingBackTooltip,
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: MotionTokens.standard,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: KeyedSubtree(
                  key: stepKey,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step content
// ---------------------------------------------------------------------------

class _StepContent extends StatelessWidget {
  const _StepContent({
    required this.title,
    required this.subtitle,
    required this.body,
    this.leading,
    this.centered = false,
    this.primaryAction,
    this.secondaryAction,
    this.helperText,
  });

  final String title;
  final String subtitle;
  final String? helperText;
  // Widget opcional exibido acima do título (ex.: marca no step de intro)
  final Widget? leading;
  // Quando true, centraliza ícone → título → subtítulo verticalmente na tela
  final bool centered;
  final Widget body;
  final Widget? primaryAction;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return centered ? _buildCentered(context) : _buildLinear(context);
  }

  /// Layout padrão: título e subtítulo no topo, conteúdo scrollável abaixo.
  /// Usado em telas com listas de opções (contexto, autor, horário).
  Widget _buildLinear(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(height: AethorSpacing.md),
          ],
          Text(
            title,
            style: textTheme.displaySmall?.copyWith(
              fontFamily: 'Cormorant Garamond',
              fontSize: 40,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AethorSpacing.sm),
          Text(
            subtitle,
            style: textTheme.bodyLarge?.copyWith(
              color: AethorColors.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AethorSpacing.lg),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  body,
                  if (helperText != null) ...[
                    const SizedBox(height: AethorSpacing.sm),
                    Text(
                      helperText!,
                      style: textTheme.bodySmall?.copyWith(
                        color: AethorColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (primaryAction != null) ...[
            const SizedBox(height: AethorSpacing.sm),
            primaryAction!,
          ],
          if (secondaryAction != null) ...[
            const SizedBox(height: AethorSpacing.sm),
            secondaryAction!,
          ],
        ],
      ),
    );
  }

  /// Layout de foco: ícone → título → subtítulo → corpo, tudo centralizado.
  /// Usado em telas de decisão única (lembrete, conclusão).
  Widget _buildCentered(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(height: AethorSpacing.lg),
                  ],
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 40,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: AethorSpacing.sm),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AethorColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AethorSpacing.lg),
                  body,
                ],
              ),
            ),
          ),
          if (primaryAction != null) ...[
            const SizedBox(height: AethorSpacing.sm),
            primaryAction!,
          ],
          if (secondaryAction != null) ...[
            const SizedBox(height: AethorSpacing.sm),
            secondaryAction!,
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress bar com trilha de fundo e indicador numérico
// ---------------------------------------------------------------------------

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.value,
    required this.currentStep,
    required this.totalSteps,
    this.showLabel = true,
  });

  final double value;
  final int currentStep;
  final int totalSteps;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).onboardingProgressLabel(currentStep, totalSteps),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final clamped = value.clamp(0.05, 1.0).toDouble();
                final fillWidth = constraints.maxWidth * clamped;
                return Stack(
                  children: [
                    // Trilha de fundo
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AethorColors.sand.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    // Preenchimento animado
                    AnimatedContainer(
                      duration: MotionTokens.standard,
                      curve: Curves.easeInOut,
                      width: fillWidth,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AethorColors.copper,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 10),
            // Indicador numérico visível — complementa a semântica acima
            Text(
              '$currentStep/$totalSteps',
              style: const TextStyle(
                fontSize: 11,
                color: AethorColors.textSubtle,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Marca tipográfica do intro
// ---------------------------------------------------------------------------

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).onboardingBrandTitle,
          style: const TextStyle(
            fontFamily: 'Cormorant Garamond',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.5,
            color: AethorColors.copper,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 28,
          height: 1.5,
          decoration: BoxDecoration(
            color: AethorColors.copper.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Option card
// ---------------------------------------------------------------------------

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? AethorColors.deepBlue : AethorColors.cardOutline;

    return Semantics(
      label: subtitle != null ? '$title, $subtitle' : title,
      selected: selected,
      button: true,
      child: AethorPressScale(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AethorRadius.lg),
          child: AnimatedContainer(
            duration: MotionTokens.micro,
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AethorSpacing.lg,
              vertical: AethorSpacing.md,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? AethorColors.deepBlue.withValues(alpha: 0.06)
                  : AethorColors.cardBackground,
              borderRadius: BorderRadius.circular(AethorRadius.lg),
              border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Cormorant Garamond',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AethorColors.textMuted,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                ExcludeSemantics(
                    child: _SelectionIndicator(selected: selected)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Selection indicator
// ---------------------------------------------------------------------------

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AethorColors.deepBlue : AethorColors.cardOutline,
          width: 2,
        ),
      ),
      child: AnimatedScale(
        duration: MotionTokens.micro,
        scale: selected ? 1.0 : 0.0,
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AethorColors.deepBlue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Preview card com citação real e atribuição ao autor
// ---------------------------------------------------------------------------

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.quote,
    required this.author,
    required this.action,
  });

  final String quote;
  final String author;
  final String action;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AethorSpacing.lg),
      decoration: BoxDecoration(
        color: AethorColors.cardBackground,
        borderRadius: BorderRadius.circular(AethorRadius.lg),
        border: Border.all(color: AethorColors.cardOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingIntroTodayLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AethorColors.textSubtle,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: AethorSpacing.sm),
          Text(
            quote,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: AethorSpacing.xs),
          Text(
            '— $author',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AethorColors.copperText,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AethorSpacing.md),
          Container(
            height: 1,
            color: AethorColors.cardOutline,
          ),
          const SizedBox(height: AethorSpacing.md),
          Text(
            l10n.onboardingIntroActionLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AethorColors.textMuted,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            action,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AethorColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Buttons
// ---------------------------------------------------------------------------

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AethorPressScale(
        enabled: enabled,
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          child: Text(label),
        ),
      ),
    );
  }
}

class _TextLink extends StatelessWidget {
  const _TextLink({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(double.infinity, 44),
        ),
        child: Text(
          label,
          style: const TextStyle(
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary chip
// ---------------------------------------------------------------------------

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AethorColors.cardBackground,
        borderRadius: BorderRadius.circular(AethorRadius.pill),
        border: Border.all(color: AethorColors.cardOutline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AethorColors.textSecondary,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bullet item
// ---------------------------------------------------------------------------

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AethorColors.copper,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AethorColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Intro step — coreografia de entrada animada
//
// Timeline (ms / 2600ms total):
//   0ms    → Brand AETHOR        fadeIn 420ms            contemplative
//   340ms  → Headline            typewriter 32ms/char    linear
//   1120ms → Subtitle            fadeSlideIn Y6  420ms   contemplative
//   1360ms → Preview card        heroSlideIn Y14 500ms   easeOutCubic
//   1740ms → "Ver como funciona" fadeIn 380ms             easeOut
//   1940ms → CTA button          heroSlideIn Y10 500ms   easeOutCubic
// ---------------------------------------------------------------------------

class _IntroStep extends StatefulWidget {
  const _IntroStep({
    required this.onBegin,
    required this.onHowItWorks,
    required this.previewFuture,
    required this.dailyProvider,
  });

  final VoidCallback onBegin;
  final VoidCallback onHowItWorks;
  final Future<void> previewFuture;
  final DailyPackage? Function() dailyProvider;

  @override
  State<_IntroStep> createState() => _IntroStepState();
}

class _IntroStepState extends State<_IntroStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _started = false;

  static const int _totalMs = 2600;
  static const int _msPerChar = 32;

  // Janelas de tempo em ms
  static const int _brandStart      = 0;
  static const int _brandDur        = 420;
  static const int _typewriterStart = 340;
  static const int _subtitleStart   = 1120;
  static const int _subtitleDur     = 420;
  static const int _cardStart       = 1360;
  static const int _cardDur         = 500;
  static const int _linkStart       = 1740;
  static const int _linkDur         = 380;
  static const int _ctaStart        = 1940;
  static const int _ctaDur          = 500;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _maybeStart(bool reduceMotion) {
    if (_started) return;
    _started = true;
    if (reduceMotion) {
      _ctrl.value = 1.0;
    } else {
      _ctrl.forward();
    }
  }

  double _progress(int startMs, int durMs) {
    final ms = _ctrl.value * _totalMs;
    if (ms < startMs) return 0.0;
    if (ms >= startMs + durMs) return 1.0;
    return ((ms - startMs) / durMs).clamp(0.0, 1.0);
  }

  double _easeOut(int start, int dur) =>
      MotionTokens.curveEntry.transform(_progress(start, dur));

  double _contemplate(int start, int dur) =>
      MotionTokens.curveContemplative.transform(_progress(start, dur));

  double _heroEase(int start, int dur) =>
      MotionTokens.curveHeroEntry.transform(_progress(start, dur));

  int _visibleChars(int textLength) {
    final ms = _ctrl.value * _totalMs;
    if (ms < _typewriterStart) return 0;
    return ((ms - _typewriterStart) / _msPerChar)
        .floor()
        .clamp(0, textLength);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MotionTokens.reduceMotionOf(context);
    _maybeStart(reduceMotion);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => _buildContent(context, reduceMotion),
    );
  }

  Widget _buildContent(BuildContext context, bool rm) {
    final l10n = AppLocalizations.of(context);
    final titleText = l10n.onboardingIntroTitle;
    final brandT    = rm ? 1.0 : _contemplate(_brandStart, _brandDur);
    final subtitleT = rm ? 1.0 : _contemplate(_subtitleStart, _subtitleDur);
    final cardT     = rm ? 1.0 : _heroEase(_cardStart, _cardDur);
    final linkT     = rm ? 1.0 : _easeOut(_linkStart, _linkDur);
    final ctaT      = rm ? 1.0 : _heroEase(_ctaStart, _ctaDur);
    final chars     = rm ? titleText.length : _visibleChars(titleText.length);
    final allDone   = chars >= titleText.length;

    final titleStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
          fontFamily: 'Cormorant Garamond',
          fontSize: 40,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
          height: 1.1,
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          Opacity(
            opacity: brandT,
            child: const _BrandHeader(),
          ),
          const SizedBox(height: AethorSpacing.md),

          // Headline — typewriter espelha o QuoteCard
          Semantics(
            label: titleText,
            child: ExcludeSemantics(
              child: Text.rich(
                TextSpan(
                  style: titleStyle,
                  children: [
                    if (chars > 0)
                      TextSpan(text: titleText.substring(0, chars)),
                    if (!allDone)
                      TextSpan(
                        text: titleText.substring(chars),
                        style: titleStyle?.copyWith(color: Colors.transparent),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AethorSpacing.sm),

          // Subtitle
          Opacity(
            opacity: subtitleT,
            child: Transform.translate(
              offset: Offset(0, 6.0 * (1.0 - subtitleT)),
              child: Text(
                l10n.onboardingIntroSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AethorColors.textMuted,
                      height: 1.4,
                    ),
              ),
            ),
          ),
          const SizedBox(height: AethorSpacing.lg),

          // Corpo scrollável
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview card
                  Opacity(
                    opacity: cardT,
                    child: Transform.translate(
                      offset: Offset(0, 14.0 * (1.0 - cardT)),
                      child: FutureBuilder<void>(
                        future: widget.previewFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const _PreviewCardSkeleton();
                          }
                          final pkg = widget.dailyProvider();
                          if (pkg != null) {
                            return _LivePreviewCard(package: pkg);
                          }
                          final l10n2 = AppLocalizations.of(context);
                          return _PreviewCard(
                            quote: l10n2.onboardingIntroExampleQuote,
                            author: l10n2.onboardingIntroExampleAuthor,
                            action: l10n2.onboardingIntroExampleAction,
                          );
                        },
                      ),
                    ),
                  ),
                  // Link
                  Opacity(
                    opacity: linkT,
                    child: _TextLink(
                      label: l10n.onboardingIntroHowItWorks,
                      onPressed: widget.onHowItWorks,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CTA
          const SizedBox(height: AethorSpacing.sm),
          Opacity(
            opacity: ctaT,
            child: Transform.translate(
              offset: Offset(0, 10.0 * (1.0 - ctaT)),
              child: _PrimaryButton(
                label: l10n.onboardingIntroCta,
                onPressed: widget.onBegin,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Preview card — skeleton de carregamento
// ---------------------------------------------------------------------------

class _PreviewCardSkeleton extends StatelessWidget {
  const _PreviewCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AethorColors.cardBackground,
        borderRadius: BorderRadius.circular(AethorRadius.lg),
        border: Border.all(color: AethorColors.cardOutline),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AethorColors.deepBlue,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Preview card — conteúdo real vindo da API (DailyPackage)
// ---------------------------------------------------------------------------

class _LivePreviewCard extends StatelessWidget {
  const _LivePreviewCard({required this.package});

  final DailyPackage package;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final quote = package.quote;
    final action = package.recommendation.title;
    final sourceLine =
        '${quote.sourceWork.toUpperCase()} / ${quote.sourceRef.toUpperCase()}';

    return Container(
      padding: const EdgeInsets.all(AethorSpacing.lg),
      decoration: BoxDecoration(
        color: AethorColors.cardBackground,
        borderRadius: BorderRadius.circular(AethorRadius.lg),
        border: Border.all(color: AethorColors.cardOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingIntroTodayLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AethorColors.textSubtle,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: AethorSpacing.sm),
          Text(
            '"${quote.text}"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: AethorSpacing.xs),
          Text(
            '— ${quote.author}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AethorColors.copperText,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            sourceLine,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AethorColors.textSubtle,
                  fontSize: 11,
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w400,
                ),
          ),
          const SizedBox(height: AethorSpacing.md),
          Container(height: 1, color: AethorColors.cardOutline),
          const SizedBox(height: AethorSpacing.md),
          Text(
            l10n.onboardingIntroActionLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AethorColors.textMuted,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            action,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AethorColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}


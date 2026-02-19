import 'package:flutter/material.dart';

import '../../../app_state.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/aethor_icons.dart';
import '../../../core/design_system/tokens/design_tokens.dart';
import '../../../core/domain/authors.dart';
import '../../../core/domain/context_labels.dart';

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
  static const int _totalSteps = 6;

  int _stepIndex = 0;
  String? _selectedContext;
  late Set<String> _selectedAuthors;
  String _selectedVoiceLabel = kMixedAuthorsLabel;
  String? _selectedTime;
  bool _remindersEnabled = false;
  bool _skipTimeStep = false;

  // Contextos com descrição de benefício orientada ao usuário
  final List<_ContextOption> _contextOptions = const [
    _ContextOption(
      key: 'ansiedade',
      description: 'Recuperar clareza quando a mente acelera',
    ),
    _ContextOption(
      key: 'foco',
      description: 'Separar o essencial do urgente',
    ),
    _ContextOption(
      key: 'trabalho',
      description: 'Agir com intenção no ambiente profissional',
    ),
    _ContextOption(
      key: 'relacionamentos',
      description: 'Reagir menos, entender mais',
    ),
    _ContextOption(
      key: 'decisao_dificil',
      description: 'Encontrar firmeza na incerteza',
    ),
  ];

  // Subtítulos orientados ao benefício, não ao conceito filosófico
  late final List<_VoiceOption> _voiceOptions = [
    const _VoiceOption(
      label: 'Sêneca',
      subtitle: 'direto ao ponto, sem rodeios',
      authors: {'Sêneca'},
    ),
    const _VoiceOption(
      label: 'Epicteto',
      subtitle: 'foco no que você pode controlar',
      authors: {'Epicteto'},
    ),
    const _VoiceOption(
      label: 'Marco Aurélio',
      subtitle: 'reflexão e autoconsciência',
      authors: {'Marco Aurélio'},
    ),
    _VoiceOption(
      label: kMixedAuthorsLabel,
      subtitle: 'variedade de perspectivas',
      authors: kAethorAuthors.toSet(),
    ),
  ];

  final List<_TimeOption> _timeOptions = const [
    _TimeOption(value: '07:30', label: 'Manhã'),
    _TimeOption(value: '12:30', label: 'Almoço'),
    _TimeOption(value: '20:30', label: 'Noite'),
    _TimeOption(value: 'custom', label: 'Outro horário'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedAuthors = kAethorAuthors.toSet();
  }

  void _goNext() {
    if (_stepIndex >= _totalSteps - 1) return;
    setState(() => _stepIndex += 1);
  }

  void _goBack() {
    if (_stepIndex == 0) return;
    // Usuário pulou o step de horário: voltar ao step de lembrete
    if (_stepIndex == 5 && _skipTimeStep) {
      setState(() => _stepIndex = 3);
      return;
    }
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

  String _summaryVoice() {
    if (_selectedAuthors.length == kAethorAuthors.length) {
      return kMixedAuthorsLabel;
    }
    return _selectedVoiceLabel;
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
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Como funciona',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cormorant Garamond',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Simples. Direto. Todo dia.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AethorColors.textMuted,
                      ),
                ),
                const SizedBox(height: 16),
                const _BulletItem(
                  text:
                      'Uma citação verificada de Sêneca, Epicteto ou Marco Aurélio — não frases de internet.',
                ),
                const _BulletItem(
                  text:
                      'Uma ação prática para aplicar hoje, no contexto que você escolher.',
                ),
                const _BulletItem(
                  text:
                      'Sem quiz infinito. Sem gamificação. Só prática real, todo dia.',
                ),
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
                  child: const Text(
                    '"A filosofia não está nas palavras, mas nos atos."\n— Sêneca',
                    style: TextStyle(
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
        return _buildReminder(context);
      case 4:
        return _buildTime(context);
      default:
        return _buildDone(context);
    }
  }

  Widget _buildIntro(BuildContext context) {
    return _StepContent(
      leading: const _BrandHeader(),
      title: 'Menos reação.\nMais intenção.',
      subtitle: '1 citação verificada. 1 ação para hoje.',
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PreviewCard(
            quote:
                '"Não são os acontecimentos que nos perturbam, mas a interpretação que fazemos deles."',
            author: 'Epicteto',
            action: 'Reescreva um fato recente sem usar adjetivos.',
          ),
        ],
      ),
      primaryAction: _PrimaryButton(
        label: 'Começar agora',
        onPressed: _goNext,
      ),
      secondaryAction: _TextLink(
        label: 'Ver como funciona',
        onPressed: _showHowItWorks,
      ),
    );
  }

  Widget _buildContext(BuildContext context) {
    final hasSelection = _selectedContext != null;

    return _StepContent(
      title: 'Qual área você quer fortalecer agora?',
      subtitle: 'Isso personaliza o insight de hoje.',
      helperText: hasSelection ? null : 'Escolha uma opção para continuar.',
      body: Column(
        children: _contextOptions.map((option) {
          final label = contextLabel(option.key);
          final selected = _selectedContext == option.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: AethorSpacing.md),
            child: _OptionCard(
              title: label,
              subtitle: option.description,
              selected: selected,
              onTap: () => setState(() => _selectedContext = option.key),
            ),
          );
        }).toList(),
      ),
      primaryAction: _PrimaryButton(
        label: 'Continuar',
        enabled: hasSelection,
        onPressed: hasSelection ? _goNext : null,
      ),
      secondaryAction: _TextLink(
        label: 'Escolher depois',
        onPressed: _goNext,
      ),
    );
  }

  Widget _buildVoice(BuildContext context) {
    return _StepContent(
      title: 'Escolha o autor que guia sua prática',
      subtitle: 'Você pode trocar a qualquer momento nos ajustes.',
      body: Column(
        children: _voiceOptions.map((option) {
          final selected = _selectedVoiceLabel == option.label;
          return Padding(
            padding: const EdgeInsets.only(bottom: AethorSpacing.md),
            child: _OptionCard(
              title: option.label,
              subtitle: option.subtitle,
              selected: selected,
              onTap: () {
                setState(() {
                  _selectedVoiceLabel = option.label;
                  _selectedAuthors = option.authors;
                });
              },
            ),
          );
        }).toList(),
      ),
      primaryAction: _PrimaryButton(
        label: 'Continuar',
        onPressed: _goNext,
      ),
      secondaryAction: _TextLink(
        label: 'Escolher depois',
        onPressed: _goNext,
      ),
    );
  }

  Widget _buildReminder(BuildContext context) {
    return _StepContent(
      centered: true,
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
      title: 'Mantenha o ritmo.',
      subtitle:
          'Um lembrete diário no horário que você escolher — nada além disso.',
      body: Text(
        'Você vai autorizar no próximo passo.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AethorColors.textMuted,
            ),
      ),
      primaryAction: _PrimaryButton(
        label: 'Ativar lembretes',
        onPressed: () async {
          bool granted = true;
          if (widget.onRequestNotificationPermission != null) {
            granted = await widget.onRequestNotificationPermission!();
          }
          if (!mounted) return;
          if (granted) {
            setState(() {
              _remindersEnabled = true;
              _skipTimeStep = false;
            });
            _goNext();
          } else {
            // Permissão negada pelo sistema: pular horário e ir direto ao fim
            setState(() {
              _remindersEnabled = false;
              _skipTimeStep = true;
              _stepIndex = 5;
            });
          }
        },
      ),
      // TextLink mantém hierarquia visual consistente com os outros steps
      secondaryAction: _TextLink(
        label: 'Agora não',
        onPressed: () {
          setState(() {
            _remindersEnabled = false;
            _skipTimeStep = true;
            _stepIndex = 5;
          });
        },
      ),
    );
  }

  Widget _buildTime(BuildContext context) {
    final hasSelection = _selectedTime != null;

    return _StepContent(
      title: 'Defina seu horário de prática',
      subtitle: 'Escolha o horário do seu lembrete diário.',
      body: Column(
        children: _timeOptions.map((option) {
          final isCustom = option.value == 'custom';
          final selected = isCustom
              ? _selectedTime != null && !_isPresetTime()
              : _selectedTime == option.value;
          final subtitle = isCustom
              ? (_selectedTime != null && !_isPresetTime()
                  ? 'Selecionado: $_selectedTime'
                  : null)
              : option.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AethorSpacing.md),
            child: _OptionCard(
              title: option.label,
              subtitle: subtitle,
              selected: selected,
              onTap: () async {
                if (isCustom) {
                  await _pickCustomTime();
                } else {
                  setState(() => _selectedTime = option.value);
                }
              },
            ),
          );
        }).toList(),
      ),
      footer: Padding(
        padding: const EdgeInsets.only(top: AethorSpacing.xs),
        child: Text(
          'Fuso horário: ${_readableTimezone(widget.state.timezone)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AethorColors.textSubtle,
              ),
        ),
      ),
      primaryAction: _PrimaryButton(
        label: 'Salvar horário',
        enabled: hasSelection,
        onPressed: hasSelection ? _goNext : null,
      ),
      secondaryAction: _TextLink(
        label: 'Definir depois',
        onPressed: () {
          setState(() => _selectedTime = null);
          _goNext();
        },
      ),
    );
  }

  bool _isPresetTime() {
    return _timeOptions
        .where((option) => option.value != 'custom')
        .any((option) => option.value == _selectedTime);
  }

  Widget _buildDone(BuildContext context) {
    final chips = <Widget>[
      if (_selectedContext != null)
        _SummaryChip(label: 'Área: ${contextLabel(_selectedContext!)}'),
      _SummaryChip(label: 'Voz: ${_summaryVoice()}'),
      if (_selectedTime != null)
        _SummaryChip(label: 'Horário: $_selectedTime'),
      if (_remindersEnabled) const _SummaryChip(label: 'Lembrete: ativo'),
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
      title: 'Pronto. Seu primeiro dia está preparado.',
      subtitle: 'Sem pressa. Um passo de cada vez.',
      body: hasChips
          ? Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: chips,
            )
          : Text(
              'Você pode personalizar sua experiência a qualquer momento nos ajustes.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AethorColors.textMuted,
                    height: 1.5,
                  ),
            ),
      primaryAction: _PrimaryButton(
        label: 'Ver meu primeiro insight',
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
  });

  final double progress;
  final Key stepKey;
  final int currentStep;
  final int totalSteps;
  final Widget child;
  final bool showBack;
  final VoidCallback? onBack;

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
              child: _ProgressBar(
                value: progress,
                currentStep: currentStep,
                totalSteps: totalSteps,
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
                  tooltip: 'Voltar',
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
    this.footer,
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
  final Widget? footer;

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
                  if (footer != null) ...[
                    const SizedBox(height: AethorSpacing.md),
                    footer!,
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
  });

  final double value;
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Passo $currentStep de $totalSteps',
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
        const Text(
          'AETHOR',
          style: TextStyle(
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
            'Hoje, para começar',
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
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: AethorSpacing.xs),
          Text(
            '— $author',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AethorColors.copper,
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
            'Ação de hoje',
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
// Data models
// ---------------------------------------------------------------------------

class _ContextOption {
  const _ContextOption({required this.key, required this.description});

  final String key;
  final String description;
}

class _VoiceOption {
  const _VoiceOption({
    required this.label,
    required this.subtitle,
    required this.authors,
  });

  final String label;
  final String subtitle;
  final Set<String> authors;
}

class _TimeOption {
  const _TimeOption({required this.value, required this.label});

  final String value;
  final String label;
}

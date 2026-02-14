import 'package:flutter/material.dart';

import '../../../app_state.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/design_tokens.dart';
import '../../../core/domain/authors.dart';
import '../../../core/domain/context_labels.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.state});

  final AppState state;

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

  final List<_ContextOption> _contextOptions = const [
    _ContextOption(key: 'ansiedade'),
    _ContextOption(key: 'foco'),
    _ContextOption(key: 'trabalho'),
    _ContextOption(key: 'relacionamentos'),
    _ContextOption(key: 'decisao_dificil'),
  ];

  late final List<_VoiceOption> _voiceOptions = [
    _VoiceOption(
      label: 'Sêneca',
      subtitle: 'prático e direto',
      authors: const {'Sêneca'},
    ),
    _VoiceOption(
      label: 'Epicteto',
      subtitle: 'disciplina interna',
      authors: const {'Epicteto'},
    ),
    _VoiceOption(
      label: 'Marco Aurélio',
      subtitle: 'introspecção e dever',
      authors: const {'Marco Aurélio'},
    ),
    _VoiceOption(
      label: kMixedAuthorsLabel,
      subtitle: 'alternar autores',
      authors: kStoicAuthors.toSet(),
    ),
  ];

  final List<_TimeOption> _timeOptions = const [
    _TimeOption(value: '07:30', label: 'Manhã'),
    _TimeOption(value: '12:30', label: 'Almoço'),
    _TimeOption(value: '20:30', label: 'Noite'),
    _TimeOption(value: 'custom', label: 'Escolher outro'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedAuthors = kStoicAuthors.toSet();
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
    final initial = _parseTime(_selectedTime) ?? const TimeOfDay(hour: 7, minute: 30);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(primary: StoicColors.deepBlue),
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
    if (_selectedAuthors.length == kStoicAuthors.length) {
      return kMixedAuthorsLabel;
    }
    return _selectedVoiceLabel;
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
      backgroundColor: StoicColors.cardBackground,
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
              children: const [
                Text(
                  'Como funciona',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cormorant Garamond',
                  ),
                ),
                SizedBox(height: 12),
                _BulletItem(text: 'Receba um insight estoico direto ao ponto.'),
                _BulletItem(text: 'Aplique uma ação prática em poucos minutos.'),
                _BulletItem(text: 'Feche o dia com mais intenção.'),
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
        return _buildTime(context);
      case 4:
        return _buildReminder(context);
      default:
        return _buildDone(context);
    }
  }

  Widget _buildIntro(BuildContext context) {
    return _StepContent(
      title: 'Menos reação.\nMais intenção.',
      subtitle: '1 insight estoico e 1 ação prática em poucos minutos.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _PreviewCard(
            insight: 'Fatos antes de julgamentos.',
            action: 'Descreva uma situação só com fatos.',
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
            padding: const EdgeInsets.only(bottom: StoicSpacing.md),
            child: _OptionCard(
              title: label,
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
      title: 'Escolha a voz que vai te acompanhar',
      subtitle: 'Você pode trocar depois.',
      body: Column(
        children: _voiceOptions.map((option) {
          final selected = _selectedVoiceLabel == option.label;
          return Padding(
            padding: const EdgeInsets.only(bottom: StoicSpacing.md),
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

  Widget _buildTime(BuildContext context) {
    final hasSelection = _selectedTime != null;

    return _StepContent(
      title: 'Defina seu horário de prática',
      subtitle: 'Você pode alterar depois em Ajustes.',
      body: Column(
        children: _timeOptions.map((option) {
          final isCustom = option.value == 'custom';
          final selected =
              isCustom ? _selectedTime != null && !_isPresetTime() : _selectedTime == option.value;
          final subtitle = isCustom
              ? (_selectedTime != null && !_isPresetTime() ? 'Selecionado: $_selectedTime' : null)
              : option.label;
          return Padding(
            padding: const EdgeInsets.only(bottom: StoicSpacing.md),
            child: _OptionCard(
              title: option.value == 'custom' ? option.label : option.value,
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
        padding: const EdgeInsets.only(top: StoicSpacing.xs),
        child: Text(
          'Fuso horário: ${widget.state.timezone}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: StoicColors.textSubtle,
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

  Widget _buildReminder(BuildContext context) {
    return _StepContent(
      title: 'Quer um lembrete diário?',
      subtitle: 'Um lembrete curto ajuda a manter consistência.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: StoicColors.mist,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: StoicColors.deepBlue,
              size: 32,
            ),
          ),
          const SizedBox(height: StoicSpacing.lg),
          Text(
            'No próximo passo o sistema vai pedir permissão.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: StoicColors.textMuted,
                ),
          ),
        ],
      ),
      primaryAction: _PrimaryButton(
        label: 'Ativar lembretes',
        onPressed: () {
          setState(() => _remindersEnabled = true);
          _goNext();
        },
      ),
      secondaryAction: _SecondaryButton(
        label: 'Agora não',
        onPressed: () {
          setState(() => _remindersEnabled = false);
          _goNext();
        },
      ),
    );
  }

  Widget _buildDone(BuildContext context) {
    final summaryArea = _selectedContext == null
        ? 'Não definido'
        : contextLabel(_selectedContext!);
    final summaryTime = _selectedTime ?? 'Não definido';

    return _StepContent(
      title: 'Pronto. Seu primeiro dia está preparado.',
      subtitle: 'Sem pressa. Um passo de cada vez.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SummaryChip(label: 'Área: $summaryArea'),
              _SummaryChip(label: 'Voz: ${_summaryVoice()}'),
              _SummaryChip(label: 'Horário: $summaryTime'),
            ],
          ),
        ],
      ),
      primaryAction: _PrimaryButton(
        label: 'Ver meu primeiro insight',
        onPressed: _completeOnboarding,
      ),
      secondaryAction: _TextLink(
        label: 'Explorar o app',
        onPressed: _completeOnboarding,
      ),
    );
  }
}

class _OnboardingScaffold extends StatelessWidget {
  const _OnboardingScaffold({
    required this.progress,
    required this.child,
    this.showBack = true,
    this.onBack,
  });

  final double progress;
  final Widget child;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoicColors.screenBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: StoicSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ProgressBar(value: progress),
            ),
            if (showBack)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 20, 0),
                child: TextButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Voltar'),
                  style: TextButton.styleFrom(
                    foregroundColor: StoicColors.textPrimary,
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({
    required this.title,
    required this.subtitle,
    required this.body,
    this.primaryAction,
    this.secondaryAction,
    this.helperText,
    this.footer,
  });

  final String title;
  final String subtitle;
  final String? helperText;
  final Widget body;
  final Widget? primaryAction;
  final Widget? secondaryAction;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: StoicSpacing.sm),
          Text(
            subtitle,
            style: textTheme.bodyLarge?.copyWith(
              color: StoicColors.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: StoicSpacing.lg),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  body,
                  if (helperText != null) ...[
                    const SizedBox(height: StoicSpacing.sm),
                    Text(
                      helperText!,
                      style: textTheme.bodySmall?.copyWith(
                        color: StoicColors.textMuted,
                      ),
                    ),
                  ],
                  if (footer != null) ...[
                    const SizedBox(height: StoicSpacing.md),
                    footer!,
                  ],
                ],
              ),
            ),
          ),
          if (primaryAction != null) ...[
            const SizedBox(height: StoicSpacing.sm),
            primaryAction!,
          ],
          if (secondaryAction != null) ...[
            const SizedBox(height: StoicSpacing.sm),
            secondaryAction!,
          ],
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final clamped = value.clamp(0.05, 1.0).toDouble();
        final width = constraints.maxWidth * clamped;
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: width,
            height: 4,
            decoration: BoxDecoration(
              color: StoicColors.copper,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      },
    );
  }
}

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
        selected ? StoicColors.deepBlue : StoicColors.cardOutline;

    return StoicPressScale(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(StoicRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: StoicSpacing.lg,
            vertical: StoicSpacing.md,
          ),
          decoration: BoxDecoration(
            color: StoicColors.cardBackground,
            borderRadius: BorderRadius.circular(StoicRadius.lg),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontFamily: 'Cormorant Garamond',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: StoicColors.textMuted,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              _SelectionIndicator(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

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
          color: selected ? StoicColors.deepBlue : StoicColors.cardOutline,
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
              color: StoicColors.deepBlue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.insight, required this.action});

  final String insight;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(StoicSpacing.lg),
      decoration: BoxDecoration(
        color: StoicColors.cardBackground,
        borderRadius: BorderRadius.circular(StoicRadius.lg),
        border: Border.all(color: StoicColors.cardOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoje, para começar',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: StoicColors.textSubtle,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: StoicSpacing.sm),
          Text(
            'Insight',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: StoicColors.textMuted,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            insight,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: StoicSpacing.md),
          Text(
            'Ação',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: StoicColors.textMuted,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            action,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: StoicColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

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
      child: StoicPressScale(
        enabled: enabled,
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          child: Text(label),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
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
        color: StoicColors.cardBackground,
        borderRadius: BorderRadius.circular(StoicRadius.pill),
        border: Border.all(color: StoicColors.cardOutline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: StoicColors.textSecondary,
            ),
      ),
    );
  }
}

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
              color: StoicColors.copper,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: StoicColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextOption {
  const _ContextOption({required this.key});

  final String key;
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

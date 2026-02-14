import 'package:flutter/material.dart';

import '../../../app_state.dart';
import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/design_tokens.dart';
import '../../../core/domain/authors.dart';
import '../../../core/domain/context_labels.dart';
import '../../../core/paywall/paywall_flow.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.state});

  final AppState state;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _authors = kStoicAuthors;
  late Set<String> _selectedAuthors;

  @override
  void initState() {
    super.initState();
    _selectedAuthors = {...widget.state.preferredAuthors};
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.preferredAuthors != widget.state.preferredAuthors) {
      _selectedAuthors = {...widget.state.preferredAuthors};
    }
  }

  String _timezoneLabel(String timezone) {
    return switch (timezone) {
      'America/Sao_Paulo' => 'Brasília (GMT-3)',
      'America/Rio_Branco' => 'Rio Branco (GMT-5)',
      _ => timezone,
    };
  }

  String _authorsSummary() {
    if (_selectedAuthors.length == _authors.length) {
      return 'Todos (Modo Misto)';
    }
    if (_selectedAuthors.isEmpty) {
      return 'Nenhum';
    }
    return 'Personalizado';
  }

  Future<void> _showTimezonePicker() async {
    const timezones = <String>[
      'America/Sao_Paulo',
      'America/Rio_Branco',
    ];

    final selected = await _showSingleSelect(
      title: 'Fuso Horário',
      options: timezones,
      labelBuilder: _timezoneLabel,
      currentValue: widget.state.timezone,
    );

    if (selected != null) {
      widget.state.setTimezone(selected);
      await widget.state.bootstrap();
    }
  }

  Future<void> _showContextPicker() async {
    const contexts = <String>[
      'trabalho',
      'relacionamentos',
      'ansiedade',
      'foco',
      'decisao_dificil',
    ];

    final selected = await _showSingleSelect(
      title: 'Contexto Preferencial',
      options: contexts,
      labelBuilder: contextLabel,
      currentValue: widget.state.preferredContext,
    );

    if (selected != null) {
      await widget.state.setPreferredContext(selected);
    }
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

  Future<void> _showReminderTimePicker() async {
    final initial = _parseTime(widget.state.reminderTime) ??
        const TimeOfDay(hour: 8, minute: 0);
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

    if (picked != null) {
      widget.state.setReminderTime(_formatTime(picked));
    }
  }

  Future<void> _showAuthorPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: StoicColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Autores Preferidos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ..._authors.map(
                      (author) => CheckboxListTile(
                        value: _selectedAuthors.contains(author),
                        dense: true,
                        activeColor: StoicColors.deepBlue,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        title: Text(
                          author,
                          style: const TextStyle(
                            fontSize: 14,
                            color: StoicColors.obsidian,
                          ),
                        ),
                        onChanged: (selected) {
                          setModalState(() {
                            if (selected ?? false) {
                              _selectedAuthors.add(author);
                            } else {
                              _selectedAuthors.remove(author);
                            }
                          });
                          setState(() {});
                          widget.state.setPreferredAuthors(_selectedAuthors);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: StoicPressScale(
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Concluir'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmResetOnboarding() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: StoicColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Resetar onboarding?'),
          content: const Text(
            'Isso reabre o fluxo inicial e limpa as preferências de onboarding.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Resetar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await widget.state.resetOnboarding();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Onboarding será exibido ao reabrir o app.'),
      ),
    );
  }

  Future<T?> _showSingleSelect<T>({
    required String title,
    required List<T> options,
    required String Function(T) labelBuilder,
    required T currentValue,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: StoicColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                ...options.map(
                  (option) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(labelBuilder(option)),
                    trailing: option == currentValue
                        ? const Icon(Icons.check_rounded, color: StoicColors.copper)
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
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
    final reminderTime = widget.state.reminderTime ?? '08:00';
    final permissionDenied =
        widget.state.notificationPermission == NotificationPermissionStatus.denied;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Text(
          'Ajustes',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontFamily: 'Cormorant Garamond',
                fontSize: 48,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: StoicColors.obsidian,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'CONFIGURAÇÕES E PREFERÊNCIAS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 11,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w400,
                color: StoicColors.textSubtle,
              ),
        ),
        const SizedBox(height: 32),
        _SettingsSection(
          title: 'Geral',
          child: Column(
            children: [
              _SettingsRow(
                icon: Icons.public,
                title: 'Fuso Horário',
                trailing: _timezoneLabel(widget.state.timezone),
                onTap: _showTimezonePicker,
                showDivider: true,
              ),
              _SettingsRow(
                icon: Icons.person_outline,
                title: 'Autores Preferidos',
                trailing: _authorsSummary(),
                onTap: _showAuthorPicker,
                showDivider: true,
              ),
              _SettingsRow(
                icon: Icons.calendar_month_outlined,
                title: 'Contexto Preferencial',
                subtitle: 'Personalize suas práticas',
                trailing: contextLabel(widget.state.preferredContext),
                onTap: _showContextPicker,
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _SettingsSection(
          title: 'Assinatura',
          child: SubscriptionSettingsCard(
            status: widget.state.subscriptionStatus,
            plan: widget.state.subscriptionPlan,
            trialEndsAt: widget.state.trialEndsAt,
            nextBillingDate: widget.state.nextBillingDate,
            onViewPlans: () => PaywallFlow.showPaywall(
              context,
              state: widget.state,
              trigger: PaywallTrigger.manual,
            ),
            onManage: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gerencie sua assinatura na App Store/Play Store.'),
                ),
              );
            },
            onRestore: () => PaywallFlow.showRestore(context, state: widget.state),
          ),
        ),
        const SizedBox(height: 32),
        _SettingsSection(
          title: 'Conteúdo',
          child: Column(
            children: [
              NotificationSettingRow(
                enabled: widget.state.remindersEnabled,
                time: reminderTime,
                timezone: _timezoneLabel(widget.state.timezone),
                systemPermissionDenied: permissionDenied,
                embedded: true,
                onToggle: () {
                  final next = !widget.state.remindersEnabled;
                  widget.state.setRemindersEnabled(next);
                  if (next && widget.state.reminderTime == null) {
                    widget.state.setReminderTime('08:00');
                  }
                },
                onTimeTap: _showReminderTimePicker,
                onOpenSystemSettings: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Abra as configurações do sistema para permitir notificações.'),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: StoicColors.rowDivider),
              _SettingsRow(
                icon: Icons.verified_outlined,
                title: 'Fontes Verificadas',
                trailing: 'Sempre',
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _SettingsSection(
          title: 'QA',
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fluxo inicial',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: StoicColors.obsidian,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Reabra o onboarding para testes.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: StoicColors.textMuted,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _confirmResetOnboarding,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Resetar onboarding'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Column(
          children: [
            Text(
              'Figma Make • Versão Protótipo 1.0.0',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: StoicColors.textSubtle,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Foco na filosofia prática e ação consciente.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: StoicColors.textMuted,
                  ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 137,
              height: 48,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: StoicColors.mutedButtonBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Sair da conta',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: StoicColors.stone,
                      ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: StoicColors.textSubtle,
                ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: StoicColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
    required this.showDivider,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final rowContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints(minHeight: subtitle == null ? 56 : 72),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(
                  color: StoicColors.rowDivider,
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment:
            subtitle == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Icon(icon, size: 24, color: StoicColors.obsidian),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: StoicColors.obsidian,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                            color: StoicColors.textSubtle,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trailing,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: StoicColors.textMuted,
                      ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: StoicColors.textSubtle,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return rowContent;
    }

    return InkWell(
      onTap: onTap,
      child: rowContent,
    );
  }
}

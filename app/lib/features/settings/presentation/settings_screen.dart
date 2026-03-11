import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app_state.dart';
import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/aethor_icons.dart';
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
  final List<String> _authors = kAethorAuthors;
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

  /// Detecta automaticamente o fuso horário do dispositivo.
  /// Mapeia o offset UTC para o timezone IANA mais próximo.
  String _detectDeviceTimezone() {
    final offset = DateTime.now().timeZoneOffset;
    if (offset.inHours == -5) return 'America/Rio_Branco';
    return 'America/Sao_Paulo';
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

    // Detecta automaticamente o timezone e oferece como primeiro item se diferente
    final detected = _detectDeviceTimezone();
    final detectedLabel =
        '${_timezoneLabel(detected)} (detectado automaticamente)';

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AethorColors.cardBackground,
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
                  'Fuso Horário',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                // Opção de detecção automática
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(detectedLabel),
                  trailing: detected == widget.state.timezone
                      ? const Icon(AethorIcons.check, color: AethorColors.copper)
                      : null,
                  onTap: () => Navigator.of(context).pop(detected),
                ),
                const Divider(height: 1, color: AethorColors.rowDivider),
                ...timezones.map(
                  (tz) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_timezoneLabel(tz)),
                    trailing: tz == widget.state.timezone
                        ? const Icon(AethorIcons.check, color: AethorColors.copper)
                        : null,
                    onTap: () => Navigator.of(context).pop(tz),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                .copyWith(primary: AethorColors.deepBlue),
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
      backgroundColor: AethorColors.cardBackground,
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
                        activeColor: AethorColors.deepBlue,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        title: Text(
                          author,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AethorColors.obsidian,
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
                      child: AethorPressScale(
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

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AethorColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Sair da conta?'),
          content: const Text(
            'Seus check-ins e favoritos estão salvos na nuvem e serão restaurados ao entrar novamente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AethorColors.error,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    widget.state.markAuthenticated(false);
  }

  Future<void> _showPushDiagnostic() async {
    String apnsToken;
    String fcmToken;
    try {
      apnsToken = await FirebaseMessaging.instance.getAPNSToken() ?? '(null)';
    } catch (e) {
      apnsToken = '(erro: $e)';
    }
    try {
      fcmToken = await FirebaseMessaging.instance.getToken() ?? '(null)';
    } catch (e) {
      fcmToken = '(erro: $e)';
    }
    final permission = widget.state.notificationPermission.name;
    final pushEnabled = widget.state.pushNotificationsEnabled;
    final fcmTokenCopy = fcmToken;

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        String registerResult = '';
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: AethorColors.cardBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Diagnóstico Push'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Permissão: $permission', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Push habilitado: $pushEnabled', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                  const Text('APNs Token:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  SelectableText(apnsToken, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  const SizedBox(height: 12),
                  const Text('FCM Token:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  SelectableText(fcmTokenCopy, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  if (registerResult.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Registro backend:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(registerResult, style: const TextStyle(fontSize: 12)),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  setDialogState(() => registerResult = 'Enviando...');
                  try {
                    await widget.state.api.post(
                      '/v1/push-tokens',
                      body: {'fcm_token': fcmTokenCopy, 'platform': 'ios'},
                    );
                    setDialogState(() => registerResult = '✓ Sucesso');
                  } catch (e) {
                    setDialogState(() => registerResult = '✗ Erro: $e');
                  }
                },
                child: const Text('Registrar'),
              ),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: fcmTokenCopy));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('FCM token copiado!')),
                  );
                },
                child: const Text('Copiar FCM'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
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
          backgroundColor: AethorColors.cardBackground,
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
      backgroundColor: AethorColors.cardBackground,
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
                        ? const Icon(AethorIcons.check,
                            color: AethorColors.copper)
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
    final permissionDenied = widget.state.notificationPermission ==
        NotificationPermissionStatus.denied;
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
                color: AethorColors.obsidian,
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
                color: AethorColors.textSubtle,
              ),
        ),
        const SizedBox(height: 32),
        _SettingsSection(
          title: 'Geral',
          child: Column(
            children: [
              _SettingsRow(
                icon: AethorIcons.globe,
                title: 'Fuso Horário',
                trailing: _timezoneLabel(widget.state.timezone),
                onTap: _showTimezonePicker,
                showDivider: true,
              ),
              _SettingsRow(
                icon: AethorIcons.user,
                title: 'Autores Preferidos',
                trailing: _authorsSummary(),
                onTap: _showAuthorPicker,
                showDivider: true,
              ),
              _SettingsRow(
                icon: AethorIcons.calendar,
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
                  content:
                      Text('Gerencie sua assinatura na App Store/Play Store.'),
                ),
              );
            },
            onRestore: () =>
                PaywallFlow.showRestore(context, state: widget.state),
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
                      content: Text(
                          'Abra as configurações do sistema para permitir notificações.'),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: AethorColors.rowDivider),
              const _SettingsRow(
                icon: AethorIcons.verified,
                title: 'Fontes Verificadas',
                trailing: 'Sempre',
                showDivider: false,
              ),
            ],
          ),
        ),
        // Seção QA visível apenas em builds de debug
        if (kDebugMode) ...[
          const SizedBox(height: 32),
          _SettingsSection(
            title: 'QA (debug)',
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
                          color: AethorColors.obsidian,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Reabra o onboarding para testes.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AethorColors.textMuted,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _confirmResetOnboarding,
                      icon: const Icon(AethorIcons.refresh),
                      label: const Text('Resetar onboarding'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),
        Column(
          children: [
            GestureDetector(
              onLongPress: _showPushDiagnostic,
              child: Text(
                'Aethor • Versão 1.0.0',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      color: AethorColors.textSubtle,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Clareza para agir.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AethorColors.textMuted,
                  ),
            ),
            const SizedBox(height: 8),
            Semantics(
              button: true,
              label: 'Sair da conta',
              child: SizedBox(
                width: 137,
                height: 48,
                child: TextButton(
                  onPressed: widget.state.isAuthenticated ? _confirmLogout : null,
                  style: TextButton.styleFrom(
                    backgroundColor: AethorColors.mutedButtonBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Sair da conta',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AethorColors.stone,
                        ),
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
                  color: AethorColors.textSubtle,
                ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AethorColors.cardBackground,
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
                  color: AethorColors.rowDivider,
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: subtitle == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Icon(icon, size: 24, color: AethorColors.obsidian),
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
                          color: AethorColors.obsidian,
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
                            color: AethorColors.textSubtle,
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
                        color: AethorColors.textMuted,
                      ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  AethorIcons.chevronRight,
                  color: AethorColors.textSubtle,
                  size: AethorIconSize.sm,
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

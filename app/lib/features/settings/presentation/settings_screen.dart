import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app_state.dart';
import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/aethor_icons.dart';
import '../../../core/design_system/tokens/design_tokens.dart';
import '../../../core/domain/authors.dart';
import '../../../core/domain/context_labels.dart';
import '../../../core/auth/auth_flow.dart';
import '../../../core/auth/auth_models.dart';
import '../../../core/paywall/paywall_flow.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.state});

  final AppState state;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _authors = kAethorAuthors;
  late Set<String> _selectedAuthors;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _selectedAuthors = {...widget.state.preferredAuthors};
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _appVersion = info.version);
    });
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.preferredAuthors != widget.state.preferredAuthors) {
      _selectedAuthors = {...widget.state.preferredAuthors};
    }
  }

  String _timezoneLabel(String timezone, AppLocalizations l10n) {
    return switch (timezone) {
      'America/Sao_Paulo' => l10n.settingsTzBrasilia,
      'America/Rio_Branco' => l10n.settingsTzRioBranco,
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

  String _authorsSummary(AppLocalizations l10n) {
    if (_selectedAuthors.length == _authors.length) {
      return l10n.settingsAuthorsAll;
    }
    if (_selectedAuthors.isEmpty) {
      return l10n.settingsAuthorsNone;
    }
    return l10n.settingsAuthorsCustom;
  }

  Future<void> _showLanguagePicker(AppLocalizations l10n) async {
    final options = <({String code, String label})>[
      (code: 'pt', label: l10n.languagePt),
      (code: 'en', label: l10n.languageEn),
      (code: 'es', label: l10n.languageEs),
    ];

    await showModalBottomSheet<void>(
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
                  l10n.settingsLanguagePickerTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                ...options.map(
                  (opt) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(opt.label),
                    trailing: widget.state.locale == opt.code
                        ? const Icon(AethorIcons.check, color: AethorColors.copper)
                        : null,
                    onTap: () {
                      widget.state.setLocale(opt.code);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const Divider(height: 1, color: AethorColors.rowDivider),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '🌐 Seguir idioma do dispositivo',
                    style: TextStyle(color: AethorColors.textMuted, fontSize: 14),
                  ),
                  trailing: widget.state.locale == null
                      ? const Icon(AethorIcons.check, color: AethorColors.copper)
                      : null,
                  onTap: () {
                    widget.state.setLocale(null);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showTimezonePicker() async {
    final l10n = AppLocalizations.of(context);
    const timezones = <String>[
      'America/Sao_Paulo',
      'America/Rio_Branco',
    ];

    final detected = _detectDeviceTimezone();
    final detectedLabel = l10n.settingsTimezoneAuto(_timezoneLabel(detected, l10n));

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AethorColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final innerL10n = AppLocalizations.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  innerL10n.settingsTimezone,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
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
                    title: Text(_timezoneLabel(tz, innerL10n)),
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

    final l10n = AppLocalizations.of(context);
    final selected = await _showSingleSelect(
      title: l10n.settingsPreferredContext,
      options: contexts,
      labelBuilder: (k) => localizedContextLabel(context, k),
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
                      AppLocalizations.of(context).settingsPreferredAuthors,
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
                          child: Text(AppLocalizations.of(context).actionDone),
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
        final dl10n = AppLocalizations.of(context);
        return AlertDialog(
          backgroundColor: AethorColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(dl10n.settingsLogoutDialogTitle),
          content: Text(dl10n.settingsLogoutDialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(dl10n.actionCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AethorColors.error,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(dl10n.actionSignOut),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await widget.state.signOut();
    if (!mounted) return;
    await AuthFlow.showLoginPrompt(
      context,
      state: widget.state,
      contextType: AuthPromptContext.sync,
      force: true,
    );
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
                child: const Text('Copiar FCM'),  // debug-only, stays hardcoded
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),  // debug-only
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
        final dl10n = AppLocalizations.of(context);
        return AlertDialog(
          backgroundColor: AethorColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(dl10n.settingsResetOnboardingTitle),
          content: Text(dl10n.settingsResetOnboardingMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(dl10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(dl10n.actionReset),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await widget.state.resetOnboarding();
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsResetOnboardingSuccess)),
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
    final l10n = AppLocalizations.of(context);
    final reminderTime = widget.state.reminderTime ?? '08:00';
    final permissionDenied = widget.state.notificationPermission ==
        NotificationPermissionStatus.denied;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Text(
          l10n.settingsTitle,
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
          l10n.settingsSubtitle,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 11,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w400,
                color: AethorColors.textSubtle,
              ),
        ),
        const SizedBox(height: 32),
        _SettingsSection(
          title: l10n.settingsSectionGeneral,
          child: Column(
            children: [
              _SettingsRow(
                icon: AethorIcons.globe,
                title: l10n.settingsTimezone,
                trailing: _timezoneLabel(widget.state.timezone, l10n),
                onTap: _showTimezonePicker,
                showDivider: true,
              ),
              _SettingsRow(
                icon: AethorIcons.globe,
                title: l10n.settingsLanguage,
                trailing: switch (widget.state.locale) {
                  'en' => l10n.languageEn,
                  'es' => l10n.languageEs,
                  _ => l10n.languagePt,
                },
                onTap: () => _showLanguagePicker(l10n),
                showDivider: true,
              ),
              _SettingsRow(
                icon: AethorIcons.user,
                title: l10n.settingsPreferredAuthors,
                trailing: _authorsSummary(l10n),
                onTap: _showAuthorPicker,
                showDivider: true,
              ),
              _SettingsRow(
                icon: AethorIcons.calendar,
                title: l10n.settingsPreferredContext,
                subtitle: l10n.settingsPreferredContextSubtitle,
                trailing: localizedContextLabel(context, widget.state.preferredContext),
                onTap: _showContextPicker,
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _SettingsSection(
          title: l10n.settingsSectionSubscription,
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
                SnackBar(content: Text(l10n.settingsManageSubscriptionSnackbar)),
              );
            },
            onRestore: () =>
                PaywallFlow.showRestore(context, state: widget.state),
          ),
        ),
        const SizedBox(height: 32),
        _SettingsSection(
          title: l10n.settingsSectionContent,
          child: Column(
            children: [
              NotificationSettingRow(
                enabled: widget.state.remindersEnabled,
                time: reminderTime,
                timezone: _timezoneLabel(widget.state.timezone, l10n),
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
                    SnackBar(content: Text(l10n.settingsOpenSystemSettingsHint)),
                  );
                },
              ),
              const Divider(height: 1, color: AethorColors.rowDivider),
              _SettingsRow(
                icon: AethorIcons.verified,
                title: l10n.settingsVerifiedSources,
                trailing: l10n.settingsAlways,
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
                  const SizedBox(height: 20),
                  Text(
                    'Diagnóstico IAP',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AethorColors.obsidian,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Builder(builder: (context) {
                    final ps = widget.state.purchaseService;
                    if (ps == null) {
                      return const Text('PurchaseService: null',
                          style: TextStyle(fontSize: 12, color: Colors.red));
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('isAvailable: ${ps.available}',
                            style: TextStyle(
                                fontSize: 12,
                                color: ps.available ? Colors.green : Colors.red)),
                        Text('productsLoaded: ${ps.productsLoaded}',
                            style: TextStyle(
                                fontSize: 12,
                                color: ps.productsLoaded ? Colors.green : Colors.orange)),
                        if (ps.notFoundIds.isNotEmpty)
                          Text('notFound: ${ps.notFoundIds}',
                              style: const TextStyle(fontSize: 12, color: Colors.red)),
                        if (ps.queryError != null)
                          Text('error: ${ps.queryError!.message}',
                              style: const TextStyle(fontSize: 12, color: Colors.red)),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await widget.state.purchaseService?.reload();
                        if (context.mounted) setState(() {});
                      },
                      child: const Text('Reload produtos IAP'),
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
                l10n.appVersion(_appVersion.isEmpty ? '—' : _appVersion),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      color: AethorColors.textSubtle,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.appTagline,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AethorColors.textMuted,
                  ),
            ),
            const SizedBox(height: 8),
            Semantics(
              button: true,
              label: l10n.settingsLogout,
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
                    l10n.settingsLogout,
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

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens/aethor_icons.dart';
import '../tokens/design_tokens.dart';

class NotificationSettingRow extends StatelessWidget {
  const NotificationSettingRow({
    super.key,
    required this.enabled,
    required this.time,
    required this.timezone,
    required this.systemPermissionDenied,
    required this.onToggle,
    required this.onTimeTap,
    required this.onOpenSystemSettings,
    this.embedded = false,
  });

  final bool enabled;
  final String time;
  final String timezone;
  final bool systemPermissionDenied;
  final VoidCallback onToggle;
  final VoidCallback onTimeTap;
  final VoidCallback onOpenSystemSettings;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AethorColors.deepBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  AethorIcons.bell,
                  color: AethorColors.deepBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notificationSettingDailyReminder,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AethorColors.obsidian,
                          ),
                    ),
                    if (enabled && !systemPermissionDenied) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.notificationSettingDailySchedule} $time',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: AethorColors.textMuted,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              _ToggleSwitch(
                value: enabled && !systemPermissionDenied,
                onChanged: systemPermissionDenied ? null : (_) => onToggle(),
              ),
            ],
          ),
        ),
        if (systemPermissionDenied)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AethorColors.copper.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AethorRadius.md),
                border: Border.all(
                  color: AethorColors.copper.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(AethorIcons.warning,
                          size: 16, color: AethorColors.copper),
                      const SizedBox(width: 6),
                      Text(
                        l10n.notificationSettingPermissionDenied,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AethorColors.copper,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.notificationSettingEnableSystem,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: AethorColors.textMuted,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onOpenSystemSettings,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AethorColors.copper,
                        backgroundColor: Colors.white.withValues(alpha: 0.6),
                        side: BorderSide(
                          color: AethorColors.copper.withValues(alpha: 0.2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AethorRadius.sm),
                        ),
                      ),
                      child: Text(l10n.notificationSettingOpenSettings),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (enabled && !systemPermissionDenied)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(height: 1, color: AethorColors.border.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text(
                  l10n.notificationSettingTimeLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: AethorColors.stone.withValues(alpha: 0.5),
                      ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: onTimeTap,
                  borderRadius: BorderRadius.circular(AethorRadius.md),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AethorRadius.md),
                      border: Border.all(color: AethorColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          time,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const Icon(AethorIcons.chevronRight,
                            color: AethorColors.textSubtle),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.notificationSettingTimezoneLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: AethorColors.stone.withValues(alpha: 0.5),
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AethorRadius.md),
                    border: Border.all(color: AethorColors.border.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    timezone,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: AethorColors.textMuted,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.notificationSettingReminderInfo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: AethorColors.textSubtle,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
      ],
    );

    if (embedded) {
      return content;
    }

    return Container(
      decoration: BoxDecoration(
        color: AethorColors.cardBackground,
        borderRadius: BorderRadius.circular(AethorRadius.lg),
      ),
      child: content,
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  const _ToggleSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 50,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AethorColors.deepBlue : AethorColors.sand,
          borderRadius: BorderRadius.circular(99),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

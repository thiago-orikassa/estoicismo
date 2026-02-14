import 'package:flutter/material.dart';

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
                  color: StoicColors.deepBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: StoicColors.deepBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lembrete Diário',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: StoicColors.obsidian,
                          ),
                    ),
                    if (enabled && !systemPermissionDenied) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Todos os dias às $time',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: StoicColors.textMuted,
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
                color: StoicColors.copper.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: StoicColors.copper.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_rounded,
                          size: 16, color: StoicColors.copper),
                      const SizedBox(width: 6),
                      Text(
                        'Permissão negada',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: StoicColors.copper,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ative notificações nas configurações do sistema para receber lembretes.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: StoicColors.textMuted,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onOpenSystemSettings,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: StoicColors.copper,
                        backgroundColor: Colors.white.withValues(alpha: 0.6),
                        side: BorderSide(
                          color: StoicColors.copper.withValues(alpha: 0.2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Abrir Configurações'),
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
                Divider(height: 1, color: StoicColors.border.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text(
                  'HORÁRIO DO LEMBRETE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: StoicColors.textSubtle,
                      ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: onTimeTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: StoicColors.border),
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
                        const Icon(Icons.chevron_right_rounded,
                            color: StoicColors.textSubtle),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'FUSO HORÁRIO',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: StoicColors.textSubtle,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: StoicColors.border.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    timezone,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: StoicColors.textMuted,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Você receberá um lembrete todos os dias no horário escolhido.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: StoicColors.textSubtle,
                        height: 1.4,
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
        color: StoicColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
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
          color: value ? StoicColors.deepBlue : StoicColors.sand,
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

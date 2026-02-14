import 'package:flutter/material.dart';

enum NotificationPromptPlatform {
  ios,
  android,
}

class NotificationPrompt extends StatelessWidget {
  const NotificationPrompt({
    super.key,
    required this.platform,
    required this.onAllow,
    required this.onDeny,
  });

  final NotificationPromptPlatform platform;
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    return platform == NotificationPromptPlatform.ios
        ? _IosPrompt(onAllow: onAllow, onDeny: onDeny)
        : _AndroidPrompt(onAllow: onAllow, onDeny: onDeny);
  }
}

class _IosPrompt extends StatelessWidget {
  const _IosPrompt({required this.onAllow, required this.onDeny});

  final VoidCallback onAllow;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F6),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                Text(
                  '"Estoicismo Diário" quer enviar notificações',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: Colors.black,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Notificações podem incluir alertas, sons e emblemas de ícone. Isso pode ser configurado em Ajustes.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black54,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x1A000000)),
          SizedBox(
            height: 44,
            child: TextButton(
              onPressed: onDeny,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF007AFF),
                shape: const RoundedRectangleBorder(),
              ),
              child: const Text('Não Permitir'),
            ),
          ),
          const Divider(height: 1, color: Color(0x1A000000)),
          SizedBox(
            height: 44,
            child: TextButton(
              onPressed: onAllow,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF007AFF),
                shape: const RoundedRectangleBorder(),
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              child: const Text('Permitir'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AndroidPrompt extends StatelessWidget {
  const _AndroidPrompt({required this.onAllow, required this.onDeny});

  final VoidCallback onAllow;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 312,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permitir que Estoicismo Diário envie notificações?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'As notificações podem incluir alertas, sons e emblemas de ícone.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5F6368),
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDeny,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1A73E8),
                    textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  child: const Text('NÃO PERMITIR'),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: onAllow,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1A73E8),
                    textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  child: const Text('PERMITIR'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationPromptDialog extends StatelessWidget {
  const NotificationPromptDialog({
    super.key,
    required this.platform,
    required this.onAllow,
    required this.onDeny,
  });

  final NotificationPromptPlatform platform;
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: NotificationPrompt(
          platform: platform,
          onAllow: onAllow,
          onDeny: onDeny,
        ),
      ),
    );
  }
}

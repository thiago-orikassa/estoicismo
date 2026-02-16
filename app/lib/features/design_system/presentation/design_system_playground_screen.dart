import 'package:flutter/material.dart';

import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/tokens/design_tokens.dart';

class DesignSystemPlaygroundScreen extends StatefulWidget {
  const DesignSystemPlaygroundScreen({super.key});

  @override
  State<DesignSystemPlaygroundScreen> createState() =>
      _DesignSystemPlaygroundScreenState();
}

class _DesignSystemPlaygroundScreenState
    extends State<DesignSystemPlaygroundScreen> {
  bool _isFavorite = false;
  bool _showLoading = false;
  bool _showEmpty = false;
  bool _showError = false;
  bool _ctaLoading = false;
  AethorCheckinStatus _checkinStatus = AethorCheckinStatus.pending;

  final TextEditingController _noteController = TextEditingController(
    text: 'Hoje escolhi pausar antes de reagir.',
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sectionLabelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 11,
          letterSpacing: 0.8,
          color: AethorColors.stone.withValues(alpha: 0.4),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Design System Playground',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Validação visual dos componentes reutilizáveis do app.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        AethorCard(
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilterChip(
                selected: _showLoading,
                label: const Text('Loading'),
                onSelected: (v) => setState(() => _showLoading = v),
              ),
              FilterChip(
                selected: _showEmpty,
                label: const Text('Empty state'),
                onSelected: (v) => setState(() => _showEmpty = v),
              ),
              FilterChip(
                selected: _showError,
                label: const Text('Error state'),
                onSelected: (v) => setState(() => _showError = v),
              ),
              FilterChip(
                selected: _ctaLoading,
                label: const Text('CTA loading'),
                onSelected: (v) => setState(() => _ctaLoading = v),
              ),
            ],
          ),
        ),
        AethorSection(
          spacing: AethorSectionSpacing.normal,
          children: [
            Text('QuoteCard', style: sectionLabelStyle),
            QuoteCard(
              quoteText:
                  'A felicidade de sua vida depende da qualidade de seus pensamentos.',
              author: 'Marco Aurélio',
              sourceWork: 'Meditações',
              sourceRef: '5.16',
              behaviorIntent: 'Observar antes de reagir.',
              contextTags: const ['foco', 'ansiedade', 'trabalho'],
              favorite: _isFavorite,
              favoriteLoading: false,
              onToggleFavorite: () => setState(() => _isFavorite = !_isFavorite),
            ),
          ],
        ),
        AethorSection(
          spacing: AethorSectionSpacing.normal,
          children: [
            Text('PracticeCard', style: sectionLabelStyle),
            const PracticeCard(
              title: 'Pausa de 2 minutos',
              quoteLinkExplanation:
                  'Para criar espaço entre impulso e ação quando surgir pressão.',
              practiceContext: 'trabalho',
              minutes: 2,
              steps: [
                'Respire profundamente por 30 segundos.',
                'Nomeie o impulso sem agir.',
                'Escolha a próxima ação com intenção.',
              ],
              expectedOutcome: 'Resposta mais racional.',
              completionCriteria: 'Você pausou antes de agir.',
              journalPrompt: 'O que mudou ao pausar?',
            ),
          ],
        ),
        AethorSection(
          spacing: AethorSectionSpacing.normal,
          children: [
            Text('Check-in Card', style: sectionLabelStyle),
            AethorCheckinCard(
              noteController: _noteController,
              reflectionPrompt:
                  'Reflexão do dia: Onde você escolheu agir com mais intenção?',
              status: _checkinStatus,
              isSubmitting: _ctaLoading,
              savedNote: _noteController.text,
              onApplied: () =>
                  setState(() => _checkinStatus = AethorCheckinStatus.applied),
              onNotApplied: () =>
                  setState(() => _checkinStatus = AethorCheckinStatus.notApplied),
            ),
          ],
        ),
        AethorSection(
          spacing: AethorSectionSpacing.normal,
          children: [
            Text('Estados de Tela', style: sectionLabelStyle),
            if (_showLoading) const AethorLoadingState(),
            if (_showEmpty)
              const AethorEmptyState(
                title: 'Nenhum item encontrado.',
                description: 'Adicione favoritos para preencher esta área.',
              ),
            if (_showError)
              AethorErrorState(
                message: 'Falha ao carregar dados. Tente novamente.',
                onRetry: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tentativa acionada.')),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

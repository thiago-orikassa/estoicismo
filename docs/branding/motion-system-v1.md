# Motion System v1 - Estoicismo

## Objetivo
Definir padrões de movimento consistentes, discretos e funcionais, alinhados à sobriedade da marca e ao ritual diário do app.

## Princípios de Motion
- Funcional antes de ornamental.
- Curto e claro, sem distração.
- Movimento deve reforçar hierarquia e continuidade.
- Sem loops decorativos no fluxo principal.

## Tokens
### Duração
| Token | Duração | Uso |
| --- | --- | --- |
| `motion.duration.micro` | 120ms | microfeedback (toque, toggle, favorito) |
| `motion.duration.standard` | 200ms | transições de estado internas |
| `motion.duration.entry` | 260ms | entrada de tela/conteúdo |

### Curvas
| Token | Curva | Uso |
| --- | --- | --- |
| `motion.curve.entry` | `easeOut` | entrada de tela e conteúdo |
| `motion.curve.transition` | `easeInOut` | transições entre estados/telas |

### Distância de deslocamento
| Token | Valor | Uso |
| --- | --- | --- |
| `motion.move.xs` | 4 | microelementos (chips, labels) |
| `motion.move.sm` | 8 | itens de lista, cards |
| `motion.move.md` | 12 | seções/headers |

### Escala
| Token | Valor | Uso |
| --- | --- | --- |
| `motion.scale.press` | 0.98 | feedback de toque |
| `motion.scale.emphasis` | 0.96 | ênfase breve (ex.: favorito) |

### Opacidade
| Token | Valor | Uso |
| --- | --- | --- |
| `motion.opacity.in` | 0 → 1 | entrada discreta |
| `motion.opacity.out` | 1 → 0 | saída discreta |

## Padrões de Transição (Telas)
### Sistema de transições (Material Motion)
| Padrão | Quando usar | Receita visual |
| --- | --- | --- |
| `Container transform` | Elementos com relação direta (card -> detalhe) | morfismo de forma, posição e tamanho com cross-fade |
| `Shared axis (X)` | Ir e voltar no mesmo nível (tabs, stepper) | slide + fade na direção do eixo |
| `Shared axis (Y)` | Mudança hierárquica vertical (lista -> seção) | slide + fade vertical |
| `Shared axis (Z)` | Navegação em profundidade (push/pop) | scale + fade (aproxima/afasta) |
| `Fade through` | Troca sem relação direta (destinos diferentes) | saída -> breve pausa -> entrada com leve escala |
| `Fade` | Elementos dentro da mesma tela (dialogs, menus, snackbar) | opacidade simples |

### Regras de uso
- `Container transform` sempre que o usuário perceber continuidade do elemento.
- `Shared axis` para reforcar direcao e hierarquia de navegacao.
- `Fade through` para mudar contexto sem relacao direta.
- `Fade` para elementos efemeros dentro do mesmo contexto.

## Padrões de Microinteração (Componentes)
- `PrimaryButton`/`SecondaryButton`: compressão leve (`scale.press`) em `micro`.
- `Favorite`: micro escala + leve opacidade, sem overshoot.
- `StoicCard` hover/press: variação de elevação mínima + `scale.press`.
- `TagGroup`: entrada em cascata com `motion.move.xs` e `micro`.

## Interações Prioritárias (v1)
- `PrimaryButton`: press com `scale.press` e feedback de estado (idle -> loading -> success).
- `SecondaryButton`: press com `scale.press` e mudança sutil de tonalidade.
- `TonalButton`: press com `scale.press` e realce de fundo.
- `Favorite` (icone/coracao): toggle com micro escala + leve opacidade, sem overshoot.
- `EmptyState`: entrada por `fade`.
- `ErrorState`: entrada por `fade` + acao de retry.
- `NavigationBar`: troca de destino com `fade through`.
- `ListItem` (Historico/Favoritos): entrada `fade + move.sm`, tap abre detalhe.

## Implementacao Flutter (v1)
### Tokens base (Dart)
```dart
class MotionTokens {
  static const micro = Duration(milliseconds: 120);
  static const standard = Duration(milliseconds: 200);
  static const entry = Duration(milliseconds: 260);

  static const curveEntry = Curves.easeOut;
  static const curveTransition = Curves.easeInOut;

  static const moveXs = 4.0;
  static const moveSm = 8.0;
  static const moveMd = 12.0;

  static const pressScale = 0.98;
}
```

### Press feedback (Primary/Secondary/Tonal)
```dart
class PressableScale extends StatefulWidget {
  const PressableScale({required this.child, super.key});
  final Widget child;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? MotionTokens.pressScale : 1.0,
        duration: MotionTokens.micro,
        curve: MotionTokens.curveTransition,
        child: widget.child,
      ),
    );
  }
}
```

### Favorite toggle (micro escala + opacidade)
```dart
AnimatedScale(
  scale: isFavorited ? 1.0 : 0.96,
  duration: MotionTokens.micro,
  curve: MotionTokens.curveTransition,
  child: AnimatedOpacity(
    opacity: isFavorited ? 1.0 : 0.85,
    duration: MotionTokens.micro,
    curve: MotionTokens.curveTransition,
    child: icon,
  ),
)
```

### Empty/Error state (fade)
```dart
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: MotionTokens.standard,
  curve: MotionTokens.curveEntry,
  child: stateWidget,
)
```

### List item entry (fade + move.sm)
```dart
AnimatedSlide(
  offset: isVisible ? Offset.zero : const Offset(0, 0.08),
  duration: MotionTokens.entry,
  curve: MotionTokens.curveEntry,
  child: AnimatedOpacity(
    opacity: isVisible ? 1.0 : 0.0,
    duration: MotionTokens.entry,
    curve: MotionTokens.curveEntry,
    child: item,
  ),
)
```

### NavigationBar (Fade Through)
```dart
return PageTransitionSwitcher(
  duration: MotionTokens.entry,
  transitionBuilder: (child, primary, secondary) {
    return FadeThroughTransition(
      animation: primary,
      secondaryAnimation: secondary,
      child: child,
    );
  },
  child: currentDestination,
);
```

### Reduce motion (gate)
Use `disableAnimations` quando disponivel na sua versao do Flutter. Como fallback, use `accessibleNavigation`.
```dart
final reduceMotion = MediaQuery.of(context).accessibleNavigation;

final duration = reduceMotion ? Duration.zero : MotionTokens.standard;
```


## Morfologia de Componentes (Estados)
### Botões
- `default -> pressed`: `scale.press` + leve escurecimento.
- `default -> loading`: texto fade out, spinner fade in, largura constante.
- `loading -> success`: spinner fade out, label "Feito" entra com `fade + move.xs`.

### Cards (Quote/Practice)
- `collapsed -> expanded`: `Container transform` ou `scale + size` com canto preservado.
- Metadados entram com `fade + move.xs` após 60ms do titulo.
- Acoes secundarias entram por ultimo, sem overshoot.

### Chips/Tags
- `inactive -> active`: preenchimento e texto mudam com `standard`.
- Insercao/remoção: `fade + move.xs`, sem spring.

### TextField/Dropdown
- `idle -> focus`: borda e label animam com `standard`.
- Sugestao/erro: cor e icone entram por `fade`.

### Lista/Timeline
- Novo item: `fade + move.sm` de baixo para cima.
- Reordenacao: deslocamento direto, sem escala.

### FeedbackBar
- Entrada: `fade + move.sm` a partir da base.
- Saida: `fade` simples.

## Cadencia e Orquestracao
- Sequencia recomendada: titulo -> conteudo -> acoes.
- Atraso maximo entre elementos: 60-80ms.
- Entradas simultaneas apenas quando nao ha hierarquia editorial.

## Conteúdo Editorial
- `QuoteCard`: entrada com `fade + move.sm`, sem parallax.
- `PracticeCard`: entrada subsequente, atraso de 60–80ms para cadência.
- Evitar qualquer loop animado enquanto o usuário lê.

## Estados e Feedback
- `LoadingState`: indicador nativo simples. Evitar shimmer persistente.
- `EmptyState`/`ErrorState`: fade de 200ms, sem deslocamento.
- `FeedbackBar`: entrada 200ms, saída 160ms.

## Acessibilidade e Performance
- Respeitar preferências do sistema de “reduzir movimento”.
- Reduzir deslocamento a 0 quando `reduce motion` estiver ativo.
- Evitar animações contínuas em telas de leitura.
- Priorizar 60fps, assets leves e animações curtas.

## Stack de Bibliotecas (Flutter)
### Base obrigatória
- Animações nativas do Flutter para o core do sistema (implicit/explicit).
- `animations` (Material motion) para padrões de transição entre telas.

### Opcional (uso pontual)
- `flutter_animate` para microinterações declarativas e consistentes.
- `lottie` para ilustrações curtas e leves (loading/empty), sem loops longos.
- `rive` para uma única peça interativa de alto valor (se necessário).

## Checklist de QA de Motion
- Cada movimento tem propósito claro.
- Nenhum loop contínuo no fluxo diário.
- Durações seguem tokens.
- Reduz movimento respeitado.
- Transições coerentes entre Android/iOS.

# Referencias de Mercado — Lacuna 4: Voice Chart

> Pesquisa de benchmarks e frameworks para construir o Voice Chart do Aethor com exemplos de contraste, gradiente de formalidade por canal e vocabulario de marca.

Data: 2026-02-15
Status: pesquisa consolidada para informar a execucao da Lacuna 4

---

## 1. Frameworks Teoricos de Voice & Tone

### 1.1 Nielsen Norman Group — 4 Dimensoes de Tom de Voz

O NN/g define quatro espectros primarios para analisar tom de voz. Cada dimensao funciona como um continuo, nao como binario.

| Dimensao | Polo A | Polo B |
|----------|--------|--------|
| 1 | Formal | Casual |
| 2 | Serio | Engraçado |
| 3 | Respeitoso | Irreverente |
| 4 | Factual | Entusiastico |

**Exemplo pratico do NN/g — mensagem de erro no mesmo contexto:**

| Versao | Tom | Texto |
|--------|-----|-------|
| 1 | Formal + Serio + Respeitoso + Factual | "We apologize, but we are experiencing a problem." |
| 2 | + Casual | "We're sorry, but we're experiencing a problem on our end." |
| 3 | + Entusiastico | "Oops! We're sorry, but we're experiencing a problem on our end." |
| 4 | + Humor + Irreverente | "What did you do!? You broke it! (Just kidding. We're experiencing a problem on our end.)" |

**Aplicacao para Aethor:**
- Aethor vive em: **Formal (8/10), Serio (8/10), Respeitoso (9/10), Factual (7/10)**
- Nunca vai para irreverente ou engraçado
- O unico ajuste permitido e o grau de calor humano (factual → levemente caloroso), nunca entusiastico

**Fonte**: [The Four Dimensions of Tone of Voice — NN/g](https://www.nngroup.com/articles/tone-of-voice-dimensions/)

---

### 1.2 Mailchimp Content Style Guide — Voz Constante, Tom Variavel

O framework do Mailchimp e o padrao da industria para separar voz (permanente) de tom (contextual):

**Principio central:** "A voz nao muda muito de um dia para outro, mas o tom muda o tempo todo."

**Estrutura:**
- **Voz** = personalidade constante (palavras que voce usa, caracteristicas definidoras)
- **Tom** = ajuste emocional por contexto (estado emocional do leitor no momento)

**Regras de escrita do Mailchimp:**
1. Voz ativa, nunca passiva
2. Ingles simples (plain English), sem jargao
3. Linguagem positiva em vez de negativa
4. Humor existe mas nunca e forçado — "humor forçado e pior do que nenhum humor"
5. "Preferimos o sutil ao barulhento, o ironico ao farsesco"

**O que o Mailchimp declara sobre si:**
- "Falamos como um parceiro de negocios experiente e compassivo"
- "Queremos educar sem patronizar ou confundir"
- "Tratamos cada marca esperançosa com seriedade"

**Aplicacao para Aethor:**
- Adotar a mesma separacao voz/tom
- Voz do Aethor: constante (editorial, severa, calorosa, profunda, breve)
- Tom: varia por contexto (push = mais breve e caloroso; citaçao = mais formal e profundo; erro = factual e respeitoso)

**Fonte**: [Voice and Tone — Mailchimp Content Style Guide](https://styleguide.mailchimp.com/voice-and-tone/)

---

### 1.3 The Economist Style Guide — Autoridade sem Pedantismo

Principios editoriais do The Economist que se aplicam diretamente ao Aethor:

| Principio | Regra | Aplicacao Aethor |
|-----------|-------|------------------|
| Clareza acima de tudo | "Ambiguidade e o inimigo. Cada frase deve servir a um proposito." | Microcopy do app: cada palavra deve justificar sua existencia |
| Simplicidade | "Pense o que quer dizer, depois diga da forma mais simples possivel." | Reflexoes guiadas: maximo 2-3 linhas, cada uma precisa |
| Voz ativa | "Pesquisadores analisaram os dados" > "Os dados foram analisados" | CTAs e praticas: "Observe", "Pratique", "Aja" |
| Verbos fortes | Substituir "ser" e "ter" por verbos de acao precisos | "Sua pratica aguarda" > "Voce tem uma pratica disponivel" |
| Anti-pomposidade | Eliminar construcoes prolixas, linguagem burocratica, metaforas gastas | Zero jargao motivacional: sem "jornada", "transformacao", "experiencia" |
| Tom autoritativo + legivel | "Autoridade vem de clareza e precisao, legibilidade vem de tom conversacional" | Exatamente o par Aethor: Profunda + Breve |

**Fonte**: [The Economist Style Guide](https://worldecomag.com/5-tips-on-writing-from-the-economist-style-guide/)

---

### 1.4 Apple Human Interface Guidelines — Writing

Principios de escrita da Apple que se aplicam a interface do Aethor:

| Principio Apple | Regra | Aplicacao Aethor |
|-----------------|-------|------------------|
| Clareza | "Escolha palavras facilmente compreendidas que transmitam a coisa certa" | Evitar termos filosoficos sem contexto |
| Concisao | "Verifique cada palavra para ter certeza de que precisa estar ali" | Microcopy de 1-2 frases por campo |
| Acao | "Voz ativa e rotulos claros ajudam pessoas a navegar" | Botoes com verbos: "Praticar", "Salvar", "Refletir" |
| Contexto | "Desenvolva a voz do app primeiro, depois varie o tom" | Voz Aethor fixa; tom ajusta por tela |
| Teste | "Na duvida, leia em voz alta" | Regra de ouro para validar microcopy |

**Destaque — WWDC24 "Add personality to your app through UX writing":**
- Apple recomenda que apps definam "o que diria e o que NAO diria" — exatamente a tabela de contraste da Lacuna 4

**Fonte**: [Writing — Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/writing)

---

## 2. Benchmarks de Marcas — Tom de Voz Aplicado

### 2.1 Aesop — "Respeito, Nao Simpatia"

**Relevancia para Aethor:** Aesop e a referencia mais proxima para o par "Severa no conteudo, calorosa no cuidado".

**Principios de voz Aesop:**

| Principio | Como funciona | Paralelo Aethor |
|-----------|---------------|-----------------|
| Restraint como confianca | "O produto nao precisa gritar." Embalagem minimalista, labels como instrucoes, nao slogans | Cards de citacao sem ornamento — a tipografia e a mensagem |
| Naming funcional e descritivo | Reduz friccao, suporta tom sem-teatralidade | "Pratica do dia" > "Sua experiencia diaria de sabedoria" |
| Publishing mindset | Conteudo como ponto de vista, nao material promocional. Newsletter sem descontos, "The Fabulist" sem referencia a produtos | Push notifications com substancia filosofica, nao marketing |
| Non-accommodation | "Nao simplifica, nao tranquiliza, nao resolve significado por voce" | Citacoes originais preservadas, sem simplificacao que deturpa |
| Unselling | "Recusa de entregar promessas falsas" | Zero promessas terapeuticas, zero linguagem pseudocientifica |
| Educacao consultiva | "Funcionarios treinados para explicar ingredientes e uso, nao para vender mais" | App que explica contexto historico da citacao, nao que vende "transformacao" |

**Frase iconica Aesop:**
> "Defendemos o uso de nossos produtos como parte de uma vida equilibrada que inclui dieta saudavel, exercicio sensato, consumo moderado de vinho tinto e uma dose regular de literatura estimulante."

**Principio-chave:** A distincao entre uma marca que *parece* pensada e uma que *genuinamente e* pensada — e a historia inteira.

**Aplicacao direta:** O Aethor deve comunicar como Aesop comunica cuidado com a pele — com respeito a inteligencia do usuario, sem promessas infladas, com precisao funcional.

**Fontes**: [Aesop Marketing Strategy — Brand Vision](https://www.brandvm.com/post/aesop-marketing-strategy), [Aesop: Literary Storytelling — Latterly](https://www.latterly.org/aesop-marketing-strategy/)

---

### 2.2 Headspace — O Anti-Modelo (o que Aethor NAO e)

**Relevancia para Aethor:** Headspace e o benchmark de contraste — mostra o territorio que Aethor recusa.

**Tom de voz Headspace:**
- Calmo, medido, meditativo
- Ancorado na voz dos professores de meditacao (especialmente Andy Puddicombe)
- Começa serio com novos usuarios, torna-se ludico com o tempo
- Usa emojis, cores vibrantes, ilustracoes infantis
- Celebra streaks e conquistas com entusiasmo

**Push notifications Headspace (padroes):**
- Lembretes de pratica com tom encorajador
- Reflexoes mindfulness em intervalos programados
- Recomendacoes personalizadas baseadas em historico
- Tom: amigavel, gentil, levemente ludico

**Onboarding Headspace:**
- "Breathe in. Breathe out." — engajamento imediato, simples, experiencial
- Convite a participar ativamente (interacao, nao leitura)
- Tom casual e acessivel

**O que Aethor aprende por CONTRASTE:**

| Headspace faz | Aethor recusa | Porque |
|---------------|---------------|--------|
| Ilustracoes ludicas, cores vibrantes | Paleta Obsidian/Stone, tipografia editorial | Par 2: Severa, nao ludica |
| Streaks, badges, celebracoes | Zero gamificacao visivel | Par 4: Disciplina interna, nao imposta |
| "Great job! You meditated 5 days!" | Nenhuma mensagem de recompensa externa | Par 2: Respeito, nao simpatia |
| Tom que se torna playful | Tom que permanece editorial | Espectro: 8/10 formal, 8/10 editorial |
| Meditacao como "sentir melhor" | Pratica estoica como "agir melhor" | Onlyness: disciplina seria, nao conforto |

**Fonte**: [Headspace Tone of Voice — The Way With Words](https://www.thewaywithwords.co.uk/tone-of-voice-blog/headspace-tone-of-voice)

---

### 2.3 Waking Up (Sam Harris) — O Primo Intelectual

**Relevancia para Aethor:** Waking Up e o parente espiritual mais proximo. Ambos recusam simplificar o tema. Ambos priorizam profundidade intelectual.

**Tom de voz Waking Up:**
- "Nao tenta influenciar seu humor simplesmente pelo tom de voz"
- "A experiencia de meditacao menos woo-woo e mais orientada por ciencia"
- Secular, baseado em evidencias, sem dogma religioso
- Design "elegante, limpo e intuitivo" (MetaLab)

**Onde Aethor difere do Waking Up:**

| Waking Up | Aethor | Diferença |
|-----------|--------|-----------|
| Pan-filosofico (budismo, neurociencia, consciencia) | Estoicismo exclusivamente | Foco vs. amplitude |
| Curriculo progressivo (cursos longos) | Ritual diario unico (90s-3min) | Brevidade vs. profundidade extensiva |
| Tom descrito como "seco, sem paixao, sem playfulness" | Severo MAS caloroso (cobre no obsidian) | Aethor adiciona calor sem perder seriedade |
| Voz de um intelectual publico (Sam Harris) | Voz editorial curada (sem figura publica) | Autoridade institucional vs. pessoal |

**Licao-chave:** Waking Up prova que existe mercado para apps intelectualmente serios. Mas usuarios reportam que e "dry" e falta "juice, passion, playfulness". Aethor precisa evitar essa armadilha — o Par 2 (Severa + Calorosa) e o antidoto. A severidade editorial do Aethor deve sempre ser temperada pelo calor humano do cobre.

**Fonte**: [Waking Up App Review — mindful.technology](https://mindful.technology/waking-up-app-review/)

---

### 2.4 Calm — O Foil Visual e Tonal

**Relevancia para Aethor:** Calm e o oposto tonal direto — mostra o extremo que Aethor evita.

**Tom de voz Calm:**
- Passivo, imersivo, tranquilizante
- Linguagem pacifica e reconfortante
- Consistente com relaxamento e mindfulness
- Azul-celeste, natureza, sons ambientes

**O que Aethor aprende por CONTRASTE:**

| Calm | Aethor |
|------|--------|
| "Sinta-se melhor" | "Aja melhor" |
| Tom passivo (receba calma) | Tom diretivo (pratique a resposta) |
| Paleta azul-celeste + natureza | Paleta obsidian + cobre |
| Relaxamento como fim | Clareza como meio para acao |
| Conforto emocional | Confronto respeitoso |

---

## 3. Framework de Voice Chart — Estrutura Recomendada

Com base na pesquisa, a estrutura ideal para o Voice Chart do Aethor combina tres frameworks:

### 3.1 Tabela de Atributos de Voz (Branded Agency Framework)

Formato com 4 colunas:

| Atributo de Voz | Definicao | Dizemos Assim (Do) | Nao Dizemos Assim (Don't) |
|-----------------|-----------|---------------------|---------------------------|
| [Atributo] | [Descricao curta] | [3-4 exemplos concretos] | [3-4 exemplos concretos] |

**Aplicacao:** Usar os 4 pares de tensao como atributos:
1. Antiga na sabedoria, urgente na aplicacao
2. Severa no conteudo, calorosa no cuidado
3. Profunda na curadoria, breve na entrega
4. Disciplinada na forma, libertadora no efeito

**Fonte**: [Brand Voice Guidelines — Branded Agency](https://www.brandedagency.com/blog/brand-voice-guidelines)

---

### 3.2 Gradiente de Formalidade por Canal (Mailchimp Model)

O Mailchimp ensina que o tom varia por contexto emocional do usuario. Para Aethor, isso se traduz em gradiente por canal:

| Canal | Tom | Formalidade | Calor | Exemplo de referencia |
|-------|-----|-------------|-------|----------------------|
| Card de citaçao | Editorial + Profundo | 9/10 | 5/10 | The Economist encontra Aesop |
| Reflexao guiada | Direto + Caloroso | 7/10 | 7/10 | Apple HIG encontra Waking Up |
| Push notification | Breve + Caloroso | 6/10 | 8/10 | Aesop newsletter encontra Apple notification |
| Onboarding | Acessivel + Respeitoso | 6/10 | 8/10 | Waking Up intro encontra Headspace clareza |
| Empty state | Sóbrio + Expectante | 7/10 | 6/10 | Aesop label encontra Muji vazio |
| Erro/fallback | Factual + Respeitoso | 8/10 | 6/10 | Apple HIG encontra The Economist |
| App Store / Landing | Autoritativo + Acessivel | 7/10 | 7/10 | Aesop "unselling" encontra Apple keynote |

---

### 3.3 Vocabulario de Marca (Brand Vision Framework)

Tres categorias:

**1. Substantivos do produto (naming interno):**
- Usar: "pratica", "reflexao", "citacao", "ritual", "check-in"
- Evitar: "experiencia", "jornada", "sessao", "programa", "curso", "treinamento", "meditacao"

**2. Verbos de valor (como o Aethor cria valor):**
- Usar: "observe", "pratique", "reflita", "aja", "escolha", "responda"
- Evitar: "descubra", "transforme", "desbloqueie", "conquiste", "evolua", "manifeste"

**3. Lista de banimento (palavras que enfraquecem):**
- Banir: "incrivel", "transformador", "jornada", "hack", "segredo", "poder", "energia", "vibração", "universo"
- Banir padroes: exclamacoes ("!"), emojis em contextos formais, superlativos sem evidencia

**Fonte**: [Brand Voice Vocabulary Rules — Brand Vision](https://www.brandvm.com/post/brand-voice-vocabulary-rules)

---

## 4. Mapa de Referencias Cruzadas — O que Cada Marca Ensina ao Aethor

| Referencia | O que ensina | Par de tensao que alimenta | Contexto de aplicacao |
|------------|-------------|----------------------------|----------------------|
| **Aesop** | Restraint como confianca. Publishing mindset. Non-accommodation. | Par 2 (Severa + Calorosa) | Tom geral, push notifications, descriçoes |
| **The Economist** | Clareza acima de tudo. Verbos fortes. Anti-pomposidade. | Par 3 (Profunda + Breve) | Reflexoes guiadas, microcopy |
| **Apple HIG** | Concisao radical. Voz ativa. "O que diria / nao diria." | Par 1 (Antiga + Urgente) | Interface, CTAs, botoes |
| **Mailchimp** | Voz constante / tom variavel. Humor sutil, nunca forçado. | Framework geral | Gradiente de formalidade por canal |
| **NN/g** | 4 dimensoes de tom. Tom como espectro, nao binario. | Framework geral | Estrutura do Voice Chart |
| **Waking Up** | Prova de mercado para apps intelectuais serios. Risco de "secura". | Par 2 (Severa + Calorosa) — o antidoto | Calibrar calor humano |
| **Headspace** | Anti-modelo: mostra o territorio que Aethor recusa. | Anti-padroes de todos os pares | Validacao por contraste |
| **Calm** | Foil visual/tonal direto: passivo onde Aethor e ativo. | Par 4 (Disciplinada + Libertadora) | Posicionamento competitivo |
| **Muji** | "Quando o nada se torna pleno de significado." | Par 3 (Profunda + Breve) | Empty states, design negativo |

---

## 5. Recomendacoes para Execucao da Lacuna 4

### 5.1 Estrutura proposta para o Voice Chart

1. **Secao 1 — Voz do Aethor** (constante, nao muda)
   - Derivada dos 4 pares de tensao
   - Declaracoes "Somos / Nao somos"
   - Posicionamento no espectro NN/g

2. **Secao 2 — Tabela "Dizemos Assim / Nao Dizemos Assim"**
   - 10+ pares por contexto (onboarding, push, empty state, erro, CTA, descricao de feature)
   - Formato: contexto → exemplo aprovado → exemplo rejeitado → justificativa (qual par viola)

3. **Secao 3 — Gradiente de Formalidade por Canal**
   - Tabela com formalidade, calor, brevidade por canal
   - 3 exemplos reais de microcopy por canal

4. **Secao 4 — Vocabulario de Marca**
   - Palavras preferidas (com contexto de uso)
   - Palavras proibidas (com justificativa)
   - Verbos de acao aprovados
   - Substantivos do produto padronizados
   - Padroes banidos (exclamacoes, emojis, superlativos)

5. **Secao 5 — Checklist de Validacao**
   - Derivado do checklist da Lacuna 3
   - Aplicavel a qualquer peça de copy antes de publicar

### 5.2 Ordem de execucao

| Passo | Acao | Dependencia |
|-------|------|-------------|
| 1 | Criar tabela "Dizemos / Nao dizemos" (4.1) | Usa pares de tensao da Lacuna 3 |
| 2 | Definir gradiente de formalidade (4.2) | Usa tabela do passo 1 |
| 3 | Escrever microcopy real por contexto (4.3) | Usa gradiente do passo 2 |
| 4 | Compilar vocabulario de marca (4.4) | Extrai padroes dos passos 1-3 |

### 5.3 Criterio de conclusao

- [ ] Tabela "Dizemos / Nao dizemos" com 10+ pares em 6 contextos
- [ ] Gradiente de formalidade documentado para 4+ canais
- [ ] 3 exemplos de microcopy real por contexto principal
- [ ] Lista de palavras preferidas (20+) e proibidas (20+)
- [ ] Checklist de validacao aplicavel

---

## Apendice: Todas as Fontes Consultadas

### Frameworks Teoricos
- [The Four Dimensions of Tone of Voice — Nielsen Norman Group](https://www.nngroup.com/articles/tone-of-voice-dimensions/)
- [Voice and Tone — Mailchimp Content Style Guide](https://styleguide.mailchimp.com/voice-and-tone/)
- [Writing Principles — Mailchimp](https://styleguide.mailchimp.com/writing-principles/)
- [Writing — Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/writing)
- [Add Personality Through UX Writing — WWDC24](https://developer.apple.com/videos/play/wwdc2024/10140/)
- [The Economist Style Guide — Principios](https://worldecomag.com/5-tips-on-writing-from-the-economist-style-guide/)
- [Brand Voice Guidelines — Branded Agency](https://www.brandedagency.com/blog/brand-voice-guidelines)
- [Brand Voice Vocabulary Rules — Brand Vision](https://www.brandvm.com/post/brand-voice-vocabulary-rules)

### Benchmarks de Marca
- [Aesop Marketing Strategy — Brand Vision](https://www.brandvm.com/post/aesop-marketing-strategy)
- [Aesop: Literary Storytelling — Latterly](https://www.latterly.org/aesop-marketing-strategy/)
- [Can Aesop Stay Aesop? — Detail Digest](https://detaildigest.substack.com/p/can-aesop-stay-aesop)
- [Aesop: The Brand That Withholds Meaning](https://www.beyond-thelabel.com/introduction-to-beyondthelabel/aesop-the-brand-that-withholds-meaning)
- [Headspace Tone of Voice — The Way With Words](https://www.thewaywithwords.co.uk/tone-of-voice-blog/headspace-tone-of-voice)
- [Headspace Microcopy — Kinneret Yifrah](https://medium.com/@Kinneret/how-does-meditation-sound-like-44c3cc8136fc)
- [Headspace Push Notifications — nGrow](https://www.ngrow.ai/blog/8-push-notifications-from-headspace-that-will-help-you-cultivate-mindfulness)
- [Waking Up App Review — mindful.technology](https://mindful.technology/waking-up-app-review/)
- [Waking Up App Review — David William Rosales](https://davidwilliamrosales.com/2024/12/18/waking-up-app-review/)

### UX Writing e Microcopy
- [Tone of Voice for UX Writing — UX Design Institute](https://www.uxdesigninstitute.com/blog/tone-of-voice-for-ux-writing/)
- [Voice and Tone in UX Writing — UX Writing Hub](https://uxwritinghub.com/ux-writing-voice-and-tone/)
- [Tone of Voice Best Practices — Writeful](https://writefulcopy.com/blog/tone-voice-best-practices)
- [35 Great UX Writing Examples — UX Writing Hub](https://uxwritinghub.com/ux-writing-examples/)
- [Luxury Tone of Voice — Luxury Briefing](https://www.luxury-briefing.com/2020/02/luxury-branding-tone-of-voice/)

### Concorrentes e Mercado
- [Brand Voice Strategy — Sprinklr](https://www.sprinklr.com/blog/brand-voice/)
- [Brand Voice Guidelines — Toptal](https://www.toptal.com/marketing/brand-managers/define-brand-voice/)
- [Voice & Tone Guide — Centigrade](https://www.centigrade.de/en/blog/das-branding-tool-fur-ux-writers-der-voice-tone-guide/)

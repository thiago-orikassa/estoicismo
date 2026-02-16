#!/usr/bin/env node
/**
 * enrich-seed.mjs
 * Popula campos faltantes (quote_link_explanation, expected_outcome,
 * completion_criteria) nas recomendações do daily_seed.json.
 *
 * Uso: node scripts/enrich-seed.mjs
 */

import { readFileSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const seedPath = join(__dirname, '../data/daily_seed.json');

const enrichment = {
  'r-001': {
    quote_link_explanation: 'Se o tempo é tudo que possuímos, investir em ações controláveis é a forma mais sábia de usá-lo.',
    expected_outcome: 'Clareza sobre o que depende de você e ação imediata no que importa.',
    completion_criteria: 'Você executou a primeira ação de 10 minutos da sua lista.',
  },
  'r-002': {
    quote_link_explanation: 'Quando a mente dispersa entre medos, não enfrenta nenhum — nomeá-los é o primeiro passo para estar presente.',
    expected_outcome: 'Redução da ansiedade difusa ao transformar medo vago em fato específico.',
    completion_criteria: 'Você separou fato de interpretação e definiu uma resposta objetiva.',
  },
  'r-003': {
    quote_link_explanation: 'A confiança verdadeira exige atenção plena — assim como na amizade, no trabalho a presença é inegociável.',
    expected_outcome: 'Um entregável concreto finalizado com foco sustentado.',
    completion_criteria: 'Você completou 25 minutos ininterruptos e finalizou um entregável.',
  },
  'r-004': {
    quote_link_explanation: 'Perseverar no caminho exige paciência — responder sem impulso é prova de constância interior.',
    expected_outcome: 'Comunicação mais clara e relações preservadas pela moderação.',
    completion_criteria: 'Você pausou, reescreveu e enviou apenas o essencial.',
  },
  'r-005': {
    quote_link_explanation: 'O empenho nos estudos só tem valor quando guiado pela virtude — o critério ético é o filtro de toda decisão.',
    expected_outcome: 'Uma decisão tomada com integridade, independente da conveniência.',
    completion_criteria: 'Você avaliou as opções por justiça e coragem e escolheu a mais íntegra.',
  },
  'r-006': {
    quote_link_explanation: 'Ser transformado exige espaço — eliminar o supérfluo da agenda é proteger o essencial.',
    expected_outcome: 'Mais tempo para trabalho profundo e menos esgotamento por excesso.',
    completion_criteria: 'Você removeu um compromisso e comunicou o novo limite.',
  },
  'r-007': {
    quote_link_explanation: 'Assim como o caráter se revela nas primeiras palavras, a preparação mental revela o estoico — antecipe para não reagir.',
    expected_outcome: 'Redução da surpresa emocional diante de adversidades.',
    completion_criteria: 'Você imaginou o pior plausível, planejou a resposta e voltou ao presente.',
  },
  'r-008': {
    quote_link_explanation: 'A velhice avança sem pedir permissão — cada momento disperso é irrecuperável. Fazer uma coisa de cada vez honra o tempo.',
    expected_outcome: 'Progresso tangível sem o desgaste da alternância de contexto.',
    completion_criteria: 'Você concluiu uma entrega antes de iniciar outra tarefa.',
  },
  'r-009': {
    quote_link_explanation: 'O sábio deseja amigos não por necessidade, mas por valor — escutar com justiça é o primeiro ato de amizade verdadeira.',
    expected_outcome: 'Conexão mais profunda ao demonstrar interesse genuíno.',
    completion_criteria: 'Você escutou sem interromper, repetiu o ponto e respondeu ao que foi dito.',
  },
  'r-010': {
    quote_link_explanation: 'Evitar a multidão é proteger o juízo — testar a decisão pelo olhar do futuro é proteger o caráter.',
    expected_outcome: 'Decisão mais robusta, validada contra o risco moral.',
    completion_criteria: 'Você avaliou a decisão pela perspectiva de 1 ano e anotou o risco.',
  },
  'r-011': {
    quote_link_explanation: 'Separar o que depende de nós do que não depende é o fundamento de toda ação estoica — comece o dia com essa clareza.',
    expected_outcome: 'Energia direcionada apenas ao que você pode influenciar.',
    completion_criteria: 'Você escreveu as duas colunas, riscou a segunda e agiu na primeira.',
  },
  'r-012': {
    quote_link_explanation: 'A infelicidade nasce de desejar o que não controlamos — reenquadrar o julgamento devolve o poder à razão.',
    expected_outcome: 'Pensamento mais equilibrado ao substituir reação automática por análise.',
    completion_criteria: 'Você detectou o pensamento automático e o substituiu por descrição neutra.',
  },
  'r-013': {
    quote_link_explanation: 'Perguntar a natureza de cada coisa evita ilusões — aplicar disciplina de início evita a procrastinação.',
    expected_outcome: 'Ação iniciada sem depender de motivação externa.',
    completion_criteria: 'Você definiu critério, começou sem negociar e cronometrou 10 minutos.',
  },
  'r-014': {
    quote_link_explanation: 'Recordar o tipo de ação antes de agir previne o impulso — controlar a reatividade é exercer razão sobre emoção.',
    expected_outcome: 'Conflitos evitados ou resolvidos com linguagem factual.',
    completion_criteria: 'Você respirou, esperou o pico emocional passar e retomou com clareza.',
  },
  'r-015': {
    quote_link_explanation: 'Se não são os eventos que perturbam mas nossas opiniões, escolher pelo papel virtuoso é escolher pela razão.',
    expected_outcome: 'Ação alinhada ao papel que você quer desempenhar, não ao impulso.',
    completion_criteria: 'Você definiu seu papel, agiu conforme ele e registrou a experiência.',
  },
  'r-016': {
    quote_link_explanation: 'Exaltar-se por vantagem alheia é fragilidade — comprometer-se com o próprio processo é a verdadeira fortaleza.',
    expected_outcome: 'Progresso consistente sem dependência de validação externa.',
    completion_criteria: 'Você executou a etapa do dia e revisou sem autocondenação.',
  },
  'r-017': {
    quote_link_explanation: 'Manter atenção no navio é cuidar do real — provar a realidade dos medos é aterrar a mente no que existe.',
    expected_outcome: 'Ação proporcional ao risco real, sem magnificação catastrófica.',
    completion_criteria: 'Você escreveu a previsão, encontrou evidências contrárias e agiu.',
  },
  'r-018': {
    quote_link_explanation: 'Aceitar os acontecimentos como são liberta energia — a higiene mental remove o que compete com sua atenção.',
    expected_outcome: 'Foco restaurado após eliminar distrações e gatilhos de comparação.',
    completion_criteria: 'Você bloqueou notificações, afastou gatilhos e voltou ao trabalho.',
  },
  'r-019': {
    quote_link_explanation: 'A doença impede o corpo mas não a vontade — expectativas realistas protegem a vontade nas relações.',
    expected_outcome: 'Conversas mais produtivas ao focar no que depende de você.',
    completion_criteria: 'Você definiu sua parte, aceitou a do outro e conduziu com clareza.',
  },
  'r-020': {
    quote_link_explanation: 'Voltar-se para os próprios recursos é o conselho de Epicteto — conhecer a perda aceitável é usar esse recurso com sabedoria.',
    expected_outcome: 'Decisão tomada dentro de limites claros, sem risco desmedido.',
    completion_criteria: 'Você listou a pior perda aceitável, definiu limite e decidiu.',
  },
  'r-021': {
    quote_link_explanation: 'Nada se perde, tudo é devolvido — fechar ciclos curtos pratica o desapego do resultado perfeito.',
    expected_outcome: 'Progresso concreto em vez de paralisia por perfeccionismo.',
    completion_criteria: 'Você entregou uma versão imperfeita e coletou feedback.',
  },
  'r-022': {
    quote_link_explanation: 'Manter morte e exílio diante dos olhos elimina pensamentos baixos — aceitar o inevitável libera coragem para agir.',
    expected_outcome: 'Resposta digna ao inevitável em vez de resistência improdutiva.',
    completion_criteria: 'Você nomeou o evento, definiu resposta digna e executou o primeiro passo.',
  },
  'r-023': {
    quote_link_explanation: 'Aceitar parecer tolo é liberdade — um contrato de prioridade exige essa coragem de simplificar.',
    expected_outcome: 'Constância aumentada pela prestação de contas externa.',
    completion_criteria: 'Você definiu prioridade única, compartilhou e prestou contas.',
  },
  'r-024': {
    quote_link_explanation: 'Desejar que outros vivam para sempre é negar a realidade — corrigir sem humilhar aceita a imperfeição humana com firmeza.',
    expected_outcome: 'Feedback entregue com clareza e respeito, sem ressentimento.',
    completion_criteria: 'Você descreveu o fato, explicou o impacto e pediu ajuste específico.',
  },
  'r-025': {
    quote_link_explanation: 'Num banquete, toma o que é servido com decência — separar valor de resultado é aceitar o que a vida oferece sem exigir mais.',
    expected_outcome: 'Paz interior ao desacoplar a decisão correta do resultado externo.',
    completion_criteria: 'Você definiu a decisão correta, executou e aceitou o resultado.',
  },
  'r-026': {
    quote_link_explanation: 'Não se deixar arrastar pela aparência da dor é agir com razão — dividir a tarefa em partes vence a procrastinação sem drama.',
    expected_outcome: 'Tarefa iniciada e primeira parte concluída, quebrando a inércia.',
    completion_criteria: 'Você dividiu em 3 partes, fez a primeira e marcou conclusão.',
  },
  'r-027': {
    quote_link_explanation: 'Somos atores no papel que nos foi dado — reduzir a antecipação é aceitar que o roteiro não nos pertence.',
    expected_outcome: 'Menos energia gasta em cenários imaginários, mais presença.',
    completion_criteria: 'Você limitou o planejamento, parou de simular e voltou ao presente.',
  },
  'r-028': {
    quote_link_explanation: 'Voltar-se aos externos para agradar é perder o rumo — a atenção ao presente reconecta com o que é interno e real.',
    expected_outcome: 'Retorno imediato ao presente através de ação física concreta.',
    completion_criteria: 'Você respirou, definiu próxima ação e a executou imediatamente.',
  },
  'r-029': {
    quote_link_explanation: 'Ser invencível é não entrar em disputas que não se pode vencer — extrair o útil da crítica sem rancor é vitória interior.',
    expected_outcome: 'Crescimento a partir de crítica, sem desgaste emocional.',
    completion_criteria: 'Você ouviu a crítica, extraiu 1 ponto útil e descartou o resto.',
  },
  'r-030': {
    quote_link_explanation: 'Não é quem insulta que ofende, mas a opinião sobre o insulto — ensaiar objeções fortalece a decisão contra opiniões externas.',
    expected_outcome: 'Decisão mais sólida, testada contra os melhores argumentos contrários.',
    completion_criteria: 'Você listou 3 objeções, respondeu com fatos e reavaliou.',
  },
  'r-031': {
    quote_link_explanation: 'Se encontraremos o intrometido e o ingrato a cada manhã, a melhor defesa é cumprir nosso dever antes do ruído.',
    expected_outcome: 'Dever principal concluído antes que distrações externas interfiram.',
    completion_criteria: 'Você definiu o dever, começou antes das mensagens e concluiu o bloco.',
  },
  'r-032': {
    quote_link_explanation: 'A tranquilidade mora dentro de nós — lembrar a impermanência dissolve o medo ao revelar que tudo passa.',
    expected_outcome: 'Ansiedade reduzida pela perspectiva de que a dificuldade é temporária.',
    completion_criteria: 'Você escreveu a lembrança, nomeou uma ação correta e a executou.',
  },
  'r-033': {
    quote_link_explanation: 'Se algo é difícil mas não impossível, a simplicidade deliberada remove o supérfluo para tornar o essencial viável.',
    expected_outcome: 'Essencial finalizado com qualidade ao eliminar o desnecessário.',
    completion_criteria: 'Você removeu uma tarefa secundária e finalizou o essencial.',
  },
  'r-034': {
    quote_link_explanation: 'A mente assume o caráter dos seus pensamentos — colorir os pensamentos com benevolência transforma as relações.',
    expected_outcome: 'Relação fortalecida por firmeza respeitosa, sem passividade nem agressão.',
    completion_criteria: 'Você assumiu boa intenção, corrigiu com clareza e manteve respeito.',
  },
  'r-035': {
    quote_link_explanation: 'Pensar e agir como ser humano racional exige cuidado em cada ato — a razão é o critério de toda decisão virtuosa.',
    expected_outcome: 'Decisão alinhada à razão e ao bem comum, livre de vaidade.',
    completion_criteria: 'Você escolheu a opção mais racional e justa e agiu.',
  },
  'r-036': {
    quote_link_explanation: 'Se a vida pode acabar a qualquer instante, cada ato deve ser regulado — disciplina silenciosa é trabalhar sem performar.',
    expected_outcome: 'Produção real sem o ruído da autoexibição.',
    completion_criteria: 'Você trabalhou 30 minutos, registrou resultado e repetiu.',
  },
  'r-037': {
    quote_link_explanation: 'Se coisas externas distraem, reservar tempo para o corpo é voltar ao que é interno — o corpo é a âncora do presente.',
    expected_outcome: 'Tensão física reduzida e retorno da calma para decisões melhores.',
    completion_criteria: 'Você relaxou ombros e mandíbula, respirou por 1 minuto e retomou.',
  },
  'r-038': {
    quote_link_explanation: 'A infelicidade vem de não observar a própria mente — presença sem pressa é o antídoto contra a dispersão interior.',
    expected_outcome: 'Trabalho com mais qualidade ao manter ritmo sustentável.',
    completion_criteria: 'Você definiu ritmo, evitou multitarefa e concluiu 1 ciclo completo.',
  },
  'r-039': {
    quote_link_explanation: 'Lembrar a natureza do todo e como nos relacionamos com ela transforma dever em cooperação — ajudar é agir conforme a natureza.',
    expected_outcome: 'Fortalecimento de vínculos por meio de ação concreta.',
    completion_criteria: 'Você perguntou como ajudar, ofereceu apoio real e cumpriu.',
  },
  'r-040': {
    quote_link_explanation: 'Tudo desaparece depressa — revisar as escolhas do dia é o último ato de quem trata cada dia como se fosse inteiro.',
    expected_outcome: 'Ajuste consciente de caráter para o dia seguinte.',
    completion_criteria: 'Você revisou 3 escolhas, marcou 1 ajuste e se comprometeu.',
  },
};

const seed = JSON.parse(readFileSync(seedPath, 'utf-8'));

let enriched = 0;
for (const rec of seed.recommendations) {
  const data = enrichment[rec.id];
  if (!data) {
    console.error(`⚠ Sem dados de enriquecimento para ${rec.id}`);
    continue;
  }
  rec.quote_link_explanation = data.quote_link_explanation;
  rec.expected_outcome = data.expected_outcome;
  rec.completion_criteria = data.completion_criteria;
  enriched += 1;
}

writeFileSync(seedPath, JSON.stringify(seed, null, 2) + '\n', 'utf-8');
console.log(`✓ ${enriched} recomendações enriquecidas em ${seedPath}`);

# PRD - Aethor: App Mobile de Estoicismo Diário

## 1. Visão do produto
Aplicativo mobile que entrega diariamente uma citação estoica autêntica e uma recomendação prática para aplicação no cotidiano, com linguagem guiada pela "personalidade filosófica" do autor escolhido (Sêneca, Epicteto, Marco Aurélio).

## 2. Problema
Pessoas buscam calma, direção e disciplina, mas consomem conteúdo motivacional fragmentado, sem consistência filosófica nem prática diária.

## 3. Objetivo
Transformar filosofia estoica em prática diária, com:
- Conteúdo curto, confiável e acionável.
- Recomendação contextual (trabalho, ansiedade, relacionamento, disciplina).
- Rotina com hábito (notificação + check-in).

## 4. Público-alvo
- Adultos 18-45 com interesse em desenvolvimento pessoal.
- Usuários que gostam de leitura curta e rotina diária.
- Iniciantes em estoicismo e praticantes intermediários.

## 5. Proposta de valor
"1 insight estoico por dia, com 1 ação concreta para viver melhor hoje."

## 6. Escopo MVP
### Funcionalidades essenciais
- Citação diária (com fonte e metadados).
- Recomendação prática do dia (1 ação de 5-10 minutos).
- Escolha de autor preferido (ou modo misto).
- Notificação diária com horário configurável.
- Favoritar citações.
- Histórico dos últimos 30 dias.
- Check-in simples: "apliquei hoje" (sim/não + nota curta).

### Fora do MVP
- Comunidade/feed social.
- Gamificação complexa.
- Assinatura paga.
- IA generativa livre para criar citações.

## 7. Requisitos de qualidade
- Toda citação precisa de referência (obra/livro/seção).
- Separar claramente: texto original x interpretação prática.
- UX rápida: abrir app e consumir conteúdo em menos de 30 segundos.
- Funcionar offline com cache local da última semana.

## 8. Métricas principais
- D1 e D7 retention.
- Taxa de abertura da notificação diária.
- Taxa de check-in diário.
- % de usuários que favoritam ao menos 3 citações na primeira semana.

## 9. Riscos e mitigação
- Risco: citação falsa atribuída a autor.
  Mitigação: pipeline editorial com revisão e fonte obrigatória.
- Risco: recomendação prática superficial.
  Mitigação: framework de recomendação por contexto + revisão humana.
- Risco: abandono após poucos dias.
  Mitigação: progressão leve, personalização por tema e horário ideal.

# Previsoes de Custo - Projeto Estoico

Data de inicio: 2026-02-14
Autor: Agente CTO
Moeda: USD (com conversao local quando aplicavel)

## Objetivo
Este documento registra previsoes de custo do projeto, com foco em infraestrutura, operacao, produto e crescimento. Servira como referencia para planejamento financeiro, metas de runway e decisoes de escopo.

## Premissas atuais (a validar)
- Modelo de negocio: assinatura mensal (B2C) + possivel oferta institucional futura.
- Distribuicao: iOS e Android (Flutter), backend proprio.
- Volume de usuarios: estimativas por cenarios (abaixo).
- Regiao principal: Brasil, com infraestrutura em regiao US/EU conforme custo/latencia.
- Conteudo diario com curadoria e notificacoes.

## Escopo considerado na previsao
- Backend e dados (API, scheduler diario, banco, cache)
- Conteudo e curadoria (licencas, direitos, revisao)
- Mobile (build, QA, distribuicao)
- Analytics e observabilidade
- Marketing inicial (orgânico e pago leve)

## Fases e horizontes
- Curto prazo: 0-6 meses (MVP + validacao)
- Medio prazo: 6-18 meses (tracao e melhoria de retenção)
- Longo prazo: 18-36 meses (escala e otimizacao)

## Itens de custo (baseline)
- Infraestrutura
  - Hosting/API
  - Banco de dados
  - Cache/filas
  - Armazenamento de conteudo
- Terceiros
  - Push/FCM/APNs (quando aplicavel)
  - Analytics/Crash (ex: Sentry, Amplitude)
- Operacao
  - Suporte
  - Ferramentas internas
- Produto
  - Design
  - QA
  - Conteudo
- Distribuicao
  - Taxas de loja (Apple/Google)

## Mapa de custos essenciais (MVP ultra-enxuto)
| Categoria | Ferramenta | Custo no MVP | Observacoes |
| --- | --- | --- | --- |
| Publicacao iOS | Apple Developer Program | USD 99/ano | Necessario para publicar no App Store. |
| Publicacao Android | Google Play Console | USD 25 (taxa unica) | Necessario para publicar no Google Play. |
| Backend/DB/Auth/Storage | Firebase (Spark plan) | USD 0 (free tier) | Plano sem custo e sem cartao; uso limitado por quotas. |
| Banco de dados | Cloud Firestore (Spark) | USD 0 dentro da free tier | Quotas: 1 GiB armazenado, 50k reads/dia, 20k writes/dia, 20k deletes/dia, 10 GiB outbound/mes. |
| Analytics | Firebase Analytics | USD 0 | Produto no-cost. |
| Crash | Firebase Crashlytics | USD 0 | Produto no-cost. |
| Push | Firebase Cloud Messaging (FCM) | USD 0 | Produto no-cost. |

## Cenários de custo (rascunho)
### 1) MVP (0-6 meses)
- Usuarios ativos mensais (MAU): 1k - 10k
- Infraestrutura: baixa
- Objetivo: custo mensal <= 1% da receita projetada

### 2) Tracao (6-18 meses)
- MAU: 10k - 100k
- Infraestrutura: moderada
- Objetivo: custo mensal <= 10-15% da receita

### 3) Escala (18-36 meses)
- MAU: 100k - 1M
- Infraestrutura: alta
- Objetivo: custo mensal <= 20% da receita

## Lacunas para completar a previsao
- Projecao de receita por plano (preco, conversao, churn)
- Escolha de stack final de analytics/observabilidade
- Custos reais de push/scheduler e storage de conteudo
- Custo de equipe (FTE/terceiros)

## Proximos passos
- Definir precificacao e metas de conversao
- Estimar custos reais por stack (API, DB, analytics)
- Refinar cenarios com dados de benchmark

## Fontes
- https://developer.apple.com/programs/enroll/
- https://support.google.com/googleplay/android-developer/answer/6112435
- https://firebase.google.com/pricing
- https://firebase.google.com/docs/firestore/pricing

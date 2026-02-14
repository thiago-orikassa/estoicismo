# Contratos de Dados v1 (MA-02)

Data: 2026-02-14
Versão: 1.0.0

## Quote
- id: string (uuid)
- author: enum [seneca, epictetus, marcus_aurelius]
- text: string
- source_work: string
- source_ref: string
- language: enum [pt, en, es]
- theme_primary: string
- theme_secondary: string?
- context_tags: string[]
- authenticity_level: enum [verified, probable]
- created_at: datetime

## DailyRecommendation
- id: string (uuid)
- quote_id: string (uuid)
- context: enum [trabalho, relacionamentos, ansiedade, foco, decisao_dificil]
- action_title: string
- action_steps: string[]
- estimated_minutes: integer [1..30]
- journal_prompt: string
- created_at: datetime

## DailyPackage
- date_local: string (YYYY-MM-DD)
- timezone: string (IANA)
- quote: Quote
- recommendation: DailyRecommendation

## DailyCheckin
- id: string (uuid)
- user_id: string (uuid)
- date_local: string (YYYY-MM-DD)
- applied: boolean
- note: string?
- created_at_utc: datetime
- created_at_local: datetime

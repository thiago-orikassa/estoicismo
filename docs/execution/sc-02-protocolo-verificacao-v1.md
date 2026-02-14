# Protocolo de Verificação de Citações v1 (SC-02)

Data: 2026-02-14
Status: APROVADO (decisão operacional)

## Objetivo
Garantir que toda citação publicada seja literal, verificável e rastreável, mantendo fidelidade filosófica e consistência editorial.

## Decisões confirmadas
1. Fonte de verdade: uma edição canônica por autor, preferencialmente domínio público ou com licença clara.
2. Prioridade: cobertura por contexto do MVP primeiro, com equilíbrio mínimo por autor.
3. Tradução: uma tradução única e consistente por autor em PT, com referência explícita.

## Campos editoriais obrigatórios (por citação)
- catalog_id
- author
- quote_text (literal)
- source_work
- source_ref (livro/seção/parágrafo)
- source_url (ou referência bibliográfica)
- source_edition (edição/ano)
- source_language
- translation_edition (se aplicável)
- translator (se aplicável)
- authenticity_level (verified|probable)
- verification_status (pending_literal_extraction|pending_review|verified|rejected)
- verification_notes
- verified_by
- verified_at (YYYY-MM-DD)

## Fluxo de verificação
1. Inventário de fontes canônicas por autor.
2. Extração literal (texto exato + referência canônica).
3. Revisão cruzada (conferência com fonte primária).
4. Classificação de autenticidade (verified somente com prova documental).
5. Publicação no seed verificado.

## Critérios de aceite
- 100% das citações com fonte explícita.
- Zero citações com status indefinido no seed final.
- `authenticity_level=verified` somente quando comprovado.
- Coerência com taxonomia de temas e contextos do MVP.

## Saídas esperadas
- Seed editorial verificado em `content/seeds/`.
- Catálogo atualizado com evidências de fonte.
- Log de validação por autor.

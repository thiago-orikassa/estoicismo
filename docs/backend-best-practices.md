# Backend — Boas Práticas e Decisões Arquiteturais

> Documento vivo. Atualizado em: 2026-03-08.
> Audiência: qualquer engenheiro que toque o backend Node.js do Aethor.

---

## 1. Princípios gerais

### Dependências mínimas
O backend usa **zero dependências externas em produção** — apenas APIs nativas do Node.js (`node:http`, `node:crypto`, `node:sqlite`, `node:fs`, etc.). Isso reduz a superfície de ataque, elimina atualizações de segurança de terceiros e torna o container de deploy menor.

> **Regra:** antes de adicionar qualquer `npm install`, questionar se `node:crypto`, `node:http` ou outra built-in já resolve. Se a dependência for inevitável, documentar o motivo aqui.

### SQL parametrizado sempre
Todos os acessos ao banco usam `db.prepare(sql).run(params)` ou `.get(params)` — **nunca interpolação de string em SQL**. Isso elimina SQL injection por construção.

```js
// ✅ correto
const row = selectSession.get(tokenHash);

// ❌ nunca fazer
const row = db.prepare(`select * from sessions where token_hash = '${tokenHash}'`).get();
```

### Sem framework HTTP
O servidor usa `node:http` diretamente. Não usar Express, Fastify ou similar sem deliberação explícita. O ganho de produtividade não justifica a dependência para o escopo atual.

---

## 2. Segurança

### 2.1 Autenticação e sessões

**Geração de tokens**
Tokens de sessão usam `randomBytes(32).toString('hex')` — 256 bits de entropia. **Nunca usar `randomUUID()`** para secrets; UUID tem apenas 122 bits efetivos e inclui bits fixos de versão.

```js
// ✅ para access tokens
import { randomBytes } from 'node:crypto';
const token = randomBytes(32).toString('hex');

// ✅ para IDs de banco (não são secrets)
import { randomUUID } from 'node:crypto';
const id = randomUUID();
```

**Armazenamento de tokens**
Tokens nunca são armazenados em texto puro. Sempre persistir o hash SHA-256:

```js
function hashToken(token) {
  return createHash('sha256').update(token).digest('hex');
}
// Banco guarda tokenHash, cliente recebe token
```

**TTL de sessão**
Sessões expiram em **90 dias** (`expires_at_utc`). Toda chamada que cria ou renova um token deve propagar o novo TTL. `requireSession()` rejeita silenciosamente tokens expirados (retorna `null`, handler responde 401).

```js
const SESSION_TTL_MS = 90 * 24 * 60 * 60 * 1000;
function sessionExpiresAt() {
  return new Date(Date.now() + SESSION_TTL_MS).toISOString();
}
```

> Para apps mobile 90 dias é razoável. Não reduzir sem medir o impacto em re-autenticação forçada.

### 2.2 Rate limiting

Rate limiting em memória com janela fixa. Política atual:

| Endpoint | Limite | Janela | Motivo |
|---|---|---|---|
| `POST /v1/auth/send-otp` | 5 req/IP | 15 min | Previne spam de email |
| `POST /v1/auth/verify-otp` | 10 req/IP | 15 min | Previne brute-force do código OTP de 6 dígitos |
| `POST /v1/auth/oauth` | 20 req/IP | 15 min | Previne token stuffing |

**Resposta padrão ao exceder:** HTTP 429 com `retry_after_seconds`.

```js
function allowRequest(routeKey, ip, limit, windowMs) {
  const key = `${routeKey}:${ip}`;
  // ...fixed-window counter...
}
```

> **Limitação conhecida:** o estado de rate limit é in-process. Em múltiplas instâncias (horizontal scaling), cada instância tem seu próprio contador — o limite efetivo se multiplica pelo número de instâncias. Para produção com scaling, migrar para Redis ou similar.

### 2.3 Limite de payload

Todo body de requisição é limitado a **100 KB** em `parseBody()`. Requisições que excedem recebem HTTP 413 e a conexão é destruída imediatamente.

```js
const MAX_BODY_BYTES = 100 * 1024;
// parseBody() conta bytes e chama req.destroy() ao exceder
```

### 2.4 O que não fazer

- **Não logar tokens, hashes ou credenciais** — mesmo em desenvolvimento
- **Não retornar stacks de erro em produção** — apenas `{ error: 'codigo_snake_case' }`
- **Não confiar em `user_id` do body** — sempre usar o `user_id` da sessão autenticada; o body pode conter `user_id` somente para validação cruzada (ex: checkins), nunca como fonte primária de identidade

---

## 3. Banco de dados (SQLite)

### Pragmas obrigatórios

Definidos em `src/db.mjs` e aplicados a toda conexão:

```sql
pragma journal_mode = WAL;     -- leituras concorrentes sem bloquear escritas
pragma foreign_keys = ON;      -- integridade referencial forçada
pragma busy_timeout = 5000;    -- espera até 5s antes de retornar SQLITE_BUSY
```

> Nunca remover `foreign_keys = ON`. Se uma migration quebrar por FK violation, a migration está errada — corrigir o SQL, não desabilitar a constraint.

### Migrations

- Arquivos em `backend/migrations/`, nomeados `NNN_descricao.sql` (zero-padded)
- Cada migration é executada dentro de uma transação explícita (`BEGIN` / `COMMIT` / `ROLLBACK`)
- A tabela `schema_migrations` registra quais migrações foram aplicadas
- **Migrations são irreversíveis** — não há rollback automático. Para desfazer, escrever uma nova migration `NNN_reverter_descricao.sql`
- Testar localmente antes de fazer deploy: `node --experimental-sqlite scripts/start-railway.mjs` em ambiente limpo

### Convenções de schema

- Toda tabela tem `id text primary key` (UUID gerado no aplicativo, não `autoincrement`)
- Timestamps sempre em UTC: `created_at_utc text`, `updated_at_utc text`, formato ISO 8601
- Booleanos como `integer` (0/1) — SQLite não tem tipo boolean nativo
- Soft deletes preferidos a hard deletes (ex: `push_tokens.active = 0`)

---

## 4. API e contratos

### Códigos HTTP

| Situação | Código |
|---|---|
| Sucesso com corpo | 200 |
| Recurso criado | 201 |
| Bad request / validação | 400 |
| Sem autenticação | 401 |
| Autenticado mas sem permissão | 403 |
| Recurso não encontrado | 404 |
| Conflito de estado | 409 |
| Recurso expirado (OTP, etc.) | 410 |
| Rate limit excedido | 429 |
| Erro interno | 500 |

### Formato de erro

Sempre retornar um objeto com `error` em snake_case. Nunca retornar strings soltas ou stacks.

```json
{ "error": "invalid_device_id", "message": "device_id must be non-empty string" }
{ "error": "unauthorized" }
{ "error": "too_many_requests", "retry_after_seconds": 900 }
```

### Validação de entrada

- Validar **tipo**, **formato** e **tamanho máximo** de cada campo antes de usar
- Campos de texto: sempre `.trim()` antes de validar comprimento
- Timezone: `new Intl.DateTimeFormat('en-US', { timeZone: tz })` — é o validador mais correto disponível
- Email: regex básico + lowercase + trim. Não usar bibliotecas pesadas para isso
- IDs externos (user_id, quote_id): verificar formato UUID antes de bater no banco

---

## 5. Logging

### Estrutura

Logs em JSON estruturado via `src/logger.mjs`. Campos obrigatórios em todo log:

```json
{
  "timestamp_utc": "2026-03-08T...",
  "level": "info|warn|error",
  "service": "aethor-backend",
  "runtime_env": "production",
  "event": "nome_snake_case",
  ...campos adicionais
}
```

### O que logar

| Evento | Nível | Quando |
|---|---|---|
| `server_bootstrap` | info | Startup — configuração carregada |
| `server_listening` | info | Porta aberta |
| `http_request_completed` | info | Toda requisição (método, path, status, duração, user_id) |
| `otp_code_dev` | info | Apenas quando `RESEND_API_KEY` não está definida (dev only) |
| `observability_metrics_unauthorized` | warn | Tentativa de acesso sem token |
| `fcm_send_error` | error | Falha ao enviar push |

### O que NÃO logar

- Tokens, hashes, senhas, códigos OTP em produção
- Conteúdo de requests (pode conter PII)
- Stack traces completos de erros esperados (ex: JSON inválido) — apenas o evento é suficiente

---

## 6. Variáveis de ambiente

| Variável | Obrigatória em prod | Padrão | Descrição |
|---|---|---|---|
| `PORT` | Sim (Railway injeta) | 8787 | Porta HTTP |
| `HOST` | Sim | 0.0.0.0 | Interface de bind |
| `STOIC_DATA_DIR` | Não | `./data` | Diretório de dados |
| `STOIC_DB_PATH` | Não | `$DATA_DIR/aethor.db` | Caminho do SQLite |
| `STOIC_SEED_PATH` | Não | `$DATA_DIR/daily_seed.json` | Seed de conteúdo |
| `STOIC_RUNTIME_ENV` | Sim | `dev` | `production` / `dev` / `stage` |
| `JWT_SECRET` | Sim | — | Segredo para JWT (Railway) |
| `RESEND_API_KEY` | Sim (para email OTP) | — | Chave da API Resend |
| `FCM_SERVICE_ACCOUNT_PATH` | Sim (para push) | `secrets/fcm-service-account.json` | Service account Firebase |
| `STOIC_OBSERVABILITY_TOKEN` | Recomendado | `""` (sem auth) | Token para `/v1/observability/metrics` |
| `NIXPACKS_NODE_VERSION` | Sim (Railway) | — | `23` — necessário para `node:sqlite` |

> **Segredos nunca entram no código ou no git.** Adicionar ao Railway via dashboard ou `railway variables set --skip-deploys KEY=VALUE`.

---

## 7. Deploy (Railway)

### Fluxo

1. `railway up --detach` a partir de `backend/` — faz upload e build via Nixpacks
2. `nixpacks.toml` força `nodejs_23` (necessário para `node:sqlite`)
3. `railway.json` define o comando de start: `npm run start:railway`
4. `start-railway.mjs` executa na sequência: cria dirs → copia seed → migrations → inicia servidor

### Checklist antes de deploy

- [ ] Testes passando: `npm run test`
- [ ] Seed validada: `npm run validate:seed`
- [ ] Variáveis de produção configuradas no Railway dashboard
- [ ] Nova migration testada localmente em banco limpo

### Node.js em produção

- Versão mínima: **Node 23** (`node:sqlite` é experimental no 22 e estável no 23+)
- Flag `--experimental-sqlite` necessária até Node 23.4 / 24+
- Em `start-railway.mjs`: o processo filho (servidor) herda o flag via `spawn(['--experimental-sqlite', 'src/server.mjs'])`

### Persistência ⚠️

**Estado atual:** SQLite em disco local do container Railway — **ephemeral**. Dados são perdidos em cada redeploy.

**Para produção real (BE-09):** configurar Railway Volume montado em `$STOIC_DATA_DIR`. O volume persiste entre deploys.

Enquanto BE-09 não estiver completo, o banco é recriado do seed a cada redeploy. Isso é aceitável para TestFlight interno, não para release público.

---

## 8. Testes

### Rodar os testes

```bash
node --experimental-sqlite --test tests/*.mjs
```

### Estrutura

| Arquivo | Cobertura |
|---|---|
| `tests/server.test.mjs` | Endpoints REST (happy path + validação) |
| `tests/monetization.test.mjs` | Fluxo trial → compra → restore |
| `tests/ritual-7day.test.mjs` | Push → deeplink → daily-package → check-in → favorito |

### Padrões

- Cada teste cria seu próprio diretório de dados temporário (`mkdtempSync`) — isolamento total
- Banco é sempre um novo SQLite em memória/tmp — sem dependência de dados externos
- `FCM_DRY_RUN=true` desabilita envio real de push nos testes
- Servidor escuta em porta aleatória (`server.listen(0)`) — sem conflito de porta
- Teardown em `after()` fecha o servidor e limpa o diretório temp

### O que testar obrigatoriamente ao adicionar endpoint

1. Happy path — resposta esperada com dados válidos
2. Autenticação — 401 sem token, 403 com token de usuário errado
3. Validação — 400 para campos obrigatórios faltando e tipos inválidos
4. Idempotência — se aplicável (ex: restore, upserts)

---

## 9. Dívida técnica conhecida (priorizada)

| ID | Item | Prioridade | Bloqueador de release |
|---|---|---|---|
| BE-09 | Railway Volume para SQLite persistente | P0 | **Sim** — dados são perdidos em redeploy |
| BE-10 | Validação de recibos Apple/Google server-side | P1 | Não (fraude controlada pelo app) |
| BE-12 | Audit log de mudanças de assinatura | P2 | Não |
| — | Rate limiting multi-instância (Redis) | P2 | Não (single instance agora) |
| — | HTTPS enforcement no servidor | P2 | Não (Railway termina TLS) |

---

## 10. Referências

- [Node.js SQLite docs](https://nodejs.org/api/sqlite.html) — `node:sqlite` (experimental em < 23.4)
- [Railway — Volumes](https://docs.railway.com/guides/volumes) — persistência de dados
- [Nixpacks — Node.js](https://nixpacks.com/docs/providers/node) — configuração de build
- [OWASP Top 10](https://owasp.org/www-project-top-ten/) — referência de segurança web
- [Resend API](https://resend.com/docs/api-reference/emails/send-email) — envio de email OTP

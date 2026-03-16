// Testes unitários da feature de Favoritos.
//
// Cobre:
//   1. Deserialização do modelo Favorite
//   2. isFavorited — lógica de busca na lista
//   3. findQuoteById — busca em daily e history
//   4. shouldPromptAfterFavorite / markFavoritePromptShown
//   5. toggleFavorite — fluxo de adicionar e remover
//   6. Limites do plano free (upsell) e filtro de busca

import 'package:flutter_test/flutter_test.dart';

import 'package:aethor_app/app_state.dart';
import 'package:aethor_app/features/daily_quote/data/daily_repository.dart';
import 'package:aethor_app/features/daily_quote/domain/models.dart';
import 'package:aethor_app/core/auth/session_service.dart';
import 'package:aethor_app/core/networking/api_client.dart';
import 'package:aethor_app/core/storage/secure_store.dart';

// ---------------------------------------------------------------------------
// Helpers de criação de objetos de domínio
// ---------------------------------------------------------------------------

Favorite _makeFavorite({
  String id = 'fav-1',
  String userId = 'user-1',
  String quoteId = 'quote-1',
  String createdAtUtc = '2026-02-21T00:00:00Z',
}) =>
    Favorite(
      id: id,
      userId: userId,
      quoteId: quoteId,
      createdAtUtc: createdAtUtc,
    );

Quote _makeQuote({
  String id = 'quote-1',
  String author = 'Marco Aurélio',
  String text = 'Você tem poder sobre sua mente.',
  String sourceWork = 'Meditações',
  String sourceRef = 'VI.2',
}) =>
    Quote(
      id: id,
      author: author,
      text: text,
      sourceWork: sourceWork,
      sourceRef: sourceRef,
      behaviorIntent: 'reflexão',
      contextTags: const ['estoicismo'],
    );

Recommendation _makeRec() => Recommendation(
      context: 'foco',
      title: 'Meditação matinal',
      quoteLinkExplanation: 'A citação convida à reflexão.',
      steps: const ['Respire fundo', 'Leia a citação'],
      minutes: 5,
      expectedOutcome: 'Clareza mental.',
      completionCriteria: 'Concluiu a reflexão.',
      journalPrompt: 'O que você aprendeu hoje?',
    );

DailyPackage _makeDaily({required Quote quote}) => DailyPackage(
      dateLocal: '2026-02-21',
      timezone: 'America/Sao_Paulo',
      userContext: null,
      quote: quote,
      recommendation: _makeRec(),
    );

// ---------------------------------------------------------------------------
// Fakes de infra (sem I/O real)
// ---------------------------------------------------------------------------

class _FakeRepo extends DailyRepository {
  _FakeRepo() : super(ApiClient(baseUrl: 'http://test'));

  // Estado interno que simula o banco do servidor
  final List<Favorite> fakes = [];

  bool addCalled = false;
  bool removeCalled = false;
  String? lastAddedQuoteId;
  String? lastRemovedQuoteId;

  @override
  Future<List<Favorite>> listFavorites({required String userId}) async =>
      List.of(fakes);

  @override
  Future<void> addFavorite({
    required String userId,
    required String quoteId,
  }) async {
    addCalled = true;
    lastAddedQuoteId = quoteId;
    fakes.add(Favorite(
      id: 'fav-$quoteId',
      userId: userId,
      quoteId: quoteId,
      createdAtUtc: '2026-02-21T00:00:00Z',
    ));
  }

  @override
  Future<void> removeFavorite({
    required String userId,
    required String quoteId,
  }) async {
    removeCalled = true;
    lastRemovedQuoteId = quoteId;
    fakes.removeWhere((f) => f.quoteId == quoteId);
  }
}

class _FakeSessionService extends SessionService {
  _FakeSessionService()
      : super(
          ApiClient(baseUrl: 'http://test'),
          SecureStore(),
        );

  @override
  Future<SessionData> ensureSession() async => const SessionData(
        deviceId: 'dev-1',
        userId: 'user-1',
        accessToken: 'token-1',
        isNew: false,
      );

  @override
  Future<void> clearSession() async {}
}

// Constrói um AppState pronto para uso, sem inicialização de rede.
AppState _buildState({_FakeRepo? repo}) {
  final fakeRepo = repo ?? _FakeRepo();
  final state = AppState(fakeRepo, _FakeSessionService());
  // userId precisa ser definido para os métodos que verificam autenticação
  state.userId = 'user-1';
  return state;
}

// ---------------------------------------------------------------------------
// Testes
// ---------------------------------------------------------------------------

void main() {
  // ─── 1. Deserialização do modelo ─────────────────────────────────────────

  group('Favorite.fromJson', () {
    test('parseia todos os campos corretamente', () {
      final json = {
        'id': 'fav-abc',
        'user_id': 'usr-123',
        'quote_id': 'qt-456',
        'created_at_utc': '2026-01-01T12:00:00Z',
      };

      final fav = Favorite.fromJson(json);

      expect(fav.id, 'fav-abc');
      expect(fav.userId, 'usr-123');
      expect(fav.quoteId, 'qt-456');
      expect(fav.createdAtUtc, '2026-01-01T12:00:00Z');
    });

    test('fromJson com quoteId diferente mantém id separado', () {
      final f1 = Favorite.fromJson({
        'id': 'fav-1',
        'user_id': 'u',
        'quote_id': 'q1',
        'created_at_utc': '2026-01-01T00:00:00Z',
      });
      final f2 = Favorite.fromJson({
        'id': 'fav-2',
        'user_id': 'u',
        'quote_id': 'q2',
        'created_at_utc': '2026-01-02T00:00:00Z',
      });

      expect(f1.quoteId, isNot(f2.quoteId));
      expect(f1.id, isNot(f2.id));
    });

    test('fromJson preserva createdAtUtc sem modificações', () {
      const ts = '2025-12-31T23:59:59Z';
      final fav = Favorite.fromJson({
        'id': 'x',
        'user_id': 'u',
        'quote_id': 'q',
        'created_at_utc': ts,
      });
      expect(fav.createdAtUtc, ts);
    });
  });

  // ─── 2. isFavorited ──────────────────────────────────────────────────────

  group('AppState.isFavorited', () {
    test('retorna false quando a lista está vazia', () {
      final state = _buildState();
      expect(state.isFavorited('quote-1'), isFalse);
    });

    test('retorna true quando o quoteId está na lista', () {
      final state = _buildState();
      state.favorites = [_makeFavorite(quoteId: 'quote-1')];

      expect(state.isFavorited('quote-1'), isTrue);
    });

    test('retorna false para quoteId diferente', () {
      final state = _buildState();
      state.favorites = [_makeFavorite(quoteId: 'quote-1')];

      expect(state.isFavorited('quote-2'), isFalse);
    });

    test('funciona com múltiplos favoritos', () {
      final state = _buildState();
      state.favorites = [
        _makeFavorite(id: 'f1', quoteId: 'q1'),
        _makeFavorite(id: 'f2', quoteId: 'q2'),
        _makeFavorite(id: 'f3', quoteId: 'q3'),
      ];

      expect(state.isFavorited('q1'), isTrue);
      expect(state.isFavorited('q2'), isTrue);
      expect(state.isFavorited('q3'), isTrue);
      expect(state.isFavorited('q4'), isFalse);
    });
  });

  // ─── 3. findQuoteById ────────────────────────────────────────────────────

  group('AppState.findQuoteById', () {
    test('retorna null quando daily e history estão vazios', () {
      final state = _buildState();
      expect(state.findQuoteById('any-id'), isNull);
    });

    test('encontra citação no daily', () {
      final state = _buildState();
      final quote = _makeQuote(id: 'q-daily');
      state.daily = _makeDaily(quote: quote);

      final found = state.findQuoteById('q-daily');

      expect(found, isNotNull);
      expect(found!.id, 'q-daily');
    });

    test('retorna null quando quoteId não corresponde ao daily', () {
      final state = _buildState();
      state.daily = _makeDaily(quote: _makeQuote(id: 'q-daily'));

      expect(state.findQuoteById('outro-id'), isNull);
    });

    test('encontra citação no history', () {
      final state = _buildState();
      final quote = _makeQuote(id: 'q-hist');
      state.history = [_makeDaily(quote: quote)];

      final found = state.findQuoteById('q-hist');

      expect(found, isNotNull);
      expect(found!.id, 'q-hist');
    });

    test('prioriza daily sobre history quando ambos têm o mesmo id', () {
      final state = _buildState();
      final dailyQuote = _makeQuote(id: 'q-shared', text: 'Do daily');
      final histQuote = _makeQuote(id: 'q-shared', text: 'Do history');
      state.daily = _makeDaily(quote: dailyQuote);
      state.history = [_makeDaily(quote: histQuote)];

      final found = state.findQuoteById('q-shared');

      // O daily é verificado primeiro
      expect(found!.text, 'Do daily');
    });

    test('encontra entre vários itens no history', () {
      final state = _buildState();
      state.history = [
        _makeDaily(quote: _makeQuote(id: 'q1')),
        _makeDaily(quote: _makeQuote(id: 'q2')),
        _makeDaily(quote: _makeQuote(id: 'q3')),
      ];

      expect(state.findQuoteById('q2')?.id, 'q2');
      expect(state.findQuoteById('q99'), isNull);
    });
  });

  // ─── 4. Login prompt após favoritar ──────────────────────────────────────

  group('shouldPromptAfterFavorite / markFavoritePromptShown', () {
    test('retorna true quando usuário não autenticado e prompt não foi exibido',
        () {
      final state = _buildState();
      state.isAuthenticated = false;
      state.hasShownFavoritePrompt = false;
      state.hasShownLoginPromptThisSession = false;

      expect(state.shouldPromptAfterFavorite, isTrue);
    });

    test('retorna false quando usuário já está autenticado', () {
      final state = _buildState();
      state.isAuthenticated = true;
      state.hasShownFavoritePrompt = false;
      state.hasShownLoginPromptThisSession = false;

      expect(state.shouldPromptAfterFavorite, isFalse);
    });

    test('retorna false quando prompt já foi exibido nesta sessão', () {
      final state = _buildState();
      state.isAuthenticated = false;
      state.hasShownLoginPromptThisSession = true;

      expect(state.shouldPromptAfterFavorite, isFalse);
    });

    test('retorna false quando prompt de favorito já foi marcado', () {
      final state = _buildState();
      state.isAuthenticated = false;
      state.hasShownLoginPromptThisSession = false;
      state.hasShownFavoritePrompt = true;

      expect(state.shouldPromptAfterFavorite, isFalse);
    });

    test('markFavoritePromptShown é idempotente', () {
      final state = _buildState();
      state.isAuthenticated = false;
      state.hasShownLoginPromptThisSession = false;

      state.markFavoritePromptShown();
      expect(state.hasShownFavoritePrompt, isTrue);

      // Segunda chamada não deve alterar o estado nem lançar exceção
      state.markFavoritePromptShown();
      expect(state.hasShownFavoritePrompt, isTrue);
    });
  });

  // ─── 5. toggleFavorite ───────────────────────────────────────────────────

  group('AppState.toggleFavorite', () {
    test('adiciona favorito quando citação ainda não está na lista', () async {
      final repo = _FakeRepo();
      final state = _buildState(repo: repo);

      // Lista vazia → isFavorited('q-new') == false → deve chamar addFavorite
      state.favorites = [];

      await state.toggleFavorite('q-new');

      expect(repo.addCalled, isTrue);
      expect(repo.lastAddedQuoteId, 'q-new');
      expect(state.isFavorited('q-new'), isTrue);
    });

    test('remove favorito quando citação já está na lista', () async {
      final repo = _FakeRepo();
      // Semeia o estado tanto no repo quanto no AppState
      repo.fakes.add(_makeFavorite(quoteId: 'q-existing'));
      final state = _buildState(repo: repo);
      state.favorites = [_makeFavorite(quoteId: 'q-existing')];

      await state.toggleFavorite('q-existing');

      expect(repo.removeCalled, isTrue);
      expect(repo.lastRemovedQuoteId, 'q-existing');
      expect(state.isFavorited('q-existing'), isFalse);
    });

    test('sincroniza lista após adicionar (loadFavorites interno)', () async {
      final repo = _FakeRepo();
      final state = _buildState(repo: repo);
      state.favorites = [];

      await state.toggleFavorite('q-sync');

      // Após toggleFavorite, loadFavorites é chamado internamente
      expect(state.favorites.length, 1);
      expect(state.favorites.first.quoteId, 'q-sync');
    });

    test('sincroniza lista após remover (loadFavorites interno)', () async {
      final repo = _FakeRepo();
      repo.fakes.add(_makeFavorite(quoteId: 'q-rm'));
      final state = _buildState(repo: repo);
      state.favorites = [_makeFavorite(quoteId: 'q-rm')];

      await state.toggleFavorite('q-rm');

      expect(state.favorites, isEmpty);
    });

    test('múltiplos favoritos independentes são gerenciados corretamente',
        () async {
      final repo = _FakeRepo();
      final state = _buildState(repo: repo);
      state.favorites = [];

      await state.toggleFavorite('q-a');
      await state.toggleFavorite('q-b');
      await state.toggleFavorite('q-c');

      expect(state.favorites.length, 3);
      expect(state.isFavorited('q-a'), isTrue);
      expect(state.isFavorited('q-b'), isTrue);
      expect(state.isFavorited('q-c'), isTrue);
    });

    test('lança exceção quando userId está vazio e sessão não inicializa',
        () async {
      final repo = _FakeRepo();
      // Fake de sessão que não consegue restaurar userId
      final badSession = _BadSessionService();
      final state = AppState(repo, badSession);
      // userId permanece vazio

      await expectLater(
        () => state.toggleFavorite('q-any'),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ─── 6. Limites do plano free e filtro de busca ──────────────────────────

  group('Free tier limit (lógica de dados)', () {
    test('usuário free vê no máximo 10 favoritos', () {
      final allFavorites = List.generate(
        15,
        (i) => _makeFavorite(id: 'f$i', quoteId: 'q$i'),
      );

      // Simula a lógica da FavoritesScreen
      const freeLimit = 10;
      final favoritesToShow = allFavorites.take(freeLimit).toList();

      expect(favoritesToShow.length, 10);
    });

    test('showUpsell é verdadeiro quando há mais de 10 favoritos (não Pro)', () {
      final allFavorites = List.generate(
        12,
        (i) => _makeFavorite(id: 'f$i', quoteId: 'q$i'),
      );
      const isPro = false;
      const freeLimit = 10;
      final favoritesToShow = isPro
          ? allFavorites
          : allFavorites.take(freeLimit).toList(growable: false);
      final showUpsell = !isPro && allFavorites.length > favoritesToShow.length;

      expect(showUpsell, isTrue);
    });

    test('showUpsell é falso quando há 10 ou menos favoritos', () {
      final allFavorites = List.generate(
        10,
        (i) => _makeFavorite(id: 'f$i', quoteId: 'q$i'),
      );
      const isPro = false;
      const freeLimit = 10;
      final favoritesToShow = allFavorites.take(freeLimit).toList();
      final showUpsell = !isPro && allFavorites.length > favoritesToShow.length;

      expect(showUpsell, isFalse);
    });

    test('showUpsell é falso para usuário Pro mesmo com mais de 10 favoritos',
        () {
      final allFavorites = List.generate(
        20,
        (i) => _makeFavorite(id: 'f$i', quoteId: 'q$i'),
      );
      const isPro = true;
      const freeLimit = 10;
      final favoritesToShow = isPro
          ? allFavorites
          : allFavorites.take(freeLimit).toList(growable: false);
      final showUpsell = !isPro && allFavorites.length > favoritesToShow.length;

      expect(showUpsell, isFalse);
      expect(favoritesToShow.length, 20);
    });
  });

  group('Filtro de busca por texto e autor', () {
    test('sem query retorna todos os favoritos', () {
      final state = _buildState();
      final quotes = [
        _makeQuote(id: 'q1', text: 'Controle o que é seu', author: 'Epicteto'),
        _makeQuote(id: 'q2', text: 'Viva conforme a natureza', author: 'Sêneca'),
      ];
      state.history = quotes.map((q) => _makeDaily(quote: q)).toList();

      final favorites = [
        _makeFavorite(id: 'f1', quoteId: 'q1'),
        _makeFavorite(id: 'f2', quoteId: 'q2'),
      ];

      // Simula lógica de filtro da FavoritesScreen
      const searchQuery = '';
      final filtered = searchQuery.isEmpty
          ? favorites
          : favorites.where((fav) {
              final quote = state.findQuoteById(fav.quoteId);
              if (quote == null) return false;
              final q = searchQuery.toLowerCase();
              return quote.text.toLowerCase().contains(q) ||
                  quote.author.toLowerCase().contains(q);
            }).toList();

      expect(filtered.length, 2);
    });

    test('filtra por texto da citação', () {
      final state = _buildState();
      final quotes = [
        _makeQuote(id: 'q1', text: 'Controle o que é seu', author: 'Epicteto'),
        _makeQuote(id: 'q2', text: 'Viva conforme a natureza', author: 'Sêneca'),
      ];
      state.history = quotes.map((q) => _makeDaily(quote: q)).toList();

      final favorites = [
        _makeFavorite(id: 'f1', quoteId: 'q1'),
        _makeFavorite(id: 'f2', quoteId: 'q2'),
      ];

      const searchQuery = 'natureza';
      final filtered = favorites.where((fav) {
        final quote = state.findQuoteById(fav.quoteId);
        if (quote == null) return false;
        final q = searchQuery.toLowerCase();
        return quote.text.toLowerCase().contains(q) ||
            quote.author.toLowerCase().contains(q);
      }).toList();

      expect(filtered.length, 1);
      expect(filtered.first.quoteId, 'q2');
    });

    test('filtra por nome do autor', () {
      final state = _buildState();
      final quotes = [
        _makeQuote(id: 'q1', text: 'Citação A', author: 'Epicteto'),
        _makeQuote(id: 'q2', text: 'Citação B', author: 'Sêneca'),
        _makeQuote(id: 'q3', text: 'Citação C', author: 'Marco Aurélio'),
      ];
      state.history = quotes.map((q) => _makeDaily(quote: q)).toList();

      final favorites = [
        _makeFavorite(id: 'f1', quoteId: 'q1'),
        _makeFavorite(id: 'f2', quoteId: 'q2'),
        _makeFavorite(id: 'f3', quoteId: 'q3'),
      ];

      const searchQuery = 'sêneca';
      final filtered = favorites.where((fav) {
        final quote = state.findQuoteById(fav.quoteId);
        if (quote == null) return false;
        final q = searchQuery.toLowerCase();
        return quote.text.toLowerCase().contains(q) ||
            quote.author.toLowerCase().contains(q);
      }).toList();

      expect(filtered.length, 1);
      expect(filtered.first.quoteId, 'q2');
    });

    test('busca case-insensitive', () {
      final state = _buildState();
      final quote = _makeQuote(id: 'q1', text: 'Sabedoria Estoica', author: 'Epicteto');
      state.history = [_makeDaily(quote: quote)];

      final favorites = [_makeFavorite(quoteId: 'q1')];

      for (final query in ['SABEDORIA', 'sabedoria', 'Sabedoria', 'sAbEdOrIa']) {
        final filtered = favorites.where((fav) {
          final q = state.findQuoteById(fav.quoteId);
          if (q == null) return false;
          final lq = query.toLowerCase();
          return q.text.toLowerCase().contains(lq) ||
              q.author.toLowerCase().contains(lq);
        }).toList();

        expect(filtered.length, 1, reason: 'query "$query" deveria encontrar 1 resultado');
      }
    });

    test('retorna lista vazia quando query não corresponde a nenhuma citação', () {
      final state = _buildState();
      state.history = [
        _makeDaily(quote: _makeQuote(id: 'q1', text: 'Texto A', author: 'Autor A')),
      ];

      final favorites = [_makeFavorite(quoteId: 'q1')];

      const searchQuery = 'xyzzy-inexistente';
      final filtered = favorites.where((fav) {
        final quote = state.findQuoteById(fav.quoteId);
        if (quote == null) return false;
        final q = searchQuery.toLowerCase();
        return quote.text.toLowerCase().contains(q) ||
            quote.author.toLowerCase().contains(q);
      }).toList();

      expect(filtered, isEmpty);
    });

    test('favorito sem quote carregada é excluído do filtro de busca', () {
      final state = _buildState();
      // Nenhuma quote carregada no state
      state.history = [];
      state.daily = null;

      final favorites = [_makeFavorite(quoteId: 'q-sem-dados')];

      const searchQuery = 'qualquer';
      final filtered = favorites.where((fav) {
        final quote = state.findQuoteById(fav.quoteId);
        if (quote == null) return false;
        final q = searchQuery.toLowerCase();
        return quote.text.toLowerCase().contains(q) ||
            quote.author.toLowerCase().contains(q);
      }).toList();

      expect(filtered, isEmpty);
    });
  });
}

// SessionService que falha ao restaurar sessão (simula userId vazio)
class _BadSessionService extends SessionService {
  _BadSessionService()
      : super(
          ApiClient(baseUrl: 'http://test'),
          SecureStore(),
        );

  @override
  Future<SessionData> ensureSession() async =>
      throw Exception('Sessão indisponível');

  @override
  Future<void> clearSession() async {}
}

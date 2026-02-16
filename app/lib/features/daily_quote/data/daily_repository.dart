import '../../../core/networking/api_client.dart';
import '../domain/models.dart';

class DailyRepository {
  DailyRepository(this._api);

  final ApiClient _api;
  ApiClient get api => _api;

  Future<DailyPackage> fetchDailyPackage({
    required String timezone,
    String? dateLocal,
    String? userContext,
  }) async {
    final data = await _api.get(
      '/v1/daily-package',
      query: {
        if (dateLocal != null && dateLocal.isNotEmpty) 'date_local': dateLocal,
        'timezone': timezone,
        if (userContext != null && userContext.isNotEmpty)
          'user_context': userContext,
      },
    );
    return DailyPackage.fromJson(data);
  }

  Future<List<DailyPackage>> fetchHistory({
    required String timezone,
    String? dateLocal,
    int days = 30,
    String? userContext,
  }) async {
    final data = await _api.get(
      '/v1/history',
      query: {
        if (dateLocal != null && dateLocal.isNotEmpty) 'date_local': dateLocal,
        'timezone': timezone,
        'days': '$days',
        if (userContext != null && userContext.isNotEmpty)
          'user_context': userContext,
      },
    );

    final items = (data['items'] as List<dynamic>)
        .map((e) => DailyPackage.fromJson(e as Map<String, dynamic>))
        .toList();
    return items;
  }

  Future<void> submitCheckin({
    required String userId,
    required String dateLocal,
    required bool applied,
    required String timezone,
    String? note,
  }) async {
    await _api.post('/v1/checkins', body: {
      'user_id': userId,
      'date_local': dateLocal,
      'applied': applied,
      'timezone': timezone,
      if (note != null && note.isNotEmpty) 'note': note,
    });
  }

  Future<List<Favorite>> listFavorites({required String userId}) async {
    final data = await _api.get('/v1/favorites', query: {'user_id': userId});
    return (data['items'] as List<dynamic>)
        .map((e) => Favorite.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorite({
    required String userId,
    required String quoteId,
  }) async {
    await _api.post('/v1/favorites', body: {
      'user_id': userId,
      'quote_id': quoteId,
    });
  }

  Future<void> removeFavorite({
    required String userId,
    required String quoteId,
  }) async {
    await _api.delete('/v1/favorites',
        query: {'user_id': userId, 'quote_id': quoteId});
  }

  Future<void> trackEvent({
    required String eventName,
    required Map<String, dynamic> properties,
  }) async {
    await _api.post('/v1/analytics/events', body: {
      'event_name': eventName,
      'properties': properties,
    });
  }
}

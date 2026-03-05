import 'dart:io';

import 'package:uuid/uuid.dart';

import '../networking/api_client.dart';
import '../storage/secure_store.dart';

class SessionService {
  SessionService(
    this._api,
    this._secureStore, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final ApiClient _api;
  final SecureStore _secureStore;
  final Uuid _uuid;

  Future<SessionData> ensureSession() async {
    var deviceId = await _secureStore.readDeviceId();
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _uuid.v4();
      await _secureStore.writeDeviceId(deviceId);
    }

    final storedUserId = await _secureStore.readUserId();
    final storedToken = await _secureStore.readAccessToken();
    if (_isValid(storedUserId) && _isValid(storedToken)) {
      _api.setAccessToken(storedToken);
      return SessionData(
        deviceId: deviceId,
        userId: storedUserId!,
        accessToken: storedToken!,
        isNew: false,
      );
    }

    final data = await _api.post('/v1/session', body: {'device_id': deviceId});
    final userId = data['user_id'] as String?;
    final token = data['access_token'] as String?;
    if (!_isValid(userId) || !_isValid(token)) {
      throw const HttpException('invalid_session_response');
    }

    await _secureStore.writeUserId(userId!);
    await _secureStore.writeAccessToken(token!);
    _api.setAccessToken(token);
    return SessionData(
      deviceId: deviceId,
      userId: userId,
      accessToken: token,
      isNew: true,
    );
  }

  Future<void> storeCredentials({
    required String userId,
    required String accessToken,
  }) async {
    await _secureStore.writeUserId(userId);
    await _secureStore.writeAccessToken(accessToken);
    _api.setAccessToken(accessToken);
  }

  Future<void> clearSession() async {
    await _secureStore.clear();
    _api.setAccessToken(null);
  }

  bool _isValid(String? value) => value != null && value.trim().isNotEmpty;
}

class SessionData {
  const SessionData({
    required this.deviceId,
    required this.userId,
    required this.accessToken,
    required this.isNew,
  });

  final String deviceId;
  final String userId;
  final String accessToken;
  final bool isNew;
}

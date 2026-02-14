import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const _deviceIdKey = 'device_id';
  static const _userIdKey = 'user_id';
  static const _accessTokenKey = 'access_token';

  SecureStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String?> readDeviceId() => _storage.read(key: _deviceIdKey);

  Future<void> writeDeviceId(String value) =>
      _storage.write(key: _deviceIdKey, value: value);

  Future<String?> readUserId() => _storage.read(key: _userIdKey);

  Future<void> writeUserId(String value) =>
      _storage.write(key: _userIdKey, value: value);

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> writeAccessToken(String value) =>
      _storage.write(key: _accessTokenKey, value: value);

  Future<void> clear() async {
    await _storage.delete(key: _deviceIdKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _accessTokenKey);
  }
}

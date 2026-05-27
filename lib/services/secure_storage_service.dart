import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // In-memory cache to avoid repeated platform keystore round-trips.
  final Map<String, String> _cache = {};

  Future<void> saveApiKey(String key, String value) async {
    _cache[key] = value;
    await _storage.write(key: key, value: value);
  }

  Future<String?> getApiKey(String key) async {
    final cached = _cache[key];
    if (cached != null) return cached;
    final value = await _storage.read(key: key);
    if (value != null) _cache[key] = value;
    return value;
  }

  Future<void> deleteApiKey(String key) async {
    _cache.remove(key);
    await _storage.delete(key: key);
  }

  Future<void> deleteAllApiKeys() async {
    _cache.clear();
    await _storage.deleteAll();
  }

  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
}

class StorageKeys {
  static const String apiToken = 'api_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
}

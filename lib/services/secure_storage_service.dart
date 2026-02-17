import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> saveApiKey(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getApiKey(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteApiKey(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAllApiKeys() async {
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

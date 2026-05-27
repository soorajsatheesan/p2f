import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class QuoteCacheService {
  static const _key = 'p2f_quote_cache_v1';
  static const _ttlHours = 24;

  Future<CachedQuote?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CachedQuote(
        quote: map['quote'] as String,
        profileSignature: map['signature'] as String,
        cachedAt: DateTime.parse(map['cached_at'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save({
    required String quote,
    required String profileSignature,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({
        'quote': quote,
        'signature': profileSignature,
        'cached_at': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class CachedQuote {
  const CachedQuote({
    required this.quote,
    required this.profileSignature,
    required this.cachedAt,
  });

  final String quote;
  final String profileSignature;
  final DateTime cachedAt;

  bool get isExpired =>
      DateTime.now().difference(cachedAt).inHours >= QuoteCacheService._ttlHours;
}

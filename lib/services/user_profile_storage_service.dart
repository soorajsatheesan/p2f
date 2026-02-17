import 'dart:convert';

import 'package:p2f/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileStorageService {
  static const String _profileKey = 'p2f_user_profile_v1';

  Future<UserProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(profile.toJson());
    await prefs.setString(_profileKey, encoded);
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }
}

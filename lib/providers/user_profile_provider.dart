import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/models/user_profile.dart';
import 'package:p2f/services/user_profile_storage_service.dart';

final userProfileStorageProvider = Provider<UserProfileStorageService>((ref) {
  return UserProfileStorageService();
});

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
      return UserProfileNotifier(storage: ref.read(userProfileStorageProvider));
    });

class UserProfileState {
  const UserProfileState({
    this.profile,
    this.isLoading = true,
    this.isSaving = false,
    this.errorMessage,
  });

  final UserProfile? profile;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  bool get hasProfile => profile != null;

  UserProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isSaving,
    Object? errorMessage = _sentinel,
    bool clearProfile = false,
  }) {
    return UserProfileState(
      profile: clearProfile ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _sentinel = Object();

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier({required UserProfileStorageService storage})
    : _storage = storage,
      super(const UserProfileState()) {
    loadProfile();
  }

  final UserProfileStorageService _storage;

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _storage.getProfile();
      state = state.copyWith(
        profile: profile,
        clearProfile: profile == null,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load your profile.',
      );
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _storage.saveProfile(profile);
      state = state.copyWith(profile: profile, isSaving: false);
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Unable to save profile. Please try again.',
      );
    }
  }
}

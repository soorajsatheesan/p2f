import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2f/services/gemini_validation_service.dart';
import 'package:p2f/services/secure_storage_service.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final geminiValidationServiceProvider = Provider<GeminiValidationService>((
  ref,
) {
  return GeminiValidationService();
});

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(
    geminiService: ref.read(geminiValidationServiceProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});

class LoginState {
  final String apiKey;
  final bool termsAccepted;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final bool showApiKeyError;
  final bool showTermsError;

  const LoginState({
    this.apiKey = '',
    this.termsAccepted = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.showApiKeyError = false,
    this.showTermsError = false,
  });

  bool get isFormValid => apiKey.isNotEmpty && termsAccepted;

  LoginState copyWith({
    String? apiKey,
    bool? termsAccepted,
    bool? isLoading,
    bool? isSuccess,
    Object? errorMessage = _sentinel,
    bool? showApiKeyError,
    bool? showTermsError,
  }) {
    return LoginState(
      apiKey: apiKey ?? this.apiKey,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      showApiKeyError: showApiKeyError ?? this.showApiKeyError,
      showTermsError: showTermsError ?? this.showTermsError,
    );
  }
}

const Object _sentinel = Object();

class LoginNotifier extends StateNotifier<LoginState> {
  final GeminiValidationService _geminiService;
  final SecureStorageService _secureStorage;

  LoginNotifier({
    required GeminiValidationService geminiService,
    required SecureStorageService secureStorage,
  }) : _geminiService = geminiService,
       _secureStorage = secureStorage,
       super(const LoginState());

  void updateApiKey(String apiKey) {
    state = state.copyWith(
      apiKey: apiKey,
      showApiKeyError: false,
      errorMessage: null,
    );
  }

  void updateTermsAccepted(bool? accepted) {
    state = state.copyWith(
      termsAccepted: accepted ?? false,
      showTermsError: false,
    );
  }

  Future<void> verifyAndLogin() async {
    // Validate form
    if (state.apiKey.isEmpty || !state.termsAccepted) {
      state = state.copyWith(
        showApiKeyError: state.apiKey.isEmpty,
        showTermsError: !state.termsAccepted,
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Validate API key with Gemini
      final isValid = await _geminiService.validateApiKey(state.apiKey);

      if (isValid) {
        // Store API key securely
        await _secureStorage.saveApiKey(StorageKeys.apiToken, state.apiKey);

        state = state.copyWith(isLoading: false, isSuccess: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid API key. Please check and try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Connection failed. Please check your internet and try again.',
      );
    }
  }

  Future<void> checkExistingLogin() async {
    try {
      final existingKey = await _secureStorage.getApiKey(StorageKeys.apiToken);
      if (existingKey != null && existingKey.isNotEmpty) {
        state = state.copyWith(apiKey: existingKey, isSuccess: true);
      }
    } catch (e) {
      // No existing login or error reading
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteApiKey(StorageKeys.apiToken);
    state = const LoginState();
  }
}

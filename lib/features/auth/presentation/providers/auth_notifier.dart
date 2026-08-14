import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/app_user.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/auth_api_service.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthFailure {
  invalidCredentials,
  generic,
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(apiService: ref.watch(authApiServiceProvider));
});

@immutable
class AuthState extends Equatable {
  const AuthState({
    this.user,
    this.accessToken,
    this.refreshToken,
    this.isLoading = false,
    this.error,
  });

  final AppUser? user;
  final String? accessToken;
  final String? refreshToken;
  final bool isLoading;
  final AuthFailure? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    String? accessToken,
    String? refreshToken,
    bool? isLoading,
    AuthFailure? error,
    bool clearUser = false,
    bool clearTokens = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      accessToken: clearTokens ? null : (accessToken ?? this.accessToken),
      refreshToken: clearTokens ? null : (refreshToken ?? this.refreshToken),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [user, accessToken, refreshToken, isLoading, error];
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<bool> signIn({
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.loginWithEmail(
        email: phone,
        password: password,
      );
      state = AuthState(
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return true;
    } catch (e, st) {
      debugPrint('signIn failed: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: AuthFailure.generic,
      );
      return false;
    }
  }

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.loginWithEmail(
        email: email,
        password: password,
      );
      state = AuthState(
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return true;
    } catch (e, st) {
      debugPrint('loginWithEmail failed: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: AuthFailure.invalidCredentials,
      );
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      state = AuthState(
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return true;
    } catch (e, st) {
      debugPrint('register failed: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: AuthFailure.generic,
      );
      return false;
    }
  }

  Future<bool> refreshToken(String refreshToken) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.refreshToken(refreshToken);
      state = AuthState(
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return true;
    } catch (e, st) {
      debugPrint('refreshToken failed: $e\n$st');
      state = const AuthState(error: AuthFailure.generic);
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final refreshToken = state.refreshToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _repository.signOut(refreshToken);
      } catch (e, st) {
        debugPrint('signOut failed: $e\n$st');
      }
    }
    state = const AuthState();
  }
}

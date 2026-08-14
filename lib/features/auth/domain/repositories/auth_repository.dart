import '../../../../shared/models/app_user.dart';

class AuthResult {
  const AuthResult({
    required this.user,
    this.accessToken,
    this.refreshToken,
  });

  final AppUser user;
  final String? accessToken;
  final String? refreshToken;
}

abstract interface class AuthRepository {
  Future<AppUser?> signIn({
    required String phone,
    required String password,
  });

  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  });

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? role,
  });

  Future<AuthResult> refreshToken(String refreshToken);

  Future<void> signOut(String refreshToken);
}

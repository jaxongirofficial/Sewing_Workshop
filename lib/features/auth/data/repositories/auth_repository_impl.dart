import '../../../../shared/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../dto/auth_dto.dart';
import '../services/auth_api_service.dart';

/// Mock credentials aligned with product brief — swap body when backend exists.
final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthApiService? apiService}) : _apiService = apiService;

  final AuthApiService? _apiService;

  @override
  Future<AppUser?> signIn({
    required String phone,
    required String password,
  }) async {
    final session = await _requireApiService().login(
      LoginRequestDto(
        phone: phone.replaceAll(RegExp(r'\D'), ''),
        password: password,
      ),
    );
    return session.user.toDomain();
  }

  @override
  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final service = _requireApiService();
    final session = await service.login(
      LoginRequestDto(phone: email, password: password),
    );
    return AuthResult(
      user: session.user.toDomain(),
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
  }

  @override
  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? role,
  }) async {
    final service = _requireApiService();
    final session = await service.register(
      RegisterRequestDto(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      ),
    );
    return AuthResult(
      user: session.user.toDomain(),
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
  }

  @override
  Future<AuthResult> refreshToken(String refreshToken) async {
    final service = _requireApiService();
    final session = await service.refreshToken(
      RefreshTokenRequestDto(refreshToken: refreshToken),
    );
    return AuthResult(
      user: session.user.toDomain(),
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
  }

  @override
  Future<void> signOut(String refreshToken) {
    return _requireApiService().logout(
      RefreshTokenRequestDto(refreshToken: refreshToken),
    );
  }

  AuthApiService _requireApiService() {
    final service = _apiService;
    if (service == null) {
      throw StateError('AuthApiService is required for backend authentication');
    }
    return service;
  }
}

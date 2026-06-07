import '../../../../shared/models/app_user.dart';
import '../../../../core/enums/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../dto/auth_dto.dart';
import '../mock/mock_accounts.dart';
import '../services/auth_api_service.dart';

/// Mock credentials aligned with product brief — swap body when backend exists.
final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({AuthApiService? apiService}) : _apiService = apiService;

  final AuthApiService? _apiService;

  static final Map<String, ({String password, AppUser user})> _accounts = {
    MockAccounts.ownerPhone: (
      password: MockAccounts.ownerPassword,
      user: const AppUser(
        id: 'user-owner-1',
        displayName: 'Dilshod Karimov',
        phone: MockAccounts.ownerPhone,
        role: UserRole.owner,
      ),
    ),
    MockAccounts.managerPhone: (
      password: MockAccounts.managerPassword,
      user: const AppUser(
        id: 'user-manager-1',
        displayName: 'Madina Yusupova',
        phone: MockAccounts.managerPhone,
        role: UserRole.manager,
      ),
    ),
    MockAccounts.workerPhone: (
      password: MockAccounts.workerPassword,
      user: const AppUser(
        id: 'user-worker-1',
        displayName: 'Javlon Toshmatov',
        phone: MockAccounts.workerPhone,
        role: UserRole.worker,
      ),
    ),
  };

  @override
  Future<AppUser?> signIn({
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final normalized = phone.replaceAll(RegExp(r'\D'), '');
    final entry = _accounts[normalized];
    if (entry == null || entry.password != password) return null;
    return entry.user;
  }

  @override
  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final service = _requireApiService();
    final session = await service.login(
      LoginRequestDto(email: email, password: password),
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
    required String password,
    String? role,
  }) async {
    final service = _requireApiService();
    final session = await service.register(
      RegisterRequestDto(
        fullName: fullName,
        email: email,
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
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  AuthApiService _requireApiService() {
    final service = _apiService;
    if (service == null) {
      throw StateError('AuthApiService is required for backend authentication');
    }
    return service;
  }
}

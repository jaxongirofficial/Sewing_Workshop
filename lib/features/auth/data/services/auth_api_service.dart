import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_paths.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../services/api_service.dart';
import '../dto/auth_dto.dart';
import '../models/auth_session_model.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ref.watch(apiServiceProvider));
});

final class AuthApiService {
  const AuthApiService(this._apiService);

  final ApiService _apiService;

  Future<AuthSessionModel> register(RegisterRequestDto dto) async {
    final response = await _apiService.post(ApiPaths.authRegister, data: dto.toJson());
    return _readSession(response.data);
  }

  Future<AuthSessionModel> login(LoginRequestDto dto) async {
    final response = await _apiService.post(ApiPaths.authLogin, data: dto.toJson());
    return _readSession(response.data);
  }

  Future<AuthSessionModel> refreshToken(RefreshTokenRequestDto dto) async {
    final response = await _apiService.post(
      ApiPaths.authRefreshToken,
      data: dto.toJson(),
    );
    return _readSession(response.data);
  }

  Future<void> logout(RefreshTokenRequestDto dto) async {
    await _apiService.post(ApiPaths.authLogout, data: dto.toJson());
  }

  AuthSessionModel _readSession(Map<String, dynamic>? response) {
    final data = ApiResponseParser.data(response, context: 'Auth');
    return AuthSessionModel.fromJson(data);
  }
}

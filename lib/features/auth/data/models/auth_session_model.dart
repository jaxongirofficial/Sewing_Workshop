import '../../../../core/enums/user_role.dart';
import '../../../../shared/models/app_user.dart';

final class AuthSessionModel {
  const AuthSessionModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final AuthUserModel user;
  final String accessToken;
  final String refreshToken;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}

final class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  final String id;
  final String fullName;
  final String email;
  final String role;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  AppUser toDomain() {
    return AppUser(
      id: id,
      displayName: fullName,
      phone: email,
      role: switch (role) {
        'admin' => UserRole.owner,
        'manager' => UserRole.manager,
        'staff' => UserRole.worker,
        _ => UserRole.worker,
      },
    );
  }
}

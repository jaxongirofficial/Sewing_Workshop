final class LoginRequestDto {
  const LoginRequestDto({
    required this.phone,
    required this.password,
  });

  final String phone;
  final String password;

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'password': password,
      };
}

final class RegisterRequestDto {
  const RegisterRequestDto({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    this.role,
  });

  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String? role;

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        if (role != null) 'role': role,
      };
}

final class RefreshTokenRequestDto {
  const RefreshTokenRequestDto({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => {
        'refreshToken': refreshToken,
      };
}

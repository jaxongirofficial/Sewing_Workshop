import '../../../../shared/models/app_user.dart';

abstract interface class AuthRepository {
  Future<AppUser?> signIn({
    required String phone,
    required String password,
  });

  Future<void> signOut();
}

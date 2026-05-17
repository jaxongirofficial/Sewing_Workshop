import 'package:equatable/equatable.dart';

import '../../core/enums/user_role.dart';

/// Authenticated operator profile (mock today; maps cleanly to API user later).
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.displayName,
    required this.phone,
    required this.role,
  });

  final String id;
  final String displayName;
  final String phone;
  final UserRole role;

  @override
  List<Object?> get props => [id, displayName, phone, role];
}

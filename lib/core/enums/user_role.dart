/// Business roles for navigation and permissions.
enum UserRole {
  owner,
  manager,
  worker,
}

extension UserRoleX on UserRole {
  String get displayLabel => switch (this) {
        UserRole.owner => 'Owner',
        UserRole.manager => 'Manager',
        UserRole.worker => 'Worker',
      };
}

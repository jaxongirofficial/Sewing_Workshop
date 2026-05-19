/// Typed route paths for [GoRouter].
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';

  static const String ownerHome = '/owner/home';
  static const String ownerAttendance = '/owner/attendance';
  static const String ownerTasks = '/owner/tasks';
  static const String ownerWarehouse = '/owner/warehouse';
  static const String ownerProfile = '/owner/profile';
  static const String ownerAddEmployee = '/owner/employees/new';

  static const String managerHome = '/manager/home';
  static const String managerAttendance = '/manager/attendance';
  static const String managerTasks = '/manager/tasks';
  static const String managerWarehouse = '/manager/warehouse';
  static const String managerProfile = '/manager/profile';

  static const String workerHome = '/worker/home';
  static const String workerAttendance = '/worker/attendance';
  static const String workerTasks = '/worker/tasks';
  static const String workerWarehouse = '/worker/warehouse';
  static const String workerProfile = '/worker/profile';

  /// Eski yo\'nalishlar → birinchi tabga yo\'naltirish uchun.
  static const String legacyOwnerDashboard = '/owner/dashboard';
  static const String legacyManagerDashboard = '/manager/dashboard';
  static const String legacyWorkerDashboard = '/worker/dashboard';

  static bool isPublicRoute(String location) {
    return location == splash || location == login;
  }
}

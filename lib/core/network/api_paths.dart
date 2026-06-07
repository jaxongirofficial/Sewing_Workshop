abstract final class ApiPaths {
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authRefreshToken = '/auth/refresh-token';
  static const String authLogout = '/auth/logout';

  static const String customers = '/customers';
  static String customerById(String customerId) => '/customers/$customerId';

  static const String orders = '/orders';
  static String orderById(String orderId) => '/orders/$orderId';
  static String orderStatus(String orderId) => '/orders/$orderId/status';

  static const String payments = '/payments';

  static const String workers = '/workers';
  static String workerById(String workerId) => '/workers/$workerId';
}

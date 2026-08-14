abstract final class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // Local backend on the development computer. Override this for another
    // network or deployment with --dart-define=API_BASE_URL=<your-url>.
    defaultValue: 'http://192.168.100.131:5000/api',
  );
}

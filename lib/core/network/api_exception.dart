final class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.code,
    this.statusCode,
  });

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() {
    final parts = [
      if (statusCode != null) 'statusCode=$statusCode',
      if (code != null) 'code=$code',
      'message=$message',
    ];
    return 'ApiException(${parts.join(', ')})';
  }
}

import 'package:dio/dio.dart';

abstract final class AuthHeaders {
  static Options bearer(String accessToken) {
    return Options(headers: {'Authorization': 'Bearer $accessToken'});
  }
}

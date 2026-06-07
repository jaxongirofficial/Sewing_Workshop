import 'api_exception.dart';

typedef JsonMap = Map<String, dynamic>;

abstract final class ApiResponseParser {
  static JsonMap data(JsonMap? response, {required String context}) {
    final data = response?['data'];
    if (data is JsonMap) return data;
    throw ApiException(message: '$context response does not contain data');
  }

  static JsonMap object(
    JsonMap? response, {
    required String key,
    required String context,
  }) {
    final data = ApiResponseParser.data(response, context: context);
    final value = data[key];
    if (value is JsonMap) return value;
    throw ApiException(message: '$context response does not contain $key');
  }

  static List<JsonMap> list(
    JsonMap? response, {
    required String key,
    required String context,
  }) {
    final data = ApiResponseParser.data(response, context: context);
    final value = data[key];
    if (value is List) {
      return value.cast<JsonMap>().toList(growable: false);
    }
    return const [];
  }
}

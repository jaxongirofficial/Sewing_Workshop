import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_paths.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/auth_headers.dart';
import '../../../../services/api_service.dart';
import '../dto/payment_dto.dart';
import '../models/payment_model.dart';

final paymentApiServiceProvider = Provider<PaymentApiService>((ref) {
  return PaymentApiService(ref.watch(apiServiceProvider));
});

final class PaymentApiService {
  const PaymentApiService(this._apiService);

  final ApiService _apiService;

  Future<List<PaymentModel>> history({
    required String accessToken,
    String? workerId,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await _apiService.get(
      ApiPaths.payments,
      queryParameters: {
        if (workerId != null) 'workerId': workerId,
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
      },
      options: AuthHeaders.bearer(accessToken),
    );

    return ApiResponseParser.list(response.data, key: 'items', context: 'Payments')
        .map(PaymentModel.fromJson)
        .toList(growable: false);
  }

  Future<PaymentModel> record({
    required String accessToken,
    required RecordPaymentDto dto,
  }) async {
    final response = await _apiService.post(
      ApiPaths.payments,
      data: dto.toJson(),
      options: AuthHeaders.bearer(accessToken),
    );
    return _readPayment(response.data);
  }

  PaymentModel _readPayment(Map<String, dynamic>? response) {
    return PaymentModel.fromJson(
      ApiResponseParser.object(response, key: 'payment', context: 'Payment'),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_paths.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/auth_headers.dart';
import '../../../../services/api_service.dart';
import '../dto/order_dto.dart';
import '../models/order_model.dart';

final orderApiServiceProvider = Provider<OrderApiService>((ref) {
  return OrderApiService(ref.watch(apiServiceProvider));
});

final class OrderApiService {
  const OrderApiService(this._apiService);

  final ApiService _apiService;

  Future<List<OrderModel>> list({
    required String accessToken,
    String? customerId,
    String? status,
  }) async {
    final response = await _apiService.get(
      ApiPaths.orders,
      queryParameters: {
        if (customerId != null) 'customerId': customerId,
        if (status != null) 'status': status,
      },
      options: AuthHeaders.bearer(accessToken),
    );

    return ApiResponseParser.list(response.data, key: 'items', context: 'Orders')
        .map(OrderModel.fromJson)
        .toList(growable: false);
  }

  Future<OrderModel> create({
    required String accessToken,
    required OrderRequestDto dto,
  }) async {
    final response = await _apiService.post(
      ApiPaths.orders,
      data: dto.toJson(),
      options: AuthHeaders.bearer(accessToken),
    );
    return _readOrder(response.data);
  }

  Future<OrderModel> update({
    required String accessToken,
    required String orderId,
    required OrderUpdateDto dto,
  }) async {
    final response = await _apiService.patch(
      ApiPaths.orderById(orderId),
      data: dto.toJson(),
      options: AuthHeaders.bearer(accessToken),
    );
    return _readOrder(response.data);
  }

  Future<OrderModel> updateStatus({
    required String accessToken,
    required String orderId,
    required OrderStatusUpdateDto dto,
  }) async {
    final response = await _apiService.patch(
      ApiPaths.orderStatus(orderId),
      data: dto.toJson(),
      options: AuthHeaders.bearer(accessToken),
    );
    return _readOrder(response.data);
  }

  Future<void> delete({
    required String accessToken,
    required String orderId,
  }) async {
    await _apiService.delete(
      ApiPaths.orderById(orderId),
      options: AuthHeaders.bearer(accessToken),
    );
  }

  OrderModel _readOrder(Map<String, dynamic>? response) {
    return OrderModel.fromJson(
      ApiResponseParser.object(response, key: 'order', context: 'Order'),
    );
  }
}

import '../../domain/repositories/order_repository.dart';
import '../dto/order_dto.dart';
import '../models/order_model.dart';
import '../services/order_api_service.dart';

final class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl(this._apiService);

  final OrderApiService _apiService;

  @override
  Future<List<OrderModel>> listOrders({
    required String accessToken,
    String? customerId,
    String? status,
  }) {
    return _apiService.list(
      accessToken: accessToken,
      customerId: customerId,
      status: status,
    );
  }

  @override
  Future<OrderModel> createOrder({
    required String accessToken,
    required OrderRequestDto dto,
  }) {
    return _apiService.create(accessToken: accessToken, dto: dto);
  }

  @override
  Future<OrderModel> updateOrder({
    required String accessToken,
    required String orderId,
    required OrderUpdateDto dto,
  }) {
    return _apiService.update(
      accessToken: accessToken,
      orderId: orderId,
      dto: dto,
    );
  }

  @override
  Future<OrderModel> updateOrderStatus({
    required String accessToken,
    required String orderId,
    required OrderStatusUpdateDto dto,
  }) {
    return _apiService.updateStatus(
      accessToken: accessToken,
      orderId: orderId,
      dto: dto,
    );
  }

  @override
  Future<void> deleteOrder({
    required String accessToken,
    required String orderId,
  }) {
    return _apiService.delete(accessToken: accessToken, orderId: orderId);
  }
}

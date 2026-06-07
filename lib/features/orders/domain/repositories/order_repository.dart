import '../../data/dto/order_dto.dart';
import '../../data/models/order_model.dart';

abstract interface class OrderRepository {
  Future<List<OrderModel>> listOrders({
    required String accessToken,
    String? customerId,
    String? status,
  });

  Future<OrderModel> createOrder({
    required String accessToken,
    required OrderRequestDto dto,
  });

  Future<OrderModel> updateOrder({
    required String accessToken,
    required String orderId,
    required OrderUpdateDto dto,
  });

  Future<OrderModel> updateOrderStatus({
    required String accessToken,
    required String orderId,
    required OrderStatusUpdateDto dto,
  });

  Future<void> deleteOrder({
    required String accessToken,
    required String orderId,
  });
}

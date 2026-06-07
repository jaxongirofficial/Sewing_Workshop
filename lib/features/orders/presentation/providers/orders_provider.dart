import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/dto/order_dto.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/services/order_api_service.dart';
import '../../domain/repositories/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(ref.watch(orderApiServiceProvider));
});

final productionOrdersProvider =
    StateNotifierProvider<OrdersNotifier, AsyncValue<List<OrderModel>>>((ref) {
  return OrdersNotifier(
    repository: ref.watch(orderRepositoryProvider),
    readAccessToken: () => ref.read(authNotifierProvider).accessToken,
  );
});

final class OrdersNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  OrdersNotifier({
    required OrderRepository repository,
    required String? Function() readAccessToken,
  })  : _repository = repository,
        _readAccessToken = readAccessToken,
        super(const AsyncValue.data([]));

  final OrderRepository _repository;
  final String? Function() _readAccessToken;

  Future<void> load({String? customerId, String? status}) async {
    final token = _requireAccessToken();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.listOrders(
        accessToken: token,
        customerId: customerId,
        status: status,
      ),
    );
  }

  Future<void> create(OrderRequestDto dto) async {
    final token = _requireAccessToken();
    try {
      final order = await _repository.createOrder(
        accessToken: token,
        dto: dto,
      );
      final previous = state.valueOrNull ?? const <OrderModel>[];
      state = AsyncValue.data([order, ...previous]);
    } catch (error, stackTrace) {
      debugPrint('create order failed: $error\n$stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> update(String orderId, OrderUpdateDto dto) async {
    final token = _requireAccessToken();
    try {
      final order = await _repository.updateOrder(
        accessToken: token,
        orderId: orderId,
        dto: dto,
      );
      _replace(order);
    } catch (error, stackTrace) {
      debugPrint('update order failed: $error\n$stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateStatus(String orderId, String status) async {
    final token = _requireAccessToken();
    try {
      final order = await _repository.updateOrderStatus(
        accessToken: token,
        orderId: orderId,
        dto: OrderStatusUpdateDto(status: status),
      );
      _replace(order);
    } catch (error, stackTrace) {
      debugPrint('update order status failed: $error\n$stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> delete(String orderId) async {
    final token = _requireAccessToken();
    try {
      await _repository.deleteOrder(accessToken: token, orderId: orderId);
      final previous = state.valueOrNull ?? const <OrderModel>[];
      state = AsyncValue.data(
        previous.where((order) => order.id != orderId).toList(growable: false),
      );
    } catch (error, stackTrace) {
      debugPrint('delete order failed: $error\n$stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _replace(OrderModel order) {
    final previous = state.valueOrNull ?? const <OrderModel>[];
    state = AsyncValue.data([
      for (final item in previous) if (item.id == order.id) order else item,
    ]);
  }

  String _requireAccessToken() {
    final token = _readAccessToken();
    if (token == null || token.isEmpty) {
      throw StateError('Orders API requires an authenticated backend session');
    }
    return token;
  }
}

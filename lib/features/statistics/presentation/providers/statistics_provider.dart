import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../payments/presentation/providers/payments_provider.dart';

final revenueChartProvider = Provider<AsyncValue<List<RevenuePoint>>>((ref) {
  final payments = ref.watch(paymentsProvider);

  return payments.when(
    data: (items) {
      final buckets = <DateTime, double>{};
      for (final payment in items) {
        final month = DateTime(payment.paymentDate.year, payment.paymentDate.month);
        buckets[month] = (buckets[month] ?? 0) + payment.amount;
      }

      final points = buckets.entries
          .map((entry) => RevenuePoint(month: entry.key, amount: entry.value))
          .toList()
        ..sort((a, b) => a.month.compareTo(b.month));

      return AsyncValue.data(points);
    },
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});

final orderAnalyticsProvider = Provider<AsyncValue<OrderAnalytics>>((ref) {
  final orders = ref.watch(productionOrdersProvider);

  return orders.when(
    data: (items) {
      final byStatus = <String, int>{
        'pending': 0,
        'in_progress': 0,
        'completed': 0,
        'cancelled': 0,
      };

      for (final order in items) {
        byStatus[order.status] = (byStatus[order.status] ?? 0) + 1;
      }

      final overdueCount = items
          .where((order) =>
              order.deadline.isBefore(DateTime.now()) && order.status != 'completed')
          .length;

      return AsyncValue.data(
        OrderAnalytics(
          totalOrders: items.length,
          byStatus: Map.unmodifiable(byStatus),
          overdueCount: overdueCount,
        ),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});

final class RevenuePoint extends Equatable {
  const RevenuePoint({
    required this.month,
    required this.amount,
  });

  final DateTime month;
  final double amount;

  @override
  List<Object?> get props => [month, amount];
}

final class OrderAnalytics extends Equatable {
  const OrderAnalytics({
    required this.totalOrders,
    required this.byStatus,
    required this.overdueCount,
  });

  final int totalOrders;
  final Map<String, int> byStatus;
  final int overdueCount;

  @override
  List<Object?> get props => [totalOrders, byStatus, overdueCount];
}

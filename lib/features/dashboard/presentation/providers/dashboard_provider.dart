import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../payments/presentation/providers/payments_provider.dart';
import '../../../workers/presentation/providers/workers_provider.dart';

final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final orders = ref.watch(productionOrdersProvider);
  final workers = ref.watch(workersProvider);
  final payments = ref.watch(paymentsProvider);

  if (orders.isLoading || workers.isLoading || payments.isLoading) {
    return const AsyncValue.loading();
  }

  final error = orders.error ?? workers.error ?? payments.error;
  if (error != null) {
    return AsyncValue.error(
      error,
      orders.stackTrace ?? workers.stackTrace ?? payments.stackTrace ?? StackTrace.current,
    );
  }

  final orderList = orders.valueOrNull ?? const [];
  final workerList = workers.valueOrNull ?? const [];
  final paymentList = payments.valueOrNull ?? const [];
  final now = DateTime.now();

  final monthlyRevenue = paymentList
      .where((payment) =>
          payment.paymentDate.year == now.year && payment.paymentDate.month == now.month)
      .fold<double>(0, (sum, payment) => sum + payment.amount);

  return AsyncValue.data(
    DashboardSummary(
      totalOrders: orderList.length,
      activeOrders: orderList
          .where((order) => order.status == 'pending' || order.status == 'in_progress')
          .length,
      monthlyRevenue: monthlyRevenue,
      workersCount: workerList.length,
    ),
  );
});

final class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalOrders,
    required this.activeOrders,
    required this.monthlyRevenue,
    required this.workersCount,
  });

  final int totalOrders;
  final int activeOrders;
  final double monthlyRevenue;
  final int workersCount;

  @override
  List<Object?> get props => [
        totalOrders,
        activeOrders,
        monthlyRevenue,
        workersCount,
      ];
}

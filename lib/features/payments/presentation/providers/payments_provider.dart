import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/dto/payment_dto.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../data/services/payment_api_service.dart';
import '../../domain/repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(ref.watch(paymentApiServiceProvider));
});

final paymentsProvider =
    StateNotifierProvider<PaymentsNotifier, AsyncValue<List<PaymentModel>>>((ref) {
  return PaymentsNotifier(
    repository: ref.watch(paymentRepositoryProvider),
    readAccessToken: () => ref.read(authNotifierProvider).accessToken,
  );
});

final class PaymentsNotifier extends StateNotifier<AsyncValue<List<PaymentModel>>> {
  PaymentsNotifier({
    required PaymentRepository repository,
    required String? Function() readAccessToken,
  })  : _repository = repository,
        _readAccessToken = readAccessToken,
        super(const AsyncValue.data([]));

  final PaymentRepository _repository;
  final String? Function() _readAccessToken;

  Future<void> load({
    String? workerId,
    DateTime? from,
    DateTime? to,
  }) async {
    final token = _requireAccessToken();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.paymentHistory(
        accessToken: token,
        workerId: workerId,
        from: from,
        to: to,
      ),
    );
  }

  Future<void> record(RecordPaymentDto dto) async {
    final token = _requireAccessToken();
    try {
      final payment = await _repository.recordPayment(
        accessToken: token,
        dto: dto,
      );
      final previous = state.valueOrNull ?? const <PaymentModel>[];
      state = AsyncValue.data([payment, ...previous]);
    } catch (error, stackTrace) {
      debugPrint('record payment failed: $error\n$stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  String _requireAccessToken() {
    final token = _readAccessToken();
    if (token == null || token.isEmpty) {
      throw StateError('Payments API requires an authenticated backend session');
    }
    return token;
  }
}

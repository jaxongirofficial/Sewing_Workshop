import '../../domain/repositories/payment_repository.dart';
import '../dto/payment_dto.dart';
import '../models/payment_model.dart';
import '../services/payment_api_service.dart';

final class PaymentRepositoryImpl implements PaymentRepository {
  const PaymentRepositoryImpl(this._apiService);

  final PaymentApiService _apiService;

  @override
  Future<List<PaymentModel>> paymentHistory({
    required String accessToken,
    String? workerId,
    DateTime? from,
    DateTime? to,
  }) {
    return _apiService.history(
      accessToken: accessToken,
      workerId: workerId,
      from: from,
      to: to,
    );
  }

  @override
  Future<PaymentModel> recordPayment({
    required String accessToken,
    required RecordPaymentDto dto,
  }) {
    return _apiService.record(accessToken: accessToken, dto: dto);
  }
}

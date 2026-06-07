import '../../data/dto/payment_dto.dart';
import '../../data/models/payment_model.dart';

abstract interface class PaymentRepository {
  Future<List<PaymentModel>> paymentHistory({
    required String accessToken,
    String? workerId,
    DateTime? from,
    DateTime? to,
  });

  Future<PaymentModel> recordPayment({
    required String accessToken,
    required RecordPaymentDto dto,
  });
}

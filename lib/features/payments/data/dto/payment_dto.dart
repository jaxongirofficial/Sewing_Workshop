final class RecordPaymentDto {
  const RecordPaymentDto({
    required this.workerId,
    required this.amount,
    this.paymentDate,
  });

  final String workerId;
  final double amount;
  final DateTime? paymentDate;

  Map<String, dynamic> toJson() => {
        'workerId': workerId,
        'amount': amount,
        if (paymentDate != null) 'paymentDate': paymentDate!.toIso8601String(),
      };
}

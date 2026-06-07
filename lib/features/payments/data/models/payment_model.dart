final class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.workerId,
    required this.amount,
    required this.paymentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String workerId;
  final double amount;
  final DateTime paymentDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      workerId: json['workerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

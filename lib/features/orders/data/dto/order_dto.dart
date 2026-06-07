final class OrderRequestDto {
  const OrderRequestDto({
    required this.orderNumber,
    required this.customerId,
    required this.quantity,
    required this.totalPrice,
    required this.deadline,
    this.status,
  });

  final String orderNumber;
  final String customerId;
  final int quantity;
  final double totalPrice;
  final DateTime deadline;
  final String? status;

  Map<String, dynamic> toJson() => {
        'orderNumber': orderNumber,
        'customerId': customerId,
        'quantity': quantity,
        'totalPrice': totalPrice,
        'deadline': deadline.toIso8601String(),
        if (status != null) 'status': status,
      };
}

final class OrderUpdateDto {
  const OrderUpdateDto({
    this.orderNumber,
    this.customerId,
    this.quantity,
    this.totalPrice,
    this.deadline,
    this.status,
  });

  final String? orderNumber;
  final String? customerId;
  final int? quantity;
  final double? totalPrice;
  final DateTime? deadline;
  final String? status;

  Map<String, dynamic> toJson() => {
        if (orderNumber != null) 'orderNumber': orderNumber,
        if (customerId != null) 'customerId': customerId,
        if (quantity != null) 'quantity': quantity,
        if (totalPrice != null) 'totalPrice': totalPrice,
        if (deadline != null) 'deadline': deadline!.toIso8601String(),
        if (status != null) 'status': status,
      };
}

final class OrderStatusUpdateDto {
  const OrderStatusUpdateDto({required this.status});

  final String status;

  Map<String, dynamic> toJson() => {'status': status};
}

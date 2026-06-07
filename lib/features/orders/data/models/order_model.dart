import '../../../workshop/models/workshop_mock_models.dart';

final class OrderModel {
  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.quantity,
    required this.totalPrice,
    required this.deadline,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String orderNumber;
  final String customerId;
  final int quantity;
  final double totalPrice;
  final DateTime deadline;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      customerId: json['customerId'] as String,
      quantity: json['quantity'] as int,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      deadline: DateTime.parse(json['deadline'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  WorkshopOrder toWorkshopOrder() {
    return WorkshopOrder(
      id: id,
      productName: orderNumber,
      orderedQty: quantity,
      producedQty: status == 'completed' ? quantity : 0,
      deadline: deadline,
      note: 'Customer: $customerId',
    );
  }
}

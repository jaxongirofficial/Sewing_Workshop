import '../../../workshop/models/workshop_mock_models.dart';

final class WorkerModel {
  const WorkerModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.position,
    required this.salary,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String fullName;
  final String phone;
  final String position;
  final double salary;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      position: json['position'] as String,
      salary: (json['salary'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  WorkshopWorker toWorkshopWorker() {
    return WorkshopWorker(
      id: id,
      name: fullName,
      phone: phone,
      role: position,
      present: status == 'active',
    );
  }
}

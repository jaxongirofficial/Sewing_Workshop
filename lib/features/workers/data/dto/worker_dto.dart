final class WorkerRequestDto {
  const WorkerRequestDto({
    required this.fullName,
    required this.phone,
    required this.position,
    required this.salary,
    this.status,
  });

  final String fullName;
  final String phone;
  final String position;
  final double salary;
  final String? status;

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phone': phone,
        'position': position,
        'salary': salary,
        if (status != null) 'status': status,
      };
}

final class WorkerUpdateDto {
  const WorkerUpdateDto({
    this.fullName,
    this.phone,
    this.position,
    this.salary,
    this.status,
  });

  final String? fullName;
  final String? phone;
  final String? position;
  final double? salary;
  final String? status;

  Map<String, dynamic> toJson() => {
        if (fullName != null) 'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (position != null) 'position': position,
        if (salary != null) 'salary': salary,
        if (status != null) 'status': status,
      };
}

/// Local mock models (keyin API bilan almashtiriladi).
class PersonAttendance {
  const PersonAttendance({
    required this.id,
    required this.name,
    required this.present,
    this.checkInTime,
  });

  final String id;
  final String name;
  final bool present;
  final String? checkInTime;

  PersonAttendance copyWith({
    String? id,
    String? name,
    bool? present,
    String? checkInTime,
    bool clearTime = false,
  }) {
    return PersonAttendance(
      id: id ?? this.id,
      name: name ?? this.name,
      present: present ?? this.present,
      checkInTime: clearTime ? null : (checkInTime ?? this.checkInTime),
    );
  }
}

class WorkshopTaskItem {
  const WorkshopTaskItem({
    required this.id,
    required this.title,
    required this.assigneeId,
    required this.assigneeName,
  });

  final String id;
  final String title;
  final String assigneeId;
  final String assigneeName;
}

/// Owner tomonidan qo'shilgan xodim (worker yoki manager).
class Employee {
  const Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    this.birthDate,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phone;

  /// `worker` yoki `manager`.
  final String role;
  final DateTime? birthDate;

  String get fullName => '$firstName $lastName'.trim();
}

/// Bosh sahifa «Jamoa» ro'yxati uchun birlashtirilgan xodim.
class WorkshopWorker {
  const WorkshopWorker({
    required this.id,
    required this.name,
    this.phone,
    this.role,
    this.present,
    this.checkInTime,
  });

  final String id;
  final String name;
  final String? phone;

  /// `worker` yoki `manager`; davomatdan kelganlarda null.
  final String? role;
  final bool? present;
  final String? checkInTime;
}

List<WorkshopWorker> buildWorkshopWorkers(
  List<PersonAttendance> attendance,
  List<Employee> employees,
) {
  final map = <String, WorkshopWorker>{};

  for (final p in attendance) {
    map[p.id] = WorkshopWorker(
      id: p.id,
      name: p.name,
      present: p.present,
      checkInTime: p.checkInTime,
    );
  }

  for (final e in employees) {
    final existing = map[e.id];
    if (existing != null) {
      map[e.id] = WorkshopWorker(
        id: e.id,
        name: existing.name,
        phone: e.phone,
        role: e.role,
        present: existing.present,
        checkInTime: existing.checkInTime,
      );
    } else {
      map[e.id] = WorkshopWorker(
        id: e.id,
        name: e.fullName,
        phone: e.phone,
        role: e.role,
      );
    }
  }

  final list = map.values.toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  return list;
}

/// Ombordagi mahsulot kategoriyasi.
enum WarehouseCategory {
  clothing,
  material,
  accessory,
  other;
}

/// Ombordagi bitta mahsulot yozuvi.
class WarehouseItem {
  const WarehouseItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
  });

  final String id;
  final String name;
  final int quantity;

  /// O'lchov birligi: 'ta', 'metr', 'kg', va h.k.
  final String unit;
  final WarehouseCategory category;

  WarehouseItem copyWith({
    String? id,
    String? name,
    int? quantity,
    String? unit,
    WarehouseCategory? category,
  }) {
    return WarehouseItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
    );
  }
}

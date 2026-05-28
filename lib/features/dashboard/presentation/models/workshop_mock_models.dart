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

/// Topshiriq — mahsulot nomi, miqdor, narx, deadline va progress bilan.
class WorkshopTaskItem {
  const WorkshopTaskItem({
    required this.id,
    required this.productName,
    required this.targetQty,
    this.doneQty = 0,
    required this.assigneeId,
    required this.assigneeName,
    this.deadline,
    this.note,
    this.pricePerUnit,
  });

  final String id;
  final String productName;
  final int targetQty;
  final int doneQty;
  final String assigneeId;
  final String assigneeName;
  final DateTime? deadline;
  final String? note;

  /// 1 ta mahsulot narxi (so'm). Ixtiyoriy.
  final double? pricePerUnit;

  /// Jami qiymat = narx × maqsad miqdor.
  double? get totalValue =>
      pricePerUnit != null ? pricePerUnit! * targetQty : null;

  /// Hozircha topilgan qiymat = narx × bajarilgan miqdor.
  double? get earnedValue =>
      pricePerUnit != null ? pricePerUnit! * doneQty : null;

  /// Backwards compat — boshqa joylarda title ishlatilgan.
  String get title => productName;

  double get progress =>
      targetQty > 0 ? (doneQty / targetQty).clamp(0.0, 1.0) : 0.0;

  bool get isDone => doneQty >= targetQty;

  int get daysLeft =>
      deadline != null ? deadline!.difference(DateTime.now()).inDays : 999;

  bool get isUrgent => daysLeft >= 0 && daysLeft <= 3;
  bool get isOverdue => deadline != null && daysLeft < 0;

  WorkshopTaskItem copyWith({
    String? id,
    String? productName,
    int? targetQty,
    int? doneQty,
    String? assigneeId,
    String? assigneeName,
    DateTime? deadline,
    bool clearDeadline = false,
    String? note,
    double? pricePerUnit,
    bool clearPrice = false,
  }) {
    return WorkshopTaskItem(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      targetQty: targetQty ?? this.targetQty,
      doneQty: doneQty ?? this.doneQty,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      note: note ?? this.note,
      pricePerUnit: clearPrice ? null : (pricePerUnit ?? this.pricePerUnit),
    );
  }
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
    this.pricePerUnit,
    this.addedBy,
  });

  final String id;
  final String name;
  final int quantity;

  /// O'lchov birligi: 'ta', 'metr', 'kg', va h.k.
  final String unit;
  final WarehouseCategory category;

  /// Birligi narxi (so'm).
  final double? pricePerUnit;

  /// Kim qo'shgani (xodim ismi).
  final String? addedBy;

  WarehouseItem copyWith({
    String? id,
    String? name,
    int? quantity,
    String? unit,
    WarehouseCategory? category,
    double? pricePerUnit,
    bool clearPrice = false,
    String? addedBy,
  }) {
    return WarehouseItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      pricePerUnit: clearPrice ? null : (pricePerUnit ?? this.pricePerUnit),
      addedBy: addedBy ?? this.addedBy,
    );
  }
}

/// Ombor harakati turi.
enum WarehouseHistoryType {
  /// Kirim (yangi mahsulot yoki qo'shimcha).
  stockIn,

  /// Chiqarish (ishlab chiqarishga / jo'natish).
  stockOut,

  /// Qo'lda +/- o'zgartirish.
  adjust,
}

/// Ombor tarixi — kim, qachon, qancha.
class WarehouseHistoryEntry {
  const WarehouseHistoryEntry({
    required this.id,
    required this.type,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.performedBy,
    required this.at,
  });

  final String id;
  final WarehouseHistoryType type;
  final String productId;
  final String productName;
  final int quantity;
  final String unit;
  final String performedBy;
  final DateTime at;
}

/// Zakaz — buyurtma modeli.
class WorkshopOrder {
  const WorkshopOrder({
    required this.id,
    required this.productName,
    required this.orderedQty,
    this.producedQty = 0,
    required this.deadline,
    this.note,
  });

  final String id;
  final String productName;
  final int orderedQty;
  final int producedQty;
  final DateTime deadline;
  final String? note;

  double get progress =>
      orderedQty > 0 ? (producedQty / orderedQty).clamp(0.0, 1.0) : 0.0;

  int get remaining => (orderedQty - producedQty).clamp(0, 999999);

  int get daysLeft => deadline.difference(DateTime.now()).inDays;

  bool get isUrgent => daysLeft >= 0 && daysLeft <= 3;
  bool get isOverdue => daysLeft < 0;
  bool get isDone => producedQty >= orderedQty;

  WorkshopOrder copyWith({
    String? id,
    String? productName,
    int? orderedQty,
    int? producedQty,
    DateTime? deadline,
    String? note,
  }) {
    return WorkshopOrder(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      orderedQty: orderedQty ?? this.orderedQty,
      producedQty: producedQty ?? this.producedQty,
      deadline: deadline ?? this.deadline,
      note: note ?? this.note,
    );
  }
}

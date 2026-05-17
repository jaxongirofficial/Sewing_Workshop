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

/// Ombordagi mahsulot kategoriyasi.
enum WarehouseCategory {
  clothing,
  material,
  accessory,
  other;

  String get uzLabel => switch (this) {
        WarehouseCategory.clothing => 'Kiyim',
        WarehouseCategory.material => 'Material',
        WarehouseCategory.accessory => 'Aksessuar',
        WarehouseCategory.other => 'Boshqa',
      };
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

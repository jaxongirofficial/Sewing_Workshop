import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workshop_mock_models.dart';

String _hhmmNow() {
  final n = DateTime.now();
  return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
}

// ─── Attendance ───────────────────────────────────────────────────────────────

final class AttendanceNotifier extends StateNotifier<List<PersonAttendance>> {
  AttendanceNotifier() : super(_seed);

  static final _seed = <PersonAttendance>[
    const PersonAttendance(
      id: 'user-worker-1',
      name: 'Javlon Toshmatov',
      present: true,
      checkInTime: '08:58',
    ),
    const PersonAttendance(
      id: 'w-2',
      name: 'Nilufar Karimova',
      present: true,
      checkInTime: '09:05',
    ),
    const PersonAttendance(
      id: 'w-3',
      name: 'Sherzod Mamadov',
      present: false,
    ),
    const PersonAttendance(
      id: 'w-4',
      name: 'Dilnoza Ergasheva',
      present: true,
      checkInTime: '08:47',
    ),
    const PersonAttendance(
      id: 'w-5',
      name: 'Bekzod Rahimov',
      present: false,
    ),
  ];

  void toggle(String id) {
    state = [
      for (final p in state)
        if (p.id == id)
          p.copyWith(
            present: !p.present,
            clearTime: p.present,
            checkInTime: p.present ? null : _hhmmNow(),
          )
        else
          p,
    ];
  }

  void addIfMissing({required String id, required String name}) {
    if (state.any((p) => p.id == id)) return;
    state = [
      ...state,
      PersonAttendance(id: id, name: name, present: false),
    ];
  }
}

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, List<PersonAttendance>>((ref) {
  return AttendanceNotifier();
});

// ─── Tasks ────────────────────────────────────────────────────────────────────

final class TasksNotifier extends StateNotifier<List<WorkshopTaskItem>> {
  TasksNotifier() : super(_seed);

  static final _now = DateTime.now();

  static final _seed = <WorkshopTaskItem>[
    WorkshopTaskItem(
      id: 't-1',
      productName: 'Ko\'ylak',
      targetQty: 120,
      doneQty: 45,
      assigneeId: 'user-worker-1',
      assigneeName: 'Javlon Toshmatov',
      deadline: _now.add(const Duration(days: 5)),
      pricePerUnit: 8000,
    ),
    WorkshopTaskItem(
      id: 't-2',
      productName: 'Shim',
      targetQty: 80,
      doneQty: 80,
      assigneeId: 'w-4',
      assigneeName: 'Dilnoza Ergasheva',
      deadline: _now.subtract(const Duration(days: 1)),
      pricePerUnit: 10000,
    ),
    WorkshopTaskItem(
      id: 't-3',
      productName: 'Jaket',
      targetQty: 50,
      doneQty: 12,
      assigneeId: 'w-2',
      assigneeName: 'Nilufar Karimova',
      deadline: _now.add(const Duration(days: 2)),
      pricePerUnit: 15000,
    ),
  ];

  void assign({
    required String productName,
    required int targetQty,
    required String assigneeId,
    required String assigneeName,
    DateTime? deadline,
    String? note,
    double? pricePerUnit,
  }) {
    final name = productName.trim();
    if (name.isEmpty || targetQty <= 0) return;
    final id = 't-${DateTime.now().millisecondsSinceEpoch}';
    state = [
      WorkshopTaskItem(
        id: id,
        productName: name,
        targetQty: targetQty,
        assigneeId: assigneeId,
        assigneeName: assigneeName,
        deadline: deadline,
        note: note,
        pricePerUnit: pricePerUnit,
      ),
      ...state,
    ];
  }

  void updateProgress(String id, int newDone) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(doneQty: newDone.clamp(0, t.targetQty))
        else t,
    ];
  }

  void update(WorkshopTaskItem updated) {
    state = [
      for (final t in state) if (t.id == updated.id) updated else t,
    ];
  }

  void delete(String id) =>
      state = state.where((t) => t.id != id).toList();
}

final tasksProvider =
    StateNotifierProvider<TasksNotifier, List<WorkshopTaskItem>>((ref) {
  return TasksNotifier();
});

// ─── Warehouse history ────────────────────────────────────────────────────────

final class WarehouseHistoryNotifier
    extends StateNotifier<List<WarehouseHistoryEntry>> {
  WarehouseHistoryNotifier() : super(_seed);

  static final _now = DateTime.now();

  static final _seed = <WarehouseHistoryEntry>[
    WarehouseHistoryEntry(
      id: 'h-1',
      type: WarehouseHistoryType.stockIn,
      productId: 'w-1',
      productName: 'Shim',
      quantity: 45,
      unit: 'ta',
      performedBy: 'Sherzod M.',
      at: _now.subtract(const Duration(hours: 5)),
    ),
    WarehouseHistoryEntry(
      id: 'h-2',
      type: WarehouseHistoryType.stockOut,
      productId: 'w-1',
      productName: 'Shim',
      quantity: 3,
      unit: 'ta',
      performedBy: 'Madina Y.',
      at: _now.subtract(const Duration(hours: 3)),
    ),
    WarehouseHistoryEntry(
      id: 'h-3',
      type: WarehouseHistoryType.stockIn,
      productId: 'w-2',
      productName: 'Ko\'ylak',
      quantity: 15,
      unit: 'ta',
      performedBy: 'Sherzod M.',
      at: _now.subtract(const Duration(days: 1, hours: 2)),
    ),
    WarehouseHistoryEntry(
      id: 'h-4',
      type: WarehouseHistoryType.stockOut,
      productId: 'w-5',
      productName: 'Jaket',
      quantity: 2,
      unit: 'ta',
      performedBy: 'Nilufar K.',
      at: _now.subtract(const Duration(days: 1, hours: 5)),
    ),
    WarehouseHistoryEntry(
      id: 'h-5',
      type: WarehouseHistoryType.adjust,
      productId: 'w-8',
      productName: 'Mato (ko\'k)',
      quantity: -10,
      unit: 'metr',
      performedBy: 'Dilshod K.',
      at: _now.subtract(const Duration(days: 2)),
    ),
  ];

  void _prepend(WarehouseHistoryEntry entry) {
    state = [entry, ...state];
  }

  void logStockIn({
    required WarehouseItem item,
    required int quantity,
    required String performedBy,
  }) {
    _prepend(
      WarehouseHistoryEntry(
        id: 'h-${DateTime.now().microsecondsSinceEpoch}',
        type: WarehouseHistoryType.stockIn,
        productId: item.id,
        productName: item.name,
        quantity: quantity,
        unit: item.unit,
        performedBy: performedBy,
        at: DateTime.now(),
      ),
    );
  }

  void logStockOut({
    required WarehouseItem item,
    required int quantity,
    required String performedBy,
  }) {
    _prepend(
      WarehouseHistoryEntry(
        id: 'h-${DateTime.now().microsecondsSinceEpoch}',
        type: WarehouseHistoryType.stockOut,
        productId: item.id,
        productName: item.name,
        quantity: quantity,
        unit: item.unit,
        performedBy: performedBy,
        at: DateTime.now(),
      ),
    );
  }

  void logAdjust({
    required WarehouseItem item,
    required int delta,
    required String performedBy,
  }) {
    if (delta == 0) return;
    _prepend(
      WarehouseHistoryEntry(
        id: 'h-${DateTime.now().microsecondsSinceEpoch}',
        type: WarehouseHistoryType.adjust,
        productId: item.id,
        productName: item.name,
        quantity: delta,
        unit: item.unit,
        performedBy: performedBy,
        at: DateTime.now(),
      ),
    );
  }
}

final warehouseHistoryProvider =
    StateNotifierProvider<WarehouseHistoryNotifier, List<WarehouseHistoryEntry>>(
        (ref) {
  return WarehouseHistoryNotifier();
});

// ─── Warehouse ────────────────────────────────────────────────────────────────

final class WarehouseNotifier extends StateNotifier<List<WarehouseItem>> {
  WarehouseNotifier(this._history) : super(_seed);

  final WarehouseHistoryNotifier _history;

  static final _seed = <WarehouseItem>[
    const WarehouseItem(
      id: 'w-1',
      name: 'Shim',
      quantity: 7,
      unit: 'ta',
      category: WarehouseCategory.clothing,
      pricePerUnit: 45000,
      addedBy: 'Sherzod M.',
    ),
    const WarehouseItem(
      id: 'w-2',
      name: 'Ko\'ylak',
      quantity: 15,
      unit: 'ta',
      category: WarehouseCategory.clothing,
      pricePerUnit: 38000,
      addedBy: 'Sherzod M.',
    ),
    const WarehouseItem(
      id: 'w-3',
      name: 'Yeng (qo\'l)',
      quantity: 20,
      unit: 'ta',
      category: WarehouseCategory.clothing,
    ),
    const WarehouseItem(
      id: 'w-4',
      name: 'Kalta yubka',
      quantity: 12,
      unit: 'ta',
      category: WarehouseCategory.clothing,
      pricePerUnit: 32000,
    ),
    const WarehouseItem(
      id: 'w-5',
      name: 'Jaket',
      quantity: 5,
      unit: 'ta',
      category: WarehouseCategory.clothing,
      pricePerUnit: 95000,
      addedBy: 'Nilufar K.',
    ),
    const WarehouseItem(
      id: 'w-6',
      name: 'Sumka',
      quantity: 30,
      unit: 'ta',
      category: WarehouseCategory.accessory,
      pricePerUnit: 22000,
    ),
    const WarehouseItem(
      id: 'w-7',
      name: 'Belbog\'',
      quantity: 25,
      unit: 'ta',
      category: WarehouseCategory.accessory,
    ),
    const WarehouseItem(
      id: 'w-8',
      name: 'Mato (ko\'k)',
      quantity: 150,
      unit: 'metr',
      category: WarehouseCategory.material,
      pricePerUnit: 8500,
      addedBy: 'Sherzod M.',
    ),
    const WarehouseItem(
      id: 'w-9',
      name: 'Ip (oq)',
      quantity: 40,
      unit: 'dona',
      category: WarehouseCategory.material,
      pricePerUnit: 3200,
    ),
    const WarehouseItem(
      id: 'w-10',
      name: 'Tugma',
      quantity: 500,
      unit: 'dona',
      category: WarehouseCategory.material,
      pricePerUnit: 150,
    ),
  ];

  WarehouseItem? _find(String id) {
    for (final item in state) {
      if (item.id == id) return item;
    }
    return null;
  }

  void add(WarehouseItem item, {required String performedBy}) {
    state = [item, ...state];
    _history.logStockIn(
      item: item,
      quantity: item.quantity,
      performedBy: performedBy,
    );
  }

  void updateQuantity(String id, int delta, {required String performedBy}) {
    final before = _find(id);
    if (before == null || delta == 0) return;
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(quantity: (item.quantity + delta).clamp(0, 99999))
        else
          item,
    ];
    final after = _find(id);
    if (after != null) {
      _history.logAdjust(item: after, delta: delta, performedBy: performedBy);
    }
  }

  /// Chiqarish (otpravka) — miqdorni kamaytiradi.
  void dispatch(String id, int qty, {required String performedBy}) {
    final item = _find(id);
    if (item == null || qty <= 0) return;
    state = [
      for (final i in state)
        if (i.id == id)
          i.copyWith(quantity: (i.quantity - qty).clamp(0, 99999))
        else
          i,
    ];
    _history.logStockOut(item: item, quantity: qty, performedBy: performedBy);
  }

  void update(WarehouseItem updated) {
    state = [
      for (final item in state) if (item.id == updated.id) updated else item,
    ];
  }

  void remove(String id) => state = state.where((e) => e.id != id).toList();
}

final warehouseProvider =
    StateNotifierProvider<WarehouseNotifier, List<WarehouseItem>>((ref) {
  return WarehouseNotifier(ref.read(warehouseHistoryProvider.notifier));
});

// ─── Employees ────────────────────────────────────────────────────────────────

final class EmployeesNotifier extends StateNotifier<List<Employee>> {
  EmployeesNotifier() : super(_seed);

  static final _seed = <Employee>[
    Employee(
      id: 'user-worker-1',
      firstName: 'Javlon',
      lastName: 'Toshmatov',
      phone: '+998 90 123 45 67',
      role: 'worker',
      birthDate: DateTime(1998, 4, 12),
    ),
    Employee(
      id: 'w-2',
      firstName: 'Nilufar',
      lastName: 'Karimova',
      phone: '+998 91 234 56 78',
      role: 'worker',
      birthDate: DateTime(2000, 8, 3),
    ),
    Employee(
      id: 'w-3',
      firstName: 'Sherzod',
      lastName: 'Mamadov',
      phone: '+998 93 345 67 89',
      role: 'manager',
      birthDate: DateTime(1992, 11, 21),
    ),
    Employee(
      id: 'w-4',
      firstName: 'Dilnoza',
      lastName: 'Ergasheva',
      phone: '+998 94 456 78 90',
      role: 'worker',
      birthDate: DateTime(1999, 2, 17),
    ),
    Employee(
      id: 'w-5',
      firstName: 'Bekzod',
      lastName: 'Rahimov',
      phone: '+998 95 567 89 01',
      role: 'worker',
      birthDate: DateTime(1997, 6, 30),
    ),
  ];

  void add(Employee e) => state = [e, ...state];

  void remove(String id) =>
      state = state.where((e) => e.id != id).toList(growable: false);
}

final employeesProvider =
    StateNotifierProvider<EmployeesNotifier, List<Employee>>((ref) {
  return EmployeesNotifier();
});

/// Davomat va qo'shilgan xodimlardan yig'ilgan jamoa ro'yxati.
final workshopWorkersProvider = Provider<List<WorkshopWorker>>((ref) {
  final attendance = ref.watch(attendanceProvider);
  final employees = ref.watch(employeesProvider);
  return buildWorkshopWorkers(attendance, employees);
});

// ─── Orders (Zakazlar) ────────────────────────────────────────────────────────

final class OrdersNotifier extends StateNotifier<List<WorkshopOrder>> {
  OrdersNotifier() : super(_seed);

  static final _now = DateTime.now();

  static final _seed = <WorkshopOrder>[
    WorkshopOrder(
      id: 'o-1',
      productName: 'Ko\'ylak',
      orderedQty: 500,
      producedQty: 245,
      deadline: _now.add(const Duration(days: 8)),
    ),
    WorkshopOrder(
      id: 'o-2',
      productName: 'Shim',
      orderedQty: 300,
      producedQty: 295,
      deadline: _now.add(const Duration(days: 2)),
    ),
    WorkshopOrder(
      id: 'o-3',
      productName: 'Jaket',
      orderedQty: 150,
      producedQty: 12,
      deadline: _now.subtract(const Duration(days: 1)),
    ),
  ];

  void add(WorkshopOrder order) => state = [order, ...state];

  void updateProduced(String id, int newProduced) {
    state = [
      for (final o in state)
        if (o.id == id)
          o.copyWith(
            producedQty: newProduced.clamp(0, o.orderedQty),
          )
        else
          o,
    ];
  }

  void delete(String id) =>
      state = state.where((o) => o.id != id).toList();
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<WorkshopOrder>>((ref) {
  return OrdersNotifier();
});

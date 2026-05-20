import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workshop_mock_models.dart';

String _hhmmNow() {
  final n = DateTime.now();
  return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
}

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

  /// Yangi xodim qo'shilganda davomat ro'yxatiga ham qo'shiladi.
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

final class TasksNotifier extends StateNotifier<List<WorkshopTaskItem>> {
  TasksNotifier() : super(_seed);

  static final _seed = <WorkshopTaskItem>[
    const WorkshopTaskItem(
      id: 't-1',
      title: 'B — liniya: 120 ta ko\'ylak tikish',
      assigneeId: 'user-worker-1',
      assigneeName: 'Javlon Toshmatov',
    ),
    const WorkshopTaskItem(
      id: 't-2',
      title: 'QC: export partiya tekshiruvi',
      assigneeId: 'w-4',
      assigneeName: 'Dilnoza Ergasheva',
    ),
  ];

  void assign({
    required String title,
    required String assigneeId,
    required String assigneeName,
  }) {
    final t = title.trim();
    if (t.isEmpty) return;
    final id = 't-${DateTime.now().millisecondsSinceEpoch}';
    state = [
      WorkshopTaskItem(
        id: id,
        title: t,
        assigneeId: assigneeId,
        assigneeName: assigneeName,
      ),
      ...state,
    ];
  }
}

final tasksProvider =
    StateNotifierProvider<TasksNotifier, List<WorkshopTaskItem>>((ref) {
  return TasksNotifier();
});

// ─── Warehouse ────────────────────────────────────────────────────────────────

final class WarehouseNotifier extends StateNotifier<List<WarehouseItem>> {
  WarehouseNotifier() : super(_seed);

  static final _seed = <WarehouseItem>[
    const WarehouseItem(
      id: 'w-1',
      name: 'Shim',
      quantity: 7,
      unit: 'ta',
      category: WarehouseCategory.clothing,
    ),
    const WarehouseItem(
      id: 'w-2',
      name: 'Ko\'ylak',
      quantity: 15,
      unit: 'ta',
      category: WarehouseCategory.clothing,
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
    ),
    const WarehouseItem(
      id: 'w-5',
      name: 'Jaket',
      quantity: 5,
      unit: 'ta',
      category: WarehouseCategory.clothing,
    ),
    const WarehouseItem(
      id: 'w-6',
      name: 'Sumka',
      quantity: 30,
      unit: 'ta',
      category: WarehouseCategory.accessory,
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
    ),
    const WarehouseItem(
      id: 'w-9',
      name: 'Ip (oq)',
      quantity: 40,
      unit: 'dona',
      category: WarehouseCategory.material,
    ),
    const WarehouseItem(
      id: 'w-10',
      name: 'Tugma',
      quantity: 500,
      unit: 'dona',
      category: WarehouseCategory.material,
    ),
  ];

  void add(WarehouseItem item) => state = [item, ...state];

  void updateQuantity(String id, int delta) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(quantity: (item.quantity + delta).clamp(0, 99999))
        else
          item,
    ];
  }

  void remove(String id) => state = state.where((e) => e.id != id).toList();
}

final warehouseProvider =
    StateNotifierProvider<WarehouseNotifier, List<WarehouseItem>>((ref) {
  return WarehouseNotifier();
});

// ─── Employees (xodimlar) ─────────────────────────────────────────────────────

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

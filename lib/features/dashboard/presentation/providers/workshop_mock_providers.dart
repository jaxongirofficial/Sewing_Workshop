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

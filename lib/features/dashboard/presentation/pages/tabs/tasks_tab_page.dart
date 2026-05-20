import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/enums/user_role.dart';
import '../../../../../l10n/s.dart';
import '../../../../auth/presentation/providers/auth_notifier.dart';
import '../../models/workshop_mock_models.dart';
import '../../providers/workshop_mock_providers.dart';
import '../../widgets/tasks/task_assign_form.dart';
import '../../widgets/tasks/task_empty_state.dart';
import '../../widgets/tasks/task_list_header.dart';
import '../../widgets/tasks/task_list_tile.dart';

class TasksTabPage extends ConsumerStatefulWidget {
  const TasksTabPage({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<TasksTabPage> createState() => _TasksTabPageState();
}

class _TasksTabPageState extends ConsumerState<TasksTabPage> {
  final _titleCtrl = TextEditingController();
  String? _assigneeId;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  bool get _canAssign =>
      widget.role == UserRole.owner || widget.role == UserRole.manager;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final user = ref.watch(authNotifierProvider).user;
    final people = ref.watch(attendanceProvider);
    final tasks = ref.watch(tasksProvider);

    _assigneeId ??= people.isNotEmpty ? people.first.id : null;

    late final List<WorkshopTaskItem> visibleTasks;
    if (widget.role == UserRole.worker && user != null) {
      visibleTasks = tasks.where((t) => t.assigneeId == user.id).toList();
    } else {
      visibleTasks = tasks.toList();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (_canAssign) ...[
          TaskAssignForm(
            titleCtrl: _titleCtrl,
            people: people,
            assigneeId: _assigneeId,
            onAssigneeChanged: (v) => setState(() => _assigneeId = v),
            onSubmit: people.isEmpty || _assigneeId == null
                ? null
                : () {
                    final id = _assigneeId!;
                    final name =
                        people.firstWhere((p) => p.id == id).name;
                    ref.read(tasksProvider.notifier).assign(
                          title: _titleCtrl.text,
                          assigneeId: id,
                          assigneeName: name,
                        );
                    _titleCtrl.clear();
                    FocusScope.of(context).unfocus();
                  },
          ),
          const SizedBox(height: 24),
        ],
        TaskListHeader(
          title: _canAssign ? s.tasks : s.yourTasks,
          count: visibleTasks.length,
        ),
        if (visibleTasks.isEmpty)
          const TaskEmptyState()
        else
          ...visibleTasks.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TaskListTile(task: t),
            ),
          ),
      ],
    );
  }
}

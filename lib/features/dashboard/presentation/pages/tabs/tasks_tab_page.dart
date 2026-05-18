import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/theme/app_radius.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../l10n/s.dart';
import '../../../../../shared/widgets/brand/brand_primary_button.dart';
import '../../../../../shared/widgets/brand/brand_surface.dart';
import '../../../../../shared/widgets/brand/brand_text_field.dart';
import '../../../../auth/presentation/providers/auth_notifier.dart';
import '../../models/workshop_mock_models.dart';
import '../../providers/workshop_mock_providers.dart';

String _localizedTaskTitle(WorkshopTaskItem task, S s) => switch (task.id) {
      't-1' => s.seedTaskDresses,
      't-2' => s.seedTaskQc,
      _ => task.title,
    };

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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          BrandSurface(
            radius: AppRadius.lg,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.add_task_rounded,
                      color: scheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      s.newTask,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                BrandTextField(
                  controller: _titleCtrl,
                  hintText: s.taskInputHint,
                  prefixIcon: Icons.edit_note_rounded,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 14),
                Container(
                  height: 60,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? scheme.surfaceContainerHigh
                        : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: scheme.outline.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 22,
                        color:
                            scheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            value: _assigneeId != null &&
                                    people.any((p) => p.id == _assigneeId)
                                ? _assigneeId
                                : null,
                            hint: Text(
                              s.assignTo,
                              style: TextStyle(
                                color: scheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: scheme.onSurfaceVariant,
                            ),
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            items: people
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p.id,
                                    child: Text(p.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _assigneeId = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                BrandPrimaryButton(
                  label: s.assignTask,
                  icon: Icons.send_rounded,
                  onPressed: people.isEmpty || _assigneeId == null
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
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Text(
                _canAssign ? s.tasks : s.yourTasks,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${visibleTasks.length}',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (visibleTasks.isEmpty)
          BrandSurface(
            radius: AppRadius.lg,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 44,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.noTasksYet,
                    style: textTheme.titleSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...visibleTasks.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: BrandSurface(
                radius: AppRadius.md,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            scheme.primary.withValues(alpha: 0.20),
                            scheme.primary.withValues(alpha: 0.08),
                          ],
                        ),
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Icon(
                        Icons.task_alt_rounded,
                        color: scheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _localizedTaskTitle(t, s),
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 14,
                                color: scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                t.assigneeName,
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

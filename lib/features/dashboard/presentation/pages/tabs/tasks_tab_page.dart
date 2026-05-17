import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/theme/app_spacing.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../shared/widgets/atoms/app_card.dart';
import '../../../../auth/presentation/providers/auth_notifier.dart';
import '../../models/workshop_mock_models.dart';
import '../../providers/workshop_mock_providers.dart';

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
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (_canAssign) ...[
          Text(
            'Yangi topshiriq',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              hintText: 'Masalan: A liniya — 80 ta shim tikish',
              filled: true,
              fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: scheme.primary, width: 1.4),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Kimga',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                borderRadius: BorderRadius.circular(14),
                value: _assigneeId != null &&
                        people.any((p) => p.id == _assigneeId)
                    ? _assigneeId
                    : null,
                hint: const Text('Tanlang'),
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
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
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
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('Topshiriq berish'),
          ),
          const SizedBox(height: AppSpacing.xl),
          Divider(color: scheme.outlineVariant),
          const SizedBox(height: AppSpacing.md),
        ] else ...[
          Text(
            'Sizga berilgan ishlar',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(
          'Ro\'yxat (${visibleTasks.length})',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (visibleTasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text(
                'Hozircha topshiriq yo\'q',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...visibleTasks.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                hoverable: false,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.task_alt_rounded, color: scheme.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Kim: ${t.assigneeName}',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
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

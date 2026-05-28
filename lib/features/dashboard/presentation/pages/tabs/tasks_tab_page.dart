import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/app_radius.dart';
import '../../../../../core/enums/user_role.dart';
import '../../../../../l10n/s.dart';
import '../../../../../shared/widgets/brand/brand_scrollable_sheet.dart';
import '../../../../auth/presentation/providers/auth_notifier.dart';
import '../../models/workshop_mock_models.dart';
import '../../providers/workshop_mock_providers.dart';
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
  bool get _canAssign =>
      widget.role == UserRole.owner || widget.role == UserRole.manager;

  Future<void> _openAddSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TaskFormSheet(
        onSave: (productName, targetQty, assigneeId, assigneeName, deadline,
            price) {
          ref.read(tasksProvider.notifier).assign(
                productName: productName,
                targetQty: targetQty,
                assigneeId: assigneeId,
                assigneeName: assigneeName,
                deadline: deadline,
                pricePerUnit: price,
              );
        },
        people: ref.read(attendanceProvider),
      ),
    );
  }

  Future<void> _openEditSheet(WorkshopTaskItem task) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TaskFormSheet(
        initialTask: task,
        onSave: (productName, targetQty, assigneeId, assigneeName, deadline,
            price) {
          ref.read(tasksProvider.notifier).update(
                task.copyWith(
                  productName: productName,
                  targetQty: targetQty,
                  assigneeId: assigneeId,
                  assigneeName: assigneeName,
                  deadline: deadline,
                  pricePerUnit: price,
                  clearPrice: price == null,
                ),
              );
        },
        people: ref.read(attendanceProvider),
      ),
    );
  }

  Future<void> _openProgressSheet(WorkshopTaskItem task) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProgressSheet(task: task, ref: ref),
    );
  }

  Future<void> _confirmDelete(WorkshopTaskItem task) async {
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteConfirmTitle),
        content: Text(s.deleteTaskConfirm(task.productName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(tasksProvider.notifier).delete(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final user = ref.watch(authNotifierProvider).user;
    final tasks = ref.watch(tasksProvider);

    late final List<WorkshopTaskItem> visibleTasks;
    if (widget.role == UserRole.worker && user != null) {
      visibleTasks = tasks.where((t) => t.assigneeId == user.id).toList();
    } else {
      visibleTasks = tasks.toList();
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            TaskListHeader(
              title: _canAssign ? s.tasks : s.yourTasks,
              count: visibleTasks.length,
            ),
            const SizedBox(height: 8),
            if (visibleTasks.isEmpty)
              const TaskEmptyState()
            else
              ...visibleTasks.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskListTile(
                    task: t,
                    canEdit: _canAssign,
                    onEdit: _canAssign ? () => _openEditSheet(t) : null,
                    onDelete: _canAssign ? () => _confirmDelete(t) : null,
                    onUpdateProgress: !_canAssign
                        ? () => _openProgressSheet(t)
                        : null,
                  ),
                ),
              ),
          ],
        ),
        if (_canAssign)
          Positioned(
            right: 20,
            bottom: 20,
            child: _NewTaskFab(
              label: s.newTask,
              onTap: _openAddSheet,
            ),
          ),
      ],
    );
  }
}

class _NewTaskFab extends StatelessWidget {
  const _NewTaskFab({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        splashColor: Colors.white.withValues(alpha: 0.18),
        highlightColor: Colors.white.withValues(alpha: 0.08),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary,
                Color.lerp(
                  scheme.primary,
                  AppColors.brandDeep,
                  isDark ? 0.35 : 0.55,
                )!,
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.22),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Task Form Sheet ──────────────────────────────────────────────────────────

class _TaskFormSheet extends StatefulWidget {
  const _TaskFormSheet({
    required this.onSave,
    required this.people,
    this.initialTask,
  });

  final WorkshopTaskItem? initialTask;
  final List<PersonAttendance> people;
  final void Function(
    String productName,
    int targetQty,
    String assigneeId,
    String assigneeName,
    DateTime? deadline,
    double? pricePerUnit,
  ) onSave;

  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _productCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _priceCtrl;
  String? _assigneeId;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTask;
    _productCtrl = TextEditingController(text: t?.productName ?? '');
    _qtyCtrl = TextEditingController(text: t != null ? '${t.targetQty}' : '');
    _priceCtrl = TextEditingController(
      text: t?.pricePerUnit != null ? '${t!.pricePerUnit!.toInt()}' : '',
    );
    _assigneeId = t?.assigneeId ??
        (widget.people.isNotEmpty ? widget.people.first.id : null);
    _deadline = t?.deadline;
  }

  @override
  void dispose() {
    _productCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  int get _qty => int.tryParse(_qtyCtrl.text.trim()) ?? 0;
  double? get _price => double.tryParse(_priceCtrl.text.trim());
  double? get _totalValue =>
      (_price != null && _qty > 0) ? _price! * _qty : null;

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_assigneeId == null) return;
    final assignee = widget.people.firstWhere((p) => p.id == _assigneeId);
    widget.onSave(
      _productCtrl.text.trim(),
      _qty,
      _assigneeId!,
      assignee.name,
      _deadline,
      _price,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEdit = widget.initialTask != null;

    return BrandScrollableSheet(
      child: BrandSheetContainer(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          14 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BrandSheetHandle(),
              const SizedBox(height: 16),
            Text(
              isEdit ? s.editTask : s.newTask,
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _productCtrl,
              decoration: InputDecoration(
                labelText: s.newTask,
                hintText: s.taskProductHint,
                prefixIcon: const Icon(Icons.checkroom_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? s.nameRequired : null,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: s.taskTargetQtyHint,
                      hintText: '50',
                      prefixIcon:
                          const Icon(Icons.format_list_numbered_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return s.numberRequired;
                      }
                      final n = int.tryParse(v.trim());
                      if (n == null || n <= 0) return s.numberRequired;
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: s.taskPricePerUnit,
                      hintText: s.taskPriceHint,
                      prefixIcon: const Icon(Icons.sell_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Avtomatik jami hisob
            if (_totalValue != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                      color: scheme.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calculate_rounded,
                        size: 16, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.taskTotalValue(_totalValue!.toInt()),
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${_priceCtrl.text} × $_qty',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (widget.people.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                value: _assigneeId,
                decoration: InputDecoration(
                  labelText: s.assignTo,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                items: widget.people
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _assigneeId = v),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: _pickDeadline,
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: Text(
                _deadline != null
                    ? '${_deadline!.day}.${_deadline!.month.toString().padLeft(2, '0')}.${_deadline!.year}'
                    : s.taskPickDeadline,
              ),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              child: Text(isEdit ? s.save : s.assignTask),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

// ─── Progress Sheet ───────────────────────────────────────────────────────────

class _ProgressSheet extends StatefulWidget {
  const _ProgressSheet({required this.task, required this.ref});
  final WorkshopTaskItem task;
  final WidgetRef ref;

  @override
  State<_ProgressSheet> createState() => _ProgressSheetState();
}

class _ProgressSheetState extends State<_ProgressSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.task.doneQty}');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final n = int.tryParse(_ctrl.text.trim());
    if (n == null || n < 0) return;
    widget.ref
        .read(tasksProvider.notifier)
        .updateProgress(widget.task.id, n);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BrandScrollableSheet(
      child: BrandSheetContainer(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          14 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BrandSheetHandle(),
            const SizedBox(height: 16),
            Text(
              widget.task.productName,
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              s.taskProgress(widget.task.doneQty, widget.task.targetQty),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: s.doneQtyHint,
                suffixText: '/ ${widget.task.targetQty}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              child: Text(s.save),
            ),
          ],
        ),
      ),
    );
  }
}

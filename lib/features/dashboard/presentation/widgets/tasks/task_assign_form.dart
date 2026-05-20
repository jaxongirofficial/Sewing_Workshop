import 'package:flutter/material.dart';

import '../../../../../config/theme/app_radius.dart';
import '../../../../../l10n/s.dart';
import '../../../../../shared/widgets/brand/brand_primary_button.dart';
import '../../../../../shared/widgets/brand/brand_surface.dart';
import '../../../../../shared/widgets/brand/brand_text_field.dart';
import '../../models/workshop_mock_models.dart';

class TaskAssignForm extends StatelessWidget {
  const TaskAssignForm({
    super.key,
    required this.titleCtrl,
    required this.people,
    required this.assigneeId,
    required this.onAssigneeChanged,
    required this.onSubmit,
  });

  final TextEditingController titleCtrl;
  final List<PersonAttendance> people;
  final String? assigneeId;
  final ValueChanged<String?> onAssigneeChanged;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = S.of(context);

    return BrandSurface(
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
            controller: titleCtrl,
            hintText: s.taskProductHint,
            prefixIcon: Icons.edit_note_rounded,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 14),
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? scheme.surfaceContainerHigh : Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 22,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      value: assigneeId != null &&
                              people.any((p) => p.id == assigneeId)
                          ? assigneeId
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
                      onChanged: onAssigneeChanged,
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
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

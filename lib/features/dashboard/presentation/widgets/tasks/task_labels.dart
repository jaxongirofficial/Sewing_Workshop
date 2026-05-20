import '../../../../../l10n/s.dart';
import '../../models/workshop_mock_models.dart';

String localizedTaskTitle(WorkshopTaskItem task, S s) => switch (task.id) {
  't-1' => s.seedTaskDresses,
  't-2' => s.seedTaskQc,
  _ => task.title,
};

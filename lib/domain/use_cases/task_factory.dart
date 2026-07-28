import '../../core/utils/constants.dart';
import '../entities/priority.dart';
import '../entities/standard_task.dart';
import '../entities/task.dart';
import '../entities/urgent_task.dart';

abstract final class TaskFactory {
  const TaskFactory._();

  static Task create({
    required String title,
    required Priority priority,
    DateTime? deadline,
    String? id,
    bool isDone = false,
    DateTime? now,
  }) {
    if (deadline == null) {
      return StandardTask(
        title: title,
        priority: priority,
        id: id,
        isDone: isDone,
      );
    }

    final reference = now ?? DateTime.now();
    final hoursUntilDue = deadline.difference(reference).inHours;
    final isUrgent = hoursUntilDue <= AppConstants.urgentWindowHours;

    if (isUrgent) {
      return UrgentTask(
        title: title,
        priority: priority,
        deadline: deadline,
        id: id,
        isDone: isDone,
      );
    }

    return StandardTask(
      title: title,
      priority: priority,
      deadline: deadline,
      id: id,
      isDone: isDone,
    );
  }
}

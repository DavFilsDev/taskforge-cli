import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/constants.dart';
import 'priority.dart';
import 'task.dart';

final class UrgentTask extends Task {
  UrgentTask({
    required super.title,
    required super.priority,
    required DateTime super.deadline,
    super.id,
    super.isDone,
  }) {
    if (deadline.isBefore(DateTime(1971))) {
      throw const TaskValidationException(
        'UrgentTask requires a valid, meaningful deadline.',
      );
    }
  }

  DateTime get requiredDeadline => deadline!;

  bool isOverdue({DateTime? now}) =>
      !isDone && requiredDeadline.isBefore(now ?? DateTime.now());

  bool isDueSoon({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final hoursRemaining = requiredDeadline.difference(reference).inHours;
    return !isDone &&
        hoursRemaining >= 0 &&
        hoursRemaining <= AppConstants.urgentWindowHours;
  }

  @override
  String describe({DateTime? now}) {
    final base = super.describe();
    if (isDone) return base;
    if (isOverdue(now: now)) return '$base  ⚠ OVERDUE';
    if (isDueSoon(now: now)) return '$base  ⏰ due soon';
    return base;
  }

  @override
  UrgentTask copyWith({
    String? title,
    Priority? priority,
    DateTime? deadline,
    bool? isDone,
  }) {
    return UrgentTask(
      id: id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      deadline: deadline ?? requiredDeadline,
      isDone: isDone ?? this.isDone,
    );
  }
}

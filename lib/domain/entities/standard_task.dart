import 'priority.dart';
import 'task.dart';

final class StandardTask extends Task {
  StandardTask({
    required super.title,
    required super.priority,
    super.id,
    super.deadline,
    super.isDone,
  });

  @override
  StandardTask copyWith({
    String? title,
    Priority? priority,
    DateTime? deadline,
    bool? isDone,
  }) {
    return StandardTask(
      id: id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      isDone: isDone ?? this.isDone,
    );
  }
}

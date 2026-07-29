import '../../core/exceptions/app_exceptions.dart';
import '../../domain/entities/priority.dart';
import '../../domain/entities/standard_task.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/urgent_task.dart';

abstract final class TaskModel {
  const TaskModel._();

  static const _typeStandard = 'standard';
  static const _typeUrgent = 'urgent';

  static Map<String, dynamic> toJson(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'priority': task.priority.name,
      'deadline': task.deadline?.toIso8601String(),
      'isDone': task.isDone,
      'type': task is UrgentTask ? _typeUrgent : _typeStandard,
    };
  }

  static Task fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'] as String;
      final title = json['title'] as String;
      final priority = PriorityX.parse(json['priority'] as String);
      final deadlineRaw = json['deadline'] as String?;
      final deadline = deadlineRaw == null ? null : DateTime.parse(deadlineRaw);
      final isDone = json['isDone'] as bool? ?? false;
      final type = json['type'] as String? ?? _typeStandard;

      if (type == _typeUrgent) {
        if (deadline == null) {
          throw const MalformedDataException(
            'Stored task is marked urgent but has no deadline.',
          );
        }
        return UrgentTask(
          id: id,
          title: title,
          priority: priority,
          deadline: deadline,
          isDone: isDone,
        );
      }

      return StandardTask(
        id: id,
        title: title,
        priority: priority,
        deadline: deadline,
        isDone: isDone,
      );
    } on TypeError catch (e) {
      throw MalformedDataException('Malformed task record: $e');
    } on FormatException catch (e) {
      throw MalformedDataException('Malformed task record: $e');
    } on TaskValidationException catch (e) {
      throw MalformedDataException('Malformed task record: ${e.message}');
    }
  }
}

import '../../domain/entities/task.dart';

final class TaskFormatter {
  const TaskFormatter();

  String formatOne(Task task) => task.describe();

  String formatList(List<Task> tasks) {
    if (tasks.isEmpty) return 'No tasks found.';
    final buffer = StringBuffer();
    for (final task in tasks) {
      buffer.writeln(task.describe());
    }
    return buffer.toString().trimRight();
  }

  String formatError(String message) => 'Error: $message';

  String formatSuccess(String message) => message;
}

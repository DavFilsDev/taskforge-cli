import '../entities/priority.dart';
import '../entities/task.dart';

abstract interface class SortStrategy {
  List<Task> sort(List<Task> tasks);
}

final class PrioritySortStrategy implements SortStrategy {
  const PrioritySortStrategy();

  @override
  List<Task> sort(List<Task> tasks) {
    final copy = [...tasks];
    copy.sort((a, b) {
      final byPriority = b.priority.weight.compareTo(a.priority.weight);
      if (byPriority != 0) return byPriority;
      return _compareDeadlines(a, b);
    });
    return copy;
  }
}

final class DateSortStrategy implements SortStrategy {
  const DateSortStrategy();

  @override
  List<Task> sort(List<Task> tasks) {
    final copy = [...tasks];
    copy.sort(_compareDeadlines);
    return copy;
  }
}

int _compareDeadlines(Task a, Task b) {
  final aDeadline = a.deadline;
  final bDeadline = b.deadline;
  if (aDeadline == null && bDeadline == null) return 0;
  if (aDeadline == null) return 1;
  if (bDeadline == null) return -1;
  return aDeadline.compareTo(bDeadline);
}

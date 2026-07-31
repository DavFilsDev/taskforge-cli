import 'package:test/test.dart';
import 'package:taskforge_cli/domain/entities/priority.dart';
import 'package:taskforge_cli/domain/entities/standard_task.dart';
import 'package:taskforge_cli/domain/strategies/sort_strategy.dart';

void main() {
  group('PrioritySortStrategy', () {
    test('should order tasks from high to low priority', () {
      final low = StandardTask(title: 'Low', priority: Priority.low);
      final high = StandardTask(title: 'High', priority: Priority.high);
      final medium = StandardTask(title: 'Medium', priority: Priority.medium);

      final sorted = const PrioritySortStrategy().sort([low, high, medium]);

      expect(sorted.map((t) => t.title), ['High', 'Medium', 'Low']);
    });

    test('should not mutate the input list', () {
      final tasks = [
        StandardTask(title: 'A', priority: Priority.low),
        StandardTask(title: 'B', priority: Priority.high),
      ];
      final originalOrder = [...tasks];

      const PrioritySortStrategy().sort(tasks);

      expect(tasks.map((t) => t.title), originalOrder.map((t) => t.title));
    });

    test('should return an empty list unchanged', () {
      expect(const PrioritySortStrategy().sort([]), isEmpty);
    });
  });

  group('DateSortStrategy', () {
    test('should order tasks by earliest deadline first', () {
      final later = StandardTask(
        title: 'Later',
        priority: Priority.low,
        deadline: DateTime(2030, 6, 1),
      );
      final sooner = StandardTask(
        title: 'Sooner',
        priority: Priority.low,
        deadline: DateTime(2026, 1, 1),
      );

      final sorted = const DateSortStrategy().sort([later, sooner]);

      expect(sorted.map((t) => t.title), ['Sooner', 'Later']);
    });

    test('should push tasks with no deadline to the end', () {
      final noDeadline = StandardTask(title: 'Someday', priority: Priority.low);
      final withDeadline = StandardTask(
        title: 'Scheduled',
        priority: Priority.low,
        deadline: DateTime(2026, 1, 1),
      );

      final sorted = const DateSortStrategy().sort([noDeadline, withDeadline]);

      expect(sorted.map((t) => t.title), ['Scheduled', 'Someday']);
    });
  });
}

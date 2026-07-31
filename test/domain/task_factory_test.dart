import 'package:test/test.dart';
import 'package:taskforge_cli/domain/entities/priority.dart';
import 'package:taskforge_cli/domain/entities/standard_task.dart';
import 'package:taskforge_cli/domain/entities/urgent_task.dart';
import 'package:taskforge_cli/domain/use_cases/task_factory.dart';

void main() {
  group('TaskFactory', () {
    test('should build a StandardTask when no deadline is given', () {
      final task = TaskFactory.create(title: 'Task', priority: Priority.low);
      expect(task, isA<StandardTask>());
    });

    test('should build a StandardTask when the deadline is far away', () {
      final now = DateTime(2026, 1, 1);
      final task = TaskFactory.create(
        title: 'Task',
        priority: Priority.low,
        deadline: now.add(const Duration(days: 10)),
        now: now,
      );
      expect(task, isA<StandardTask>());
    });

    test('should promote to UrgentTask when the deadline is within the urgent window', () {
      final now = DateTime(2026, 1, 1);
      final task = TaskFactory.create(
        title: 'Task',
        priority: Priority.high,
        deadline: now.add(const Duration(hours: 5)),
        now: now,
      );
      expect(task, isA<UrgentTask>());
    });

    test('should promote to UrgentTask when the deadline has already passed', () {
      final now = DateTime(2026, 1, 1);
      final task = TaskFactory.create(
        title: 'Task',
        priority: Priority.medium,
        deadline: now.subtract(const Duration(hours: 2)),
        now: now,
      );
      expect(task, isA<UrgentTask>());
    });

    test('should preserve isDone across the promotion decision', () {
      final now = DateTime(2026, 1, 1);
      final task = TaskFactory.create(
        title: 'Task',
        priority: Priority.high,
        deadline: now.add(const Duration(hours: 1)),
        now: now,
        isDone: true,
      );
      expect(task.isDone, isTrue);
    });
  });
}

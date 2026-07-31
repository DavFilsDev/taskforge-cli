import 'package:test/test.dart';
import 'package:taskforge_cli/core/exceptions/app_exceptions.dart';
import 'package:taskforge_cli/domain/entities/priority.dart';
import 'package:taskforge_cli/domain/entities/standard_task.dart';
import 'package:taskforge_cli/domain/entities/urgent_task.dart';

void main() {
  group('Priority', () {
    test('should order high above medium above low by weight', () {
      final weights = [Priority.low, Priority.medium, Priority.high]
          .map((p) => p.weight)
          .toList();

      expect(weights, [1, 2, 3]);
    });

    test('should parse valid case-insensitive strings', () {
      expect(PriorityX.parse('HIGH'), Priority.high);
      expect(PriorityX.parse('  medium '), Priority.medium);
    });

    test('should throw TaskValidationException when parsing an invalid value', () {
      expect(
        () => PriorityX.parse('urgent'),
        throwsA(isA<TaskValidationException>()),
      );
    });
  });

  group('StandardTask', () {
    test('should trim the title on construction', () {
      final task = StandardTask(title: '  Buy milk  ', priority: Priority.low);

      expect(task.title, 'Buy milk');
    });

    test('should throw TaskValidationException when title is empty', () {
      expect(
        () => StandardTask(title: '   ', priority: Priority.low),
        throwsA(isA<TaskValidationException>()),
      );
    });

    test('should default isDone to false', () {
      final task = StandardTask(title: 'Task', priority: Priority.medium);
      expect(task.isDone, isFalse);
    });

    test('copyWith should preserve the concrete StandardTask type', () {
      final task = StandardTask(title: 'Task', priority: Priority.low);
      final updated = task.copyWith(isDone: true);

      expect(updated, isA<StandardTask>());
      expect(updated.isDone, isTrue);
      expect(updated.id, task.id);
    });

    test('two tasks with the same id should be equal', () {
      final task = StandardTask(title: 'Task', priority: Priority.low, id: 'x1');
      final other = StandardTask(title: 'Other', priority: Priority.high, id: 'x1');
      expect(task, equals(other));
    });
  });

  group('UrgentTask', () {
    test('should require a deadline and reject a degenerate one', () {
      expect(
        () => UrgentTask(
          title: 'Task',
          priority: Priority.high,
          deadline: DateTime(1969),
        ),
        throwsA(isA<TaskValidationException>()),
      );
    });

    test('should report isOverdue when the deadline has passed', () {
      final task = UrgentTask(
        title: 'Renew passport',
        priority: Priority.high,
        deadline: DateTime(2020, 1, 1),
      );

      expect(task.isOverdue(now: DateTime(2020, 1, 2)), isTrue);
    });

    test('should not report isOverdue for a completed task', () {
      final task = UrgentTask(
        title: 'Renew passport',
        priority: Priority.high,
        deadline: DateTime(2020, 1, 1),
        isDone: true,
      );

      expect(task.isOverdue(now: DateTime(2020, 1, 2)), isFalse);
    });

    test('should report isDueSoon within the urgent window but not overdue', () {
      final now = DateTime(2026, 1, 1, 12);
      final task = UrgentTask(
        title: 'Submit report',
        priority: Priority.medium,
        deadline: now.add(const Duration(hours: 5)),
      );

      expect(task.isDueSoon(now: now), isTrue);
      expect(task.isOverdue(now: now), isFalse);
    });

    test('describe should include an overdue marker', () {
      final task = UrgentTask(
        title: 'Renew passport',
        priority: Priority.high,
        deadline: DateTime(2020, 1, 1),
      );

      expect(task.describe(now: DateTime(2020, 1, 2)), contains('OVERDUE'));
    });

    test('copyWith should preserve the concrete UrgentTask type', () {
      final task = UrgentTask(
        title: 'Task',
        priority: Priority.low,
        deadline: DateTime(2030, 1, 1),
      );
      final updated = task.copyWith(priority: Priority.high);

      expect(updated, isA<UrgentTask>());
      expect(updated.priority, Priority.high);
    });
  });
}

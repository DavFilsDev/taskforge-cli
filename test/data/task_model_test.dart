import 'package:test/test.dart';
import 'package:taskforge_cli/core/exceptions/app_exceptions.dart';
import 'package:taskforge_cli/data/models/task_model.dart';
import 'package:taskforge_cli/domain/entities/priority.dart';
import 'package:taskforge_cli/domain/entities/standard_task.dart';
import 'package:taskforge_cli/domain/entities/urgent_task.dart';

void main() {
  group('TaskModel', () {
    test('should round-trip a StandardTask through toJson/fromJson', () {
      final task = StandardTask(
        title: 'Task',
        priority: Priority.medium,
        deadline: DateTime(2030, 1, 1),
        id: 's1',
      );

      final restored = TaskModel.fromJson(TaskModel.toJson(task));

      expect(restored, isA<StandardTask>());
      expect(restored.title, 'Task');
      expect(restored.deadline, DateTime(2030, 1, 1));
    });

    test('should round-trip an UrgentTask, preserving its subclass', () {
      final task = UrgentTask(
        title: 'Task',
        priority: Priority.high,
        deadline: DateTime(2030, 1, 1),
        id: 'u1',
      );

      final restored = TaskModel.fromJson(TaskModel.toJson(task));

      expect(restored, isA<UrgentTask>());
    });

    test(
        'should throw MalformedDataException when marked urgent but missing a deadline',
        () {
      final json = {
        'id': 'x',
        'title': 'Task',
        'priority': 'high',
        'deadline': null,
        'isDone': false,
        'type': 'urgent',
      };

      expect(() => TaskModel.fromJson(json),
          throwsA(isA<MalformedDataException>()));
    });

    test(
        'should throw MalformedDataException for a record with the wrong field types',
        () {
      final json = {
        'id': 'x',
        'title': 123,
        'priority': 'low',
        'deadline': null,
        'isDone': false,
        'type': 'standard',
      };

      expect(() => TaskModel.fromJson(json),
          throwsA(isA<MalformedDataException>()));
    });
  });
}

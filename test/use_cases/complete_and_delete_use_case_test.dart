import 'package:test/test.dart';
import 'package:taskforge_cli/core/exceptions/app_exceptions.dart';
import 'package:taskforge_cli/domain/entities/priority.dart';
import 'package:taskforge_cli/domain/entities/standard_task.dart';
import 'package:taskforge_cli/domain/use_cases/complete_task_use_case.dart';
import 'package:taskforge_cli/domain/use_cases/delete_task_use_case.dart';

import '../fakes/fake_task_repository.dart';

void main() {
  group('CompleteTaskUseCase', () {
    late FakeTaskRepository repository;
    late CompleteTaskUseCase useCase;

    setUp(() {
      repository = FakeTaskRepository();
      useCase = CompleteTaskUseCase(repository);
    });

    test('should mark the matching task as done', () async {
      final task =
          StandardTask(title: 'Task', priority: Priority.low, id: 't1');
      repository.seed([task]);

      final updated = await useCase('t1');

      expect(updated.isDone, isTrue);
      final stored = await repository.getById('t1');
      expect(stored!.isDone, isTrue);
    });

    test('should throw TaskNotFoundException for an unknown id', () async {
      expect(() => useCase('missing'), throwsA(isA<TaskNotFoundException>()));
    });
  });

  group('DeleteTaskUseCase', () {
    late FakeTaskRepository repository;
    late DeleteTaskUseCase useCase;

    setUp(() {
      repository = FakeTaskRepository();
      useCase = DeleteTaskUseCase(repository);
    });

    test('should remove the matching task', () async {
      repository.seed(
          [StandardTask(title: 'Task', priority: Priority.low, id: 't1')]);

      await useCase('t1');

      expect(await repository.getById('t1'), isNull);
    });

    test(
        'should throw TaskNotFoundException for an unknown id and leave the store untouched',
        () async {
      repository.seed(
          [StandardTask(title: 'Task', priority: Priority.low, id: 't1')]);

      expect(() => useCase('missing'), throwsA(isA<TaskNotFoundException>()));
      expect(await repository.getAll(), hasLength(1));
    });
  });
}

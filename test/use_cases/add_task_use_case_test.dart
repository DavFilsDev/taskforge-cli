import 'package:test/test.dart';
import 'package:taskforge_cli/core/exceptions/app_exceptions.dart';
import 'package:taskforge_cli/domain/entities/priority.dart';
import 'package:taskforge_cli/domain/entities/standard_task.dart';
import 'package:taskforge_cli/domain/use_cases/add_task_use_case.dart';

import '../fakes/fake_task_repository.dart';

void main() {
  group('AddTaskUseCase', () {
    late FakeTaskRepository repository;
    late AddTaskUseCase useCase;

    setUp(() {
      repository = FakeTaskRepository();
      useCase = AddTaskUseCase(repository);
    });

    test('should persist a new task and return it', () async {
      final task =
          await useCase(title: 'Write tests', priority: Priority.medium);

      expect(task.title, 'Write tests');
      final stored = await repository.getAll();
      expect(stored, hasLength(1));
    });

    test(
        'should throw DuplicateTaskException for a case-insensitive duplicate title',
        () async {
      repository
          .seed([StandardTask(title: 'Write tests', priority: Priority.low)]);

      expect(
        () => useCase(title: '  WRITE TESTS  ', priority: Priority.high),
        throwsA(isA<DuplicateTaskException>()),
      );
    });

    test('should propagate TaskValidationException for an empty title',
        () async {
      expect(
        () => useCase(title: '   ', priority: Priority.low),
        throwsA(isA<TaskValidationException>()),
      );
    });

    test('should not call repository.add when validation fails first',
        () async {
      try {
        await useCase(title: '', priority: Priority.low);
      } catch (_) {}
      expect(repository.callCountAdd, 0);
    });
  });
}

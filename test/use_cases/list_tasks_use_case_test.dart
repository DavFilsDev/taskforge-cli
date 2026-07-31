import 'package:test/test.dart';
import 'package:taskforge_cli/domain/entities/priority.dart';
import 'package:taskforge_cli/domain/entities/standard_task.dart';
import 'package:taskforge_cli/domain/strategies/sort_strategy.dart';
import 'package:taskforge_cli/domain/use_cases/list_tasks_use_case.dart';

import '../fakes/fake_task_repository.dart';

void main() {
  group('ListTasksUseCase', () {
    late FakeTaskRepository repository;
    late ListTasksUseCase useCase;

    setUp(() {
      repository = FakeTaskRepository();
      useCase = ListTasksUseCase(repository);
    });

    test('should return an empty list when no tasks exist', () async {
      final result = await useCase();
      expect(result, isEmpty);
    });

    test('should delegate ordering to the supplied SortStrategy', () async {
      repository.seed([
        StandardTask(title: 'Low', priority: Priority.low),
        StandardTask(title: 'High', priority: Priority.high),
      ]);

      final result = await useCase(strategy: const PrioritySortStrategy());

      expect(result.map((t) => t.title), ['High', 'Low']);
    });

    test('should exclude completed tasks when includeCompleted is false', () async {
      repository.seed([
        StandardTask(title: 'Done', priority: Priority.low, isDone: true),
        StandardTask(title: 'Pending', priority: Priority.low),
      ]);

      final result = await useCase(includeCompleted: false);

      expect(result.map((t) => t.title), ['Pending']);
    });
  });
}

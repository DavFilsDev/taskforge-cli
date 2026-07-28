import '../entities/task.dart';
import '../interfaces/task_repository.dart';
import '../strategies/sort_strategy.dart';

final class ListTasksUseCase {
  const ListTasksUseCase(this._repository);

  final TaskRepository _repository;

  Future<List<Task>> call({
    SortStrategy strategy = const _NoOpSortStrategy(),
    bool includeCompleted = true,
  }) async {
    final tasks = await _repository.getAll();
    final filtered =
        includeCompleted ? tasks : tasks.where((t) => !t.isDone).toList();
    return strategy.sort(filtered);
  }
}

final class _NoOpSortStrategy implements SortStrategy {
  const _NoOpSortStrategy();

  @override
  List<Task> sort(List<Task> tasks) => tasks;
}

import '../../core/exceptions/app_exceptions.dart';
import '../entities/priority.dart';
import '../entities/task.dart';
import '../interfaces/task_repository.dart';
import 'task_factory.dart';

final class AddTaskUseCase {
  const AddTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Task> call({
    required String title,
    required Priority priority,
    DateTime? deadline,
  }) async {
    final existing = await _repository.findByTitle(title);
    if (existing != null) {
      throw DuplicateTaskException(title);
    }

    final task = TaskFactory.create(
      title: title,
      priority: priority,
      deadline: deadline,
    );

    await _repository.add(task);
    return task;
  }
}

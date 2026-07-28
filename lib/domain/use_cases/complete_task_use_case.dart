import '../../core/exceptions/app_exceptions.dart';
import '../entities/task.dart';
import '../interfaces/task_repository.dart';

final class CompleteTaskUseCase {
  const CompleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Task> call(String id) async {
    final task = await _repository.getById(id);
    if (task == null) {
      throw TaskNotFoundException(id);
    }

    final updated = task.copyWith(isDone: true);
    await _repository.update(updated);
    return updated;
  }
}

import '../../core/exceptions/app_exceptions.dart';
import '../interfaces/task_repository.dart';

final class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> call(String id) async {
    final task = await _repository.getById(id);
    if (task == null) {
      throw TaskNotFoundException(id);
    }
    await _repository.deleteById(id);
  }
}

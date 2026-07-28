import '../entities/task.dart';
import 'repository.dart';

abstract interface class TaskRepository implements Repository<Task> {
  @override
  Future<List<Task>> getAll();

  @override
  Future<Task?> getById(String id);

  @override
  Future<void> add(Task item);

  @override
  Future<void> update(Task item);

  @override
  Future<void> deleteById(String id);

  Future<Task?> findByTitle(String title);
}

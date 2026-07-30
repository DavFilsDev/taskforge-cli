import '../../domain/entities/task.dart';
import '../../domain/interfaces/task_repository.dart';
import '../models/task_model.dart';
import '../sources/json_file_data_source.dart';

final class JsonTaskRepository implements TaskRepository {
  JsonTaskRepository(this._dataSource);

  final JsonFileDataSource _dataSource;

  @override
  Future<List<Task>> getAll() async {
    final records = await _dataSource.readAll();
    return records.map(TaskModel.fromJson).toList();
  }

  @override
  Future<Task?> getById(String id) async {
    final tasks = await getAll();
    for (final task in tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  @override
  Future<Task?> findByTitle(String title) async {
    final normalized = title.trim().toLowerCase();
    final tasks = await getAll();
    for (final task in tasks) {
      if (task.title.trim().toLowerCase() == normalized) return task;
    }
    return null;
  }

  @override
  Future<void> add(Task item) async {
    final tasks = await getAll();
    tasks.add(item);
    await _persist(tasks);
  }

  @override
  Future<void> update(Task item) async {
    final tasks = await getAll();
    final index = tasks.indexWhere((t) => t.id == item.id);
    if (index == -1) {
      tasks.add(item);
    } else {
      tasks[index] = item;
    }
    await _persist(tasks);
  }

  @override
  Future<void> deleteById(String id) async {
    final tasks = await getAll();
    tasks.removeWhere((t) => t.id == id);
    await _persist(tasks);
  }

  Future<void> _persist(List<Task> tasks) {
    return _dataSource.writeAll(tasks.map(TaskModel.toJson).toList());
  }
}

import 'package:taskforge_cli/domain/entities/task.dart';
import 'package:taskforge_cli/domain/interfaces/task_repository.dart';

final class FakeTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  void seed(Iterable<Task> tasks) => _tasks.addAll(tasks);

  int get callCountAdd => _addCalls;
  int _addCalls = 0;

  @override
  Future<List<Task>> getAll() async => List.unmodifiable(_tasks);

  @override
  Future<Task?> getById(String id) async {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  @override
  Future<Task?> findByTitle(String title) async {
    final normalized = title.trim().toLowerCase();
    for (final task in _tasks) {
      if (task.title.trim().toLowerCase() == normalized) return task;
    }
    return null;
  }

  @override
  Future<void> add(Task item) async {
    _addCalls++;
    _tasks.add(item);
  }

  @override
  Future<void> update(Task item) async {
    final index = _tasks.indexWhere((t) => t.id == item.id);
    if (index == -1) {
      _tasks.add(item);
    } else {
      _tasks[index] = item;
    }
  }

  @override
  Future<void> deleteById(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }
}

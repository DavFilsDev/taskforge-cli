import '../../core/utils/validators.dart';
import 'priority.dart';

abstract base class Task {
  Task({
    required String title,
    required this.priority,
    String? id,
    this.deadline,
    this.isDone = false,
  })  : id = id ?? _generateId(),
        title = Validators.requireNonEmptyTitle(title);

  final String id;

  final String title;
  final Priority priority;
  final DateTime? deadline;
  final bool isDone;

  Task copyWith({
    String? title,
    Priority? priority,
    DateTime? deadline,
    bool? isDone,
  });

  String describe({DateTime? now}) {
    final status = isDone ? '[x]' : '[ ]';
    final due = deadline != null ? ' (due ${deadline!.toIso8601String()})' : '';
    return '$status $title — ${priority.label}$due';
  }

  static String _generateId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_counter++}';

  static int _counter = 0;

  @override
  String toString() => describe();

  @override
  bool operator ==(Object other) => other is Task && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

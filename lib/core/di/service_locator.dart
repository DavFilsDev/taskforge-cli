import '../../data/repositories/json_task_repository.dart';
import '../../data/sources/json_file_data_source.dart';
import '../../domain/interfaces/task_repository.dart';
import '../../domain/use_cases/add_task_use_case.dart';
import '../../domain/use_cases/complete_task_use_case.dart';
import '../../domain/use_cases/delete_task_use_case.dart';
import '../../domain/use_cases/list_tasks_use_case.dart';
import '../../presentation/commands/add_command.dart';
import '../../presentation/commands/command.dart';
import '../../presentation/commands/delete_command.dart';
import '../../presentation/commands/done_command.dart';
import '../../presentation/commands/help_command.dart';
import '../../presentation/commands/list_command.dart';
import '../../presentation/formatters/task_formatter.dart';
import '../utils/constants.dart';

final class ServiceLocator {
  ServiceLocator._({String storagePath = AppConstants.defaultStoragePath})
      : _dataSource = JsonFileDataSource(storagePath) {
    _repository = JsonTaskRepository(_dataSource);
    _formatter = const TaskFormatter();

    _addTaskUseCase = AddTaskUseCase(_repository);
    _listTasksUseCase = ListTasksUseCase(_repository);
    _completeTaskUseCase = CompleteTaskUseCase(_repository);
    _deleteTaskUseCase = DeleteTaskUseCase(_repository);

    _commands = [
      AddCommand(_addTaskUseCase, _formatter),
      ListCommand(_listTasksUseCase, _formatter),
      DoneCommand(_completeTaskUseCase, _formatter),
      DeleteCommand(_deleteTaskUseCase, _formatter),
    ];
    _commands.add(HelpCommand(_commands));
  }

  static ServiceLocator? _instance;

  factory ServiceLocator({String? storagePath}) {
    return _instance ??= ServiceLocator._(
      storagePath: storagePath ?? AppConstants.defaultStoragePath,
    );
  }

  static void reset() => _instance = null;

  final JsonFileDataSource _dataSource;
  late final TaskRepository _repository;
  late final TaskFormatter _formatter;

  late final AddTaskUseCase _addTaskUseCase;
  late final ListTasksUseCase _listTasksUseCase;
  late final CompleteTaskUseCase _completeTaskUseCase;
  late final DeleteTaskUseCase _deleteTaskUseCase;

  late final List<Command> _commands;

  List<Command> get commands => List.unmodifiable(_commands);
}

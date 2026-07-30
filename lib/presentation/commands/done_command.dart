import '../../core/utils/constants.dart';
import '../../domain/use_cases/complete_task_use_case.dart';
import '../formatters/task_formatter.dart';
import '../validators/cli_input_validator.dart';
import 'command.dart';

final class DoneCommand implements Command {
  const DoneCommand(this._useCase, this._formatter);

  final CompleteTaskUseCase _useCase;
  final TaskFormatter _formatter;

  @override
  String get name => 'done';

  @override
  String get summary => 'done --id <task-id>';

  @override
  Future<int> execute(CliInputValidator input) async {
    final id = input.require('id');
    final task = await _useCase(id);
    print(_formatter.formatSuccess('Completed: ${_formatter.formatOne(task)}'));
    return AppConstants.exitSuccess;
  }
}

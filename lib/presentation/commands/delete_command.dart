import '../../core/utils/constants.dart';
import '../../domain/use_cases/delete_task_use_case.dart';
import '../formatters/task_formatter.dart';
import '../validators/cli_input_validator.dart';
import 'command.dart';

final class DeleteCommand implements Command {
  const DeleteCommand(this._useCase, this._formatter);

  final DeleteTaskUseCase _useCase;
  final TaskFormatter _formatter;

  @override
  String get name => 'delete';

  @override
  String get summary => 'delete --id <task-id>';

  @override
  Future<int> execute(CliInputValidator input) async {
    final id = input.require('id');
    await _useCase(id);
    print(_formatter.formatSuccess('Deleted task $id.'));
    return AppConstants.exitSuccess;
  }
}

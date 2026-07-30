import '../../core/utils/constants.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/priority.dart';
import '../../domain/use_cases/add_task_use_case.dart';
import '../formatters/task_formatter.dart';
import '../validators/cli_input_validator.dart';
import 'command.dart';

final class AddCommand implements Command {
  const AddCommand(this._useCase, this._formatter);

  final AddTaskUseCase _useCase;
  final TaskFormatter _formatter;

  @override
  String get name => 'add';

  @override
  String get summary =>
      'add --title <title> --priority <low|medium|high> [--deadline <date>]';

  @override
  Future<int> execute(CliInputValidator input) async {
    final title = input.require('title');
    final priority = PriorityX.parse(input.require('priority'));
    final deadlineRaw = input.optional('deadline');
    final deadline =
        deadlineRaw == null ? null : Validators.parseDeadline(deadlineRaw);

    final task = await _useCase(
      title: title,
      priority: priority,
      deadline: deadline,
    );

    print(_formatter.formatSuccess('Added: ${_formatter.formatOne(task)}'));
    return AppConstants.exitSuccess;
  }
}

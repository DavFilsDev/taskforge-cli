import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/constants.dart';
import '../../domain/strategies/sort_strategy.dart';
import '../../domain/use_cases/list_tasks_use_case.dart';
import '../formatters/task_formatter.dart';
import '../validators/cli_input_validator.dart';
import 'command.dart';

final class ListCommand implements Command {
  const ListCommand(this._useCase, this._formatter);

  final ListTasksUseCase _useCase;
  final TaskFormatter _formatter;

  @override
  String get name => 'list';

  @override
  String get summary => 'list [--sort priority|date] [--pending-only]';

  @override
  Future<int> execute(CliInputValidator input) async {
    final sortValue = input.optional('sort');
    final strategy = _strategyFor(sortValue);
    final includeCompleted = !input.has('pending-only');

    final tasks = await _useCase(
      strategy: strategy,
      includeCompleted: includeCompleted,
    );

    print(_formatter.formatList(tasks));
    return AppConstants.exitSuccess;
  }

  SortStrategy _strategyFor(String? sortValue) {
    switch (sortValue) {
      case null:
      case 'priority':
        return const PrioritySortStrategy();
      case 'date':
        return const DateSortStrategy();
      default:
        throw InvalidArgumentException(
          'Invalid --sort value "$sortValue". Expected "priority" or "date".',
        );
    }
  }
}

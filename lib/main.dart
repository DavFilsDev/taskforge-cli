import 'core/di/service_locator.dart';
import 'core/exceptions/app_exceptions.dart';
import 'core/utils/constants.dart';
import 'presentation/commands/command.dart';
import 'presentation/validators/cli_input_validator.dart';

Future<int> run(List<String> arguments) async {
  final locator = ServiceLocator();

  if (arguments.isEmpty ||
      arguments.first == '--help' ||
      arguments.first == '-h') {
    return _findHelp(locator.commands).execute(CliInputValidator(const []));
  }

  final commandName = arguments.first;
  final rest = arguments.skip(1).toList();

  Command? command;
  for (final candidate in locator.commands) {
    if (candidate.name == commandName) {
      command = candidate;
      break;
    }
  }

  if (command == null) {
    print('Unknown command "$commandName". Run with --help for usage.');
    return AppConstants.exitUsageError;
  }

  try {
    return await command.execute(CliInputValidator(rest));
  } on TaskValidationException catch (e) {
    print('Error: ${e.message}');
    return AppConstants.exitUsageError;
  } on InvalidArgumentException catch (e) {
    print('Error: ${e.message}');
    return AppConstants.exitUsageError;
  } on TaskNotFoundException catch (e) {
    print('Error: ${e.message}');
    return AppConstants.exitDataError;
  } on DuplicateTaskException catch (e) {
    print('Error: ${e.message}');
    return AppConstants.exitDataError;
  } on MalformedDataException catch (e) {
    print('Error: ${e.message}');
    return AppConstants.exitDataError;
  } on FileException catch (e) {
    print('Error: ${e.message}');
    return AppConstants.exitIoError;
  }
}

Command _findHelp(List<Command> commands) =>
    commands.firstWhere((c) => c.name == 'help');

import 'core/di/service_locator.dart';
import 'core/exceptions/app_exceptions.dart';
import 'core/utils/constants.dart';
import 'presentation/commands/command.dart';
import 'presentation/validators/cli_input_validator.dart';

Future<int> run(List<String> arguments, {ServiceLocator? locator}) async {
  final resolvedLocator = locator ?? ServiceLocator();

  if (arguments.isEmpty ||
      arguments.first == '--help' ||
      arguments.first == '-h') {
    return _findHelp(resolvedLocator.commands)
        .execute(CliInputValidator(const []));
  }

  final commandName = arguments.first;
  final rest = arguments.skip(1).toList();

  Command? command;
  for (final candidate in resolvedLocator.commands) {
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
  } on AppException catch (e) {
    return _handle(e);
  }
}

int _handle(AppException exception) {
  final exitCode = switch (exception) {
    TaskValidationException() => AppConstants.exitUsageError,
    InvalidArgumentException() => AppConstants.exitUsageError,
    TaskNotFoundException() => AppConstants.exitDataError,
    DuplicateTaskException() => AppConstants.exitDataError,
    MalformedDataException() => AppConstants.exitDataError,
    FileException() => AppConstants.exitIoError,
  };
  print('Error: ${exception.message}');
  return exitCode;
}

Command _findHelp(List<Command> commands) =>
    commands.firstWhere((c) => c.name == 'help');

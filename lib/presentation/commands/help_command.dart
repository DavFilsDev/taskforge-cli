import '../../core/utils/constants.dart';
import '../validators/cli_input_validator.dart';
import 'command.dart';

final class HelpCommand implements Command {
  const HelpCommand(this._allCommands);

  final List<Command> _allCommands;

  @override
  String get name => 'help';

  @override
  String get summary => 'help — show this message';

  @override
  Future<int> execute(CliInputValidator input) async {
    final buffer = StringBuffer()
      ..writeln('${AppConstants.appName} v${AppConstants.version}')
      ..writeln('Usage: dart run bin/taskforge_cli.dart <command> [options]')
      ..writeln()
      ..writeln('Commands:');
    for (final command in _allCommands) {
      buffer.writeln('  ${command.summary}');
    }
    print(buffer.toString().trimRight());
    return AppConstants.exitSuccess;
  }
}

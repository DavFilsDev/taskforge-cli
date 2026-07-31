import '../validators/cli_input_validator.dart';

abstract interface class Command {
  String get name;

  String get summary;

  Future<int> execute(CliInputValidator input);
}

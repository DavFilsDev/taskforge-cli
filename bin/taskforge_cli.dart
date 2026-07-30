import 'dart:io';

import 'package:taskforge_cli/main.dart' as app;

Future<void> main(List<String> arguments) async {
  final exitCode = await app.run(arguments);
  exit(exitCode);
}

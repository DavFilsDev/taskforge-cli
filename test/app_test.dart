import 'dart:io';

import 'package:test/test.dart';
import 'package:taskforge_cli/core/di/service_locator.dart';
import 'package:taskforge_cli/core/utils/constants.dart';
import 'package:taskforge_cli/main.dart' as app;

void main() {
  group('run', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('taskforge_cli_app_test_');
      ServiceLocator.reset();
    });

    tearDown(() {
      ServiceLocator.reset();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('should print usage and return exitSuccess for --help', () async {
      final locator = ServiceLocator(storagePath: '${tempDir.path}/tasks.json');

      final code = await app.run(['--help'], locator: locator);

      expect(code, AppConstants.exitSuccess);
    });

    test('should return exitUsageError for an unrecognized command', () async {
      final locator = ServiceLocator(storagePath: '${tempDir.path}/tasks.json');

      final code = await app.run(['bogus'], locator: locator);

      expect(code, AppConstants.exitUsageError);
    });

    test('should return exitUsageError when a required flag is missing',
        () async {
      final locator = ServiceLocator(storagePath: '${tempDir.path}/tasks.json');

      final code =
          await app.run(['add', '--priority', 'high'], locator: locator);

      expect(code, AppConstants.exitUsageError);
    });

    test('should return exitDataError when completing an unknown task id',
        () async {
      final locator = ServiceLocator(storagePath: '${tempDir.path}/tasks.json');

      final code = await app.run(['done', '--id', 'missing'], locator: locator);

      expect(code, AppConstants.exitDataError);
    });

    test('should return exitSuccess and persist a task end to end', () async {
      final locator = ServiceLocator(storagePath: '${tempDir.path}/tasks.json');

      final code = await app.run(
        ['add', '--title', 'Test task', '--priority', 'low'],
        locator: locator,
      );

      expect(code, AppConstants.exitSuccess);
      expect(await File('${tempDir.path}/tasks.json').exists(), isTrue);
    });
  });
}

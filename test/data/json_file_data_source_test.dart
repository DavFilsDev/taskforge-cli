import 'dart:io';

import 'package:test/test.dart';
import 'package:taskforge_cli/core/exceptions/app_exceptions.dart';
import 'package:taskforge_cli/data/sources/json_file_data_source.dart';

void main() {
  group('JsonFileDataSource', () {
    late Directory tempDir;
    late String filePath;
    late JsonFileDataSource dataSource;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('taskforge_cli_test_');
      filePath = '${tempDir.path}/tasks.json';
      dataSource = JsonFileDataSource(filePath);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should return an empty list when the file does not exist yet', () async {
      final result = await dataSource.readAll();
      expect(result, isEmpty);
    });

    test('should round-trip records written then read back', () async {
      final records = [
        {'id': '1', 'title': 'A', 'priority': 'low', 'deadline': null, 'isDone': false, 'type': 'standard'},
      ];

      await dataSource.writeAll(records);
      final result = await dataSource.readAll();

      expect(result, hasLength(1));
      expect(result.first['title'], 'A');
    });

    test('should throw MalformedDataException when the file contains invalid JSON', () async {
      await File(filePath).writeAsString('{invalid json}');

      expect(() => dataSource.readAll(), throwsA(isA<MalformedDataException>()));
    });

    test('should throw MalformedDataException when the JSON root is not an array', () async {
      await File(filePath).writeAsString('{"not": "a list"}');

      expect(() => dataSource.readAll(), throwsA(isA<MalformedDataException>()));
    });

    test('should treat an empty file as an empty task list', () async {
      await File(filePath).writeAsString('');
      final result = await dataSource.readAll();
      expect(result, isEmpty);
    });

    test('should create parent directories on write if they do not exist', () async {
      final nestedPath = '${tempDir.path}/nested/dir/tasks.json';
      final nestedSource = JsonFileDataSource(nestedPath);

      await nestedSource.writeAll([]);

      expect(await File(nestedPath).exists(), isTrue);
    });
  });
}

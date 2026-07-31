import 'dart:io';

import 'package:test/test.dart';
import 'package:taskforge_cli/data/repositories/json_task_repository.dart';
import 'package:taskforge_cli/data/sources/json_file_data_source.dart';
import 'package:taskforge_cli/domain/entities/priority.dart';
import 'package:taskforge_cli/domain/entities/standard_task.dart';
import 'package:taskforge_cli/domain/entities/urgent_task.dart';

void main() {
  group('JsonTaskRepository', () {
    late Directory tempDir;
    late JsonTaskRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('taskforge_cli_repo_test_');
      final dataSource = JsonFileDataSource('${tempDir.path}/tasks.json');
      repository = JsonTaskRepository(dataSource);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should persist an added task so it can be retrieved by id', () async {
      final task = StandardTask(title: 'Write report', priority: Priority.medium, id: 'a1');

      await repository.add(task);
      final fetched = await repository.getById('a1');

      expect(fetched, isNotNull);
      expect(fetched!.title, 'Write report');
    });

    test('should round-trip an UrgentTask as the exact same subclass', () async {
      final task = UrgentTask(
        title: 'File taxes',
        priority: Priority.high,
        deadline: DateTime(2030, 4, 15),
        id: 'u1',
      );

      await repository.add(task);
      final fetched = await repository.getById('u1');

      expect(fetched, isA<UrgentTask>());
    });

    test('should find a task by a case-insensitive, trimmed title match', () async {
      await repository.add(StandardTask(title: 'Buy Milk', priority: Priority.low, id: 'm1'));

      final found = await repository.findByTitle('  buy milk  ');

      expect(found?.id, 'm1');
    });

    test('should return null from findByTitle when nothing matches', () async {
      final found = await repository.findByTitle('Nonexistent');
      expect(found, isNull);
    });

    test('should update an existing task in place rather than duplicating it', () async {
      final task = StandardTask(title: 'Task', priority: Priority.low, id: 't1');
      await repository.add(task);

      await repository.update(task.copyWith(isDone: true));

      final all = await repository.getAll();
      expect(all, hasLength(1));
      expect(all.first.isDone, isTrue);
    });

    test('should remove a task by id on delete', () async {
      await repository.add(StandardTask(title: 'Task', priority: Priority.low, id: 't1'));

      await repository.deleteById('t1');

      expect(await repository.getById('t1'), isNull);
    });

    test('should persist across repository instances pointed at the same file', () async {
      await repository.add(StandardTask(title: 'Persisted', priority: Priority.low, id: 'p1'));

      final dataSource2 = JsonFileDataSource('${tempDir.path}/tasks.json');
      final repository2 = JsonTaskRepository(dataSource2);
      final all = await repository2.getAll();

      expect(all.map((t) => t.id), contains('p1'));
    });
  });
}

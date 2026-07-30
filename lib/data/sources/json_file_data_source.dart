import 'dart:convert';
import 'dart:io';

import '../../core/exceptions/app_exceptions.dart';

final class JsonFileDataSource {
  JsonFileDataSource(this.filePath);

  final String filePath;

  Future<List<Map<String, dynamic>>> readAll() async {
    final file = File(filePath);
    if (!await file.exists()) return [];

    late final String raw;
    try {
      raw = await file.readAsString();
    } on FileSystemException catch (e) {
      throw FileException('Could not read "$filePath".', e);
    }

    if (raw.trim().isEmpty) return [];

    late final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (e) {
      throw MalformedDataException(
        'The task store at "$filePath" contains invalid JSON: ${e.message}',
      );
    }

    if (decoded is! List) {
      throw const MalformedDataException(
        'The task store must contain a JSON array of tasks.',
      );
    }

    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> writeAll(List<Map<String, dynamic>> records) async {
    final file = File(filePath);
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(records));
    } on FileSystemException catch (e) {
      throw FileException('Could not write to "$filePath".', e);
    }
  }
}

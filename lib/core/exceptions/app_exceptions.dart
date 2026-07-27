sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class TaskValidationException extends AppException {
  const TaskValidationException(super.message);
}

final class TaskNotFoundException extends AppException {
  TaskNotFoundException(String id) : super('No task found with id "$id".');
}

final class DuplicateTaskException extends AppException {
  DuplicateTaskException(String title)
      : super('A task titled "$title" already exists.');
}

final class FileException extends AppException {
  const FileException(super.message, [this.cause]);

  final Object? cause;
}

final class MalformedDataException extends AppException {
  const MalformedDataException(super.message);
}

final class InvalidArgumentException extends AppException {
  const InvalidArgumentException(super.message);
}

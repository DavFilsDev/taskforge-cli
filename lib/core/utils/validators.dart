import '../exceptions/app_exceptions.dart';

abstract final class Validators {
  const Validators._();

  static String requireNonEmptyTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw const TaskValidationException('Task title cannot be empty.');
    }
    return trimmed;
  }

  static DateTime parseDeadline(String raw) {
    try {
      return DateTime.parse(raw.trim());
    } on FormatException {
      throw TaskValidationException(
        'Invalid deadline "$raw". Expected format: YYYY-MM-DD or '
        'YYYY-MM-DDTHH:mm.',
      );
    }
  }
}

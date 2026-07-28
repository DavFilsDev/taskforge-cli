import '../../core/exceptions/app_exceptions.dart';

enum Priority { low, medium, high }

extension PriorityX on Priority {
  int get weight => switch (this) {
        Priority.high => 3,
        Priority.medium => 2,
        Priority.low => 1,
      };

  String get label => switch (this) {
        Priority.high => 'High',
        Priority.medium => 'Medium',
        Priority.low => 'Low',
      };

  static Priority parse(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final value in Priority.values) {
      if (value.name == normalized) return value;
    }
    throw TaskValidationException(
      'Invalid priority "$raw". Expected one of: low, medium, high.',
    );
  }
}

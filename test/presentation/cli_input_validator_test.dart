import 'package:test/test.dart';
import 'package:taskforge_cli/core/exceptions/app_exceptions.dart';
import 'package:taskforge_cli/presentation/validators/cli_input_validator.dart';

void main() {
  group('CliInputValidator', () {
    test('should extract a flag with its value', () {
      final input = CliInputValidator(['--title', 'Buy milk', '--priority', 'high']);

      expect(input.require('title'), 'Buy milk');
      expect(input.require('priority'), 'high');
    });

    test('should throw InvalidArgumentException for a missing required flag', () {
      final input = CliInputValidator(['--priority', 'high']);

      expect(() => input.require('title'), throwsA(isA<InvalidArgumentException>()));
    });

    test('should fall back to the provided default when the flag is absent', () {
      final input = CliInputValidator([]);

      expect(input.require('sort', fallback: 'priority'), 'priority');
    });

    test('optional() should return null for a flag that was not passed', () {
      final input = CliInputValidator(['--title', 'Task']);

      expect(input.optional('deadline'), isNull);
    });

    test('should treat a boolean-style flag with no value as present', () {
      final input = CliInputValidator(['--pending-only']);

      expect(input.has('pending-only'), isTrue);
      expect(input.require('pending-only'), 'true');
    });
  });
}

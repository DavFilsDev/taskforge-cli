import '../../core/exceptions/app_exceptions.dart';

final class CliInputValidator {
  CliInputValidator(List<String> rawArgs) : _flags = _parse(rawArgs);

  final Map<String, String> _flags;

  static Map<String, String> _parse(List<String> rawArgs) {
    final flags = <String, String>{};
    var i = 0;
    while (i < rawArgs.length) {
      final token = rawArgs[i];
      if (!token.startsWith('--')) {
        i++;
        continue;
      }
      final key = token.substring(2);
      final hasValue =
          i + 1 < rawArgs.length && !rawArgs[i + 1].startsWith('--');
      flags[key] = hasValue ? rawArgs[i + 1] : 'true';
      i += hasValue ? 2 : 1;
    }
    return flags;
  }

  String require(String flag, {String? fallback}) {
    final value = _flags[flag] ?? fallback;
    if (value == null) {
      throw InvalidArgumentException('Missing required flag: --$flag');
    }
    return value;
  }

  String? optional(String flag) => _flags[flag];

  bool has(String flag) => _flags.containsKey(flag);
}

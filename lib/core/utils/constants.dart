abstract final class AppConstants {
  const AppConstants._();

  static const String appName = 'taskforge_cli';
  static const String version = '1.0.0';

  static const String defaultStoragePath = 'tasks.json';

  static const int urgentWindowHours = 24;

  static const String deadlineFormatHint = 'YYYY-MM-DD or YYYY-MM-DDTHH:mm';

  static const int exitSuccess = 0;
  static const int exitUsageError = 64;
  static const int exitDataError = 65;
  static const int exitIoError = 74;
  static const int exitUnknownError = 1;
}

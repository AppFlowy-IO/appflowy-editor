import 'package:logging/logging.dart';

enum AppFlowyEditorLogLevel {
  off,
  error,
  warn,
  info,
  debug,
  all,
}

typedef AppFlowyEditorLogHandler = void Function(String message);

/// Manages log service for [AppFlowyEditor]
///
/// Set the log level and config the handler depending on your need.
class AppFlowyLogConfiguration {
  AppFlowyLogConfiguration._() {
    Logger.root.onRecord.listen((record) {
      if (handler != null) {
        handler!(
          '[${record.level.toLogLevel().name}][${record.loggerName}]: ${record.time}: ${record.message}',
        );
      }
    });
  }

  factory AppFlowyLogConfiguration() => _logConfiguration;

  static final AppFlowyLogConfiguration _logConfiguration =
      AppFlowyLogConfiguration._();

  AppFlowyEditorLogHandler? handler;

  AppFlowyEditorLogLevel _level = AppFlowyEditorLogLevel.off;

  AppFlowyEditorLogLevel get level => _level;
  set level(AppFlowyEditorLogLevel level) {
    _level = level;
    Logger.root.level = level.toLevel();
  }
}

/// For logging message in AppFlowyEditor
class AppFlowyEditorLog {
  AppFlowyEditorLog._({
    required this.name,
  }) : _logger = Logger(name);

  final String name;
  late final Logger _logger;

  /// For logging message related to [AppFlowyEditor].
  ///
  /// For example, uses the logger when registering plugins
  ///   or handling something related to [EditorState].
  static AppFlowyEditorLog editor = AppFlowyEditorLog._(name: 'editor');

  /// For logging message related to [AppFlowySelectionService].
  ///
  /// For example, uses the logger when updating or clearing selection.
  static AppFlowyEditorLog selection = AppFlowyEditorLog._(name: 'selection');

  /// For logging message related to [AppFlowyKeyboardService].
  ///
  /// For example, uses the logger when processing shortcut events.
  static AppFlowyEditorLog keyboard = AppFlowyEditorLog._(name: 'keyboard');

  /// For logging message related to [AppFlowyInputService].
  ///
  /// For example, uses the logger when processing text inputs.
  static AppFlowyEditorLog input = AppFlowyEditorLog._(name: 'input');

  /// For logging message related to [AppFlowyScrollService].
  ///
  /// For example, uses the logger when processing scroll events.
  static AppFlowyEditorLog scroll = AppFlowyEditorLog._(name: 'scroll');

  /// For logging message related to [FloatingToolbar] or [MobileToolbar].
  ///
  /// For example, uses the logger when processing toolbar events.
  static AppFlowyEditorLog toolbar = AppFlowyEditorLog._(name: 'toolbar');

  /// For logging message related to UI.
  ///
  /// For example, uses the logger when building the widget.
  static AppFlowyEditorLog ui = AppFlowyEditorLog._(name: 'ui');

  void error(String message) => _logger.severe(message);
  void warn(String message) => _logger.warning(message);
  void info(String message) => _logger.info(message);
  void debug(String message) => _logger.fine(message);
}

extension on AppFlowyEditorLogLevel {
  Level toLevel() {
    switch (this) {
      case AppFlowyEditorLogLevel.off:
        return Level.OFF;
      case AppFlowyEditorLogLevel.error:
        return Level.SEVERE;
      case AppFlowyEditorLogLevel.warn:
        return Level.WARNING;
      case AppFlowyEditorLogLevel.info:
        return Level.INFO;
      case AppFlowyEditorLogLevel.debug:
        return Level.FINE;
      case AppFlowyEditorLogLevel.all:
        return Level.ALL;
    }
  }

  String get name {
    switch (this) {
      case AppFlowyEditorLogLevel.off:
        return 'OFF';
      case AppFlowyEditorLogLevel.error:
        return 'ERROR';
      case AppFlowyEditorLogLevel.warn:
        return 'WARN';
      case AppFlowyEditorLogLevel.info:
        return 'INFO';
      case AppFlowyEditorLogLevel.debug:
        return 'DEBUG';
      case AppFlowyEditorLogLevel.all:
        return 'ALL';
    }
  }
}

extension on Level {
  AppFlowyEditorLogLevel toLogLevel() {
    if (this == Level.SEVERE) {
      return AppFlowyEditorLogLevel.error;
    } else if (this == Level.WARNING) {
      return AppFlowyEditorLogLevel.warn;
    } else if (this == Level.INFO) {
      return AppFlowyEditorLogLevel.info;
    } else if (this == Level.FINE) {
      return AppFlowyEditorLogLevel.debug;
    }
    return AppFlowyEditorLogLevel.off;
  }
}

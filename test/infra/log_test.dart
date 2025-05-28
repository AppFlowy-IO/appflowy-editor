import 'package:appflowy_editor/src/infra/log.dart';
import 'package:flutter_test/flutter_test.dart';

import '../new/infra/testable_editor.dart';

void main() async {
  group('log.dart', () {
    testWidgets('test LogConfiguration in EditorState', (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();

      const text = 'Welcome to Appflowy 😁';

      final List<String> logs = [];

      final editor = tester.editor;
      editor.editorState.logConfiguration
        ..level = AppFlowyEditorLogLevel.all
        ..handler = (message) {
          logs.add(message);
        };

      AppFlowyEditorLog.editor.debug(text);
      expect(logs.last.contains('DEBUG'), true);
      expect(logs.length, 1);
    });

    test('test LogLevel.all', () {
      const text = 'Welcome to Appflowy 😁';

      final List<String> logs = [];
      AppFlowyLogConfiguration()
        ..level = AppFlowyEditorLogLevel.all
        ..handler = (message) {
          logs.add(message);
        };

      AppFlowyEditorLog.editor.debug(text);
      expect(logs.last.contains('DEBUG'), true);
      AppFlowyEditorLog.editor.info(text);
      expect(logs.last.contains('INFO'), true);
      AppFlowyEditorLog.editor.warn(text);
      expect(logs.last.contains('WARN'), true);
      AppFlowyEditorLog.editor.error(text);
      expect(logs.last.contains('ERROR'), true);

      expect(logs.length, 4);
    });

    test('test LogLevel.off', () {
      const text = 'Welcome to Appflowy 😁';

      final List<String> logs = [];
      AppFlowyLogConfiguration()
        ..level = AppFlowyEditorLogLevel.off
        ..handler = (message) {
          logs.add(message);
        };

      AppFlowyEditorLog.editor.debug(text);
      AppFlowyEditorLog.editor.info(text);
      AppFlowyEditorLog.editor.warn(text);
      AppFlowyEditorLog.editor.error(text);

      expect(logs.length, 0);
    });

    test('test LogLevel.error', () {
      const text = 'Welcome to Appflowy 😁';

      final List<String> logs = [];
      AppFlowyLogConfiguration()
        ..level = AppFlowyEditorLogLevel.error
        ..handler = (message) {
          logs.add(message);
        };

      AppFlowyEditorLog.editor.debug(text);
      AppFlowyEditorLog.editor.info(text);
      AppFlowyEditorLog.editor.warn(text);
      AppFlowyEditorLog.editor.error(text);

      expect(logs.length, 1);
    });

    test('test LogLevel.warn', () {
      const text = 'Welcome to Appflowy 😁';

      final List<String> logs = [];
      AppFlowyLogConfiguration()
        ..level = AppFlowyEditorLogLevel.warn
        ..handler = (message) {
          logs.add(message);
        };

      AppFlowyEditorLog.editor.debug(text);
      AppFlowyEditorLog.editor.info(text);
      AppFlowyEditorLog.editor.warn(text);
      AppFlowyEditorLog.editor.error(text);

      expect(logs.length, 2);
    });

    test('test LogLevel.info', () {
      const text = 'Welcome to Appflowy 😁';

      final List<String> logs = [];
      AppFlowyLogConfiguration()
        ..level = AppFlowyEditorLogLevel.info
        ..handler = (message) {
          logs.add(message);
        };

      AppFlowyEditorLog.editor.debug(text);
      AppFlowyEditorLog.editor.info(text);
      AppFlowyEditorLog.editor.warn(text);
      AppFlowyEditorLog.editor.error(text);

      expect(logs.length, 3);
    });

    test('test LogLevel.debug', () {
      const text = 'Welcome to Appflowy 😁';

      final List<String> logs = [];
      AppFlowyLogConfiguration()
        ..level = AppFlowyEditorLogLevel.debug
        ..handler = (message) {
          logs.add(message);
        };

      AppFlowyEditorLog.editor.debug(text);
      AppFlowyEditorLog.editor.info(text);
      AppFlowyEditorLog.editor.warn(text);
      AppFlowyEditorLog.editor.error(text);

      expect(logs.length, 4);
    });

    test('test logger', () {
      const text = 'Welcome to Appflowy 😁';

      final List<String> logs = [];
      AppFlowyLogConfiguration()
        ..level = AppFlowyEditorLogLevel.all
        ..handler = (message) {
          logs.add(message);
        };

      AppFlowyEditorLog.editor.debug(text);
      expect(logs.last.contains('editor'), true);

      AppFlowyEditorLog.selection.debug(text);
      expect(logs.last.contains('selection'), true);

      AppFlowyEditorLog.keyboard.debug(text);
      expect(logs.last.contains('keyboard'), true);

      AppFlowyEditorLog.input.debug(text);
      expect(logs.last.contains('input'), true);

      AppFlowyEditorLog.scroll.debug(text);
      expect(logs.last.contains('scroll'), true);

      AppFlowyEditorLog.ui.debug(text);
      expect(logs.last.contains('ui'), true);

      expect(logs.length, 6);
    });
  });
}

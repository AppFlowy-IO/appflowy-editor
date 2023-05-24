import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import '../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('l10n.dart', () {
    for (final locale
        in AppFlowyEditorLocalizations.delegate.supportedLocales) {
      testWidgets('test localization', (tester) async {
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting(locale: locale);
      });
    }
  });
}

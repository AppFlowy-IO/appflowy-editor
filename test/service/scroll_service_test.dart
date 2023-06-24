import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Testing Scroll With Gestures', () {
    testWidgets('Test Gesture Scroll', (tester) async {
      final editor = tester.editor;
      for (var i = 0; i < 100; i++) {
        editor.addParagraph(initialText: '$i');
      }
      editor.addParagraph(initialText: 'mark');
      for (var i = 100; i < 200; i++) {
        editor.addParagraph(initialText: '$i');
      }
      await editor.startTesting();
      final listFinder = find.byType(Scrollable);
      final itemFinder = find.text('mark', findRichText: true);
      await tester.scrollUntilVisible(
        itemFinder,
        500.0,
        scrollable: listFinder,
      );
      expect(itemFinder, findsOneWidget);
      await editor.dispose();
    });
  });
}

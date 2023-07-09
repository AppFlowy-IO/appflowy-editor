import 'package:appflowy_editor/src/infra/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

class MockClipboard {
  final String? text;
  final String? html;

  const MockClipboard({required this.text, required this.html});

  MockClipboard copyWith({
    String? text,
    String? html,
  }) =>
      MockClipboard(
        text: text,
        html: html,
      );

  Map<String, String?> get getData => {"html": html, "text": text};
}

void main() {
  late MockClipboard mockClipboard;

  setUp(() {
    mockClipboard = const MockClipboard(html: null, text: null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (message) async {
      switch (message.method) {
        case "Clipboard.getData":
          return mockClipboard.getData;
        case "Clipboard.setData":
          final args = message.arguments as Map<String, dynamic>;
          mockClipboard = mockClipboard.copyWith(
            text: args['text'],
          );
      }
      return null;
    });
  });

  group('Clipboard tests', () {
    test('AppFlowyClipboardData constructor', () {
      const data = AppFlowyClipboardData(text: null, html: null);

      expect(data.text, null);
      expect(data.html, null);
    });

    testWidgets('AppFlowyClipboard setData and getData', (tester) async {
      const rawText = "Hello World";

      AppFlowyClipboardData? clipboardData;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.windows),
          home: Column(
            children: [
              TextButton(
                onPressed: () async =>
                    await AppFlowyClipboard.setData(text: rawText),
                child: const Text('setData'),
              ),
              TextButton(
                onPressed: () async =>
                    clipboardData = await AppFlowyClipboard.getData(),
                child: const Text('getData'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('setData'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('getData'));
      await tester.pumpAndSettle();

      expect(clipboardData?.text, rawText);
    });
  });
}

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helper.dart';

void main() {
  group("AppFlowyEditor tests", () {
    testWidgets('can render', (tester) async {
      await tester.buildAndPump(
        AppFlowyEditor(
          editorState: EditorState.blank(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppFlowyEditor), findsOneWidget);
    });

    testWidgets('can render with footer', (tester) async {
      await tester.buildAndPump(
        AppFlowyEditor(
          editorState: EditorState(
            document: Document(root: pageNode(children: [])),
          ),
          footer: const Icon(Icons.abc),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.abc), findsOneWidget);
    });

    testWidgets('can render with header', (tester) async {
      await tester.buildAndPump(
        AppFlowyEditor(
          editorState: EditorState.blank(),
          header: const Icon(Icons.abc),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.abc), findsOneWidget);
    });

    testWidgets('can render with header and footer', (tester) async {
      await tester.buildAndPump(
        AppFlowyEditor(
          editorState: EditorState.blank(),
          header: const Icon(Icons.abc),
          footer: const Icon(Icons.abc_outlined),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.abc), findsOneWidget);
      expect(find.byIcon(Icons.abc_outlined), findsOneWidget);
    });
  });
}

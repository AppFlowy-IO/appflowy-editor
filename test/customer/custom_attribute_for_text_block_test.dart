import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../new/util/util.dart';

void main() async {
  // column
  // - text field
  // - editor

  // 1. When the text field is focused, the editor's cursor should be disabled.
  // 2. When the editor is focused, the text field's cursor should be disabled.
  // 3. Tapping a non-first line of the editor should still allow the editor to grab focus.
  await AppFlowyEditorLocalizations.load(
    const Locale.fromSubtags(languageCode: 'en'),
  );
  testWidgets('text field + editor', (tester) async {
    const widget = CustomAttributeKeyForTextBlock();
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.edit_document), findsOneWidget);
    expect(find.textContaining('PAGE_ID'), findsOneWidget);
  });
}

class CustomAttributeKeyForTextBlock extends StatelessWidget {
  const CustomAttributeKeyForTextBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final editorStyle = EditorStyle.desktop(
      // Example for customizing a new attribute key.
      textSpanDecorator: (_, __, ___, textInsert, textSpan) {
        final attributes = textInsert.attributes;
        if (attributes == null) {
          return textSpan;
        }
        final mention = attributes['mention'] as Map?;
        if (mention != null) {
          return WidgetSpan(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit_document),
                    Text(mention['id']),
                  ],
                ),
              ),
            ),
          );
        }
        return textSpan;
      },
    );
    final document = Document.blank()
      ..addParagraph(
        builder: (index) {
          return Delta()
            ..insert(
              '\$',
              attributes: {
                'mention': {'id': 'PAGE_ID'},
              },
            );
        },
      );
    final editorState = EditorState(document: document);
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Container(
            width: 500,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
            ),
            child: AppFlowyEditor(
              editorState: editorState,
              editorStyle: editorStyle,
            ),
          ),
        ),
      ),
    );
  }
}

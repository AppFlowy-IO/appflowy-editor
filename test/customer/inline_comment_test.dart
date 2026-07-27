import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../new/util/util.dart';

void main() async {
  await AppFlowyEditorLocalizations.load(
    const Locale.fromSubtags(languageCode: 'en'),
  );

  testWidgets('inline comment: render editor with InlineCommentWidget',
      (tester) async {
    // 1. Build a simple document
    final document = Document.blank()
      ..addParagraph(
        initialText: 'Hello World',
      );
    final editorState = EditorState(document: document);
    final controller = InlineCommentController(
      onCommentAdded: (_, __, ___, ____) async => null,
      onCommentDeleted: (_) async {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InlineCommentWidget(
            editorState: editorState,
            controller: controller,
            child: AppFlowyEditor(
              editorState: editorState,
              editorStyle: EditorStyle.desktop(
                textSpanDecorator: buildCommentTextSpanDecorator(
                  controller: controller,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Should render without error
    expect(
      find.textContaining('Hello World', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('inline comment: highlight text with comment-ids attribute',
      (tester) async {
    // 2. Build a document with pre-existing comment-ids in the delta
    final document = Document.blank()
      ..addParagraph(
        builder: (index) => Delta()
          ..insert('Normal text ')
          ..insert(
            'commented text',
            attributes: {AppFlowyRichTextKeys.commentIds: 'cmt-1'},
          )
          ..insert(' more text'),
      );
    final editorState = EditorState(document: document);

    final tappedIds = <String>[];
    final controller = InlineCommentController(
      onCommentAdded: (_, __, ___, ____) async => null,
      onCommentDeleted: (_) async {},
      onCommentTapped: (id, _) => tappedIds.add(id),
      initialComments: [
        InlineComment(
          id: 'cmt-1',
          content: 'Test comment',
          authorName: 'Tester',
          createdAt: DateTime.now(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppFlowyEditor(
            editorState: editorState,
            editorStyle: EditorStyle.desktop(
              textSpanDecorator: buildCommentTextSpanDecorator(
                controller: controller,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Should render all text
    expect(
      find.textContaining('Normal text', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('commented text', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('inline comment: render with sidebar', (tester) async {
    final document = Document.blank()
      ..addParagraph(
        builder: (index) => Delta()
          ..insert(
            'commented text',
            attributes: {AppFlowyRichTextKeys.commentIds: 'cmt-1'},
          ),
      );
    final editorState = EditorState(document: document);
    final controller = InlineCommentController(
      onCommentAdded: (_, __, ___, ____) async => null,
      onCommentDeleted: (_) async {},
      initialComments: [
        InlineComment(
          id: 'cmt-1',
          content: 'Sidebar comment',
          authorName: 'Tester',
          createdAt: DateTime.now(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InlineCommentWidget(
            editorState: editorState,
            controller: controller,
            showSidebar: true,
            sidebarWidth: 240,
            child: AppFlowyEditor(
              editorState: editorState,
              editorStyle: EditorStyle.desktop(
                textSpanDecorator: buildCommentTextSpanDecorator(
                  controller: controller,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The editor + sidebar should render without error
    expect(
      find.textContaining('commented text', findRichText: true),
      findsOneWidget,
    );
  });
}

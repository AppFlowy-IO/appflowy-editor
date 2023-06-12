import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../new/infra/testable_editor.dart';

void main() async {
  bool allInSelection(
    Node? node,
    Selection selection,
    String key,
  ) {
    return node?.allSatisfyInSelection(
          selection,
          (delta) => delta.whereType<TextInsert>().every(
                (element) => element.attributes?[key] == true,
              ),
        ) ??
        false;
  }

  bool allCodeInSelection(Node? node, Selection selection) => allInSelection(
        node,
        selection,
        'code',
      );

  bool allStrikethroughInSelection(Node? node, Selection selection) =>
      allInSelection(
        node,
        selection,
        'strikethrough',
      );

  bool allBoldInSelection(Node? node, Selection selection) => allInSelection(
        node,
        selection,
        'bold',
      );

  bool allItalicInSelection(Node? node, Selection selection) => allInSelection(
        node,
        selection,
        'bold',
      );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('markdown_syntax_to_styled_text.dart', () {
    Future<void> insertBackquote(
      TestableEditor editor, {
      int repeat = 1,
    }) async {
      for (var i = 0; i < repeat; i++) {
        await editor.pressKey(
          key: LogicalKeyboardKey.backquote,
        );
      }
    }

    group('convert single backquote to code', () {
      testWidgets('`AppFlowy` to code AppFlowy', (tester) async {
        const text = '`AppFlowy';
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );

        await editor.editorState.insertTextAtCurrentSelection(text);
        await insertBackquote(editor);
        final node = editor.nodeAtPath([0]);

        final allCode = allCodeInSelection(
          node,
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: text.length - 1,
          ),
        );

        expect(allCode, true);
        expect(node?.delta?.toPlainText(), 'AppFlowy');
        await editor.dispose();
      });

      testWidgets('App`Flowy` to code AppFlowy', (tester) async {
        const text = 'App`Flowy';
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );

        await editor.editorState.insertTextAtCurrentSelection(text);

        await insertBackquote(editor);
        final node = editor.nodeAtPath([0]);

        final allCode = allCodeInSelection(
          node,
          Selection.single(
            path: [0],
            startOffset: 3,
            endOffset: text.length - 1,
          ),
        );

        expect(allCode, true);
        expect(node?.delta?.toPlainText(), 'AppFlowy');
        await editor.dispose();
      });

      testWidgets('`` nothing changes', (tester) async {
        const text = '`';
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.editorState.insertTextAtCurrentSelection(text);
        await insertBackquote(editor);
        final node = editor.nodeAtPath([0]);
        final allCode = allCodeInSelection(
          node,
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: node!.delta!.toPlainText().length,
          ),
        );

        expect(allCode, false);
        expect(node.delta?.toPlainText(), '``');
        await editor.dispose();
      });
    });

    group('convert double backquote to code', () {
      testWidgets('```` nothing changes', (tester) async {
        const text = '```';
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.editorState.insertTextAtCurrentSelection(text);
        await insertBackquote(editor);
        final node = editor.nodeAtPath([0]);
        final allCode = allCodeInSelection(
          node,
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: node!.delta!.toPlainText().length,
          ),
        );

        expect(allCode, false);
        expect(node.delta?.toPlainText(), '````');
        await editor.dispose();
      });
    });

    group('convert double tilde to strikethrough', () {
      Future<void> insertTilde(
        TestableEditor editor, {
        int repeat = 1,
      }) async {
        for (var i = 0; i < repeat; i++) {
          await editor.pressKey(key: LogicalKeyboardKey.tilde);
        }
      }

      testWidgets('~~AppFlowy~~ to strikethrough AppFlowy', (tester) async {
        const text = '~~AppFlowy~';
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.editorState.insertTextAtCurrentSelection(text);
        await insertTilde(editor);
        final node = editor.nodeAtPath([0]);
        final result = allStrikethroughInSelection(
          node,
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: node!.delta!.toPlainText().length,
          ),
        );

        expect(result, true);
        expect(node.delta?.toPlainText(), 'AppFlowy');
        await editor.dispose();
      });

      testWidgets('App~~Flowy~~ to strikethrough AppFlowy', (tester) async {
        const text = 'App~~Flowy~';
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.editorState.insertTextAtCurrentSelection(text);
        await insertTilde(editor);
        final node = editor.nodeAtPath([0]);
        final result = allStrikethroughInSelection(
          node,
          Selection.single(
            path: [0],
            startOffset: 3,
            endOffset: node!.delta!.toPlainText().length,
          ),
        );

        expect(result, true);
        expect(node.delta?.toPlainText(), 'AppFlowy');
        await editor.dispose();
      });

      testWidgets('~~~~ nothing changes', (tester) async {
        const text = '~~~';
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.editorState.insertTextAtCurrentSelection(text);
        await insertTilde(editor);
        final node = editor.nodeAtPath([0]);
        final result = allStrikethroughInSelection(
          node,
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: node!.delta!.toPlainText().length,
          ),
        );

        expect(result, false);
        expect(node.delta?.toPlainText(), '~~~~');
        await editor.dispose();
      });
    });
  });

  group('convert double asterisk to bold', () {
    Future<void> insertAsterisk(
      TestableEditor editor, {
      int repeat = 1,
    }) async {
      for (var i = 0; i < repeat; i++) {
        await editor.pressKey(key: LogicalKeyboardKey.asterisk);
      }
    }

    testWidgets(
      '**AppFlowy** to bold AppFlowy',
      (tester) async {
        const text = '**AppFlowy*';
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.editorState.insertTextAtCurrentSelection(text);
        await insertAsterisk(editor);
        final node = editor.nodeAtPath([0]);
        final result = allBoldInSelection(
          node,
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: node!.delta!.toPlainText().length,
          ),
        );

        expect(result, true);
        expect(node.delta?.toPlainText(), 'AppFlowy');
        await editor.dispose();
      },
    );

    testWidgets(
      'App**Flowy** to bold AppFlowy',
      ((tester) async {
        const text = 'App**Flowy*';
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.editorState.insertTextAtCurrentSelection(text);
        await insertAsterisk(editor);
        final node = editor.nodeAtPath([0]);
        final result = allBoldInSelection(
          node,
          Selection.single(
            path: [0],
            startOffset: 3,
            endOffset: node!.delta!.toPlainText().length,
          ),
        );

        expect(result, true);
        expect(node.delta?.toPlainText(), 'AppFlowy');
        await editor.dispose();
      }),
    );

    testWidgets(
      '***AppFlowy** to bold *AppFlowy',
      ((tester) async {
        const text = '***AppFlowy*';
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.editorState.insertTextAtCurrentSelection(text);
        await insertAsterisk(editor);
        final node = editor.nodeAtPath([0]);
        final result = allBoldInSelection(
          node,
          Selection.single(
            path: [0],
            startOffset: 1,
            endOffset: node!.delta!.toPlainText().length,
          ),
        );

        expect(result, true);
        expect(node.delta?.toPlainText(), '*AppFlowy');
        await editor.dispose();
      }),
    );

    testWidgets(
      '**** nothing changes',
      ((tester) async {
        const text = '***';
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.editorState.insertTextAtCurrentSelection(text);
        await insertAsterisk(editor);
        final node = editor.nodeAtPath([0]);
        final result = allBoldInSelection(
          node,
          Selection.single(
            path: [0],
            startOffset: 1,
            endOffset: node!.delta!.toPlainText().length,
          ),
        );

        expect(result, false);
        expect(node.delta?.toPlainText(), '****');
        await editor.dispose();
      }),
    );
  });

  group('convert double underscore to bold', () {
    Future<void> insertUnderscore(
      TestableEditor editor, {
      int repeat = 1,
    }) async {
      for (var i = 0; i < repeat; i++) {
        await editor.pressKey(key: LogicalKeyboardKey.underscore);
      }
    }

    testWidgets(
      '__AppFlowy__ to bold AppFlowy',
      ((tester) async {
        const text = '__AppFlowy_';
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.editorState.insertTextAtCurrentSelection(text);
        await insertUnderscore(editor);
        final node = editor.nodeAtPath([0]);

        final result = allItalicInSelection(
          node,
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: node!.delta!.toPlainText().length,
          ),
        );

        expect(result, true);
        expect(node.delta!.toPlainText(), 'AppFlowy');
        await editor.dispose();
      }),
    );

    testWidgets(
      'App__Flowy__ to bold AppFlowy',
      ((tester) async {
        const text = 'App__Flowy_';
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.editorState.insertTextAtCurrentSelection(text);
        await insertUnderscore(editor);
        final node = editor.nodeAtPath([0]);

        final result = allItalicInSelection(
          node,
          Selection.single(
            path: [0],
            startOffset: 3,
            endOffset: node!.delta!.toPlainText().length,
          ),
        );

        expect(result, true);
        expect(node.delta!.toPlainText(), 'AppFlowy');
        await editor.dispose();
      }),
    );

    testWidgets(
      '__*AppFlowy__ to bold *AppFlowy',
      ((tester) async {
        const text = '__*AppFlowy_';
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.editorState.insertTextAtCurrentSelection(text);
        await insertUnderscore(editor);
        final node = editor.nodeAtPath([0]);

        final result = allItalicInSelection(
          node,
          Selection.single(
            path: [0],
            startOffset: 1,
            endOffset: node!.delta!.toPlainText().length,
          ),
        );

        expect(result, true);
        expect(node.delta!.toPlainText(), '*AppFlowy');
        await editor.dispose();
      }),
    );

    testWidgets(
      '____ nothing changes',
      ((tester) async {
        const text = '___';
        final editor = tester.editor..addEmptyParagraph();
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.editorState.insertTextAtCurrentSelection(text);
        await insertUnderscore(editor);
        final node = editor.nodeAtPath([0]);

        final result = allItalicInSelection(
          node,
          Selection.single(
            path: [0],
            startOffset: 1,
            endOffset: node!.delta!.toPlainText().length,
          ),
        );

        expect(result, false);
        expect(node.delta!.toPlainText(), '____');
        await editor.dispose();
      }),
    );
  });
}

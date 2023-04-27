import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../infra/test_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('markdown_syntax_to_styled_text.dart', () {
    group('convert single backquote to code', () {
      Future<void> insertBackquote(
        EditorWidgetTester editor, {
        int repeat = 1,
      }) async {
        for (var i = 0; i < repeat; i++) {
          await editor.pressLogicKey(
            key: LogicalKeyboardKey.backquote,
          );
        }
      }

      testWidgets('`AppFlowy` to code AppFlowy', (tester) async {
        const text = '`AppFlowy';
        final editor = tester.editor..insertTextNode('');
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }
        await insertBackquote(editor);
        final allCode = textNode.allSatisfyCodeInSelection(
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: textNode.toPlainText().length,
          ),
        );
        expect(allCode, true);
        expect(textNode.toPlainText(), 'AppFlowy');
      });

      testWidgets('App`Flowy` to code AppFlowy', (tester) async {
        const text = 'App`Flowy';
        final editor = tester.editor..insertTextNode('');
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }
        await insertBackquote(editor);
        final allCode = textNode.allSatisfyCodeInSelection(
          Selection.single(
            path: [0],
            startOffset: 3,
            endOffset: textNode.toPlainText().length,
          ),
        );
        expect(allCode, true);
        expect(textNode.toPlainText(), 'AppFlowy');
      });

      testWidgets('`` nothing changes', (tester) async {
        const text = '`';
        final editor = tester.editor..insertTextNode('');
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }
        await insertBackquote(editor);
        final allCode = textNode.allSatisfyCodeInSelection(
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: textNode.toPlainText().length,
          ),
        );
        expect(allCode, false);
        expect(textNode.toPlainText(), text);
      });
    });

    group('convert double backquote to code', () {
      Future<void> insertBackquote(
        EditorWidgetTester editor, {
        int repeat = 1,
      }) async {
        for (var i = 0; i < repeat; i++) {
          await editor.pressLogicKey(
            key: LogicalKeyboardKey.backquote,
          );
        }
      }

      testWidgets('```AppFlowy`` to code `AppFlowy', (tester) async {
        const text = '```AppFlowy`';
        final editor = tester.editor..insertTextNode('');
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }
        await insertBackquote(editor);
        final allCode = textNode.allSatisfyCodeInSelection(
          Selection.single(
            path: [0],
            startOffset: 1,
            endOffset: textNode.toPlainText().length,
          ),
        );
        expect(allCode, true);
        expect(textNode.toPlainText(), '`AppFlowy');
      });

      testWidgets('```` nothing changes', (tester) async {
        const text = '```';
        final editor = tester.editor..insertTextNode('');
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }
        await insertBackquote(editor);
        final allCode = textNode.allSatisfyCodeInSelection(
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: textNode.toPlainText().length,
          ),
        );
        expect(allCode, false);
        expect(textNode.toPlainText(), text);
      });
    });

    group('convert double tilde to strikethrough', () {
      Future<void> insertTilde(
        EditorWidgetTester editor, {
        int repeat = 1,
      }) async {
        for (var i = 0; i < repeat; i++) {
          await editor.pressLogicKey(character: '~');
        }
      }

      testWidgets('~~AppFlowy~~ to strikethrough AppFlowy', (tester) async {
        const text = '~~AppFlowy~';
        final editor = tester.editor..insertTextNode('');
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }
        await insertTilde(editor);
        final allStrikethrough = textNode.allSatisfyStrikethroughInSelection(
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: textNode.toPlainText().length,
          ),
        );
        expect(allStrikethrough, true);
        expect(textNode.toPlainText(), 'AppFlowy');
      });

      testWidgets('App~~Flowy~~ to strikethrough AppFlowy', (tester) async {
        const text = 'App~~Flowy~';
        final editor = tester.editor..insertTextNode('');
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }
        await insertTilde(editor);
        final allStrikethrough = textNode.allSatisfyStrikethroughInSelection(
          Selection.single(
            path: [0],
            startOffset: 3,
            endOffset: textNode.toPlainText().length,
          ),
        );
        expect(allStrikethrough, true);
        expect(textNode.toPlainText(), 'AppFlowy');
      });

      testWidgets('~~~AppFlowy~~ to bold ~AppFlowy', (tester) async {
        const text = '~~~AppFlowy~';
        final editor = tester.editor..insertTextNode('');
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }
        await insertTilde(editor);
        final allStrikethrough = textNode.allSatisfyStrikethroughInSelection(
          Selection.single(
            path: [0],
            startOffset: 1,
            endOffset: textNode.toPlainText().length,
          ),
        );
        expect(allStrikethrough, true);
        expect(textNode.toPlainText(), '~AppFlowy');
      });

      testWidgets('~~~~ nothing changes', (tester) async {
        const text = '~~~';
        final editor = tester.editor..insertTextNode('');
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }
        await insertTilde(editor);
        final allStrikethrough = textNode.allSatisfyStrikethroughInSelection(
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: textNode.toPlainText().length,
          ),
        );
        expect(allStrikethrough, false);
        expect(textNode.toPlainText(), text);
      });
    });
  });

  group('convert double asterisk to bold', () {
    Future<void> insertAsterisk(
      EditorWidgetTester editor, {
      int repeat = 1,
    }) async {
      for (var i = 0; i < repeat; i++) {
        await editor.pressLogicKey(character: '*');
      }
    }

    testWidgets(
      '**AppFlowy** to bold AppFlowy',
      ((widgetTester) async {
        const text = '**AppFlowy*';
        final editor = widgetTester.editor..insertTextNode('');

        await editor.startTesting();
        await editor
            .updateSelection(Selection.single(path: [0], startOffset: 0));
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }

        await insertAsterisk(editor);

        final allBold = textNode.allSatisfyBoldInSelection(
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: textNode.toPlainText().length,
          ),
        );

        expect(allBold, true);
        expect(textNode.toPlainText(), 'AppFlowy');
      }),
    );

    testWidgets(
      'App**Flowy** to bold AppFlowy',
      ((widgetTester) async {
        const text = 'App**Flowy*';
        final editor = widgetTester.editor..insertTextNode('');

        await editor.startTesting();
        await editor
            .updateSelection(Selection.single(path: [0], startOffset: 0));
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }

        await insertAsterisk(editor);

        final allBold = textNode.allSatisfyBoldInSelection(
          Selection.single(
            path: [0],
            startOffset: 3,
            endOffset: textNode.toPlainText().length,
          ),
        );

        expect(allBold, true);
        expect(textNode.toPlainText(), 'AppFlowy');
      }),
    );

    testWidgets(
      '***AppFlowy** to bold *AppFlowy',
      ((widgetTester) async {
        const text = '***AppFlowy*';
        final editor = widgetTester.editor..insertTextNode('');

        await editor.startTesting();
        await editor
            .updateSelection(Selection.single(path: [0], startOffset: 0));
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }

        await insertAsterisk(editor);

        final allBold = textNode.allSatisfyBoldInSelection(
          Selection.single(
            path: [0],
            startOffset: 1,
            endOffset: textNode.toPlainText().length,
          ),
        );

        expect(allBold, true);
        expect(textNode.toPlainText(), '*AppFlowy');
      }),
    );

    testWidgets(
      '**** nothing changes',
      ((widgetTester) async {
        const text = '***';
        final editor = widgetTester.editor..insertTextNode('');

        await editor.startTesting();
        await editor
            .updateSelection(Selection.single(path: [0], startOffset: 0));
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }

        await insertAsterisk(editor);

        final allBold = textNode.allSatisfyBoldInSelection(
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: textNode.toPlainText().length,
          ),
        );

        expect(allBold, false);
        expect(textNode.toPlainText(), text);
      }),
    );

    testWidgets(
      '**bold and _nested_ italics**',
      ((widgetTester) async {
        const doubleAsterix = "**";
        const singleAstrix = "*";
        const firstBoldSegment = "bold and ";
        const underscore = "_";
        const italicsSegment = "nested";
        const secondBoldSegment = " italics";
        const text = doubleAsterix +
            firstBoldSegment +
            underscore +
            italicsSegment +
            underscore +
            secondBoldSegment +
            singleAstrix;
        final editor = widgetTester.editor..insertTextNode('');

        await editor.startTesting();
        await editor
            .updateSelection(Selection.single(path: [0], startOffset: 0));
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }

        await insertAsterisk(editor);

        final allTextBold = textNode.allSatisfyBoldInSelection(
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: text.length,
          ),
        );

        final segmentItalic = textNode.allSatisfyItalicInSelection(
          Selection.single(
            path: [0],
            startOffset: firstBoldSegment.length,
            endOffset: firstBoldSegment.length + italicsSegment.length - 1,
          ),
        );

        final lastSegmentItalic = textNode.allSatisfyItalicInSelection(
          Selection.single(
            path: [0],
            startOffset: firstBoldSegment.length + italicsSegment.length,
            endOffset: text.length,
          ),
        );

        const plainText = firstBoldSegment + italicsSegment + secondBoldSegment;
        final plainResult = textNode.toPlainText();
        expect(allTextBold, true);
        expect(segmentItalic, true);
        expect(lastSegmentItalic, false);
        expect(plainText, plainResult);
      }),
    );

    testWidgets(
      'regular then **bold and _nested_ italics**',
      ((widgetTester) async {
        const doubleAsterix = "**";
        const singleAstrix = "*";
        const regularSegment = "regular then ";
        const firstBoldSegment = "bold and ";
        const underscore = "_";
        const italicsSegment = "nested";
        const secondBoldSegment = " italics";
        const text = regularSegment +
            doubleAsterix +
            firstBoldSegment +
            underscore +
            italicsSegment +
            underscore +
            secondBoldSegment +
            singleAstrix;
        final editor = widgetTester.editor..insertTextNode('');

        await editor.startTesting();
        await editor
            .updateSelection(Selection.single(path: [0], startOffset: 0));
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }

        await insertAsterisk(editor);

        final textInAsterixesIsBold = textNode.allSatisfyBoldInSelection(
          Selection.single(
            path: [0],
            startOffset: regularSegment.length,
            endOffset: text.length,
          ),
        );

        final segmentItalic = textNode.allSatisfyItalicInSelection(
          Selection.single(
            path: [0],
            startOffset: regularSegment.length + firstBoldSegment.length,
            endOffset: regularSegment.length +
                firstBoldSegment.length +
                italicsSegment.length -
                1,
          ),
        );

        final lastSegmentItalic = textNode.allSatisfyItalicInSelection(
          Selection.single(
            path: [0],
            startOffset: text.length - secondBoldSegment.length,
            endOffset: text.length,
          ),
        );
        const plainText = regularSegment +
            firstBoldSegment +
            italicsSegment +
            secondBoldSegment;
        final plainResult = textNode.toPlainText();
        expect(textInAsterixesIsBold, true);
        expect(segmentItalic, true);
        expect(lastSegmentItalic, false);
        expect(plainText, plainResult);
      }),
    );

    testWidgets(
      '**bold and _double_ _nested_ italics**',
      ((widgetTester) async {
        const doubleAsterix = "**";
        const singleAstrix = "*";
        const firstBoldSegment = "bold and ";
        const firstItalicsSegment = "double";
        const underscore = "_";
        const secondBoldSegment = " ";
        const secondItalicsSegment = "nested";
        const thirdBoldSegment = " italics";
        const text = doubleAsterix +
            firstBoldSegment +
            underscore +
            firstItalicsSegment +
            underscore +
            secondBoldSegment +
            underscore +
            secondItalicsSegment +
            underscore +
            thirdBoldSegment +
            singleAstrix;
        final editor = widgetTester.editor..insertTextNode('');

        await editor.startTesting();
        await editor
            .updateSelection(Selection.single(path: [0], startOffset: 0));
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }

        await insertAsterisk(editor);

        final allTextBold = textNode.allSatisfyBoldInSelection(
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: text.length,
          ),
        );

        final firstSegmentItalic = textNode.allSatisfyItalicInSelection(
          Selection.single(
            path: [0],
            startOffset: firstBoldSegment.length,
            endOffset: firstBoldSegment.length + firstItalicsSegment.length - 1,
          ),
        );

        const secondItalicsSegmentIndex = firstBoldSegment.length +
            firstItalicsSegment.length +
            secondBoldSegment.length;
        final secondSegmentItalic = textNode.allSatisfyItalicInSelection(
          Selection.single(
            path: [0],
            startOffset: secondItalicsSegmentIndex,
            endOffset:
                secondItalicsSegmentIndex + secondItalicsSegment.length - 1,
          ),
        );

        const plainText = firstBoldSegment +
            firstItalicsSegment +
            secondBoldSegment +
            secondItalicsSegment +
            thirdBoldSegment;
        final plainResult = textNode.toPlainText();
        expect(allTextBold, true);
        expect(firstSegmentItalic, true);
        expect(secondSegmentItalic, true);
        expect(plainText, plainResult);
      }),
    );
  });

  group('convert double underscore to bold', () {
    Future<void> insertUnderscore(
      EditorWidgetTester editor, {
      int repeat = 1,
    }) async {
      for (var i = 0; i < repeat; i++) {
        await editor.pressLogicKey(character: '_');
      }
    }

    testWidgets(
      '__AppFlowy__ to bold AppFlowy',
      ((widgetTester) async {
        const text = '__AppFlowy_';
        final editor = widgetTester.editor..insertTextNode('');

        await editor.startTesting();
        await editor
            .updateSelection(Selection.single(path: [0], startOffset: 0));
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }

        await insertUnderscore(editor);

        final allBold = textNode.allSatisfyBoldInSelection(
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: textNode.toPlainText().length,
          ),
        );

        expect(allBold, true);
        expect(textNode.toPlainText(), 'AppFlowy');
      }),
    );

    testWidgets(
      'App__Flowy__ to bold AppFlowy',
      ((widgetTester) async {
        const text = 'App__Flowy_';
        final editor = widgetTester.editor..insertTextNode('');

        await editor.startTesting();
        await editor
            .updateSelection(Selection.single(path: [0], startOffset: 0));
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }

        await insertUnderscore(editor);

        final allBold = textNode.allSatisfyBoldInSelection(
          Selection.single(
            path: [0],
            startOffset: 3,
            endOffset: textNode.toPlainText().length,
          ),
        );

        expect(allBold, true);
        expect(textNode.toPlainText(), 'AppFlowy');
      }),
    );

    testWidgets(
      '__*AppFlowy__ to bold *AppFlowy',
      ((widgetTester) async {
        const text = '__*AppFlowy_';
        final editor = widgetTester.editor..insertTextNode('');

        await editor.startTesting();
        await editor
            .updateSelection(Selection.single(path: [0], startOffset: 0));
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }

        await insertUnderscore(editor);

        final allBold = textNode.allSatisfyBoldInSelection(
          Selection.single(
            path: [0],
            startOffset: 1,
            endOffset: textNode.toPlainText().length,
          ),
        );

        expect(allBold, true);
        expect(textNode.toPlainText(), '*AppFlowy');
      }),
    );

    testWidgets(
      '____ nothing changes',
      ((widgetTester) async {
        const text = '___';
        final editor = widgetTester.editor..insertTextNode('');

        await editor.startTesting();
        await editor
            .updateSelection(Selection.single(path: [0], startOffset: 0));
        final textNode = editor.nodeAtPath([0]) as TextNode;
        for (var i = 0; i < text.length; i++) {
          await editor.insertText(textNode, text[i], i);
        }

        await insertUnderscore(editor);

        final allBold = textNode.allSatisfyBoldInSelection(
          Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: textNode.toPlainText().length,
          ),
        );

        expect(allBold, false);
        expect(textNode.toPlainText(), text);
      }),
    );
  });
}

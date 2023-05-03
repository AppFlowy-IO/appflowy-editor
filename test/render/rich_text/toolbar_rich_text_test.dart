import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/render/toolbar/toolbar_item_widget.dart';
import 'package:appflowy_editor/src/render/toolbar/toolbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../infra/test_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  const singleLineText = "One Line Of Text";

  group(
    'toolbar, heading',
    (() {
      testWidgets('Select Text, Click toolbar and set style for h1 heading',
          (tester) async {
        final editor = tester.editor..insertTextNode(singleLineText);
        await editor.startTesting();

        final h1 = Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: singleLineText.length),
        );

        await editor.updateSelection(h1);

        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(find.byType(ToolbarWidget), findsOneWidget);

        final h1Button = find.byWidgetPredicate((widget) {
          if (widget is ToolbarItemWidget) {
            return widget.item.id == 'appflowy.toolbar.h1';
          }
          return false;
        });

        expect(h1Button, findsOneWidget);
        await tester.tap(h1Button);
        await tester.pumpAndSettle();

        final node = editor.nodeAtPath([0]) as TextNode;
        expect(node.attributes.heading, 'h1');
      });

      testWidgets('Select Text, Click toolbar and set style for h2 heading',
          (tester) async {
        final editor = tester.editor..insertTextNode(singleLineText);
        await editor.startTesting();

        final h2 = Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: singleLineText.length),
        );

        await editor.updateSelection(h2);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(find.byType(ToolbarWidget), findsOneWidget);

        final h2Button = find.byWidgetPredicate((widget) {
          if (widget is ToolbarItemWidget) {
            return widget.item.id == 'appflowy.toolbar.h2';
          }
          return false;
        });
        expect(h2Button, findsOneWidget);
        await tester.tap(h2Button);
        await tester.pumpAndSettle();
        final node = editor.nodeAtPath([0]) as TextNode;
        expect(node.attributes.heading, 'h2');
      });

      testWidgets('Select Text, Click toolbar and set style for h3 heading',
          (tester) async {
        final editor = tester.editor..insertTextNode(singleLineText);
        await editor.startTesting();

        final h3 = Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: singleLineText.length),
        );

        await editor.updateSelection(h3);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(find.byType(ToolbarWidget), findsOneWidget);

        final h3Button = find.byWidgetPredicate((widget) {
          if (widget is ToolbarItemWidget) {
            return widget.item.id == 'appflowy.toolbar.h3';
          }
          return false;
        });
        expect(h3Button, findsOneWidget);
        await tester.tap(h3Button);
        await tester.pumpAndSettle();
        final node = editor.nodeAtPath([0]) as TextNode;
        expect(node.attributes.heading, 'h3');
      });
    }),
  );

  group(
    'toolbar, underline',
    (() {
      testWidgets('Select text, click toolbar and set style for underline',
          (tester) async {
        final editor = tester.editor..insertTextNode(singleLineText);
        await editor.startTesting();

        final underline = Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: singleLineText.length),
        );

        await editor.updateSelection(underline);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(find.byType(ToolbarWidget), findsOneWidget);
        final underlineButton = find.byWidgetPredicate((widget) {
          if (widget is ToolbarItemWidget) {
            return widget.item.id == 'appflowy.toolbar.underline';
          }
          return false;
        });

        expect(underlineButton, findsOneWidget);
        await tester.tap(underlineButton);
        await tester.pumpAndSettle();
        final node = editor.nodeAtPath([0]) as TextNode;
        // expect(node.attributes.underline, true);
        expect(node.allSatisfyUnderlineInSelection(underline), true);
      });
    }),
  );

  group(
    'toolbar, bold',
    (() {
      testWidgets('Select Text, Click Toolbar and set style for bold',
          (tester) async {
        final editor = tester.editor..insertTextNode(singleLineText);
        await editor.startTesting();

        final bold = Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: singleLineText.length),
        );

        await editor.updateSelection(bold);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(find.byType(ToolbarWidget), findsOneWidget);
        final boldButton = find.byWidgetPredicate((widget) {
          if (widget is ToolbarItemWidget) {
            return widget.item.id == 'appflowy.toolbar.bold';
          }
          return false;
        });

        expect(boldButton, findsOneWidget);
        await tester.tap(boldButton);
        await tester.pumpAndSettle();
        final node = editor.nodeAtPath([0]) as TextNode;
        expect(node.allSatisfyBoldInSelection(bold), true);
      });
    }),
  );

  group(
    'toolbar, italic',
    (() {
      testWidgets('Select Text, Click Toolbar and set style for italic',
          (tester) async {
        final editor = tester.editor..insertTextNode(singleLineText);
        await editor.startTesting();

        final italic = Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: singleLineText.length),
        );

        await editor.updateSelection(italic);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(find.byType(ToolbarWidget), findsOneWidget);
        final italicButton = find.byWidgetPredicate((widget) {
          if (widget is ToolbarItemWidget) {
            return widget.item.id == 'appflowy.toolbar.italic';
          }
          return false;
        });

        expect(italicButton, findsOneWidget);
        await tester.tap(italicButton);
        await tester.pumpAndSettle();
        final node = editor.nodeAtPath([0]) as TextNode;
        expect(node.allSatisfyItalicInSelection(italic), true);
      });
    }),
  );

  group(
    'toolbar, strikethrough',
    (() {
      testWidgets('Select Text, Click Toolbar and set style for strikethrough',
          (tester) async {
        final editor = tester.editor..insertTextNode(singleLineText);
        await editor.startTesting();

        final strikeThrough = Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: singleLineText.length),
        );

        await editor.updateSelection(strikeThrough);

        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(find.byType(ToolbarWidget), findsOneWidget);
        final strikeThroughButton = find.byWidgetPredicate((widget) {
          if (widget is ToolbarItemWidget) {
            return widget.item.id == 'appflowy.toolbar.strikethrough';
          }
          return false;
        });

        expect(strikeThroughButton, findsOneWidget);
        await tester.tap(strikeThroughButton);
        await tester.pumpAndSettle();
        final node = editor.nodeAtPath([0]) as TextNode;
        expect(node.allSatisfyStrikethroughInSelection(strikeThrough), true);
      });
    }),
  );

  group(
    'toolbar, code',
    (() {
      testWidgets('Select Text, Click Toolbar and set style for code',
          (tester) async {
        final editor = tester.editor..insertTextNode(singleLineText);
        await editor.startTesting();

        final code = Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: singleLineText.length),
        );

        await editor.updateSelection(code);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(find.byType(ToolbarWidget), findsOneWidget);
        final codeButton = find.byWidgetPredicate((widget) {
          if (widget is ToolbarItemWidget) {
            return widget.item.id == 'appflowy.toolbar.code';
          }
          return false;
        });

        expect(codeButton, findsOneWidget);
        await tester.tap(codeButton);
        await tester.pumpAndSettle();
        final node = editor.nodeAtPath([0]) as TextNode;
        expect(
          node.allSatisfyInSelection(
            code,
            BuiltInAttributeKey.code,
            (value) => value == true,
          ),
          true,
        );
      });
    }),
  );

  group(
    'toolbar, quote',
    (() {
      testWidgets('Select Text, Click Toolbar and set style for quote',
          (tester) async {
        final editor = tester.editor..insertTextNode(singleLineText);
        await editor.startTesting();

        final quote = Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: singleLineText.length),
        );

        await editor.updateSelection(quote);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(find.byType(ToolbarWidget), findsOneWidget);
        final quoteButton = find.byWidgetPredicate((widget) {
          if (widget is ToolbarItemWidget) {
            return widget.item.id == 'appflowy.toolbar.quote';
          }
          return false;
        });
        expect(quoteButton, findsOneWidget);
        await tester.tap(quoteButton);
        await tester.pumpAndSettle();
        final node = editor.nodeAtPath([0]) as TextNode;
        expect(node.subtype, 'quote');
      });
    }),
  );

  group(
    'toolbar, bullet list',
    (() {
      testWidgets('Select Text, Click Toolbar and set style for bullet',
          (tester) async {
        final editor = tester.editor..insertTextNode(singleLineText);
        await editor.startTesting();

        final bulletList = Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: singleLineText.length),
        );

        await editor.updateSelection(bulletList);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(find.byType(ToolbarWidget), findsOneWidget);
        final bulletListButton = find.byWidgetPredicate((widget) {
          if (widget is ToolbarItemWidget) {
            return widget.item.id == 'appflowy.toolbar.bulleted_list';
          }
          return false;
        });

        expect(bulletListButton, findsOneWidget);
        await tester.tap(bulletListButton);
        await tester.pumpAndSettle();
        final node = editor.nodeAtPath([0]) as TextNode;
        expect(node.subtype, 'bulleted-list');
      });
    }),
  );

  group(
    'toolbar, highlight',
    (() {
      testWidgets(
          'Select Text, Click Toolbar and set style for highlighted text',
          (tester) async {
        // FIXME: Use a const value instead of the magic string.
        const blue = '0x6000BCF0';
        final editor = tester.editor..insertTextNode(singleLineText);
        await editor.startTesting();

        final node = editor.nodeAtPath([0]) as TextNode;
        final selection = Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: singleLineText.length),
        );

        await editor.updateSelection(selection);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(find.byType(ToolbarWidget), findsOneWidget);
        final highlightButton = find.byWidgetPredicate((widget) {
          if (widget is ToolbarItemWidget) {
            return widget.item.id == 'appflowy.toolbar.highlight';
          }
          return false;
        });
        expect(highlightButton, findsOneWidget);
        await tester.tap(highlightButton);
        await tester.pumpAndSettle();
        expect(
          node.allSatisfyInSelection(
            selection,
            BuiltInAttributeKey.backgroundColor,
            (value) {
              return value == blue;
            },
          ),
          true,
        );
      });
    }),
  );

  group(
    'toolbar, color picker',
    (() {
      testWidgets(
          'Select Text, Click Toolbar and set color for the selected text',
          (tester) async {
        final editor = tester.editor..insertTextNode(singleLineText);
        await editor.startTesting();

        final node = editor.nodeAtPath([0]) as TextNode;
        final selection = Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: singleLineText.length),
        );

        await editor.updateSelection(selection);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(find.byType(ToolbarWidget), findsOneWidget);
        final colorButton = find.byWidgetPredicate((widget) {
          if (widget is ToolbarItemWidget) {
            return widget.item.id == 'appflowy.toolbar.color';
          }
          return false;
        });
        expect(colorButton, findsOneWidget);
        await tester.tap(colorButton);
        await tester.pumpAndSettle();
        // select a yellow color
        final yellowButton = find.text('Yellow');
        await tester.tap(yellowButton);
        await tester.pumpAndSettle();
        expect(
          node.allSatisfyInSelection(
            selection,
            BuiltInAttributeKey.color,
            (value) {
              return value == Colors.yellow.toHex();
            },
          ),
          true,
        );
      });
    }),
  );

  group(
    'toolbar, link menu',
    (() {
      testWidgets(
          'Select Text, Click Toolbar and test visibility of the LinkMenu',
          (tester) async {
        // use surface smaller, then default one (800x600),
        // to reduce time to test
        await tester.binding.setSurfaceSize(const Size(640, 480));

        final editor = tester.editor;
        await editor.startTesting();

        final rbSize = editor.editorState.renderBox?.size;
        final rbWidth = rbSize!.width;
        final rbHeigh = rbSize.height;

        // fill current editor render box with text
        // from top left to bottom right corner
        var textLine = '0';
        var textCompletelyFillRenderBox = false;

        while (!textCompletelyFillRenderBox) {
          editor.document.delete([0]);
          await tester.pumpAndSettle();

          editor.insertTextNode(textLine);
          await tester.pumpAndSettle();

          var selection = Selection(
            start: Position(path: [0], offset: textLine.length - 1),
            end: Position(path: [0], offset: textLine.length),
          );
          await editor.updateSelection(selection);
          await tester.pumpAndSettle();

          final rect =
              editor.editorState.service.selectionService.selectionRects[0];

          textCompletelyFillRenderBox = rect.bottom > rbHeigh;

          textLine += '0';
        }

        Map<int, Rect> indexOfTopLeftRect = {0: Rect.zero};
        Map<int, Rect> indexOfTopRightRect = {0: Rect.zero};
        Map<int, Rect> indexOfBottomLeftRect = {0: Rect.zero};
        Map<int, Rect> indexOfBottomRightRect = {0: Rect.zero};

        // walk through text to find indexes of symbols of text, which are
        // placed in corners of editor render box
        for (var i = 0; i < textLine.length; i++) {
          // select symbol at next position
          var selection = Selection(
            start: Position(path: [0], offset: i),
            end: Position(path: [0], offset: i + 1),
          );
          await editor.updateSelection(selection);
          await tester.pumpAndSettle();

          // here is exactly one selection rect
          final rect =
              editor.editorState.service.selectionService.selectionRects[0];

          // initial position is top left corner,
          // i.e. position of first symbol for all "points"
          if (0 == i) {
            indexOfTopLeftRect = {i: rect};
            indexOfTopRightRect = {i: rect};
            indexOfBottomLeftRect = {i: rect};
            indexOfBottomRightRect = {i: rect};
          }

          final foundBetterTopRightWithinRenderBoxBorders =
              rect.top <= indexOfTopRightRect.values.first.top &&
                  rect.right >= indexOfTopRightRect.values.first.right &&
                  rect.right <= rbWidth;

          if (foundBetterTopRightWithinRenderBoxBorders) {
            indexOfTopRightRect = {i: rect};
          }

          final foundBetterBottomLeftWithinRenderBoxBorders =
              rect.bottom >= indexOfBottomLeftRect.values.first.bottom &&
                  rect.left <= indexOfBottomLeftRect.values.first.left &&
                  rect.bottom <= rbHeigh;

          if (foundBetterBottomLeftWithinRenderBoxBorders) {
            indexOfBottomLeftRect = {i: rect};
          }

          final foundBetterBottomRightWithinRenderBoxBorders =
              rect.bottom >= indexOfBottomRightRect.values.first.bottom &&
                  rect.right >= indexOfBottomRightRect.values.first.right &&
                  rect.right <= rbWidth &&
                  rect.bottom <= rbHeigh;

          if (foundBetterBottomRightWithinRenderBoxBorders) {
            indexOfBottomRightRect = {i: rect};
          }
        }

        List<Selection> cornerSelections = [
          Selection(
            start: Position(
              path: [0],
              offset: indexOfTopLeftRect.keys.first,
            ),
            end: Position(
              path: [0],
              offset: indexOfTopLeftRect.keys.first + 1,
            ),
          ),
          Selection(
            start: Position(
              path: [0],
              offset: indexOfTopRightRect.keys.first,
            ),
            end: Position(
              path: [0],
              offset: indexOfTopRightRect.keys.first + 1,
            ),
          ),
          Selection(
            start: Position(
              path: [0],
              offset: indexOfBottomLeftRect.keys.first,
            ),
            end: Position(
              path: [0],
              offset: indexOfBottomLeftRect.keys.first + 1,
            ),
          ),
          Selection(
            start: Position(
              path: [0],
              offset: indexOfBottomRightRect.keys.first,
            ),
            end: Position(
              path: [0],
              offset: indexOfBottomRightRect.keys.first + 1,
            ),
          ),
        ];

        // test, that LinkMenu is visible with calling it from Toolbar
        // in each corner position
        for (final selection in cornerSelections) {
          await editor.updateSelection(selection);
          await tester.pumpAndSettle(const Duration(milliseconds: 500));

          expect(find.byType(ToolbarWidget), findsOneWidget);
          var linkButton = find.byWidgetPredicate((widget) {
            if (widget is ToolbarItemWidget) {
              return widget.item.id == 'appflowy.toolbar.link';
            }
            return false;
          });
          expect(linkButton.hitTestable(), findsOneWidget);
          await tester.tap(linkButton);
          await tester.pumpAndSettle();
          // check if LinkMenu is visible
          expect(find.text('Add your link').hitTestable(), findsOneWidget);
        }
      });
    }),
  );
}

extension on Color {
  String toHex() {
    return '0x${value.toRadixString(16)}';
  }
}

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

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helper.dart';

void main() {
  group('MobileLinkMenu', () {
    testWidgets('can render', (tester) async {
      final document = Document.blank();
      final editorState = EditorState(document: document);

      await tester.buildAndPump(
        _wrapWithStyle(
          child: MobileLinkMenu(
            editorState: editorState,
            onSubmitted: (_) {},
            onCancel: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MobileLinkMenu), findsOneWidget);
    });

    testWidgets('onSubmitted', (tester) async {
      bool onSubmitted = false;

      final document = Document.blank();
      final editorState = EditorState(document: document);

      await tester.buildAndPump(
        _wrapWithStyle(
          child: MobileLinkMenu(
            editorState: editorState,
            onSubmitted: (_) => onSubmitted = true,
            onCancel: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(Row),
          matching: find.byType(ElevatedButton).last,
        ),
      );

      expect(onSubmitted, true);
    });

    testWidgets('onCancel', (tester) async {
      bool onCancel = false;

      final document = Document.blank();
      final editorState = EditorState(document: document);

      await tester.buildAndPump(
        _wrapWithStyle(
          child: MobileLinkMenu(
            editorState: editorState,
            onSubmitted: (_) {},
            onCancel: () => onCancel = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(Row),
          matching: find.byType(ElevatedButton).first,
        ),
      );

      expect(onCancel, true);
    });
  });
}

Widget _wrapWithStyle({required Widget child}) => MobileToolbarStyle(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.blue,
      clearDiagonalLineColor: Colors.blue,
      itemHighlightColor: Colors.blue,
      itemOutlineColor: Colors.blue,
      tabbarSelectedBackgroundColor: Colors.blue,
      tabbarSelectedForegroundColor: Colors.blue,
      primaryColor: Colors.blue,
      onPrimaryColor: Colors.blue,
      outlineColor: Colors.blue,
      toolbarHeight: 55,
      borderRadius: 8,
      buttonHeight: 32,
      buttonSpacing: 8,
      buttonBorderWidth: 1,
      buttonSelectedBorderWidth: 1,
      child: child,
    );

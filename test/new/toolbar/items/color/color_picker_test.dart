import 'package:appflowy_editor/src/editor/toolbar/items/color/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('color_picker.dart widget test', () {
    testWidgets('test expansion tile widget in color picker', (tester) async {
      final editor = tester.editor;
      await editor.startTesting();
      final key = GlobalKey();
      final widget = ColorPicker(
        key: key,
        editorState: editor.editorState,
        isTextColor: true,
        colorOptions: const [],
        onDismiss: () {},
        onSubmittedColorHex: (String color) {},
        selectedColorHex: '0xFFFFFFFF',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
      final expansionTile = find.byType(ExpansionTile);
      expect(expansionTile, findsOneWidget);

      await tester.tap(expansionTile);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets(
        'test if custom font color selector text field are initialised correctly when selectedFontColorhex is provided',
        (tester) async {
      final editor = tester.editor;
      await editor.startTesting();
      final widget = ColorPicker(
        editorState: editor.editorState,
        isTextColor: true,
        colorOptions: const [],
        onDismiss: () {},
        onSubmittedColorHex: (String color) {},
        selectedColorHex: '0xFAFFFF08',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final fontColorExpansionTile = find.byType(ExpansionTile);

      await tester.tap(fontColorExpansionTile);
      await tester.pumpAndSettle();

      final fontColorTextField = find.byType(TextField).at(0);
      final fontOpacityTexField = find.byType(TextField).at(1);

      expect(
        (tester.widget(fontColorTextField) as TextField).controller!.text,
        'FFFF08',
      );
      expect(
        (tester.widget(fontOpacityTexField) as TextField).controller!.text,
        '98',
      );
    });
    testWidgets(
        'test if custom font color selector text field are initialised correctly when selectedFontColorhex is null',
        (tester) async {
      final editor = tester.editor;
      await editor.startTesting();
      final widget = ColorPicker(
        editorState: editor.editorState,
        isTextColor: true,
        colorOptions: const [],
        onDismiss: () {},
        onSubmittedColorHex: (String color) {},
        selectedColorHex: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final fontColorExpansionTile = find.byType(ExpansionTile);

      await tester.tap(fontColorExpansionTile);
      await tester.pumpAndSettle();

      final fontColorTextField = find.byType(TextField).at(0);
      final fontOpacityTexField = find.byType(TextField).at(1);

      expect(
        (tester.widget(fontColorTextField) as TextField).controller!.text,
        'FFFFFF',
      );
      expect(
        (tester.widget(fontOpacityTexField) as TextField).controller!.text,
        '100',
      );
    });
    testWidgets(
        'test if custom background color selector text field are initialised correctly when selectedBackgroundColorHex is provided',
        (tester) async {
      final editor = tester.editor;
      await editor.startTesting();
      final widget = ColorPicker(
        editorState: editor.editorState,
        isTextColor: false,
        colorOptions: const [],
        onDismiss: () {},
        onSubmittedColorHex: (String color) {},
        selectedColorHex: '0xFBFFFF08',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final backgroundColorExpansionTile = find.byType(ExpansionTile);

      await tester.tap(backgroundColorExpansionTile);
      await tester.pumpAndSettle();

      final backgroundColorTextField = find.byType(TextField).at(0);
      final backgroundOpacityTextField = find.byType(TextField).at(1);
      expect(
        (tester.widget(backgroundColorTextField) as TextField).controller!.text,
        'FFFF08',
      );
      expect(
        (tester.widget(backgroundOpacityTextField) as TextField)
            .controller!
            .text,
        '98',
      );
    });
    testWidgets(
        'test if custom background color selector text field are initialised correctly when selectedBackgroundColorHex is null',
        (tester) async {
      final editor = tester.editor;
      await editor.startTesting();
      final widget = ColorPicker(
        editorState: editor.editorState,
        isTextColor: false,
        colorOptions: const [],
        onDismiss: () {},
        onSubmittedColorHex: (String color) {},
        selectedColorHex: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final backgroundColorExpansionTile = find.byType(ExpansionTile);

      await tester.tap(backgroundColorExpansionTile);
      await tester.pumpAndSettle();

      final backgroundColorTextField = find.byType(TextField).at(0);
      final backgroundOpacityTextField = find.byType(TextField).at(1);
      expect(
        (tester.widget(backgroundColorTextField) as TextField).controller!.text,
        'FFFFFF',
      );
      expect(
        (tester.widget(backgroundOpacityTextField) as TextField)
            .controller!
            .text,
        '100',
      );
    });

    testWidgets('test submitting font color and opacity', (tester) async {
      String fontColorHex = '0xFAFFFF08';
      final editor = tester.editor;
      await editor.startTesting();
      final widget = ColorPicker(
        editorState: editor.editorState,
        isTextColor: true,
        colorOptions: const [],
        onDismiss: () {},
        onSubmittedColorHex: (String color) {
          fontColorHex = color;
        },
        selectedColorHex: fontColorHex,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final fontColorExpansionTile = find.byType(ExpansionTile);

      await tester.tap(fontColorExpansionTile);
      await tester.pumpAndSettle();

      final fontColorTextField = find.byType(TextField).at(0);
      final fontOpacityTexField = find.byType(TextField).at(1);

      await tester.enterText(fontColorTextField, '000000');
      await tester.enterText(fontOpacityTexField, '100');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      fontColorHex = fontColorHex.toLowerCase();
      expect(fontColorHex, '0xff000000');
    });

    testWidgets('test submitting wrong font color and opacity', (tester) async {
      String fontColorHex = '0xFAFFFF08';

      final editor = tester.editor;
      await editor.startTesting();
      final widget = ColorPicker(
        editorState: editor.editorState,
        isTextColor: true,
        colorOptions: const [],
        onDismiss: () {},
        onSubmittedColorHex: (String color) {
          fontColorHex = color;
        },
        selectedColorHex: fontColorHex,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final fontColorExpansionTile = find.byType(ExpansionTile);

      await tester.tap(fontColorExpansionTile);
      await tester.pumpAndSettle();

      final fontColorTextField = find.byType(TextField).at(0);
      final fontOpacityTexField = find.byType(TextField).at(1);

      await tester.enterText(fontColorTextField, '====');
      await tester.enterText(fontOpacityTexField, '***');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      fontColorHex = fontColorHex.toLowerCase();
      expect(fontColorHex, '0xffffffff');
    });

    testWidgets('test submitting  background color and opacity',
        (tester) async {
      String backgroundColorHex = '0xFAFFFFAD';

      final editor = tester.editor;
      await editor.startTesting();
      final widget = ColorPicker(
        editorState: editor.editorState,
        isTextColor: false,
        colorOptions: const [],
        onDismiss: () {},
        onSubmittedColorHex: (String color) {
          backgroundColorHex = color;
        },
        selectedColorHex: backgroundColorHex,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final backgroundColorExpansionTile = find.byType(ExpansionTile);

      await tester.tap(backgroundColorExpansionTile);
      await tester.pumpAndSettle();

      final backgroundColorTextField = find.byType(TextField).at(0);
      final backgroundOpacityTexField = find.byType(TextField).at(1);

      await tester.enterText(backgroundColorTextField, '000000');
      await tester.enterText(backgroundOpacityTexField, '100');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      backgroundColorHex = backgroundColorHex.toLowerCase();
      expect(backgroundColorHex, '0xff000000');
    });

    testWidgets('test submitting wrong background color and opacity',
        (tester) async {
      String backgroundColorHex = '0xFAFFFF08';
      final editor = tester.editor;
      await editor.startTesting();
      final widget = ColorPicker(
        editorState: editor.editorState,
        isTextColor: false,
        colorOptions: const [],
        onDismiss: () {},
        onSubmittedColorHex: (String color) {
          backgroundColorHex = color;
        },
        selectedColorHex: backgroundColorHex,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final backgroundColorExpansionTile = find.byType(ExpansionTile);

      await tester.tap(backgroundColorExpansionTile);
      await tester.pumpAndSettle();

      final backgroundColorTextField = find.byType(TextField).at(0);
      final backgroundOpacityTexField = find.byType(TextField).at(1);

      await tester.enterText(backgroundColorTextField, '***');
      await tester.enterText(backgroundOpacityTexField, '===');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      backgroundColorHex = backgroundColorHex.toLowerCase();
      expect(backgroundColorHex, '0xffffffff');
    });
  });
}

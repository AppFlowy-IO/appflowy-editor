import 'package:appflowy_editor/src/render/color_menu/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('color_picker.dart widget test', () {
    testWidgets('test expansion tile widget in color picker', (tester) async {
      final key = GlobalKey();
      final widget = ColorPicker(
        key: key,
        selectedFontColorHex: '0xFFFFFFFF',
        selectedBackgroundColorHex: '0xFFFFFFFF',
        pickerBackgroundColor: Colors.white,
        fontColorOptions: const [],
        backgroundColorOptions: const [],
        pickerItemHoverColor: Colors.white,
        pickerItemTextColor: Colors.white,
        onSubmittedbackgroundColorHex: (color) {},
        onSubmittedFontColorHex: (color) {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
      expect(find.byType(ExpansionTile), findsNWidgets(2));

      final firstExpansionTile = find.byType(ExpansionTile).at(0);

      await tester.tap(firstExpansionTile);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));

      final secondExpansionTile = find.byType(ExpansionTile).at(0);

      await tester.tap(secondExpansionTile);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets(
        'test if custom font color selector text field are initialised correctly when selectedFontColorhex is provided',
        (tester) async {
      final widget = ColorPicker(
        selectedFontColorHex: '0xFAFFFF08',
        selectedBackgroundColorHex: '0xFBFFFF08',
        pickerBackgroundColor: Colors.white,
        fontColorOptions: const [],
        backgroundColorOptions: const [],
        pickerItemHoverColor: Colors.white,
        pickerItemTextColor: Colors.white,
        onSubmittedbackgroundColorHex: (color) {},
        onSubmittedFontColorHex: (color) {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final fontColorExpansionTile = find.byType(ExpansionTile).at(0);

      await tester.tap(fontColorExpansionTile);
      await tester.pumpAndSettle();

      final fontColorTextField = find.byType(TextField).at(0);
      final fontOpacityTexField = find.byType(TextField).at(1);

      expect((tester.widget(fontColorTextField) as TextField).controller!.text,
          'FFFF08');
      expect((tester.widget(fontOpacityTexField) as TextField).controller!.text,
          '98');
    });
    testWidgets(
        'test if custom font color selector text field are initialised correctly when selectedFontColorhex is null',
        (tester) async {
      final widget = ColorPicker(
        selectedFontColorHex: null,
        selectedBackgroundColorHex: '0xFBFFFF08',
        pickerBackgroundColor: Colors.white,
        fontColorOptions: const [],
        backgroundColorOptions: const [],
        pickerItemHoverColor: Colors.white,
        pickerItemTextColor: Colors.white,
        onSubmittedbackgroundColorHex: (color) {},
        onSubmittedFontColorHex: (color) {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final fontColorExpansionTile = find.byType(ExpansionTile).at(0);

      await tester.tap(fontColorExpansionTile);
      await tester.pumpAndSettle();

      final fontColorTextField = find.byType(TextField).at(0);
      final fontOpacityTexField = find.byType(TextField).at(1);

      expect((tester.widget(fontColorTextField) as TextField).controller!.text,
          'FFFFFF');
      expect((tester.widget(fontOpacityTexField) as TextField).controller!.text,
          '100');
    });
    testWidgets(
        'test if custom background color selector text field are initialised correctly when selectedBackgroundColorHex is provided',
        (tester) async {
      final widget = ColorPicker(
        selectedFontColorHex: '0xFAFFFF08',
        selectedBackgroundColorHex: '0xFBFFFF08',
        pickerBackgroundColor: Colors.white,
        fontColorOptions: const [],
        backgroundColorOptions: const [],
        pickerItemHoverColor: Colors.white,
        pickerItemTextColor: Colors.white,
        onSubmittedbackgroundColorHex: (color) {},
        onSubmittedFontColorHex: (color) {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final backgroundColorExpansionTile = find.byType(ExpansionTile).at(1);

      await tester.tap(backgroundColorExpansionTile);
      await tester.pumpAndSettle();

      final backgroundColorTextField = find.byType(TextField).at(0);
      final backgroundOpacityTextField = find.byType(TextField).at(1);
      expect(
          (tester.widget(backgroundColorTextField) as TextField)
              .controller!
              .text,
          'FFFF08');
      expect(
          (tester.widget(backgroundOpacityTextField) as TextField)
              .controller!
              .text,
          '98');
    });
    testWidgets(
        'test if custom background color selector text field are initialised correctly when selectedBackgroundColorHex is null',
        (tester) async {
      final widget = ColorPicker(
        selectedFontColorHex: '0xFAFFFF08',
        selectedBackgroundColorHex: null,
        pickerBackgroundColor: Colors.white,
        fontColorOptions: const [],
        backgroundColorOptions: const [],
        pickerItemHoverColor: Colors.white,
        pickerItemTextColor: Colors.white,
        onSubmittedbackgroundColorHex: (color) {},
        onSubmittedFontColorHex: (color) {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final backgroundColorExpansionTile = find.byType(ExpansionTile).at(1);

      await tester.tap(backgroundColorExpansionTile);
      await tester.pumpAndSettle();

      final backgroundColorTextField = find.byType(TextField).at(0);
      final backgroundOpacityTextField = find.byType(TextField).at(1);
      expect(
          (tester.widget(backgroundColorTextField) as TextField)
              .controller!
              .text,
          'FFFFFF');
      expect(
          (tester.widget(backgroundOpacityTextField) as TextField)
              .controller!
              .text,
          '0');
    });

    testWidgets('test submitting font color and opacity', (tester) async {
      String fontColorHex = '0xFAFFFF08';
      final widget = ColorPicker(
        selectedFontColorHex: fontColorHex,
        selectedBackgroundColorHex: '0xFBFFFF08',
        pickerBackgroundColor: Colors.white,
        fontColorOptions: const [],
        backgroundColorOptions: const [],
        pickerItemHoverColor: Colors.white,
        pickerItemTextColor: Colors.white,
        onSubmittedbackgroundColorHex: (color) {},
        onSubmittedFontColorHex: (color) {
          fontColorHex = color;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final fontColorExpansionTile = find.byType(ExpansionTile).at(0);

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
      final widget = ColorPicker(
        selectedFontColorHex: fontColorHex,
        selectedBackgroundColorHex: '0xFBFFFF08',
        pickerBackgroundColor: Colors.white,
        fontColorOptions: const [],
        backgroundColorOptions: const [],
        pickerItemHoverColor: Colors.white,
        pickerItemTextColor: Colors.white,
        onSubmittedbackgroundColorHex: (color) {},
        onSubmittedFontColorHex: (color) {
          fontColorHex = color;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final fontColorExpansionTile = find.byType(ExpansionTile).at(0);

      await tester.tap(fontColorExpansionTile);
      await tester.pumpAndSettle();

      final fontColorTextField = find.byType(TextField).at(0);
      final fontOpacityTexField = find.byType(TextField).at(1);

      await tester.enterText(fontColorTextField, '00tg00');
      await tester.enterText(fontOpacityTexField, '999');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      fontColorHex = fontColorHex.toLowerCase();
      expect(fontColorHex, '0xffffffff');
    });

    testWidgets('test submitting  background color and opacity',
        (tester) async {
      String backgroundColorHex = '0xFAFFFFAD';
      final widget = ColorPicker(
        selectedFontColorHex: '0xFAFFFF08',
        selectedBackgroundColorHex: backgroundColorHex,
        pickerBackgroundColor: Colors.white,
        fontColorOptions: const [],
        backgroundColorOptions: const [],
        pickerItemHoverColor: Colors.white,
        pickerItemTextColor: Colors.white,
        onSubmittedbackgroundColorHex: (color) {
          backgroundColorHex = color;
        },
        onSubmittedFontColorHex: (color) {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final backgroundColorExpansionTile = find.byType(ExpansionTile).at(1);

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
      final widget = ColorPicker(
        selectedFontColorHex: '0xFAFFFF08',
        selectedBackgroundColorHex: backgroundColorHex,
        pickerBackgroundColor: Colors.white,
        fontColorOptions: const [],
        backgroundColorOptions: const [],
        pickerItemHoverColor: Colors.white,
        pickerItemTextColor: Colors.white,
        onSubmittedbackgroundColorHex: (color) {
          backgroundColorHex = color;
        },
        onSubmittedFontColorHex: (color) {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      final backgroundColorExpansionTile = find.byType(ExpansionTile).at(1);

      await tester.tap(backgroundColorExpansionTile);
      await tester.pumpAndSettle();

      final backgroundColorTextField = find.byType(TextField).at(0);
      final backgroundOpacityTexField = find.byType(TextField).at(1);

      await tester.enterText(backgroundColorTextField, '00tg00');
      await tester.enterText(backgroundOpacityTexField, '999');

      await tester.testTextInput.receiveAction(TextInputAction.done);
      backgroundColorHex = backgroundColorHex.toLowerCase();
      expect(backgroundColorHex, '0xffffffff');
    });
  });
}

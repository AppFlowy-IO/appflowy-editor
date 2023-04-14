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
        pickerBackgroundColor: Colors.white,
        pickerItemHoverColor: Colors.white,
        pickerItemTextColor: Colors.white,
        colorOptionLists: [
          ColorOptionList(
            header: 'font color',
            selectedColorHex: '0xFFFFFFFF',
            colorOptions: const [],
            onSubmittedAction: (color) {},
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
      expect(find.byType(ExpansionTile), findsNWidgets(1));

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
        pickerBackgroundColor: Colors.white,
        pickerItemHoverColor: Colors.white,
        pickerItemTextColor: Colors.white,
        colorOptionLists: [
          ColorOptionList(
            header: 'font color',
            selectedColorHex: '0xFAFFFF08',
            colorOptions: const [],
            onSubmittedAction: (color) {},
          ),
        ],
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
      final widget = ColorPicker(
        pickerBackgroundColor: Colors.white,
        pickerItemHoverColor: Colors.white,
        pickerItemTextColor: Colors.white,
        colorOptionLists: [
          ColorOptionList(
            header: 'font color',
            selectedColorHex: null,
            colorOptions: const [],
            onSubmittedAction: (color) {},
          ),
        ],
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

      expect(
        (tester.widget(fontColorTextField) as TextField).controller!.text,
        'FFFFFF',
      );
      expect(
        (tester.widget(fontOpacityTexField) as TextField).controller!.text,
        '100',
      );
    });

    testWidgets('test submitting font color and opacity', (tester) async {
      String fontColorHex = '0xFAFFFF08';
      final widget = ColorPicker(
        pickerBackgroundColor: Colors.white,
        pickerItemHoverColor: Colors.white,
        pickerItemTextColor: Colors.white,
        colorOptionLists: [
          ColorOptionList(
            header: 'font color',
            selectedColorHex: fontColorHex,
            colorOptions: const [],
            onSubmittedAction: (color) {
              fontColorHex = color;
            },
          ),
        ],
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
        pickerBackgroundColor: Colors.white,
        pickerItemHoverColor: Colors.white,
        pickerItemTextColor: Colors.white,
        colorOptionLists: [
          ColorOptionList(
            header: 'font color',
            selectedColorHex: fontColorHex,
            colorOptions: const [],
            onSubmittedAction: (color) {
              fontColorHex = color;
            },
          ),
        ],
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
  });
}

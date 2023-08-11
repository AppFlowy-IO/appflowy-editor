import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditorStyle', () {
    test('EditorStyle.mobile', () {
      const mobileStyle = EditorStyle.mobile(selectionColor: Colors.blue);
      expect(mobileStyle.selectionColor, Colors.blue);
    });

    test('EditorStyle.desktop', () {
      const desktopStyle = EditorStyle.mobile(selectionColor: Colors.red);
      expect(desktopStyle.selectionColor, Colors.red);
    });

    test('EditorStyle.copyWith', () {
      const padding = EdgeInsets.all(16);
      const cursorColor = Colors.orange;
      const selectionColor = Colors.pink;
      const textStyleConfiguration = TextStyleConfiguration();

      const desktopStyle = EditorStyle.mobile();
      expect(desktopStyle.padding, isNot(padding));
      expect(desktopStyle.cursorColor, isNot(cursorColor));
      expect(desktopStyle.selectionColor, isNot(selectionColor));
      expect(
        desktopStyle.textStyleConfiguration,
        isNot(textStyleConfiguration),
      );

      final oldStyle = desktopStyle.copyWith();
      expect(oldStyle.padding, isNot(padding));
      expect(oldStyle.cursorColor, isNot(cursorColor));
      expect(oldStyle.selectionColor, isNot(selectionColor));
      expect(
        oldStyle.textStyleConfiguration,
        isNot(textStyleConfiguration),
      );

      final newStyle = desktopStyle.copyWith(
        padding: padding,
        cursorColor: cursorColor,
        selectionColor: selectionColor,
        textStyleConfiguration: textStyleConfiguration,
      );
      expect(newStyle.padding, padding);
      expect(newStyle.cursorColor, cursorColor);
      expect(newStyle.selectionColor, selectionColor);
      expect(
        newStyle.textStyleConfiguration,
        textStyleConfiguration,
      );
    });
  });
}

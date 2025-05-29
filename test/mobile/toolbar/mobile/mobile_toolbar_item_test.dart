import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MobileToolbarItem', () {
    test('action item should not have a menu', () {
      final item = MobileToolbarItem.action(
        itemIconBuilder: (_, _, _) => const Icon(Icons.format_bold),
        actionHandler: (editorState, selection) {},
      );

      expect(item.hasMenu, false);
    });

    test('menu item should have a menu', () {
      final item = MobileToolbarItem.withMenu(
        itemIconBuilder: (_, _, _) => const Icon(Icons.format_color_text),
        itemMenuBuilder: (_, editorState, _) {
          return Container();
        },
      );

      expect(item.hasMenu, true);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

void main() {
  group('MobileToolbarItem', () {
    test('action item should not have a menu', () {
      final item = MobileToolbarItem.action(
        itemIcon: const Icon(Icons.format_bold),
        actionHandler: (editorState, selection) {},
      );

      expect(item.hasMenu, false);
    });

    test('menu item should have a menu', () {
      final item = MobileToolbarItem.withMenu(
        itemIcon: const Icon(Icons.format_color_text),
        itemMenuBuilder: (editorState, selection, _) {
          return Container();
        },
      );

      expect(item.hasMenu, true);
    });
  });
}

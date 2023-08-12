import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ToolbarItem', () {
    test('TolbarItem.divider constructor', () {
      final toolbarOne = ToolbarItem.divider();
      final toolbarTwo = ToolbarItem.divider();

      expect(toolbarOne == toolbarTwo, true);
      expect(toolbarOne.id, 'divider');
    });

    test('TolbarItem not equal', () {
      final toolbarOne = ToolbarItem.divider();
      final toolbarTwo = ToolbarItem(id: 'item', group: 1);

      expect(toolbarOne == toolbarTwo, false);
    });

    test('TolbarItem equal', () {
      final toolbarOne = ToolbarItem.divider();
      final toolbarTwo = ToolbarItem(id: 'divider', group: 5);

      expect(toolbarOne == toolbarTwo, true);
      expect(toolbarOne.hashCode == toolbarTwo.hashCode, true);
    });
  });
}

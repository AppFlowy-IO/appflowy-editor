import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('selection.dart', () {
    test('Selection.invalid', () {
      final invalid = Selection.invalid();
      final invalidPosition = Position.invalid();

      expect(invalid, Selection(start: invalidPosition, end: invalidPosition));
    });

    test('Selection.toString()', () {
      final selection = Selection(
        start: Position(path: [0, 1], offset: 4),
        end: Position(path: [1], offset: 8),
      );

      const str =
          "start = path = [0, 1], offset = 4, end = path = [1], offset = 8";

      expect(selection.toString(), str);
    });

    test('test selection equality', () {
      final position = Position(path: [0, 1, 2], offset: 3);
      final selectionA = Selection(start: position, end: position);
      final selectionB = Selection.collapsed(position);
      expect(selectionA, selectionB);
      expect(selectionA.hashCode, selectionB.hashCode);

      final newPosition = Position(path: [1, 2, 3], offset: 4);

      final selectionC = selectionA.copyWith(start: newPosition);
      expect(selectionC.start, newPosition);
      expect(selectionC.end, position);
      expect(selectionC.isCollapsed, false);

      final selectionD = selectionA.copyWith(end: newPosition);
      expect(selectionD.start, position);
      expect(selectionD.end, newPosition);
      expect(selectionD.isCollapsed, false);

      final selectionE = Selection.single(path: [0, 1, 2], startOffset: 3);
      expect(selectionE, selectionA);
      expect(selectionE.isSingle, true);
      expect(selectionE.isCollapsed, true);
    });

    test('test selection direction', () {
      final start = Position(path: [0, 1, 2], offset: 3);
      final end = Position(path: [1, 2, 3], offset: 3);
      final backwardSelection = Selection(start: start, end: end);
      expect(backwardSelection.isBackward, true);
      final forwardSelection = Selection(start: end, end: start);
      expect(forwardSelection.isForward, true);

      expect(backwardSelection.reversed, forwardSelection);
      expect(forwardSelection.normalized, backwardSelection);

      expect(backwardSelection.startIndex, 3);
      expect(backwardSelection.endIndex, 3);
    });

    test('test selection collapsed', () {
      final start = Position(path: [0, 1, 2], offset: 3);
      final end = Position(path: [1, 2, 3], offset: 3);
      final selection = Selection(start: start, end: end);
      final collapsedAtStart = selection.collapse(atStart: true);
      expect(collapsedAtStart.isCollapsed, true);
      expect(collapsedAtStart.start, start);
      expect(collapsedAtStart.end, start);

      final collapsedAtEnd = selection.collapse(atStart: false);
      expect(collapsedAtEnd.isCollapsed, true);
      expect(collapsedAtEnd.start, end);
      expect(collapsedAtEnd.end, end);
    });

    test('test selection toJson', () {
      final start = Position(path: [0, 1, 2], offset: 3);
      final end = Position(path: [1, 2, 3], offset: 3);
      final selection = Selection(start: start, end: end);
      expect(selection.toJson(), {
        'start': {
          'path': [0, 1, 2],
          'offset': 3,
        },
        'end': {
          'path': [1, 2, 3],
          'offset': 3,
        },
      });
    });

    testWidgets('Selection.fromJson', (tester) async {
      final selectionJson = jsonDecode("""{
        "start": {
          "path": [0],
          "offset": 0
        },
        "end": {
          "path": [2],
          "offset": 25
        }
      }""");

      final position = Selection.fromJson(selectionJson);

      expect(position.start.path.first, 0);
      expect(position.start.offset, 0);

      expect(position.end.path.first, 2);
      expect(position.end.offset, 25);
    });
  });
}

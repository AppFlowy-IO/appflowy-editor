import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('position.dart', () {
    test('Position.invalid', () {
      final invalid = Position.invalid();

      expect(invalid.path, [-1]);
      expect(invalid.offset, -1);
    });

    test('hashCode', () {
      final p1 = Position(path: [0], offset: 5);
      final p2 = Position(path: [0], offset: 5);

      expect(p1 == p2, true);
      expect(p1.hashCode == p2.hashCode, true);
    });

    test('toString', () {
      final p1 = Position(path: [0], offset: 5);
      const str = 'path = [0], offset = 5';

      expect(p1.toString(), str);
    });

    test('test position equality', () {
      final positionA = Position(path: [0, 1, 2], offset: 3);
      final positionB = Position(path: [0, 1, 2], offset: 3);
      expect(positionA, positionB);

      final positionC = positionA.copyWith(offset: 4);
      final positionD = positionB.copyWith(path: [1, 2, 3]);
      expect(positionC.offset, 4);
      expect(positionD.path, [1, 2, 3]);

      expect(positionA.toJson(), {
        'path': [0, 1, 2],
        'offset': 3,
      });
      expect(positionC.toJson(), {
        'path': [0, 1, 2],
        'offset': 4,
      });
    });

    testWidgets('Position.fromJson', (tester) async {
      final positionJson = jsonDecode("""{
        "path": [4],
        "offset": 5
      }""");

      final position = Position.fromJson(positionJson);

      expect(position.path.first, 4);
      expect(position.offset, 5);
    });
  });
}

import 'package:appflowy_editor/src/core/document/attributes.dart';
import 'package:appflowy_editor/src/core/document/text_delta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('text_delta.dart', () {
    group('TextInsert', () {
      test('hashCode', () {
        const text = 'AppFlowy';

        final t1 = TextInsert(text);
        final t2 = TextInsert(text);

        expect(t1 == t2, true);
        expect(t1.hashCode == t2.hashCode, true);
      });
    });

    group('TextRetain', () {
      test('hashCode', () {
        final t1 = TextRetain(4);
        final t2 = TextRetain(4);

        expect(t1 == t2, true);
        expect(t1.hashCode == t2.hashCode, true);
      });
    });

    group('TextDelete', () {
      test('hashCode', () {
        final t1 = TextDelete(length: 4);
        final t2 = TextDelete(length: 4);

        expect(t1 == t2, true);
        expect(t1.hashCode == t2.hashCode, true);
      });
    });

    group('compose', () {
      test('addAll + length', () {
        final delta = Delta(
          operations: [TextInsert('Welcome')],
        );

        final operations = [TextInsert(' to '), TextInsert('AppFlowy!')];
        delta.addAll(operations);

        expect(delta.toPlainText(), 'Welcome to AppFlowy!');
        expect(delta.length, 20);
      });

      test('Delta hashCode', () {
        final operations = [TextInsert('Welcome')];
        final d1 = Delta(operations: operations);
        final d2 = Delta(operations: operations);

        expect(d1 == d2, true);
        expect(d1.hashCode == d2.hashCode, true);
      });

      test('test delta', () {
        final delta = Delta(
          operations: <TextOperation>[
            TextInsert(
              'Gandalf',
              attributes: {
                'bold': true,
              },
            ),
            TextInsert(' the '),
            TextInsert(
              'Grey',
              attributes: {
                'color': '#ccc',
              },
            ),
          ],
        );

        final death = Delta()
          ..retain(12)
          ..insert(
            "White",
            attributes: {
              'color': '#fff',
            },
          )
          ..delete(4);

        final restores = delta.compose(death);
        expect(restores.toList(), <TextOperation>[
          TextInsert('Gandalf', attributes: {'bold': true}),
          TextInsert(' the '),
          TextInsert('White', attributes: {'color': '#fff'}),
        ]);
      });

      test('compose()', () {
        final a = Delta()..insert('A');
        final b = Delta()..insert('B');
        final expected = Delta()
          ..insert('B')
          ..insert('A');
        expect(a.compose(b), expected);
      });

      test('insert + retain', () {
        final a = Delta()..insert('A');
        final b = Delta()
          ..retain(
            1,
            attributes: {
              'bold': true,
              'color': 'red',
            },
          );
        final expected = Delta()
          ..insert(
            'A',
            attributes: {
              'bold': true,
              'color': 'red',
            },
          );
        expect(a.compose(b), expected);
      });

      test('insert + delete', () {
        final a = Delta()..insert('A');
        final b = Delta()..delete(1);
        final expected = Delta();
        expect(a.compose(b), expected);
      });

      test('delete + insert', () {
        final a = Delta()..delete(1);
        final b = Delta()..insert('B');
        final expected = Delta()
          ..insert('B')
          ..delete(1);
        expect(a.compose(b), expected);
      });

      test('delete + retain', () {
        final a = Delta()..delete(1);
        final b = Delta()
          ..retain(
            1,
            attributes: {
              'bold': true,
              'color': 'red',
            },
          );
        final expected = Delta()
          ..delete(1)
          ..retain(
            1,
            attributes: {
              'bold': true,
              'color': 'red',
            },
          );
        expect(a.compose(b), expected);
      });

      test('delete + delete', () {
        final a = Delta()..delete(1);
        final b = Delta()..delete(1);
        final expected = Delta()..delete(2);
        expect(a.compose(b), expected);
      });

      test('retain + insert', () {
        final a = Delta()..retain(1, attributes: {'color': 'blue'});
        final b = Delta()..insert('B');
        final expected = Delta()
          ..insert('B')
          ..retain(
            1,
            attributes: {
              'color': 'blue',
            },
          );
        expect(a.compose(b), expected);
      });

      test('retain + retain', () {
        final a = Delta()
          ..retain(
            1,
            attributes: {
              'color': 'blue',
            },
          );
        final b = Delta()
          ..retain(
            1,
            attributes: {
              'bold': true,
              'color': 'red',
            },
          );
        final expected = Delta()
          ..retain(
            1,
            attributes: {
              'bold': true,
              'color': 'red',
            },
          );
        expect(a.compose(b), expected);
      });

      test('retain + delete', () {
        final a = Delta()
          ..retain(
            1,
            attributes: {
              'color': 'blue',
            },
          );
        final b = Delta()..delete(1);
        final expected = Delta()..delete(1);
        expect(a.compose(b), expected);
      });

      test('insert in middle of text', () {
        final a = Delta()..insert('Hello');
        final b = Delta()
          ..retain(3)
          ..insert('X');
        final expected = Delta()..insert('HelXlo');
        expect(a.compose(b), expected);
      });

      test('insert and delete ordering', () {
        final a = Delta()..insert('Hello');
        final b = Delta()..insert('Hello');
        final insertFirst = Delta()
          ..retain(3)
          ..insert('X')
          ..delete(1);
        final deleteFirst = Delta()
          ..retain(3)
          ..delete(1)
          ..insert('X');
        final expected = Delta()..insert('HelXo');
        expect(a.compose(insertFirst), expected);
        expect(b.compose(deleteFirst), expected);
      });

      test('delete entire text', () {
        final a = Delta()
          ..retain(4)
          ..insert('Hello');
        final b = Delta()..delete(9);
        final expected = Delta()..delete(4);
        expect(a.compose(b), expected);
      });

      test('retain more than length of text', () {
        final a = Delta()..insert('Hello');
        final b = Delta()..retain(10);
        final expected = Delta()..insert('Hello');
        expect(a.compose(b), expected);
      });

      test('retain start optimization', () {
        final a = Delta()
          ..insert('A', attributes: {'bold': true})
          ..insert('B')
          ..insert('C', attributes: {'bold': true})
          ..delete(1);
        final b = Delta()
          ..retain(3)
          ..insert('D');
        final expected = Delta()
          ..insert('A', attributes: {'bold': true})
          ..insert('B')
          ..insert('C', attributes: {'bold': true})
          ..insert('D')
          ..delete(1);
        expect(a.compose(b), expected);
      });

      test('retain end optimization', () {
        final a = Delta()
          ..insert('A', attributes: {'bold': true})
          ..insert('B')
          ..insert('C', attributes: {'bold': true});
        final b = Delta()..delete(1);
        final expected = Delta()
          ..insert('B')
          ..insert('C', attributes: {'bold': true});
        expect(a.compose(b), expected);
      });

      test('retain end optimization join', () {
        final a = Delta()
          ..insert('A', attributes: {'bold': true})
          ..insert('B')
          ..insert('C', attributes: {'bold': true})
          ..insert('D')
          ..insert('E', attributes: {'bold': true})
          ..insert('F');
        final b = Delta()
          ..retain(1)
          ..delete(1);
        final expected = Delta()
          ..insert('AC', attributes: {'bold': true})
          ..insert('D')
          ..insert('E', attributes: {'bold': true})
          ..insert('F');
        expect(a.compose(b), expected);
      });
    });

    group('invert', () {
      test('insert', () {
        final delta = Delta()
          ..retain(2)
          ..insert('A');
        final base = Delta()..insert('12346');
        final expected = Delta()
          ..retain(2)
          ..delete(1);
        final inverted = delta.invert(base);
        expect(expected, inverted);
        expect(base.compose(delta).compose(inverted), base);
      });

      test('delete', () {
        final delta = Delta()
          ..retain(2)
          ..delete(3);
        final base = Delta()..insert('123456');
        final expected = Delta()
          ..retain(2)
          ..insert('345');
        final inverted = delta.invert(base);
        expect(expected, inverted);
        expect(base.compose(delta).compose(inverted), base);
      });

      test('retain', () {
        final delta = Delta()
          ..retain(2)
          ..retain(3, attributes: {'bold': true});
        final base = Delta()..insert('123456');
        final expected = Delta()
          ..retain(2)
          ..retain(3, attributes: {'bold': null});
        final inverted = delta.invert(base);
        expect(expected, inverted);
        final t = base.compose(delta).compose(inverted);
        expect(t, base);
      });
    });

    group('json', () {
      test('toJson()', () {
        final delta = Delta()
          ..retain(2)
          ..insert('A')
          ..delete(3);
        expect(delta.toJson(), [
          {'retain': 2},
          {'insert': 'A'},
          {'delete': 3},
        ]);
      });

      test('attributes', () {
        final delta = Delta()
          ..retain(2, attributes: {'bold': true})
          ..insert('A', attributes: {'italic': true});
        expect(delta.toJson(), [
          {
            'retain': 2,
            'attributes': {'bold': true},
          },
          {
            'insert': 'A',
            'attributes': {'italic': true},
          },
        ]);
      });

      test('fromJson()', () {
        final delta = Delta.fromJson([
          {'retain': 2},
          {'insert': 'A'},
          {'delete': 3},
        ]);
        final expected = Delta()
          ..retain(2)
          ..insert('A')
          ..delete(3);
        expect(delta, expected);
      });
    });

    group('runes', () {
      test('emoji next rune', () {
        const text = '😊👫👩‍👩‍👧‍👧👨‍👨‍👧👩‍👧🧑‍🚀'; // 6 emojis
        final delta = Delta()..insert(text);
        final pos = [0];
        for (var i = 0; i < 6; i++) {
          pos.add(delta.nextRunePosition(pos.last));
        }
        expect(pos, [0, 2, 4, 15, 23, 28, 33]);
      });

      test('text next rune', () {
        const text = 'Hello你好こんにちは안녕하세요';
        final delta = Delta()..insert(text);
        var pos = 0;
        for (var i = 0; i < text.length; i++) {
          expect(pos, i);
          pos = delta.nextRunePosition(pos);
        }
        expect(pos, text.length);
      });

      test('emoji previous rune', () {
        const text = '😊👫👩‍👩‍👧‍👧👨‍👨‍👧👩‍👧🧑‍🚀'; // 6 emojis
        final delta = Delta()..insert(text);
        final pos = [text.length];
        for (var i = 0; i < 6; i++) {
          pos.add(delta.prevRunePosition(pos.last));
        }
        expect(pos.reversed, [0, 2, 4, 15, 23, 28, 33]);
      });

      test('text previous rune', () {
        const text = 'Hello你好こんにちは안녕하세요';
        final delta = Delta()..insert(text);
        var pos = text.length;
        for (var i = text.length; i > 0; i--) {
          expect(pos, i);
          pos = delta.prevRunePosition(pos);
        }
        expect(pos, 0);
      });

      test("next rune 1", () {
        final delta = Delta()..insert('😊');
        expect(delta.nextRunePosition(0), 2);
      });

      test("next rune 2", () {
        final delta = Delta()..insert('😊a');
        expect(delta.nextRunePosition(0), 2);
      });

      test("next rune 3", () {
        final delta = Delta()..insert('😊陈');
        expect(delta.nextRunePosition(2), 3);
      });

      test("next rune 4", () {
        final delta = Delta()..insert('😊陈');
        expect(delta.nextRunePosition(2), 3);
      });

      test("prev rune 1", () {
        final delta = Delta()..insert('😊陈');
        expect(delta.prevRunePosition(2), 0);
      });

      test("prev rune 2", () {
        final delta = Delta()..insert('😊');
        expect(delta.prevRunePosition(2), 0);
      });

      test("prev rune 3", () {
        final delta = Delta()..insert('😊');
        expect(delta.prevRunePosition(0), -1);
      });
    });

    group("attributes", () {
      test("compose", () {
        final attrs =
            composeAttributes({'a': null}, {'b': null}, keepNull: true);
        expect(attrs != null, true);
        expect(attrs?.containsKey("a"), true);
        expect(attrs?.containsKey("b"), true);
        expect(attrs?["a"], null);
        expect(attrs?["b"], null);
      });
    });

    group('diff', () {
      test('diff1', () {
        final a = Delta()..insert('Hello');
        final b = Delta()..insert('Hello!');
        final diff = a.diff(b);
        expect(a.compose(diff), b);
      });

      test('diff2', () {
        final delta = Delta()
          ..insert('Gandalf', attributes: {'bold': true})
          ..insert(' the ')
          ..insert('Grey', attributes: {'color': '#ccc'});
        final death = Delta()
          ..retain(12)
          ..insert('White', attributes: {'color': '#ccc'})
          ..delete(4);
        final restored = delta.compose(death);
        expect(
          restored,
          Delta()
            ..insert('Gandalf', attributes: {'bold': true})
            ..insert(' the ')
            ..insert('White', attributes: {'color': '#ccc'}),
        );
        final diff = delta.diff(restored);
        expect(delta.compose(diff), restored);
      });
    });
  });
}

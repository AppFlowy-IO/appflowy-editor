import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('documemnt.dart', () {
    test('insert', () {
      final document = Document.blank();

      expect(document.insert([-1], []), false);
      expect(document.insert([100], []), false);

      final node0 = Node(type: '0');
      final node1 = Node(type: '1');
      final node2 = Node(type: '2');
      expect(document.insert([0], [node0, node1]), true);
      expect(document.nodeAtPath([0])?.type, '0');
      expect(document.nodeAtPath([1])?.type, '1');

      // Insert with an existing node at path
      expect(document.insert([0], [node2]), true);
      expect(document.nodeAtPath([0])?.type, '2');
      expect(document.nodeAtPath([1])?.type, '0');
      expect(document.nodeAtPath([2])?.type, '1');
    });

    test('delete', () {
      final document = Document(root: Node(type: 'root'));

      expect(document.delete([-1], 1), false);
      expect(document.delete([100], 1), false);

      for (var i = 0; i < 10; i++) {
        final node = Node(type: '$i');
        document.insert([i], [node]);
      }

      document.delete([0], 10);
      expect(document.root.children.isEmpty, true);
    });

    test('update', () {
      final firstRootAttr = {'b': 'c'};

      final node = Node(type: 'example', attributes: {'a': 'a'});
      final document =
          Document(root: Node(type: 'root', attributes: firstRootAttr));
      document.insert([0], [node]);

      final rootAttributes = {'b': 'b'};
      final attributes = {'a': 'b', 'b': 'c'};

      // If path is empty, should update attributes of root node
      expect(document.nodeAtPath([])?.attributes, firstRootAttr);
      expect(document.update([], rootAttributes), true);
      expect(document.nodeAtPath([])?.attributes, rootAttributes);

      expect(document.update([0], attributes), true);
      expect(document.nodeAtPath([0])?.attributes, attributes);

      expect(document.update([-1], attributes), false);
    });

    test('updateText', () {
      final delta = Delta()..insert('Editor');
      final textNode = paragraphNode(delta: delta);
      final document = Document.blank();
      document.insert([0], [textNode]);
      document.updateText([0], Delta()..insert('AppFlowy'));
      expect(
        document.nodeAtPath([0])?.delta?.toPlainText(),
        'AppFlowyEditor',
      );
    });

    test('serialize', () {
      final json = {
        'document': {
          'type': 'editor',
          'children': [
            {'type': 'text'},
          ],
          'data': {'a': 'a'},
        },
      };
      final document = Document.fromJson(json);
      expect(document.toJson(), json);
    });

    test('isEmpty', () {
      expect(
        true,
        Document.fromJson({
          'document': {
            'type': 'page',
            'children': [
              {
                'type': 'paragraph',
                'data': {
                  'delta': [],
                },
              }
            ],
          },
        }).isEmpty,
      );

      expect(
        true,
        Document.fromJson({
          'document': {
            'type': 'page',
            'children': [],
          },
        }).isEmpty,
      );

      expect(
        true,
        Document.fromJson({
          'document': {
            'type': 'page',
            'children': [
              {
                'type': 'paragraph',
                'data': {
                  'delta': [
                    {'insert': ''},
                  ],
                },
              }
            ],
          },
        }).isEmpty,
      );

      expect(
        false,
        Document.fromJson({
          'document': {
            'type': 'page',
            'children': [
              {
                'type': 'paragraph',
                'data': {
                  'delta': [
                    {'insert': 'Welcome to AppFlowy!'},
                  ],
                },
              }
            ],
          },
        }).isEmpty,
      );
    });
  });

  test('first', () {
    const firstLine = 'Welcome to AppFlowy!';

    final document = Document.fromJson({
      'document': {
        'type': 'page',
        'children': [
          {
            'type': 'paragraph',
            'data': {
              'delta': [
                {'insert': firstLine},
              ],
            },
          }
        ],
      },
    });

    final first = document.first;

    expect(first!.delta!.toPlainText(), firstLine);
  });

  test('last', () {
    const firstLine = 'Welcome to AppFlowy!';
    const firstChild = 'Hello';
    const secondChild = 'World';

    final document = Document.fromJson({
      'document': {
        'type': 'page',
        'children': [
          {
            'type': 'paragraph',
            'data': {
              'delta': [
                {'insert': firstLine},
              ],
            },
            'children': [
              {
                'type': 'paragraph',
                'data': {
                  'delta': [
                    {'insert': firstChild},
                  ],
                },
              },
              {
                'type': 'paragraph',
                'data': {
                  'delta': [
                    {'insert': secondChild},
                  ],
                },
              }
            ],
          }
        ],
      },
    });

    final last = document.last!;
    expect(last.delta!.toPlainText(), secondChild);
  });
}

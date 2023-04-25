import 'package:appflowy_editor/appflowy_editor.dart';

import 'delta_builder_util.dart';

typedef NodeDecorator = void Function(int index, Node node);

extension DocumentExtension on Document {
  Document combineParagraphs(
    int count, {
    DeltaBuilder? builder,
    NodeDecorator? decorator,
  }) {
    final builder0 = builder ??
        (index) => Delta()
          ..insert(
            '🔥 $index. Welcome to AppFlowy Editor!',
          );
    final decorator0 = decorator ?? (index, node) {};
    return this
      ..insert(
        [root.children.length],
        List.generate(count, (index) {
          final node = Node(type: 'paragraph');
          decorator0(index, node);
          node.updateAttributes({
            'delta': builder0(index).toJson(),
          });
          return node;
        }),
      );
  }
}

import 'package:appflowy_editor/appflowy_editor.dart';

import 'typedef_util.dart';

extension NodeExtension on Node {
  void addParagraphs(
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
    final nodes = List.generate(
      count,
      (index) {
        final node = Node(type: 'paragraph');
        decorator0(index, node);
        node.updateAttributes({
          'delta': builder0(index).toJson(),
        });
        return node;
      },
    );
    nodes.forEach(insert);
  }
}

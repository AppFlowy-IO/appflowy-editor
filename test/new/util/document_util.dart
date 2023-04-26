import 'package:appflowy_editor/appflowy_editor.dart';

import 'typedef_util.dart';

extension DocumentExtension on Document {
  Document addParagraphs(
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
    final children = List.generate(count, (index) {
      final node = Node(type: 'paragraph');
      decorator0(index, node);
      node.updateAttributes({
        'delta': builder0(index).toJson(),
      });
      return node;
    });
    return this
      ..insert(
        [root.children.length],
        children,
      );
  }
}

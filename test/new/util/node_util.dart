import 'package:appflowy_editor/appflowy_editor.dart';

import 'typedef_util.dart';

extension NodeExtension on Node {
  void addParagraphs(
    int count, {
    TextBuilder? builder,
    String? initialText,
    NodeDecorator? decorator,
  }) {
    final builder0 = builder ??
        (index) => initialText ?? '🔥 $index. Welcome to AppFlowy Editor!';
    final decorator0 = decorator ?? (index, node) {};
    final nodes = List.generate(
      count,
      (index) {
        final node = Node(type: 'paragraph');
        decorator0(index, node);
        node.updateAttributes({
          'delta': (Delta()..insert(builder0(index))).toJson(),
        });
        return node;
      },
    );
    nodes.forEach(insert);
  }

  void addParagraph({
    TextBuilder? builder,
    String? initialText,
    NodeDecorator? decorator,
  }) {
    addParagraphs(
      1,
      builder: builder,
      initialText: initialText,
      decorator: decorator,
    );
  }
}

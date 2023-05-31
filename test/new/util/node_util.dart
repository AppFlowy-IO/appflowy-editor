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
        (index) => Delta()
          ..insert(initialText ?? '🔥 $index. Welcome to AppFlowy Editor!');
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

  bool everyAttributeValue(
    Selection selection,
    String key,
    bool Function(dynamic value) test,
  ) {
    return allSatisfyInSelection(
      selection,
      (delta) => delta.whereType<TextInsert>().every(
            (element) => test(element.attributes?[key]),
          ),
    );
  }

  bool allBold(Selection selection) =>
      everyAttributeValue(selection, 'bold', (value) => value == true);
  bool allItalic(Selection selection) =>
      everyAttributeValue(selection, 'italic', (value) => value == true);
  bool allCode(Selection selection) =>
      everyAttributeValue(selection, 'code', (value) => value == true);
  bool allStrikethrough(Selection selection) =>
      everyAttributeValue(selection, 'strikethrough', (value) => value == true);
  bool allUnderline(Selection selection) =>
      everyAttributeValue(selection, 'underline', (value) => value == true);
}

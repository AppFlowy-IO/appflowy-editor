import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

enum MarkdownListType {
  ordered,
  unordered,
  unknown,
}

List<Node> parseElementChildren(
  List<md.Node>? elementChildren,
  List<CustomMarkdownParser> parsers, {
  MarkdownListType listType = MarkdownListType.unknown,
  // in case of ordered list, the start number of the list items may not start from 1
  int? startNumber,
}) {
  final List<Node> children = [];

  if (elementChildren == null || elementChildren.isEmpty) {
    return children;
  }

  // Ordered list items must be numbered sequentially. Previously every
  // item received the same start number, so a decoded list lost its
  // numbering and re-encoded as 1, 1, 1, ... instead of 1, 2, 3, ...
  var orderedIndex = 0;

  for (final child in elementChildren) {
    for (final parser in parsers) {
      final nodes = parser.transform(
        child,
        parsers,
        listType: listType,
        startNumber: listType == MarkdownListType.ordered
            ? (startNumber ?? 1) + orderedIndex
            : startNumber,
      );

      if (nodes.isNotEmpty) {
        children.addAll(nodes);
        if (listType == MarkdownListType.ordered) {
          orderedIndex++;
        }
        break;
      }
    }
  }

  return children;
}

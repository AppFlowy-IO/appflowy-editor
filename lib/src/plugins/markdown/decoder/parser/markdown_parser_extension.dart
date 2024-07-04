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

  for (final child in elementChildren) {
    for (final parser in parsers) {
      final nodes = parser.transform(
        child,
        parsers,
        listType: listType,
        startNumber: startNumber,
      );

      if (nodes.isNotEmpty) {
        children.addAll(nodes);
        break;
      }
    }
  }

  return children;
}

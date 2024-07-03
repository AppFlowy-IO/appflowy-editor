import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:markdown/markdown.dart' as md;

enum MarkdownListType {
  ordered,
  unordered,
  unknown,
}

List<Node> parseElementChildren(
  List<md.Node>? elementChildren,
  List<CustomMarkdownElementParser> parsers, {
  MarkdownListType listType = MarkdownListType.unknown,
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
        listType,
      );

      if (nodes.isNotEmpty) {
        children.addAll(nodes);
        break;
      }
    }
  }

  debugPrint('children: $children');

  return children;
}

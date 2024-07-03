import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:markdown/markdown.dart' as md;

List<Node> parseElementChildren(
  List<md.Node>? elementChildren,
  List<CustomMarkdownElementParser> parsers,
) {
  final List<Node> children = [];

  if (elementChildren == null || elementChildren.isEmpty) {
    return children;
  }

  for (final child in elementChildren) {
    for (final parser in parsers) {
      final nodes = parser.transform(child, parsers);
      if (nodes.isNotEmpty) {
        children.addAll(nodes);
        break;
      }
    }
  }

  debugPrint('children: $children');

  return children;
}

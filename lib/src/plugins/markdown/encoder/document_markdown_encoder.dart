import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';

class DocumentMarkdownEncoder extends Converter<Document, String> {
  DocumentMarkdownEncoder({
    this.parsers = const [],
  });

  final List<NodeParser> parsers;

  @override
  String convert(Document input) {
    final buffer = StringBuffer();
    for (final node in input.root.children) {
      NodeParser? parser = parsers.firstWhereOrNull(
        (element) => element.id == node.type,
      );
      if (parser != null) {
        buffer.write(parser.transform(node, this));
      }
    }
    return buffer.toString();
  }

  String convertNodes(
    List<Node> nodes, {
    bool withIndent = false,
  }) {
    final result = convert(Document(root: pageNode(children: nodes)));
    if (result.isNotEmpty && withIndent) {
      return result
          .split('\n')
          .map((e) => e.isNotEmpty ? '\t$e' : e)
          .join('\n');
    }
    return result;
  }
}

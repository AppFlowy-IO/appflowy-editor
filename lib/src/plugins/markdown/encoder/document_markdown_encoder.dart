import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';

class DocumentMarkdownEncoder extends Converter<Document, String> {
  DocumentMarkdownEncoder({
    this.parsers = const [],
    this.lineBreak = '',
  });

  final List<NodeParser> parsers;
  final String lineBreak;

  @override
  String convert(Document input) {
    final buffer = StringBuffer();
    for (final node in input.root.children) {
      NodeParser? parser = parsers.firstWhereOrNull(
        (element) => element.id == node.type,
      );
      if (parser != null) {
        buffer.write(parser.transform(node, this));
        if (lineBreak.isNotEmpty && node.id != input.root.children.last.id) {
          buffer.write(lineBreak);
        }
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

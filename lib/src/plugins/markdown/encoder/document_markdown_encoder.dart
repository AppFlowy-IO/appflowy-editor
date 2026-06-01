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
  final Map<String, int> _numberedListNumbers = {};

  int? numberedListNumberFor(Node node) => _numberedListNumbers[node.id];

  int _numberedListStartFor(Node node, int fallback) {
    final number = node.attributes[NumberedListBlockKeys.number];
    if (number is int) {
      return number;
    }
    if (number is String) {
      return int.tryParse(number) ?? fallback;
    }
    return fallback;
  }

  @override
  String convert(Document input) {
    final buffer = StringBuffer();
    var nextNumberedListNumber = 1;
    var previousWasNumberedList = false;
    for (final node in input.root.children) {
      if (node.type == NumberedListBlockKeys.type) {
        final number = previousWasNumberedList
            ? nextNumberedListNumber
            : _numberedListStartFor(node, 1);
        _numberedListNumbers[node.id] = number;
        nextNumberedListNumber = number + 1;
        previousWasNumberedList = true;
      } else {
        nextNumberedListNumber = 1;
        previousWasNumberedList = false;
      }

      NodeParser? parser = parsers.firstWhereOrNull(
        (element) => element.id == node.type,
      );
      if (parser != null) {
        buffer.write(parser.transform(node, this));
        if (lineBreak.isNotEmpty && node.id != input.root.children.last.id) {
          buffer.write(lineBreak);
        }
      }
      _numberedListNumbers.remove(node.id);
    }

    return buffer.toString();
  }

  String convertNodes(
    List<Node> nodes, {
    bool withIndent = false,
  }) {
    final result = convert(
      Document(root: pageNode(children: nodes.map((n) => n.deepCopy()))),
    );
    if (result.isNotEmpty && withIndent) {
      return result
          .split('\n')
          .map((e) => e.isNotEmpty ? '\t$e' : e)
          .join('\n');
    }

    return result;
  }
}

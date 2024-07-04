import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/custom_syntaxes/underline_syntax.dart';
import 'package:collection/collection.dart';
import 'package:markdown/markdown.dart' as md;

class DocumentMarkdownDecoder extends Converter<String, Document> {
  DocumentMarkdownDecoder({
    this.markdownElementParsers = const [],
    this.inlineSyntaxes = const [],
  });

  final List<CustomMarkdownParser> markdownElementParsers;
  final List<md.InlineSyntax> inlineSyntaxes;

  @override
  Document convert(String input) {
    final List<md.Node> mdNodes = md.Document(
      extensionSet: md.ExtensionSet.gitHubWeb,
      inlineSyntaxes: [
        ...inlineSyntaxes,
        UnderlineInlineSyntax(),
      ],
    ).parse(input);
    final document = Document.blank();

    final nodes = mdNodes
        .map((mdNode) => _parseNode(mdNode))
        .toList()
        .whereNotNull()
        .toList()
        .flattened;

    if (nodes.isNotEmpty) {
      document.insert([0], nodes);
    }

    return document;
  }

  // handle node itself and its children
  List<Node> _parseNode(md.Node mdNode) {
    List<Node> nodes = [];

    for (final parser in markdownElementParsers) {
      nodes = parser.transform(
        mdNode,
        markdownElementParsers,
        MarkdownListType.unknown,
      );

      if (nodes.isNotEmpty) {
        break;
      }
    }

    if (nodes.isEmpty) {
      Log.editor.debug(
        'empty result from node: $mdNode, text: ${mdNode.textContent}',
      );
    }

    return nodes;
  }
}

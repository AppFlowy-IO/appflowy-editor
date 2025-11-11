import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/custom_syntaxes/underline_syntax.dart';
import 'package:collection/collection.dart';
import 'package:markdown/markdown.dart' as md;

import 'custom_syntaxes/formula_syntax.dart';

class DocumentMarkdownDecoder extends Converter<String, Document> {
  DocumentMarkdownDecoder({
    this.markdownElementParsers = const [],
    this.inlineSyntaxes = const [],
  });

  final List<CustomMarkdownParser> markdownElementParsers;
  final List<md.InlineSyntax> inlineSyntaxes;

  @override
  Document convert(String input) {
    final formattedMarkdown = _formatMarkdown(input);
    final List<md.Node> mdNodes = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [
        ...inlineSyntaxes,
        FormulaInlineSyntax(),
        UnderlineInlineSyntax(),
      ],
      encodeHtml: false,
    ).parse(formattedMarkdown);

    final document = Document.blank();
    final nodes = mdNodes
        .map((e) => _parseNode(e))
        .nonNulls
        .flattened
        .toList(growable: false); // avoid lazy evaluation
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
      );

      if (nodes.isNotEmpty) {
        break;
      }
    }

    if (nodes.isEmpty) {
      AppFlowyEditorLog.editor.debug(
        'empty result from node: $mdNode, text: ${mdNode.textContent}',
      );
    }

    return nodes;
  }

  String _formatMarkdown(String markdown) {
    // Rule 1: single '\n' between text and image, add double '\n'
    String result = markdown.replaceAllMapped(
      RegExp(r'([^\n])\n!\[([^\]]*)\]\(([^)]+)\)', multiLine: true),
      (match) {
        final text = match[1] ?? '';
        final altText = match[2] ?? '';
        final url = match[3] ?? '';
        return '$text\n\n![$altText]($url)';
      },
    );

    // Rule 2: without '\n' between text and image, add double '\n'
    result = result.replaceAllMapped(
      RegExp(r'([^\n])!\[([^\]]*)\]\(([^)]+)\)'),
      (match) => '${match[1]}\n\n![${match[2]}](${match[3]})',
    );

    // Add another rules here.

    return result;
  }
}

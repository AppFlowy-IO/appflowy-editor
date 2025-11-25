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
    String result = markdown;

    // 1. Ensure every image is *preceded* by two newlines
    //    Handles:
    //    - Inline images after text (e.g., "text ![img](url)")
    //    - List items before images
    //    - Consecutive images
    //    - Images directly at line start
    //
    //    We apply two separate rules:
    //    a) Images directly after non-newline characters
    result = result.replaceAllMapped(
      RegExp(r'([^\n])\s*!\[([^\]]*)\]\(([^)]+)\)'),
      (match) {
        final before = match[1];
        final alt = match[2];
        final url = match[3];
        return '$before\n\n![$alt]($url)';
      },
    );

    //    b) Images not preceded by a blank line
    result = result.replaceAllMapped(
      RegExp(r'(?<!\n)\s*!\[([^\]]*)\]\(([^)]+)\)'),
      (match) {
        final alt = match[1];
        final url = match[2];
        return '\n\n![$alt]($url)';
      },
    );
 
    // 2. Ensure every image is *followed* by two newlines
    //    So that next content is not inline with the image
    result = result.replaceAllMapped(
      RegExp(r'!\[[^\]]*\]\([^)]+\)(?!\n\n)'),
      (match) => '${match[0]}\n\n',
    );

    // 3. Clean up excessive newlines (e.g., \n\n\n)
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return result.trim();
  }
}

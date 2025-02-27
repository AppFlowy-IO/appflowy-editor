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
    final formattedMarkdown = _formatMarkdown(input);
    final List<md.Node> mdNodes = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      inlineSyntaxes: [
        ...inlineSyntaxes,
        UnderlineInlineSyntax(),
      ],
      encodeHtml: false,
    ).parse(formattedMarkdown);

    final List<md.Node> processedNodes = _processNodes(mdNodes);
    final document = Document.blank();
    final nodes = processedNodes
        .map((e) => _parseNode(e))
        .nonNulls
        .flattened
        .toList(growable: false); // avoid lazy evaluation
    if (nodes.isNotEmpty) {
      document.insert([0], nodes);
    }

    return document;
  }

  List<md.Node> _processNodes(List<md.Node> nodes) {
    List<md.Node> result = [];

    for (var node in nodes) {
      if (node is md.Element &&
          node.children != null &&
          node.children!.length > 1) {
        // Store image elements that need to be extracted
        List<int> imageIndices = [];

        // Find all image elements
        for (var i = 0; i < node.children!.length; i++) {
          var child = node.children![i];
          if (child is md.Element && child.tag == 'img') {
            imageIndices.add(i);
          }
        }

        if (imageIndices.isNotEmpty) {
          // Extract images from back to front to maintain correct indices
          for (var i = imageIndices.length - 1; i >= 0; i--) {
            var index = imageIndices[i];
            var imageElement = node.children!.removeAt(index);
            // Create a paragraph element containing the image
            result.add(md.Element('p', [imageElement]));
          }

          // Add the original node if it still has children
          if (node.children!.isNotEmpty) {
            result.add(node);
          }
        } else {
          result.add(node);
        }
      } else {
        result.add(node);
      }
    }

    return result;
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

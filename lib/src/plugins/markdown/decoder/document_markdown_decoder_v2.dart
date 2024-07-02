import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';
import 'package:markdown/markdown.dart' as md;

class DocumentMarkdownDecoderV2 extends Converter<String, Document> {
  DocumentMarkdownDecoderV2({
    this.markdownElementParsers = const [],
    this.inlineSyntaxes = const [],
  });

  final List<CustomMarkdownElementParser> markdownElementParsers;
  final List<md.InlineSyntax> inlineSyntaxes;

  @override
  Document convert(String input) {
    final List<md.Node> mdNodes = md.Document().parse(input);
    final document = Document.blank();

    final nodes =
        mdNodes.map((mdNode) => _parseNode(mdNode)).whereNotNull().toList();
    if (nodes.isNotEmpty) {
      document.insert([0], nodes);
    }

    return document;
  }

  // handle node itself and its children
  Node? _parseNode(md.Node mdNode) {
    Node? node;
    for (final parser in markdownElementParsers) {
      node = parser.transform(mdNode);
      if (node != null) {
        break;
      }
    }

    if (node == null) {
      return null;
    }

    // handle its children
    if (mdNode is md.Element) {
      final element = mdNode;
      final children = element.children;
      if (children != null && children.isNotEmpty) {
        for (final child in children) {
          final childNode = _parseNode(child);
          if (childNode != null) {
            node.insert(childNode);
          }
        }
      }
    }

    return node;
  }
}

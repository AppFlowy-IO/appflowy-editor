import 'package:appflowy_editor/src/core/document/node.dart';
import 'package:appflowy_editor/src/core/legacy/built_in_attribute_keys.dart';
import 'package:appflowy_editor/src/plugins/markdown/encoder/delta_markdown_encoder.dart';
import 'package:appflowy_editor/src/plugins/markdown/encoder/parser/node_parser.dart';

class TextNodeParser extends NodeParser {
  const TextNodeParser();

  @override
  String get id => 'text';

  @override
  String transform(Node node, {int level = 0}) {
    assert(node is TextNode);
    final textNode = node as TextNode;
    final markdown = DeltaMarkdownEncoder().convert(textNode.delta);
    final attributes = textNode.attributes;
    var result = markdown;
    var suffix = '\n';
    if (attributes.isNotEmpty &&
        attributes.containsKey(BuiltInAttributeKey.subtype)) {
      final subtype = attributes[BuiltInAttributeKey.subtype];
      if (node.next == null) {
        suffix = '';
      }
      if (subtype == 'heading') {
        final heading = attributes[BuiltInAttributeKey.heading];
        if (heading == 'h1') {
          result = '# $markdown';
        } else if (heading == 'h2') {
          result = '## $markdown';
        } else if (heading == 'h3') {
          result = '### $markdown';
        } else if (heading == 'h4') {
          result = '#### $markdown';
        } else if (heading == 'h5') {
          result = '##### $markdown';
        } else if (heading == 'h6') {
          result = '###### $markdown';
        }
      } else if (subtype == 'quote') {
        result = '> $markdown';
      } else if (subtype == 'code_block') {
        result = '```\n$markdown\n```';
      } else if (subtype == 'bulleted-list') {
        result = '* $markdown';
      } else if (subtype == 'number-list') {
        final number = attributes['number'];
        result = '$number. $markdown';
      } else if (subtype == 'checkbox') {
        if (attributes[BuiltInAttributeKey.checkbox] == true) {
          result = '- [x] $markdown';
        } else {
          result = '- [ ] $markdown';
        }
      }
    } else {
      if (node.next == null) {
        suffix = '';
      }
    }

    final children = textNode.children;
    for (final child in children) {
      result +=
          '\n${_indentationFromLevel(level + 1)}${transform(child, level: level + 1)}';
    }

    return '$result$suffix';
  }

  String _indentationFromLevel(int level) {
    const multiplier = 2;
    final spaces = multiplier * level;

    return ' ' * spaces;
  }
}

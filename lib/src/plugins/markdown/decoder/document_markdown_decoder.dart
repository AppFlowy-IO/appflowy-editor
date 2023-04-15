import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/table_markdown_decoder.dart';
import 'package:appflowy_editor/src/render/table/table_const.dart';

class DocumentMarkdownDecoder extends Converter<String, Document> {
  @override
  Document convert(String input) {
    final lines = input.split('\n');
    final document = Document.empty();

    int path = 0;
    for (var i = 0; i < lines.length; i++) {
      late Node node;
      if (i + 1 < lines.length &&
          TableMarkdownDecoder.isTable(lines[i], lines[i + 1])) {
        node = TableMarkdownDecoder().convert(lines.sublist(i));
      } else {
        node = _convertLineToNode(lines[i]);
      }

      document.insert([path++], [node]);
      if (node.id == kTableType) {
        i += node.attributes['rowsLen'] as int;
      }
    }

    return document;
  }

  Node _convertLineToNode(String text) {
    final decoder = DeltaMarkdownDecoder();
    // Heading Style
    if (text.startsWith('### ')) {
      return TextNode(
        delta: decoder.convert(text.substring(4)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.heading,
          BuiltInAttributeKey.heading: BuiltInAttributeKey.h3,
        },
      );
    } else if (text.startsWith('## ')) {
      return TextNode(
        delta: decoder.convert(text.substring(3)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.heading,
          BuiltInAttributeKey.heading: BuiltInAttributeKey.h2,
        },
      );
    } else if (text.startsWith('# ')) {
      return TextNode(
        delta: decoder.convert(text.substring(2)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.heading,
          BuiltInAttributeKey.heading: BuiltInAttributeKey.h1,
        },
      );
    } else if (text.startsWith('- [ ] ')) {
      return TextNode(
        delta: decoder.convert(text.substring(6)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.checkbox,
          BuiltInAttributeKey.checkbox: false,
        },
      );
    } else if (text.startsWith('- [x] ')) {
      return TextNode(
        delta: decoder.convert(text.substring(6)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.checkbox,
          BuiltInAttributeKey.checkbox: true,
        },
      );
    } else if (text.startsWith('> ')) {
      return TextNode(
        delta: decoder.convert(text.substring(2)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.quote,
        },
      );
    } else if (text.startsWith('- ') || text.startsWith('* ')) {
      return TextNode(
        delta: decoder.convert(text.substring(2)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.bulletedList,
        },
      );
    } else if (text.startsWith('> ')) {
      return TextNode(
        delta: decoder.convert(text.substring(2)),
        attributes: {
          BuiltInAttributeKey.subtype: BuiltInAttributeKey.quote,
        },
      );
    } else if (text.isNotEmpty && RegExp('^-*').stringMatch(text) == text) {
      return Node(type: 'divider');
    }

    if (text.isNotEmpty) {
      return TextNode(delta: decoder.convert(text));
    }

    return TextNode(delta: Delta());
  }
}

import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final QuillDeltaEncoder quillDeltaEncoder = QuillDeltaEncoder();

const _newLineSymbol = '\n';
const _header = 'header';
const _list = 'list';
const _orderedList = 'ordered';
const _bulletedList = 'bullet';
const _uncheckedList = 'unchecked';
const _checkedList = 'checked';
const _blockquote = 'blockquote';
const _indent = 'indent';

class QuillDeltaEncoder extends Converter<Delta, Document> {
  final Map<int, List<Node>> nestedLists = {};

  @override
  Document convert(Delta input) {
    final iterator = input.iterator;
    final document = Document.blank(withInitialText: false);

    Node node = paragraphNode();
    int index = 0;

    while (iterator.moveNext()) {
      final op = iterator.current;
      final attributes = op.attributes;
      if (op is TextInsert) {
        if (op.text == _newLineSymbol) {
          if (attributes != null) {
            node = _applyListStyleIfNeeded(node, attributes);
            node = _applyHeadingStyleIfNeeded(node, attributes);
            node = _applyBlockquoteIfNeeded(node, attributes);
            _applyIndentIfNeeded(node, attributes);
          }
          if (_isIndentBulletedList(attributes)) {
            final level = _indentLevel(attributes);
            final path = [
              ...nestedLists[level - 1]!.last.path,
              nestedLists[level]!.length - 1,
            ];
            document.insert(path, [node]);
          } else {
            document.insert([index++], [node]);
          }
          node = paragraphNode();
        } else {
          final texts = op.text.split('\n');
          if (texts.length > 1) {
            node.delta?.insert(texts[0]);
            document.insert([index++], [node]);
            node = paragraphNode(delta: Delta()..insert(texts[1]));
          } else {
            _applyStyle(node, op.text, attributes);
          }
        }
      } else {
        throw UnsupportedError('only support text insert operation');
      }
    }

    if (index == 0) {
      document.insert([index], [node]);
    }

    return document;
  }

  void _applyStyle(Node node, String text, Map<String, dynamic>? attributes) {
    final Attributes attrs = {};
    if (_containsStyle(attributes, 'strike')) {
      attrs[AppFlowyRichTextKeys.strikethrough] = true;
    }
    if (_containsStyle(attributes, 'underline')) {
      attrs[AppFlowyRichTextKeys.underline] = true;
    }
    if (_containsStyle(attributes, 'bold')) {
      attrs[AppFlowyRichTextKeys.bold] = true;
    }
    if (_containsStyle(attributes, 'italic')) {
      attrs[AppFlowyRichTextKeys.italic] = true;
    }
    final link = attributes?['link'] as String?;
    if (link != null) {
      attrs[AppFlowyRichTextKeys.href] = link;
    }
    final color = attributes?['color'] as String?;
    final colorHex = _convertColorToHexString(color);
    if (colorHex != null) {
      attrs[AppFlowyRichTextKeys.textColor] = colorHex;
    }
    final backgroundColor = attributes?['background'] as String?;
    final backgroundHex = _convertColorToHexString(backgroundColor);
    if (backgroundHex != null) {
      attrs[AppFlowyRichTextKeys.highlightColor] = backgroundHex;
    }
    node.updateAttributes({
      'delta': (node.delta?..insert(text, attributes: attrs))?.toJson(),
    });
  }

  void _applyIndentIfNeeded(Node node, Map<String, dynamic> attributes) {
    final indent = attributes[_indent] as int?;
    final list = attributes[_list] as String?;
    if (indent != null && list == null && node.delta != null) {
      node.updateAttributes({
        'delta': node.delta
            ?.compose(
              Delta()
                ..retain(0)
                ..insert('  ' * indent),
            )
            .toJson(),
      });
    }
  }

  Node _applyBlockquoteIfNeeded(Node node, Map<String, dynamic> attributes) {
    final blockquote = attributes[_blockquote] as bool?;
    if (blockquote == true) {
      return quoteNode(
        delta: node.delta,
      );
    }
    return node;
  }

  Node _applyHeadingStyleIfNeeded(Node node, Map<String, dynamic> attributes) {
    final header = attributes[_header] as int?;
    if (header == null) {
      return node;
    }
    return headingNode(
      delta: node.delta,
      level: header,
    );
  }

  // If the attributes contains the list style, then apply the list style to the node.
  Node _applyListStyleIfNeeded(Node node, Map<String, dynamic> attributes) {
    final list = attributes[_list] as String?;
    switch (list) {
      case _bulletedList:
        final bulletedList = bulletedListNode(
          delta: node.delta,
        );
        final indent = attributes[_indent] as int?;
        if (indent != null) {
          nestedLists[indent] ??= [];
          nestedLists[indent]?.add(bulletedList);
        } else {
          nestedLists.clear();
          nestedLists[0] ??= [];
          nestedLists[0]?.add(bulletedList);
        }
        return bulletedList;
      case _orderedList:
        final numberedList = numberedListNode(
          delta: node.delta,
        );
        final indent = attributes[_indent] as int?;
        if (indent != null) {
          nestedLists[indent] ??= [];
          nestedLists[indent]?.add(numberedList);
        } else {
          nestedLists.clear();
          nestedLists[0] ??= [];
          nestedLists[0]?.add(numberedList);
        }
        return numberedList;
      case _checkedList:
        final checkedList = todoListNode(
          delta: node.delta,
          checked: true,
        );
        return checkedList;
      case _uncheckedList:
        final uncheckedList = todoListNode(
          delta: node.delta,
          checked: false,
        );
        return uncheckedList;
      default:
        return node;
    }
  }

  int _indentLevel(Map? attributes) {
    final indent = attributes?['indent'] as int?;
    return indent ?? 1;
  }

  bool _isIndentBulletedList(Map<String, dynamic>? attributes) {
    final list = attributes?[_list] as String?;
    final indent = attributes?[_indent] as int?;
    return [_bulletedList, _orderedList].contains(list) && indent != null;
  }

  bool _containsStyle(Map<String, dynamic>? attributes, String key) {
    final value = attributes?[key] as bool?;
    return value == true;
  }

  String? _convertColorToHexString(String? color) {
    if (color == null) {
      return null;
    }
    if (color.startsWith('#')) {
      return '0xFF${color.substring(1)}';
    } else if (color.startsWith("rgba")) {
      List rgbaList = color.substring(5, color.length - 1).split(',');
      return Color.fromRGBO(
        int.parse(rgbaList[0]),
        int.parse(rgbaList[1]),
        int.parse(rgbaList[2]),
        double.parse(rgbaList[3]),
      ).toHex();
    }
    return null;
  }
}

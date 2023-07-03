import 'dart:convert';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter/material.dart';

class DocumentHTMLEncoder extends Converter<Document, String> {
  DocumentHTMLEncoder();

  dom.Element? _stashListContainer;
  final List<dom.Node> _result = [];
  final List<Node> nodes = [];
  @override
  String convert(Document input) {
    List<Node> documentNodes = input.root.children.toList();
    nodes.addAll(documentNodes);
    return toHTMLString();
  }

  List<dom.Node> toHTMLNodes() {
    for (final documentNode in nodes) {
      if (documentNode.type != ImageBlockKeys.type) {
        _addTextNode(documentNode);
      } else {
        final anchor = dom.Element.tag(HTMLTags.image);
        anchor.attributes["src"] = documentNode.attributes[ImageBlockKeys.url];
        _result.add(anchor);
      }
    }
    if (_stashListContainer != null) {
      _result.add(_stashListContainer!);
      _stashListContainer = null;
    }
    return _result;
  }

  void _addTextNode(
    Node documentNode,
  ) {
    _addElement(
      documentNode,
      _textNodeToHtml(
        documentNode,
      ),
    );
  }

  void _addElement(Node documentNode, dom.Element element) {
    if (element.localName == HTMLTags.list) {
      final isNumbered = documentNode.type == NumberedListBlockKeys.type;
      _stashListContainer ??= dom.Element.tag(
        isNumbered ? HTMLTags.orderedList : HTMLTags.unorderedList,
      );
      _stashListContainer?.append(element);
    } else {
      if (_stashListContainer != null) {
        _result.add(_stashListContainer!);
        _stashListContainer = null;
      }
      _result.add(element);
    }
  }

  String toHTMLString() {
    final elements = toHTMLNodes();
    final copyString = elements.fold<String>(
      '',
      (previousValue, element) => previousValue + stringify(element),
    );
    return copyString.replaceAll("\n", "");
  }

  dom.Element _textNodeToHtml(
    Node documentNode,
  ) {
    return _deltaToHtml(
      Delta.fromJson(documentNode.attributes[ParagraphBlockKeys.delta]),
      type: documentNode.type,
      children: documentNode.children,
      attributes: documentNode.attributes,
    );
  }

  String _textDecorationsFromAttributes(Attributes attributes) {
    final List<String> textDecoration = [];
    if (attributes[BuiltInAttributeKey.strikethrough] == true) {
      textDecoration.add('line-through');
    }
    if (attributes[BuiltInAttributeKey.underline] == true) {
      textDecoration.add('underline');
    }

    return textDecoration.join(' ');
  }

  String _attributesToCssStyle(Map<String, dynamic> attributes) {
    final cssMap = <String, String>{};
    if (attributes[BuiltInAttributeKey.highlightColor] != null) {
      final color = Color(
        int.tryParse(attributes[BuiltInAttributeKey.highlightColor]) ??
            0xFFFFFFFF,
      );

      cssMap['background-color'] = color.toRgbaString();
    }
    if (attributes[BuiltInAttributeKey.textColor] != null) {
      final color = Color(
        int.parse(attributes[BuiltInAttributeKey.textColor]),
      );
      cssMap['color'] = color.toRgbaString();
    }
    if (attributes[BuiltInAttributeKey.bold] == true) {
      cssMap['font-weight'] = 'bold';
    }
    final textDecoration = _textDecorationsFromAttributes(attributes);
    if (textDecoration.isNotEmpty) {
      cssMap['text-decoration'] = textDecoration;
    }

    if (attributes[BuiltInAttributeKey.italic] == true) {
      cssMap['font-style'] = 'italic';
    }
    return _cssMapToCssStyle(cssMap);
  }

  String _cssMapToCssStyle(Map<String, String> cssMap) {
    return cssMap.entries.map((e) => '${e.key}: ${e.value}').join('; ');
  }

  dom.Element _deltaToHtml(
    Delta delta, {
    required String type,
    required Attributes attributes,
    required Iterable<Node> children,
  }) {
    final childNodes = <dom.Node>[];

    String tagName = HTMLTags.paragraph;

    if (type == BulletedListBlockKeys.type ||
        type == NumberedListBlockKeys.type) {
      tagName = HTMLTags.list;
    } else if (type == TodoListBlockKeys.type) {
      final node = dom.Element.html('<input type="checkbox" />');

      node.attributes['checked'] =
          attributes[TodoListBlockKeys.checked].toString();
      tagName = HTMLTags.checkbox;
      childNodes.add(node);
    } else if (type == HeadingBlockKeys.type) {
      if (attributes[HeadingBlockKeys.level] == 1) {
        tagName = HTMLTags.h1;
      } else if (attributes[HeadingBlockKeys.level] == 2) {
        tagName = HTMLTags.h2;
      } else if (attributes[HeadingBlockKeys.level] == 3) {
        tagName = HTMLTags.h3;
      }
    } else if (type == QuoteBlockKeys.type) {
      tagName = HTMLTags.blockQuote;
    }

    for (final op in delta) {
      if (op is TextInsert) {
        final attributes = op.attributes;
        if (attributes != null) {
          if (attributes.length == 1) {
            final element = _applyAttributes(attributes, text: op.text);
            childNodes.add(element);
          } else {
            final span = dom.Element.tag(HTMLTags.span);
            final cssString = _attributesToCssStyle(attributes);
            if (cssString.isNotEmpty) {
              span.attributes['style'] = cssString;
            }
            span.append(dom.Text(op.text));
            childNodes.add(span);
          }
        } else {
          childNodes.add(dom.Text(op.text));
        }
      }
    }
    if (children.isNotEmpty) {
      for (var node in children) {
        if (node.type != ImageBlockKeys.type) {
          childNodes.add(
            _deltaToHtml(
              node.attributes[ParagraphBlockKeys.delta],
              type: node.type,
              attributes: node.attributes,
              children: node.children,
            ),
          );
        } else {
          final anchor = dom.Element.tag(HTMLTags.image);
          anchor.attributes["src"] = node.attributes[ImageBlockKeys.url];

          childNodes.add(_insertText(HTMLTag.span, childNodes: [anchor]));
        }
      }
    }

    if (tagName == HTMLTags.blockQuote) {
      return _insertText(HTMLTag.blockQuote, childNodes: childNodes);
    } else if (tagName == HTMLTags.checkbox) {
      return _insertText(HTMLTag.div, childNodes: childNodes);
    } else if (!HTMLTags.isTopLevel(tagName)) {
      return _insertText(HTMLTag.list, childNodes: childNodes);
    } else {
      return _insertText(tagName, childNodes: childNodes);
    }
  }

  dom.Element _applyAttributes(Attributes attributes, {required String text}) {
    if (attributes[FlowyRichTextKeys.bold] == true) {
      final strong = dom.Element.tag(HTMLTags.strong);
      strong.append(dom.Text(text));
      return strong;
    } else if (attributes[FlowyRichTextKeys.underline] == true) {
      final underline = dom.Element.tag(HTMLTags.underline);
      underline.append(dom.Text(text));
      return underline;
    } else if (attributes[FlowyRichTextKeys.italic] == true) {
      final italic = dom.Element.tag(HTMLTags.italic);
      italic.append(dom.Text(text));
      return italic;
    } else if (attributes[FlowyRichTextKeys.strikethrough] == true) {
      final del = dom.Element.tag(HTMLTags.del);
      del.append(dom.Text(text));
      return del;
    } else if (attributes[FlowyRichTextKeys.code] == true) {
      final code = dom.Element.tag(HTMLTags.code);
      code.append(dom.Text(text));
      return code;
    } else if (attributes[FlowyRichTextKeys.href] != null) {
      final anchor = dom.Element.tag(HTMLTags.anchor);
      anchor.attributes['href'] = attributes[FlowyRichTextKeys.href];
      anchor.append(dom.Text(text));
      return anchor;
    } else {
      final paragraph = dom.Element.tag(HTMLTags.paragraph);

      paragraph.append(dom.Text(text));
      return paragraph;
    }
  }

  dom.Element _insertText(
    String tagName, {
    required List<dom.Node> childNodes,
  }) {
    final p = dom.Element.tag(tagName);
    for (final node in childNodes) {
      p.append(node);
    }
    return p;
  }
}

import 'dart:convert';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter/material.dart';

class DocumentHTMLEncoder extends Converter<Document, String> {
  DocumentHTMLEncoder();

  dom.Element? _stashListContainer;
  final List<dom.Node> _result = [];
  List<Node> nodes = [];
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
        anchor.attributes[HTMLTags.image] =
            documentNode.attributes[ImageBlockKeys.url];

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
      ((previousValue, element) => previousValue + stringify(element)),
    );
    return copyString.replaceAll("\n", "");
  }

  dom.Element _textNodeToHtml(
    Node documentNode,
  ) {
    String type = documentNode.type;

    return _deltaToHtml(
      Delta.fromJson(documentNode.attributes[ParagraphBlockKeys.delta]),
      type: type,
      attributes: documentNode.attributes,
    );
  }

  String _textDecorationsFromAttributes(Attributes attributes) {
    var textDecoration = <String>[];
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
    return cssMap.entries.fold('', (previousValue, element) {
      final kv = '${element.key}: ${element.value}';
      if (previousValue.isEmpty) {
        return kv;
      }
      return '$previousValue; $kv';
    });
  }

  dom.Element _deltaToHtml(
    Delta delta, {
    required String type,
    required Attributes attributes,
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
    } else if (type == BuiltInAttributeKey.heading) {
      if (attributes[HeadingBlockKeys.level] == 1) {
        tagName = HTMLTags.h1;
      } else if (attributes[HeadingBlockKeys.level] == 2) {
        tagName = HTMLTags.h2;
      } else if (attributes[HeadingBlockKeys.level] == 3) {
        tagName = HTMLTags.h3;
      }
    } else if (type == BuiltInAttributeKey.quote) {
      tagName = HTMLTags.blockQuote;
    }

    for (final op in delta) {
      if (op is TextInsert) {
        final attributes = op.attributes;
        if (attributes != null) {
          if (attributes.length == 1 &&
              attributes[BuiltInAttributeKey.bold] == true) {
            final strong = dom.Element.tag(HTMLTags.strong);
            strong.append(dom.Text(op.text));
            childNodes.add(strong);
          } else if (attributes.length == 1 &&
              attributes[BuiltInAttributeKey.underline] == true) {
            final strong = dom.Element.tag(HTMLTags.underline);
            strong.append(dom.Text(op.text));
            childNodes.add(strong);
          } else if (attributes.length == 1 &&
              attributes[BuiltInAttributeKey.italic] == true) {
            final strong = dom.Element.tag(HTMLTags.italic);
            strong.append(dom.Text(op.text));
            childNodes.add(strong);
          } else if (attributes.length == 1 &&
              attributes[BuiltInAttributeKey.strikethrough] == true) {
            final strong = dom.Element.tag(HTMLTags.del);
            strong.append(dom.Text(op.text));
            childNodes.add(strong);
          } else if (attributes.length == 1 &&
              attributes[BuiltInAttributeKey.code] == true) {
            final code = dom.Element.tag(HTMLTags.code);
            code.append(dom.Text(op.text));
            childNodes.add(code);
          } else if (attributes.length == 1 &&
              attributes[BuiltInAttributeKey.href] != null) {
            final anchor = dom.Element.tag(HTMLTags.anchor);
            anchor.attributes['href'] = attributes[BuiltInAttributeKey.href];
            anchor.append(dom.Text(op.text));
            childNodes.add(anchor);
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

    if (tagName == HTMLTags.blockQuote) {
      final p = dom.Element.tag(HTMLTags.paragraph);
      for (final node in childNodes) {
        p.append(node);
      }
      final blockQuote = dom.Element.tag(tagName);
      blockQuote.append(p);
      return blockQuote;
    } else if (tagName == HTMLTags.checkbox) {
      final p = dom.Element.tag(HTMLTags.div);
      for (final node in childNodes) {
        p.append(node);
      }

      return p;
    } else if (!HTMLTags.isTopLevel(tagName)) {
      final p = dom.Element.tag(HTMLTags.paragraph);
      for (final node in childNodes) {
        p.append(node);
      }
      final result = dom.Element.tag(HTMLTags.list);
      result.append(p);
      return result;
    } else {
      final p = dom.Element.tag(tagName);
      for (final node in childNodes) {
        p.append(node);
      }
      return p;
    }
  }
}

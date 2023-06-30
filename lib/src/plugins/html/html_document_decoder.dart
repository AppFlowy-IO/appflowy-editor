import 'dart:collection';
import 'dart:convert';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

class DocumentHTMLDecoder extends Converter<String, Document> {
  DocumentHTMLDecoder();

  @override
  Document convert(String input) {
    final document = parse(input);
    final body = document.body;
    if (body == null) {
      return Document.blank(withInitialText: false);
    }
    final nodes = _parseElement(body.nodes);
    return Document.blank(withInitialText: false)
      ..insert(
        [0],
        nodes,
      );
  }

  Iterable<Node> _parseElement(Iterable<dom.Node> domNodes) {
    final delta = Delta();
    final List<Node> nodes = [];
    for (final domNode in domNodes) {
      if (domNode is dom.Element) {
        final localName = domNode.localName;
        if (HTMLTags.formattingElements.contains(localName)) {
          final attributes = _parserFormattingElementAttributes(domNode);
          nodes.add(
            paragraphNode(
              delta: Delta()..insert(domNode.text, attributes: attributes),
            ),
          );
        } else if (HTMLTags.specialElements.contains(localName)) {
          nodes.addAll(
            _parseSpecialElements(
              domNode,
              type: ParagraphBlockKeys.type,
            ),
          );
        }
      } else if (domNode is dom.Text) {
        delta.insert(domNode.text);
      } else {
        assert(false, 'Unknown node type: $domNode');
      }
    }
    if (delta.isNotEmpty) {
      nodes.add(paragraphNode(delta: delta));
    }
    return nodes;
  }

  Iterable<Node> _parseSpecialElements(
    dom.Element element, {
    required String type,
  }) {
    final localName = element.localName;
    switch (localName) {
      case HTMLTags.h1:
        return _parseHeadingElement(element, level: 1);
      case HTMLTags.h2:
        return _parseHeadingElement(element, level: 2);
      case HTMLTags.h3:
        return _parseHeadingElement(element, level: 3);
      case HTMLTags.unorderedList:
        return _parseUnOrderListElement(element);
      case HTMLTags.orderedList:
        return _parseOrderListElement(element);
      case HTMLTags.list:
        return [
          _parseListElement(
            element,
            type: type,
          )
        ];
      case HTMLTags.paragraph:
        return _parseParagraphElement(element);
      case HTMLTags.blockQuote:
        return [_parseBlockQuoteElement(element)];
      case HTMLTags.image:
        return [_parseImageElement(element)];
      default:
        return _parseParagraphElement(element);
    }
  }

  Attributes _parserFormattingElementAttributes(
    dom.Element element,
  ) {
    final localName = element.localName;

    Attributes attributes = {};
    switch (localName) {
      case HTMLTags.bold || HTMLTags.strong:
        attributes = {FlowyRichTextKeys.bold: true};
        break;
      case HTMLTags.italic || HTMLTags.em:
        attributes = {FlowyRichTextKeys.italic: true};
        break;
      case HTMLTags.underline:
        attributes = {FlowyRichTextKeys.underline: true};
        break;
      case HTMLTags.del:
        attributes = {FlowyRichTextKeys.strikethrough: true};
        break;
      case HTMLTags.code:
        attributes = {FlowyRichTextKeys.code: true};
      case HTMLTags.span:
        final deltaAttributes = _getDeltaAttributesFromHTMLAttributes(
              element.attributes,
            ) ??
            {};
        attributes.addAll(deltaAttributes);
        break;
      case HTMLTags.anchor:
        final href = element.attributes['href'];
        if (href != null) {
          attributes = {FlowyRichTextKeys.href: href};
        }
        break;
      default:
        break;
    }
    for (final child in element.children) {
      attributes.addAll(_parserFormattingElementAttributes(child));
    }
    return attributes;
  }

  Iterable<Node> _parseHeadingElement(
    dom.Element element, {
    required int level,
  }) {
    final (delta, specialNodes) = _parseDeltaElement(element);
    return [
      headingNode(
        level: level,
        delta: delta,
      ),
      ...specialNodes
    ];
  }

  Node _parseBlockQuoteElement(dom.Element element) {
    final (delta, nodes) = _parseDeltaElement(element);
    return quoteNode(
      delta: delta,
      children: nodes,
    );
  }

  Iterable<Node> _parseUnOrderListElement(dom.Element element) {
    return element.children
        .map(
          (child) => _parseListElement(child, type: BulletedListBlockKeys.type),
        )
        .toList();
  }

  Iterable<Node> _parseOrderListElement(dom.Element element) {
    return element.children
        .map(
          (child) => _parseListElement(child, type: NumberedListBlockKeys.type),
        )
        .toList();
  }

  Node _parseListElement(
    dom.Element element, {
    required String type,
  }) {
    final (delta, node) = _parseDeltaElement(element);
    return Node(
      type: type != ParagraphBlockKeys.type ? type : BulletedListBlockKeys.type,
      children: node,
      attributes: {ParagraphBlockKeys.delta: delta.toJson()},
    );
  }

  Iterable<Node> _parseParagraphElement(dom.Element element) {
    final (delta, specialNodes) = _parseDeltaElement(element);
    return [paragraphNode(delta: delta), ...specialNodes];
  }

  Node _parseImageElement(dom.Element element) {
    final src = element.attributes['src'];
    if (src == null || src.isEmpty || !src.startsWith('http')) {
      return paragraphNode(); // return empty paragraph
    }
    // only support network image
    return imageNode(
      url: src,
    );
  }

  (Delta, Iterable<Node>) _parseDeltaElement(dom.Element element) {
    final delta = Delta();
    final nodes = <Node>[];
    final children = element.nodes.toList();
    for (final child in children) {
      if (child is dom.Element) {
        if (child.children.isNotEmpty) {
          for (final seocondChild in child.children) {
            nodes.addAll(
              _parseSpecialElements(
                seocondChild,
                type: ParagraphBlockKeys.type,
              ),
            );
          }
        } else {
          final attributes = _parserFormattingElementAttributes(child);
          delta.insert(child.text, attributes: attributes);
        }
      } else {
        delta.insert(child.text ?? '');
      }
    }
    return (delta, nodes);
  }

  Attributes? _getDeltaAttributesFromHTMLAttributes(
    LinkedHashMap<Object, String> htmlAttributes,
  ) {
    final Attributes attributes = {};
    final style = htmlAttributes['style'];
    final css = _getCssFromString(style);

    // font weight
    final fontWeight = css['font-weight'];
    if (fontWeight != null) {
      if (fontWeight == 'bold') {
        attributes[FlowyRichTextKeys.bold] = true;
      } else {
        final weight = int.tryParse(fontWeight);
        if (weight != null && weight >= 500) {
          attributes[FlowyRichTextKeys.bold] = true;
        }
      }
    }

    // decoration
    final textDecoration = css['text-decoration'];
    if (textDecoration != null) {
      final decorations = textDecoration.split(' ');
      for (final decoration in decorations) {
        switch (decoration) {
          case 'underline':
            attributes[FlowyRichTextKeys.underline] = true;
            break;
          case 'line-through':
            attributes[FlowyRichTextKeys.strikethrough] = true;
            break;
          default:
            break;
        }
      }
    }

    // background color
    final backgroundColor = css['background-color'];
    if (backgroundColor != null) {
      final highlightColor = backgroundColor.tryToColor()?.toHex();
      if (highlightColor != null) {
        attributes[FlowyRichTextKeys.highlightColor] = highlightColor;
      }
    }

    // italic
    final fontStyle = css['font-style'];
    if (fontStyle == 'italic') {
      attributes[FlowyRichTextKeys.italic] = true;
    }

    return attributes.isEmpty ? null : attributes;
  }

  Map<String, String> _getCssFromString(String? cssString) {
    final Map<String, String> result = {};
    if (cssString == null) {
      return result;
    }
    final entries = cssString.split(';');
    for (final entry in entries) {
      final tuples = entry.split(':');
      if (tuples.length < 2) {
        continue;
      }
      result[tuples[0].trim()] = tuples[1].trim();
    }
    return result;
  }
}

class HTMLTags {
  static const h1 = 'h1';
  static const h2 = 'h2';
  static const h3 = 'h3';
  static const orderedList = 'ol';
  static const unorderedList = 'ul';
  static const list = 'li';
  static const paragraph = 'p';
  static const image = 'img';
  static const anchor = 'a';
  static const italic = 'i';
  static const em = 'em';
  static const bold = 'b';
  static const underline = 'u';
  static const del = 'del';
  static const strong = 'strong';
  static const checkbox = 'input';
  static const span = 'span';
  static const code = 'code';
  static const blockQuote = 'blockquote';
  static const div = 'div';
  static const divider = 'hr';

  static List<String> formattingElements = [
    HTMLTags.anchor,
    HTMLTags.italic,
    HTMLTags.em,
    HTMLTags.bold,
    HTMLTags.underline,
    HTMLTags.del,
    HTMLTags.strong,
    HTMLTags.span,
    HTMLTags.code,
  ];

  static List<String> specialElements = [
    HTMLTags.h1,
    HTMLTags.h2,
    HTMLTags.h3,
    HTMLTags.unorderedList,
    HTMLTags.orderedList,
    HTMLTag.div,
    HTMLTags.list,
    HTMLTags.paragraph,
    HTMLTags.blockQuote,
    HTMLTags.checkbox,
    HTMLTag.image
  ];

  static bool isTopLevel(String tag) {
    return tag == h1 ||
        tag == h2 ||
        tag == h3 ||
        tag == checkbox ||
        tag == paragraph ||
        tag == div ||
        tag == blockQuote;
  }
}

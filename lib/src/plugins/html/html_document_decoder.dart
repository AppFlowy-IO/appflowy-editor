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
          Attributes attributes = _getParserFormattingElement(domNode);
          delta.insert(domNode.text, attributes: attributes);
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
    Delta? delta,
  }) {
    if (element.localName == HTMLTag.h1) {
      return [_handleHeadingElement(element, level: 1)];
    } else if (element.localName == HTMLTag.h2) {
      return [_handleHeadingElement(element, level: 2)];
    } else if (element.localName == HTMLTag.h3) {
      return [_handleHeadingElement(element, level: 3)];
    } else if (element.localName == HTMLTag.unorderedList) {
      return _parseUnOrderListElement(element);
    } else if (element.localName == HTMLTag.orderedList) {
      return _parseOrderListElement(element);
    } else if (element.localName == HTMLTag.list) {
      return _parseListElement(element, type: type);
    } else if (element.localName == HTMLTag.paragraph) {
      return [_parseParagraphElement(element)];
    } else if (element.localName == HTMLTag.image) {
      return [_handleImage(element)];
    } else if (element.localName == HTMLTag.blockQuote) {
      return [_parseBlockQuoteElement(element)];
    } else if (delta != null) {
      Attributes attributes = _getParserFormattingElement(element);
      delta.insert(element.text, attributes: attributes);
      return [];
    } else {
      return [paragraphNode(delta: Delta()..insert(element.text))];
    }
  }

  Node _handleImage(dom.Element element) {
    final src = element.attributes['src'] ?? '';
    return imageNode(
      url: src,
    );
  }

  Attributes _getParserFormattingElement(dom.Element element) {
    final localName = element.localName;
    Attributes attributes = {};
    switch (localName) {
      case HTMLTags.bold || HTMLTags.strong:
        attributes = {'bold': true};
        break;
      case HTMLTags.italic || HTMLTags.em:
        attributes = {'italic': true};
        break;
      case HTMLTags.underline:
        attributes = {'underline': true};
        break;
      case HTMLTags.del:
        attributes = {'strikethrough': true};
        break;
      case HTMLTags.code:
        attributes = {'code': true};
      case HTMLTags.span:
        attributes.addAll(
          _getDeltaAttributesFromHTMLAttributes(
                element.attributes,
              ) ??
              {},
        );
        break;
      case HTMLTags.anchor:
        final href = element.attributes['href'];
        if (href != null) {
          attributes = {
            'href': href,
          };
        }
        break;
      default:
        assert(false, 'Unknown formatting element: $element');
        break;
    }
    for (final newelement in element.children) {
      attributes.addAll(_getParserFormattingElement(newelement));
    }
    return attributes;
  }

  Node _handleHeadingElement(
    dom.Element element, {
    required int level,
  }) {
    final delta = Delta();
    final childNodes = element.nodes.toList();
    for (final child in childNodes) {
      if (child is dom.Text) {
        delta.insert(child.text);
      } else if (child is dom.Element) {
        _parseSpecialElements(
          child,
          delta: delta,
          type: HeadingBlockKeys.type,
        );
      }
    }
    return headingNode(
      level: level,
      delta: delta,
    );
  }

  Node _parseBlockQuoteElement(dom.Element element) => quoteNode(
        delta: Delta()..insert(element.text),
      );

  Iterable<Node> _parseUnOrderListElement(dom.Element element) {
    final result = <Node>[];
    for (var child in element.children) {
      result.addAll(_parseListElement(child, type: NumberedListBlockKeys.type));
    }
    return result;
  }

  Iterable<Node> _parseOrderListElement(dom.Element element) {
    final result = <Node>[];
    for (var child in element.children) {
      result.addAll(_parseListElement(child, type: NumberedListBlockKeys.type));
    }
    return result;
  }

  Iterable<Node> _parseListElement(
    dom.Element element, {
    required String type,
  }) {
    final childNodes = element.nodes.toList();
    final delta = Delta();
    for (final child in childNodes) {
      if (child is dom.Text) {
        delta.insert(child.text);
      } else if (child is dom.Element) {
        _parseSpecialElements(
          child,
          delta: delta,
          type: type,
        );
      }
    }
    return [
      Node(type: type, attributes: {ParagraphBlockKeys.delta: delta.toJson()})
    ];
  }

  Node _parseParagraphElement(dom.Element element) {
    final delta = Delta();
    final children = element.nodes.toList();

    for (final child in children) {
      if (child is dom.Element) {
        Attributes attributes = _getParserFormattingElement(child);
        delta.insert(child.text, attributes: attributes);
      } else {
        delta.insert(child.text ?? '');
      }
    }
    return paragraphNode(delta: delta);
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
        attributes['bold'] = true;
      } else {
        final weight = int.tryParse(fontWeight);
        if (weight != null && weight >= 500) {
          attributes['bold'] = true;
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
            attributes['underline'] = true;
            break;
          case 'line-through':
            attributes['strike'] = true;
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
        attributes['highlightColor'] = highlightColor;
      }
    }

    // italic
    final fontStyle = css['font-style'];
    if (fontStyle == 'italic') {
      attributes['italic'] = true;
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
    HTMLTags.list,
    HTMLTags.paragraph,
    HTMLTags.blockQuote,
  ];

  static bool isTopLevel(String tag) {
    return tag == h1 ||
        tag == h2 ||
        tag == h3 ||
        tag == paragraph ||
        tag == div ||
        tag == blockQuote;
  }
}

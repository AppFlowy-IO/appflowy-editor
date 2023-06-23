import 'dart:collection';
import 'dart:ui';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as html;

class HTMLTag {
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

  static bool isTopLevel(String tag) {
    return tag == h1 ||
        tag == h2 ||
        tag == h3 ||
        tag == paragraph ||
        tag == div ||
        tag == blockQuote;
  }
}

/// Converting the HTML to nodes
class HTMLToNodesConverter {
  final html.Document _document;

  /// This flag is used for parsing HTML pasting from Google Docs
  /// Google docs wraps the the content inside the `<b></b>` tag. It's strange.
  ///
  /// If a `<b>` element is parsing in the <p>, we regard it as as text spans.
  /// Otherwise, it's parsed as a container.
  bool _inParagraph = false;

  HTMLToNodesConverter(String htmlString) : _document = parse(htmlString);

  List<Node> toNodes() {
    final childNodes = _document.body?.nodes.toList() ?? <html.Node>[];
    return _handleContainer(childNodes);
  }

  Document toDocument() {
    final childNodes = _document.body?.nodes.toList() ?? <html.Node>[];
    return Document.fromJson({
      'document': {
        'type': 'page',
        'children': _handleContainer(childNodes).map((e) => e.toJson()).toList()
      }
    });
  }

  List<Node> _handleContainer(List<html.Node> childNodes) {
    final delta = Delta();
    final result = <Node>[];
    for (final child in childNodes) {
      if (child is html.Element) {
        if (child.localName == HTMLTag.anchor ||
            child.localName == HTMLTag.span ||
            child.localName == HTMLTag.code ||
            child.localName == HTMLTag.strong ||
            child.localName == HTMLTag.underline ||
            child.localName == HTMLTag.italic ||
            child.localName == HTMLTag.em ||
            child.localName == HTMLTag.del) {
          _handleRichTextElement(delta, child);
        } else if (child.localName == HTMLTag.bold) {
          // Google docs wraps the the content inside the `<b></b>` tag.
          // It's strange
          if (!_inParagraph) {
            result.addAll(_handleBTag(child));
          } else {
            result.add(_handleRichText(child));
          }
        } else if (child.localName == HTMLTag.blockQuote) {
          result.addAll(_handleBlockQuote(child));
        } else {
          result.addAll(_handleElement(child));
        }
      } else {
        delta.insert(child.text ?? '');
      }
    }
    if (delta.isNotEmpty) {
      result.add(paragraphNode(delta: delta));
    }
    return result;
  }

  List<Node> _handleBlockQuote(html.Element element) {
    final result = <Node>[];

    for (final child in element.nodes.toList()) {
      if (child is html.Element) {
        result.addAll(
          _handleElement(child, {'subtype': BuiltInAttributeKey.quote}),
        );
      }
    }

    return result;
  }

  List<Node> _handleBTag(html.Element element) {
    final childNodes = element.nodes;
    return _handleContainer(childNodes);
  }

  List<Node> _handleElement(
    html.Element element, [
    Map<String, dynamic>? attributes,
  ]) {
    if (element.localName == HTMLTag.h1) {
      return [_handleHeadingElement(element, 1)];
    } else if (element.localName == HTMLTag.h2) {
      return [_handleHeadingElement(element, 2)];
    } else if (element.localName == HTMLTag.h3) {
      return [_handleHeadingElement(element, 3)];
    } else if (element.localName == HTMLTag.unorderedList) {
      return _handleUnorderedList(element);
    } else if (element.localName == HTMLTag.orderedList) {
      return _handleOrderedList(element);
    } else if (element.localName == HTMLTag.list) {
      return _handleListElement(element);
    } else if (element.localName == HTMLTag.paragraph) {
      return [_handleParagraph(element, attributes)];
    } else if (element.localName == HTMLTag.image) {
      return [_handleImage(element)];
    } else if (element.localName == HTMLTag.divider) {
      return [_handleDivider()];
    } else {
      return [paragraphNode(delta: Delta()..insert(element.text))];
    }
  }

  Node _handleParagraph(
    html.Element element, [
    Map<String, dynamic>? attributes,
  ]) {
    _inParagraph = true;
    final node = _handleRichText(element, attributes);
    _inParagraph = false;
    return node;
  }

  Node _handleDivider() => paragraphNode(text: '---');

  Map<String, String> _cssStringToMap(String? cssString) {
    final result = <String, String>{};
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

  Attributes? _getDeltaAttributesFromHtmlAttributes(
    LinkedHashMap<Object, String> htmlAttributes,
  ) {
    final attrs = <String, dynamic>{};
    final styleString = htmlAttributes['style'];
    final cssMap = _cssStringToMap(styleString);

    final fontWeightStr = cssMap['font-weight'];
    if (fontWeightStr != null) {
      if (fontWeightStr == 'bold') {
        attrs[BuiltInAttributeKey.bold] = true;
      } else {
        int? weight = int.tryParse(fontWeightStr);
        if (weight != null && weight > 500) {
          attrs[BuiltInAttributeKey.bold] = true;
        }
      }
    }

    final textDecorationStr = cssMap['text-decoration'];
    if (textDecorationStr != null) {
      _assignTextDecorations(attrs, textDecorationStr);
    }

    final backgroundColorStr = cssMap['background-color'];
    final backgroundColor = backgroundColorStr == null
        ? null
        : ColorExtension2.tryFromRgbaString(backgroundColorStr);
    if (backgroundColor != null) {
      attrs[BuiltInAttributeKey.highlightColor] = backgroundColor.toHex();
    }

    if (cssMap['font-style'] == 'italic') {
      attrs[BuiltInAttributeKey.italic] = true;
    }

    return attrs.isEmpty ? null : attrs;
  }

  void _assignTextDecorations(Attributes attrs, String decorationStr) {
    final decorations = decorationStr.split(' ');
    for (final d in decorations) {
      if (d == 'line-through') {
        attrs[BuiltInAttributeKey.strikethrough] = true;
      } else if (d == 'underline') {
        attrs[BuiltInAttributeKey.underline] = true;
      }
    }
  }

  void _handleRichTextElement(Delta delta, html.Element element) {
    if (element.localName == HTMLTag.span) {
      delta.insert(
        element.text,
        attributes: _getDeltaAttributesFromHtmlAttributes(element.attributes),
      );
    } else if (element.localName == HTMLTag.anchor) {
      final hyperLink = element.attributes['href'];
      Map<String, dynamic>? attributes;
      if (hyperLink != null) {
        attributes = {'href': hyperLink};
      }
      delta.insert(element.text, attributes: attributes);
    } else if (element.localName == HTMLTag.strong ||
        element.localName == HTMLTag.bold) {
      delta.insert(element.text, attributes: {BuiltInAttributeKey.bold: true});
    } else if ([HTMLTag.em, HTMLTag.italic].contains(element.localName)) {
      delta.insert(
        element.text,
        attributes: {BuiltInAttributeKey.italic: true},
      );
    } else if (element.localName == HTMLTag.underline) {
      delta.insert(
        element.text,
        attributes: {BuiltInAttributeKey.underline: true},
      );
    } else if ([HTMLTag.italic, HTMLTag.em].contains(element.localName)) {
      delta
          .insert(element.text, attributes: {BuiltInAttributeKey.italic: true});
    } else if (element.localName == HTMLTag.del) {
      delta.insert(
        element.text,
        attributes: {BuiltInAttributeKey.strikethrough: true},
      );
    } else if (element.localName == HTMLTag.code) {
      delta.insert(element.text, attributes: {BuiltInAttributeKey.code: true});
    } else {
      delta.insert(element.text);
    }
  }

  /// A container contains a <input type='checkbox' > will
  /// be regarded as a checkbox block.
  ///
  /// A container contains a <img /> will be regarded as a image block
  Node _handleRichText(
    html.Element element, [
    Map<String, dynamic>? attributes,
  ]) {
    final image = element.querySelector(HTMLTag.image);
    if (image != null) {
      final imageNode = _handleImage(image);
      return imageNode;
    }
    final testInput = element.querySelector('input');
    bool checked = false;
    final isCheckbox =
        testInput != null && testInput.attributes['type'] == 'checkbox';
    if (isCheckbox) {
      checked = testInput.attributes.containsKey('checked') &&
          testInput.attributes['checked'] != 'false';
    }

    final delta = Delta();

    for (final child in element.nodes.toList()) {
      if (child is html.Element) {
        _handleRichTextElement(delta, child);
      } else {
        delta.insert(child.text ?? '');
      }
    }

    final subtype = attributes?['subtype'];
    if (subtype != null) {
      if (subtype == BuiltInAttributeKey.numberList) {
        return numberedListNode(delta: delta);
      } else if (subtype == BuiltInAttributeKey.bulletedList) {
        return bulletedListNode(delta: delta);
      } else if (isCheckbox) {
        return todoListNode(delta: delta, checked: checked);
      } else if (subtype == BuiltInAttributeKey.quote) {
        return quoteNode(delta: delta);
      } else {
        return paragraphNode(delta: delta);
      }
    } else {
      return paragraphNode(delta: delta);
    }
  }

  Node _handleImage(html.Element element) {
    final src = element.attributes['src'] ?? '';
    return imageNode(
      url: src,
    );
  }

  List<Node> _handleUnorderedList(html.Element element) {
    final result = <Node>[];
    for (var child in element.children) {
      result.addAll(
        _handleListElement(
          child,
          {'subtype': BuiltInAttributeKey.bulletedList},
        ),
      );
    }
    return result;
  }

  List<Node> _handleOrderedList(html.Element element) {
    final result = <Node>[];
    for (var i = 0; i < element.children.length; i++) {
      final child = element.children[i];
      result.addAll(
        _handleListElement(
          child,
          {'subtype': BuiltInAttributeKey.numberList, 'number': i + 1},
        ),
      );
    }
    return result;
  }

  Node _handleHeadingElement(
    html.Element element,
    int level,
  ) {
    return headingNode(
      level: level,
      delta: Delta()..insert(element.text),
    );
  }

  List<Node> _handleListElement(
    html.Element element, [
    Map<String, dynamic>? attributes,
  ]) {
    final result = <Node>[];
    final childNodes = element.nodes.toList();
    for (final child in childNodes) {
      if (child is html.Element) {
        result.addAll(_handleElement(child, attributes));
      }
    }
    return result;
  }
}

/// [NodesToHTMLConverter] is used to convert the nodes to HTML.
/// Can be used to copy & paste, exporting the document.
class NodesToHTMLConverter {
  final List<Node> nodes;
  final int? startOffset;
  final int? endOffset;
  final List<html.Node> _result = [];

  /// According to the W3C specs. The bullet list should be wrapped as
  ///
  /// <ul>
  ///   <li>xxx</li>
  ///   <li>xxx</li>
  ///   <li>xxx</li>
  /// </ul>
  ///
  /// This container is used to save the list elements temporarily.
  html.Element? _stashListContainer;

  NodesToHTMLConverter({
    required this.nodes,
    this.startOffset,
    this.endOffset,
  }) {
    if (nodes.isEmpty) {
      return;
    } else if (nodes.length == 1) {
      final first = nodes.first;
      if (first is TextNode) {
        nodes[0] = first.copyWith(
          delta: first.delta.slice(startOffset ?? 0, endOffset),
        );
      }
    } else {
      final first = nodes.first;
      final last = nodes.last;
      if (first is TextNode) {
        nodes[0] = first.copyWith(delta: first.delta.slice(startOffset ?? 0));
      }
      if (last is TextNode) {
        nodes[nodes.length - 1] =
            last.copyWith(delta: last.delta.slice(0, endOffset));
      }
    }
  }

  List<html.Node> toHTMLNodes() {
    for (final node in nodes) {
      if (node.type == 'text') {
        final textNode = node as TextNode;
        if (node == nodes.first) {
          _addTextNode(textNode);
        } else if (node == nodes.last) {
          _addTextNode(textNode, end: endOffset);
        } else {
          _addTextNode(textNode);
        }
      } else if (node.type == 'image') {
        final textNode = node;
        final anchor = html.Element.tag(HTMLTag.image);
        anchor.attributes['src'] = textNode.attributes['image_src'];

        _result.add(anchor);
      }
      // TODO: handle image and other blocks
    }
    if (_stashListContainer != null) {
      _result.add(_stashListContainer!);
      _stashListContainer = null;
    }
    return _result;
  }

  void _addTextNode(TextNode textNode, {int? end}) {
    _addElement(textNode, _textNodeToHtml(textNode, end: end));
  }

  void _addElement(TextNode textNode, html.Element element) {
    if (element.localName == HTMLTag.list) {
      final isNumbered =
          textNode.attributes['subtype'] == BuiltInAttributeKey.numberList;
      _stashListContainer ??= html.Element.tag(
        isNumbered ? HTMLTag.orderedList : HTMLTag.unorderedList,
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
    return copyString;
  }

  html.Element _textNodeToHtml(TextNode textNode, {int? end}) {
    String? subType = textNode.attributes['subtype'];
    String? heading = textNode.attributes['heading'];
    return _deltaToHtml(
      textNode.delta,
      subType: subType,
      heading: heading,
      end: end,
      checked: textNode.attributes['checkbox'] == true,
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
        int.parse(attributes[BuiltInAttributeKey.highlightColor]),
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

  /// Convert the rich text to HTML
  ///
  /// Use `<b>` for bold only.
  /// Use `<i>` for italic only.
  /// Use `<del>` for strikethrough only.
  /// Use `<u>` for underline only.
  ///
  /// If the text has multiple styles, use a `<span>`
  /// to mix the styles.
  ///
  /// A CSS style string is used to describe the styles.
  /// The HTML will be:
  ///
  /// ```html
  /// <span style='...'>Text</span>
  /// ```
  html.Element _deltaToHtml(
    Delta delta, {
    String? subType,
    String? heading,
    int? end,
    bool? checked,
  }) {
    if (end != null) {
      delta = delta.slice(0, end);
    }

    final childNodes = <html.Node>[];
    String tagName = HTMLTag.paragraph;

    if (subType == BuiltInAttributeKey.bulletedList ||
        subType == BuiltInAttributeKey.numberList) {
      tagName = HTMLTag.list;
    } else if (subType == BuiltInAttributeKey.checkbox) {
      final node = html.Element.html('<input type="checkbox" />');
      if (checked != null && checked) {
        node.attributes['checked'] = 'true';
      }
      childNodes.add(node);
    } else if (subType == BuiltInAttributeKey.heading) {
      if (heading == BuiltInAttributeKey.h1) {
        tagName = HTMLTag.h1;
      } else if (heading == BuiltInAttributeKey.h2) {
        tagName = HTMLTag.h2;
      } else if (heading == BuiltInAttributeKey.h3) {
        tagName = HTMLTag.h3;
      }
    } else if (subType == BuiltInAttributeKey.quote) {
      tagName = HTMLTag.blockQuote;
    }

    for (final op in delta) {
      if (op is TextInsert) {
        final attributes = op.attributes;
        if (attributes != null) {
          if (attributes.length == 1 &&
              attributes[BuiltInAttributeKey.bold] == true) {
            final strong = html.Element.tag(HTMLTag.strong);
            strong.append(html.Text(op.text));
            childNodes.add(strong);
          } else if (attributes.length == 1 &&
              attributes[BuiltInAttributeKey.underline] == true) {
            final strong = html.Element.tag(HTMLTag.underline);
            strong.append(html.Text(op.text));
            childNodes.add(strong);
          } else if (attributes.length == 1 &&
              attributes[BuiltInAttributeKey.italic] == true) {
            final strong = html.Element.tag(HTMLTag.italic);
            strong.append(html.Text(op.text));
            childNodes.add(strong);
          } else if (attributes.length == 1 &&
              attributes[BuiltInAttributeKey.strikethrough] == true) {
            final strong = html.Element.tag(HTMLTag.del);
            strong.append(html.Text(op.text));
            childNodes.add(strong);
          } else if (attributes.length == 1 &&
              attributes[BuiltInAttributeKey.code] == true) {
            final code = html.Element.tag(HTMLTag.code);
            code.append(html.Text(op.text));
            childNodes.add(code);
          } else if (attributes.length == 1 &&
              attributes[BuiltInAttributeKey.href] != null) {
            final anchor = html.Element.tag(HTMLTag.anchor);
            anchor.attributes['href'] = attributes[BuiltInAttributeKey.href];
            anchor.append(html.Text(op.text));
            childNodes.add(anchor);
          } else {
            final span = html.Element.tag(HTMLTag.span);
            final cssString = _attributesToCssStyle(attributes);
            if (cssString.isNotEmpty) {
              span.attributes['style'] = cssString;
            }
            span.append(html.Text(op.text));
            childNodes.add(span);
          }
        } else {
          childNodes.add(html.Text(op.text));
        }
      }
    }

    if (tagName == HTMLTag.blockQuote) {
      final p = html.Element.tag(HTMLTag.paragraph);
      for (final node in childNodes) {
        p.append(node);
      }
      final blockQuote = html.Element.tag(tagName);
      blockQuote.append(p);
      return blockQuote;
    } else if (!HTMLTag.isTopLevel(tagName)) {
      final p = html.Element.tag(HTMLTag.paragraph);
      for (final node in childNodes) {
        p.append(node);
      }
      final result = html.Element.tag(HTMLTag.list);
      result.append(p);
      return result;
    } else {
      final p = html.Element.tag(tagName);
      for (final node in childNodes) {
        p.append(node);
      }
      return p;
    }
  }
}

String stringify(html.Node node) {
  if (node is html.Element) {
    return node.outerHtml;
  }

  if (node is html.Text) {
    return node.text;
  }

  return '';
}

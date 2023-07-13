import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

/// A [Delta] encoder that encodes a [Delta] to Markdown.
///
/// Only support inline styles, like bold, italic, underline, strike, code.
class DeltaHtmlEncoder extends Converter<Delta, List<dom.Node>> {
  @override
  List<dom.Node> convert(Delta input) {
    final childNodes = <dom.Node>[];

    for (final op in input) {
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
    return childNodes;
  }

  dom.Element _applyAttributes(Attributes attributes, {required String text}) {
    if (attributes[AppFlowyRichTextKeys.bold] == true) {
      final strong = dom.Element.tag(HTMLTags.strong);
      strong.append(dom.Text(text));
      return strong;
    } else if (attributes[AppFlowyRichTextKeys.underline] == true) {
      final underline = dom.Element.tag(HTMLTags.underline);
      underline.append(dom.Text(text));
      return underline;
    } else if (attributes[AppFlowyRichTextKeys.italic] == true) {
      final italic = dom.Element.tag(HTMLTags.italic);
      italic.append(dom.Text(text));
      return italic;
    } else if (attributes[AppFlowyRichTextKeys.strikethrough] == true) {
      final del = dom.Element.tag(HTMLTags.del);
      del.append(dom.Text(text));
      return del;
    } else if (attributes[AppFlowyRichTextKeys.code] == true) {
      final code = dom.Element.tag(HTMLTags.code);
      code.append(dom.Text(text));
      return code;
    } else if (attributes[AppFlowyRichTextKeys.href] != null) {
      final anchor = dom.Element.tag(HTMLTags.anchor);
      anchor.attributes['href'] = attributes[AppFlowyRichTextKeys.href];
      anchor.append(dom.Text(text));
      return anchor;
    } else {
      final paragraph = dom.Element.tag(HTMLTags.paragraph);

      paragraph.append(dom.Text(text));
      return paragraph;
    }
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
}

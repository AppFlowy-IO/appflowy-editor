import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

final deltaHTMLEncoder = DeltaHTMLEncoder();

/// A [Delta] encoder that encodes a [Delta] to html.
///
/// supported nested styles.
class DeltaHTMLEncoder extends Converter<Delta, List<dom.Node>> {
  @override
  List<dom.Node> convert(Delta input) {
    return input
        .whereType<TextInsert>()
        .map(convertTextInsertToDomNode)
        .toList();
  }

  dom.Node convertTextInsertToDomNode(TextInsert textInsert) {
    final text = textInsert.text;
    final attributes = textInsert.attributes;

    if (attributes == null) {
      return dom.Text(text);
    }

    // if there is only one attribute, we can use the tag directly
    if (attributes.length == 1) {
      return convertSingleAttributeTextInsertToDomNode(text, attributes);
    }

    return convertMultipleAttributeTextInsertToDomNode(text, attributes);
  }

  dom.Element convertSingleAttributeTextInsertToDomNode(
    String text,
    Attributes attributes,
  ) {
    assert(attributes.length == 1);

    final domText = dom.Text(text);

    // href is a special case, it should be an anchor tag
    final href = attributes.href;
    if (href != null) {
      return dom.Element.tag(HTMLTags.anchor)
        ..attributes['href'] = href
        ..append(domText);
    }

    final keyToTag = {
      AppFlowyRichTextKeys.bold: HTMLTags.strong,
      AppFlowyRichTextKeys.italic: HTMLTags.italic,
      AppFlowyRichTextKeys.underline: HTMLTags.underline,
      AppFlowyRichTextKeys.strikethrough: HTMLTags.del,
      AppFlowyRichTextKeys.code: HTMLTags.code,
      null: HTMLTags.paragraph,
    };

    final tag = keyToTag[attributes.keys.first];
    return dom.Element.tag(tag)..append(domText);
  }

  dom.Element convertMultipleAttributeTextInsertToDomNode(
    String text,
    Attributes attributes,
  ) {
    //rich editor for webs do this so handling that case for href  <a href="https://www.google.com" rel="noopener noreferrer" target="_blank"><strong><em><u>demo</u></em></strong></a>
    final element = hrefEdgeCaseAttributes(text, attributes);
    if (element != null) {
      return element;
    }
    final span = dom.Element.tag(HTMLTags.span);
    final cssString = convertAttributesToCssStyle(attributes);
    if (cssString.isNotEmpty) {
      span.attributes['style'] = cssString;
    }
    span.append(dom.Text(text));
    return span;
  }

  dom.Element? hrefEdgeCaseAttributes(
    String text,
    Attributes attributes,
  ) {
    if (attributes[AppFlowyRichTextKeys.href] != null) {
      final element = dom.Element.tag(HTMLTags.anchor)
        ..attributes['href'] = attributes[AppFlowyRichTextKeys.href];
      dom.Element? newElement;
      dom.Element? appendElement;

      attributes.forEach((key, value) {
        if (key != AppFlowyRichTextKeys.href) {
          if (newElement == null) {
            newElement = convertSingleAttributeTextInsertToDomNode(
              text,
              {key: value},
            );
          } else {
            appendElement ??= convertSingleAttributeTextInsertToDomNode(
              "",
              {key: value},
            );

            if (appendElement != null) {
              appendElement = appendElement!..append(newElement!);
            } else {
              appendElement = convertSingleAttributeTextInsertToDomNode(
                "",
                {key: value},
              );
            }
          }
        }
      });
      if (appendElement != null) {
        element.append(appendElement!);
      } else if (newElement != null && appendElement == null) {
        element.append(newElement!);
      }

      return element;
    }
    return null;
  }

  String convertAttributesToCssStyle(Map<String, dynamic> attributes) {
    final cssMap = <String, String>{};

    if (attributes.bold) {
      cssMap['font-weight'] = 'bold';
    }

    if (attributes.underline) {
      cssMap['text-decoration'] = 'underline';
    } else if (attributes.strikethrough) {
      cssMap['text-decoration'] = 'line-through';
    }

    if (attributes.italic) {
      cssMap['font-style'] = 'italic';
    }

    final backgroundColor = attributes.backgroundColor;
    if (backgroundColor != null) {
      cssMap['background-color'] = backgroundColor.toRgbaString();
    }

    final color = attributes.color;
    if (color != null) {
      cssMap['color'] = color.toRgbaString();
    }

    return cssMap.entries.map((e) => '${e.key}: ${e.value}').join('; ');
  }
}

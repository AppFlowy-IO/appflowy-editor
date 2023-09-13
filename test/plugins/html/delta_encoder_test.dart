import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart' as dom;

void main() async {
  group('delta_html_encoder.dart', () {
    test('bold', () {
      final delta = Delta(
        operations: [
          TextInsert('Welcome to '),
          TextInsert(
            'AppFlowy',
            attributes: {
              BuiltInAttributeKey.bold: true,
            },
          ),
        ],
      );
      final childNodes = <dom.Node>[];
      final result = DeltaHTMLEncoder().convert(delta);

      childNodes.add(dom.Text('Welcome to '));

      final strong = dom.Element.tag(HTMLTags.strong);
      strong.append(dom.Text('AppFlowy'));
      childNodes.add(strong);

      expect(
        result.first.text,
        childNodes.first.text,
      );
      final resultelement = result.last as dom.Element;
      final expectElement = childNodes.last as dom.Element;
      expect(
        resultelement.className,
        expectElement.className,
      );
    });

    test('italic', () {
      final delta = Delta(
        operations: [
          TextInsert('Welcome to '),
          TextInsert(
            'AppFlowy',
            attributes: {
              BuiltInAttributeKey.italic: true,
            },
          ),
        ],
      );
      final childNodes = <dom.Node>[];
      final result = DeltaHTMLEncoder().convert(delta);

      childNodes.add(dom.Text('Welcome to '));

      final italic = dom.Element.tag(HTMLTags.italic);
      italic.append(dom.Text('AppFlowy'));
      childNodes.add(italic);

      expect(
        result.first.text,
        childNodes.first.text,
      );
      final resultelement = result.last as dom.Element;
      final expectElement = childNodes.last as dom.Element;
      expect(
        resultelement.className,
        expectElement.className,
      );
    });

    test('underline', () {
      final delta = Delta(
        operations: [
          TextInsert('Welcome to '),
          TextInsert(
            'AppFlowy',
            attributes: {
              BuiltInAttributeKey.underline: true,
              BuiltInAttributeKey.bold: true,
              BuiltInAttributeKey.italic: true,
              BuiltInAttributeKey.code: true,
            },
          ),
        ],
      );
      final childNodes = <dom.Node>[];
      final result = DeltaHTMLEncoder().convert(delta);

      childNodes.add(dom.Text('Welcome to '));

      final underline = dom.Element.tag(HTMLTags.underline);
      underline.append(dom.Text('AppFlowy'));
      childNodes.add(underline);

      expect(
        result.first.text,
        childNodes.first.text,
      );
      final resultelement = result.last as dom.Element;
      final expectElement = childNodes.last as dom.Element;
      expect(
        resultelement.className,
        expectElement.className,
      );
    });

    test('strikethrough', () {
      final delta = Delta(
        operations: [
          TextInsert('Welcome to '),
          TextInsert(
            'AppFlowy',
            attributes: {
              BuiltInAttributeKey.strikethrough: true,
            },
          ),
        ],
      );
      final childNodes = <dom.Node>[];
      final result = DeltaHTMLEncoder().convert(delta);

      childNodes.add(dom.Text('Welcome to '));

      final del = dom.Element.tag(HTMLTags.del);
      del.append(dom.Text('AppFlowy'));
      childNodes.add(del);

      expect(
        result.first.text,
        childNodes.first.text,
      );
      final resultelement = result.last as dom.Element;
      final expectElement = childNodes.last as dom.Element;
      expect(
        resultelement.className,
        expectElement.className,
      );
    });

    test('href', () {
      final delta = Delta(
        operations: [
          TextInsert('Welcome to '),
          TextInsert(
            'AppFlowy',
            attributes: {
              BuiltInAttributeKey.href: 'https://appflowy.io',
            },
          ),
        ],
      );
      final childNodes = <dom.Node>[];
      final result = DeltaHTMLEncoder().convert(delta);

      childNodes.add(dom.Text('Welcome to '));

      final anchor = dom.Element.tag(HTMLTags.anchor);
      anchor.attributes['href'] = "https://appflowy.io";
      anchor.append(dom.Text('AppFlowy'));

      childNodes.add(anchor);

      expect(
        result.first.text,
        childNodes.first.text,
      );
      final resultelement = result.last as dom.Element;
      final expectElement = childNodes.last as dom.Element;
      expect(
        resultelement.className,
        expectElement.className,
      );
    });

    test('code', () {
      final delta = Delta(
        operations: [
          TextInsert('Welcome to '),
          TextInsert(
            'AppFlowy',
            attributes: {
              BuiltInAttributeKey.code: true,
            },
          ),
        ],
      );
      final childNodes = <dom.Node>[];
      final result = DeltaHTMLEncoder().convert(delta);

      childNodes.add(dom.Text('Welcome to '));

      final code = dom.Element.tag(HTMLTags.code);

      code.append(dom.Text('AppFlowy'));

      childNodes.add(code);

      expect(
        result.first.text,
        childNodes.first.text,
      );
      final resultelement = result.last as dom.Element;
      final expectElement = childNodes.last as dom.Element;
      expect(
        resultelement.className,
        expectElement.className,
      );
    });

    test('composition', () {
      final delta = Delta(
        operations: [
          TextInsert(
            'Welcome',
            attributes: {
              BuiltInAttributeKey.code: true,
              BuiltInAttributeKey.italic: true,
              BuiltInAttributeKey.bold: true,
              BuiltInAttributeKey.underline: true,
            },
          ),
          TextInsert(' '),
          TextInsert(
            'to',
            attributes: {
              BuiltInAttributeKey.italic: true,
              BuiltInAttributeKey.bold: true,
              BuiltInAttributeKey.strikethrough: true,
            },
          ),
          TextInsert(' '),
          TextInsert(
            'AppFlowy',
            attributes: {
              BuiltInAttributeKey.href: 'https://appflowy.io',
              BuiltInAttributeKey.bold: true,
              BuiltInAttributeKey.italic: true,
              BuiltInAttributeKey.underline: true,
            },
          ),
        ],
      );
      final result = DeltaHTMLEncoder().convert(delta);

      expect(
        result.first.attributes.toString(),
        '''{style: font-weight: bold; text-decoration: underline; font-style: italic}''',
      );
      expect(
        result.first.text,
        "Welcome",
      );

      expect(
        result[2].attributes.toString(),
        '''{style: font-weight: bold; text-decoration: line-through; font-style: italic}''',
      );
      expect(
        result[2].text,
        "to",
      );

      expect(
        result[4].text,
        "AppFlowy",
      );
      final element = result[4] as dom.Element;
      expect(
        element.localName,
        "a",
      );

      expect(
        element.children.length,
        1,
      );
      final anchorChildElement = element.children.first;
      expect(
        anchorChildElement.localName,
        "u",
      );
      expect(
        element.children.first.children.length,
        1,
      );
      expect(
        element.children.first.children.first.localName,
        "i",
      );

      expect(
        element.children.first.children.first.children.length,
        1,
      );
      expect(
        element.children.first.children.first.children.first.localName,
        "strong",
      );

      expect(
        element.children.first.children.first.children.first.text,
        "AppFlowy",
      );
    });
  });
}

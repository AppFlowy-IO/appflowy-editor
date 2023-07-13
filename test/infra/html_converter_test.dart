import 'package:appflowy_editor/src/infra/html_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HTMLTag tests', () {
    test('isTopLevel', () {
      const topLevelTag = HTMLTag.h1;
      const nTopLevelTag = HTMLTag.strong;

      expect(HTMLTag.isTopLevel(topLevelTag), true);
      expect(HTMLTag.isTopLevel(nTopLevelTag), false);
    });
  });

  group('HTMLConverter tests', () {
    test('HTMLToNodesConverter and NodesToHTMLConverter', () {
      final fromHTMLConverter = HTMLToNodesConverter(rawHTML);
      final nodes = fromHTMLConverter.toNodes();

      expect(nodes.isNotEmpty, true);

      // final toHTMLConverter = NodesToHTMLConverter(nodes: nodes);
      // final html = toHTMLConverter.toHTMLString();

      // expect(html.isNotEmpty, true);
      // expect(html, rawHTML);
    });
  });
  group('HTMLConverterDocument tests', () {
    test('HTMLToNodesConverter', () {
      final converter = HTMLToNodesConverter(rawHTML);
      final document = converter.toDocument();

      expect(document.root.children.isNotEmpty, true);
    });
  });
}

const rawHTML = """<h1>AppFlowyEditor</h1>
<h2>👋 <strong>Welcome to</strong> <strong><em><a href="appflowy.io">AppFlowy Editor</a></em></strong></h2>
  <p>AppFlowy Editor is a <strong>highly customizable</strong> <em>rich-text editor</em></p>

<hr />

<p><u>Here</u> is an example <del>your</del> you can give a try</p>

<span style="font-weight: bold;background-color: #cccccc;font-style: italic;">Span element</span>

<span style="font-weight: medium;text-decoration: underline;">Span element two</span>

<span style="font-weight: 900;text-decoration: line-through;">Span element three</span>

<a href="https://appflowy.io">This is an anchor tag!</a>

<img src="https://images.squarespace-cdn.com/content/v1/617f6f16b877c06711e87373/c3f23723-37f4-44d7-9c5d-6e2a53064ae7/Asset+10.png?format=1500w" />

<h3>Features!</h3>

<ul>
  <li>[x] Customizable</li>
  <li>[x] Test-covered</li>
  <li>[ ] more to come!</li>
</ul>

<ol>
  <li>First item</li>
  <li>Second item</li>
</ol>

<li>List element</li>

<blockquote>
  <p>This is a quote!</p>
</blockquote>

<code>
  Code block
</code>

<em>Italic one</em> <i>Italic two</i>

<b>Bold tag</b>
<img src="http://appflowy.io" alt="AppFlowy">
<p>You can also use <strong><em>AppFlowy Editor</em></strong> as a component to build your own app.</p>
<h3>Awesome features</h3>
<p>If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!</p>
<hr>""";

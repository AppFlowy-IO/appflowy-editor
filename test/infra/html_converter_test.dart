import 'package:appflowy_editor/src/infra/html_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HTMLConverter tests', () {
    test('HTMLToNodesConverter', () {
      final converter = HTMLToNodesConverter(rawHTML);
      final nodes = converter.toNodes();

      expect(nodes.isNotEmpty, true);
    });
  });
}

const rawHTML = """<h1>AppFlowyEditor</h1>
<h2>👋 <strong>Welcome to</strong> <strong><em><a href="appflowy.io">AppFlowy Editor</a></em></strong></h2>
  <p>AppFlowy Editor is a <strong>highly customizable</strong> <em>rich-text editor</em></p>

<p>Here is an example you can give a try</p>

<span style="font-weight: bold;">Span element</span>

<span style="font-weight: medium;">Span element two</span>

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

<pre>
  <code>
    Code block
  </code>
</pre>

<b>Bold tag</b>
<img src="http://appflowy.io" alt="AppFlowy">
<p>You can also use <strong><em>AppFlowy Editor</em></strong> as a component to build your own app.</p>
<h3>Awesome features</h3>
<p>If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!</p>
<hr>""";

import 'package:markdown/markdown.dart' as md;

class TestCustomInlineSyntaxes extends md.InlineSyntax {
  TestCustomInlineSyntaxes() : super(r'\[AppFlowy Subpage\]\(.+?\)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    md.Element el = md.Element.text('mention_block', "\$");
    el.attributes['mention'] = '''{
      "type":"page",
      "page_id":"${match.group(0)}"
    }''';
    parser.addNode(el);
    return true;
  }
}

import 'package:markdown/markdown.dart' as md;

class UnderlineInlineSyntax extends md.InlineSyntax {
  UnderlineInlineSyntax() : super('<u>(.*)</u>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = parser.source.substring(match.start + 3, match.end - 4);
    List<md.Node> nestedNodes = md.InlineParser(text, parser.document).parse();
    parser.addNode(md.Element('u', nestedNodes));
    return true;
  }
}

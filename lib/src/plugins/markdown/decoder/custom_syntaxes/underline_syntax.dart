import 'package:markdown/markdown.dart' as md;

class UnderlineInlineSyntax extends md.InlineSyntax {
  UnderlineInlineSyntax() : super('<u>(.*)</u>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = match.group(1) ?? '';
    List<md.Node> nestedNodes = md.InlineParser(text, parser.document).parse();
    parser.addNode(md.Element('u', nestedNodes));
    return true;
  }
}

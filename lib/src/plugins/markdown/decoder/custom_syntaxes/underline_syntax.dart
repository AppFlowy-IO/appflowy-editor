import 'package:markdown/markdown.dart' as md;

class UnderlineInlineSyntax extends md.InlineSyntax {
  UnderlineInlineSyntax() : super('<u>(.*)<\/u>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = parser.source.substring(match.start + 3, match.end - 4);
    parser.addNode(md.Element('u', [md.Text(text)]));
    return true;
  }
}

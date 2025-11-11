import 'package:markdown/markdown.dart' as md;

class FormulaInlineSyntax extends md.InlineSyntax {
  FormulaInlineSyntax() : super(r'(?<!\$)\$(?!\$)([\s\S]+?)(?<!\$)\$(?!\$)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final formula = match.group(1);
    if (formula == null || formula.isEmpty) {
      return false;
    }

    final element = md.Element('formula', [md.Text('\$')]);
    element.attributes['formula'] = formula;
    parser.addNode(element);
    return true;
  }
}

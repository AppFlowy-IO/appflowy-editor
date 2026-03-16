import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

/// Parses markdown code blocks (indentation or fenced) into paragraphs.
/// This prevents code blocks from being dropped if the editor doesn't support them,
/// and effectively strips indentation from 4-space indented blocks (as per md spec).
class MarkdownSoftCodeBlockParser extends CustomMarkdownParser {
  const MarkdownSoftCodeBlockParser();

  @override
  List<Node> transform(
    md.Node node,
    List<CustomMarkdownParser> parsers, {
    MarkdownListType listType = MarkdownListType.unknown,
    int? startNumber,
  }) {
    if (node is md.Element && node.tag == 'pre') {
      String text = '';

      if (node.children?.isNotEmpty == true) {
        final codeNode = node.children!.first;
        if (codeNode is md.Element && codeNode.tag == 'code') {
          text = codeNode.textContent;
        } else {
          text = node.textContent;
        }
      } else {
        text = node.textContent;
      }

      // Remove trailing newline which code blocks often have
      if (text.endsWith('\n')) {
        text = text.substring(0, text.length - 1);
      }

      // Split into multiple lines and create a paragraph for each
      // This effectively "flattens" the code block into text
      final lines = text.split('\n');
      return lines.map((line) => paragraphNode(text: line)).toList();
    }
    return [];
  }
}

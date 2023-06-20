import 'dart:convert';
import 'package:appflowy_editor/appflowy_editor.dart';

class DocumentHTMLDecoder extends Converter<String, Document> {
  DocumentHTMLDecoder();

  @override
  Document convert(String input) {
    final nodes = htmlToNodes(input);
    return Document.blank(withInitialText: false)
      ..insert(
        [0],
        nodes,
      );
  }
}

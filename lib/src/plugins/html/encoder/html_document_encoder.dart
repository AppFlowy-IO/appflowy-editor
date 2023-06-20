import 'dart:convert';
import 'package:appflowy_editor/appflowy_editor.dart';

class DocumentHTMLEncoder extends Converter<Document, String> {
  DocumentHTMLEncoder();

  @override
  String convert(Document input) {
    List<Node> documentNodes = input.root.children.toList();
    return nodesToHTML(documentNodes);
  }
}

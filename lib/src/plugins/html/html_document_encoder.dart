import 'dart:convert';

import 'package:appflowy_editor/src/core/document/document.dart';

class DocumentHTMLEncoder extends Converter<Document, String> {
  DocumentHTMLEncoder();

  @override
  String convert(Document input) {
    final buffer = StringBuffer();
    return buffer.toString();
  }
}

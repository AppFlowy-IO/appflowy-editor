import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';

class DocumentHTMLEncoder extends Converter<Document, String> {
  DocumentHTMLEncoder({this.encodeParsers = const []});
  final List<HtmlNodeParser> encodeParsers;

  @override
  String convert(Document input) {
    final buffer = StringBuffer();
    for (final node in input.root.children) {
      HtmlNodeParser? parser = encodeParsers.firstWhereOrNull(
        (element) => element.id == node.type,
      );
      if (parser != null) {
        buffer.write(parser.transform(node, encodeParsers: encodeParsers));
      }
    }
    return buffer.toString();
  }
}

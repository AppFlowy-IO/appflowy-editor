import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '_samples.dart';

void main() async {
  group('document_html_decoder_test.dart', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('parse html sample 1', () async {
      // sample 1 contains h1-h3 and bold, italic, underline, strikethrough
      final result = DocumentHTMLDecoder().convert(htmlSample1);
      expect(result.toJson(), documentSample1);
    });

    test('parse html sample 2', () async {
      // sample 2 contains table
      final result = DocumentHTMLDecoder().convert(htmlSample2);
      expect(result.toJson(), documentSample2);
    });

    test('parse html sample 3', () async {
      // sample 3 contains lists
      final result = DocumentHTMLDecoder().convert(htmlSample3);
      expect(result.toJson(), documentSample3);
    });

    test('parse html sample 4', () async {
      // sample 4 contains lists
      final result = DocumentHTMLDecoder().convert(htmlSample4);
      expect(result.toJson(), documentSample4);
    });
  });
}

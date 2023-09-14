import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/table_markdown_decoder.dart';

void main() async {
  group('table_markdown_decoder.dart', () {
    test('rowBeginAndEndCheck', () {
      expect(rowBeginAndEndCheck('|  ## a|_c_|'), true);
      expect(rowBeginAndEndCheck('      ## a|_c_|'), false);
      expect(rowBeginAndEndCheck(r'    \|  ## a|_c_|'), false);
      expect(rowBeginAndEndCheck('|-|-'), false);
      expect(rowBeginAndEndCheck('      | -- |   -|'), true);
    });

    test('getCells', () {
      String line = '  |  ## a|_c_|';
      List<String> expCels = ['## a', '_c_'];
      expect(getCells(line), expCels);

      line = r'|      #\|# a|_c_| ';
      expCels = ['#|# a', '_c_'];
      expect(getCells(line), expCels);

      line = '|**b**| d|';
      expCels = ['**b**', 'd'];
      expect(getCells(line), expCels);

      line = '  |  ## a||';
      expCels = [];
      expect(getCells(line), expCels);
    });

    test('isTable', () {
      String input = '''  |  ## a| |
   | -- |   -|''';
      expect(
        TableMarkdownDecoder.isTable(
          input.split('\n')[0],
          input.split('\n')[1],
        ),
        true,
      );

      input = '''  |  ## a||
      | -- |   -|''';
      expect(
        TableMarkdownDecoder.isTable(
          input.split('\n')[0],
          input.split('\n')[1],
        ),
        false,
      );

      input = r'''|      #\|# a|_c_|
| -| -|''';
      expect(
        TableMarkdownDecoder.isTable(
          input.split('\n')[0],
          input.split('\n')[1],
        ),
        true,
      );
    });
  });
}

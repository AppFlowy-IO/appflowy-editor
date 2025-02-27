import 'package:appflowy_editor/src/editor/util/link_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('test for custom link', () {
    expect(isCustomUrL('https://www.example.com'), true);
    expect(isCustomUrL('http://example.com/path?query=123'), true);
    expect(isCustomUrL('ftp://example.com'), true);
    expect(isCustomUrL('xxx://custom-protocol.com'), true);
    expect(isCustomUrL('abc://123.456.789.0'), true);
    expect(isCustomUrL('https://example.com#anchor'), true);
    expect(isCustomUrL('obsidian://open?vault=xxx'), true);
    expect(isCustomUrL('invalid-link'), false);
    expect(isCustomUrL('://missing-protocol-prefix'), false);
    expect(isCustomUrL('example://'), false);
  });
}

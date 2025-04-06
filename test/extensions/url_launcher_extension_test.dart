import 'package:appflowy_editor/src/extensions/url_launcher_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('safeLaunchUrl without href and scheme', () async {
    const href = null;
    final result = await editorLaunchUrl(href);
    expect(result, false);
  });
}

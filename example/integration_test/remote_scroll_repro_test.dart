import 'package:example/remote_scroll_repro.dart' as app;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('remote document updates do not move the local viewport',
      (tester) async {
    app.main();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('reproduce_remote_scroll')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();

    final status = tester.widget<Text>(
      find.byKey(const ValueKey('remote_scroll_repro_status')),
    );
    expect(
      status.data,
      'No auto-scroll request was observed.',
      reason: 'A remote transaction may transform the local selection, but '
          'must not make this client follow that selection.',
    );
  });
}

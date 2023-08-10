import 'package:appflowy_editor/src/editor/editor_component/service/renderer/block_component_action.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_helper.dart';

void main() {
  group('BlockComponentActionList', () {
    testWidgets('can render', (tester) async {
      bool onTapAdd = false, onTapOption = false;

      await tester.buildAndPump(
        BlockComponentActionList(
          onTapAdd: () => onTapAdd = true,
          onTapOption: () => onTapOption = true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BlockComponentActionList), findsOneWidget);

      await tester.tap(find.byType(BlockComponentActionButton).first);
      expect(onTapAdd, true);

      await tester.tap(find.byType(BlockComponentActionButton).last);
      expect(onTapOption, true);
    });
  });
}

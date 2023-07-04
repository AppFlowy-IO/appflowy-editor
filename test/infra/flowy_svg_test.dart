import 'package:appflowy_editor/src/infra/flowy_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_helper.dart';

void main() {
  group('FlowySvg tests', () {
    testWidgets('FlowySvg w/ Name', (tester) async {
      await tester.buildAndPump(
        const EditorSvg(name: 'checkmark', color: Colors.blue),
      );

      final svgFinder = find.byType(SvgPicture);
      expect(svgFinder, findsOneWidget);

      final svgPicture = tester.widget<SvgPicture>(svgFinder);
      expect(svgPicture.fit, BoxFit.fill);
      expect(
        svgPicture.colorFilter,
        const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
      );
    });

    testWidgets('FlowySvg w/ Number', (tester) async {
      await tester.buildAndPump(
        const EditorSvg(number: 1),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('FlowySvg null', (tester) async {
      await tester.buildAndPump(
        const EditorSvg(),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(SvgPicture), findsNothing);
    });
  });
}

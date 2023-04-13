import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditorStyle tests', () {
    test('extensions', () {
      final lightExtensions = lightEditorStyleExtension;
      expect(lightExtensions.length, 1);
      expect(lightExtensions.contains(EditorStyle.light), true);

      final darkExtensions = darkEditorStyleExtension;
      expect(darkExtensions.length, 1);
      expect(darkExtensions.contains(EditorStyle.dark), true);
    });

    test('EditorStyle members', () {
      EditorStyle style = EditorStyle.light;
      expect(style.padding, isNot(EdgeInsets.zero));

      style = style.copyWith(padding: EdgeInsets.zero);
      expect(style.padding, EdgeInsets.zero);
    });

    testWidgets('EditorStyle.of not found', (tester) async {
      late BuildContext context;

      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox.shrink();
          },
        ),
      );

      expect(EditorStyle.of(context), null);
    });

    testWidgets('EditorStyle.of found', (tester) async {
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            extensions: [...lightEditorStyleExtension],
          ),
          home: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final editorStyle = EditorStyle.of(context);
      expect(editorStyle, isNotNull);
      expect(editorStyle!.backgroundColor, EditorStyle.light.backgroundColor);
    });

    test('EditorStyle.lerp', () {
      final editorStyle =
          EditorStyle.light.lerp(EditorStyle.dark, 1.0) as EditorStyle;
      expect(editorStyle.backgroundColor, EditorStyle.dark.backgroundColor);
    });
  });
}

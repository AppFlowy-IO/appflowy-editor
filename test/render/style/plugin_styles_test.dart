import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../infra/test_editor.dart';

void main() {
  group('PluginStyle tests', () {
    test('extensions', () {
      final lightExtensions = lightPluginStyleExtension;
      expect(lightExtensions.length, 5);
      expect(lightExtensions.contains(HeadingPluginStyle.light), true);

      final darkExtensions = darkPluginStyleExtension;
      expect(darkExtensions.length, 5);
      expect(darkExtensions.contains(HeadingPluginStyle.dark), true);
    });

    testWidgets('HeadingPluginStyle', (tester) async {
      final editor = tester.editor..insertTextNode('Welcome to AppFlowy');
      await editor.startTesting();

      HeadingPluginStyle style = HeadingPluginStyle.light;
      style = style.copyWith(
        padding: (_, __) => EdgeInsets.zero,
        textStyle: (_, __) => _newTextStyle,
      );

      final padding = style.padding(
        editor.editorState,
        editor.editorState.getTextNode(path: [0]),
      );
      expect(padding, EdgeInsets.zero);

      final textStyle = style.textStyle(
        editor.editorState,
        editor.editorState.getTextNode(path: [0]),
      );
      expect(textStyle, _newTextStyle);

      style = style.lerp(HeadingPluginStyle.dark, 1.0) as HeadingPluginStyle;
      expect(style.textStyle, HeadingPluginStyle.dark.textStyle);
    });

    testWidgets('CheckboxPluginStyle', (tester) async {
      final editor = tester.editor..insertTextNode('Welcome to AppFlowy');
      await editor.startTesting();

      CheckboxPluginStyle style = CheckboxPluginStyle.light;
      style = style.copyWith(
        padding: (_, __) => EdgeInsets.zero,
        textStyle: (_, __) => _newTextStyle,
      );

      final padding = style.padding(
        editor.editorState,
        editor.editorState.getTextNode(path: [0]),
      );
      expect(padding, EdgeInsets.zero);

      final textStyle = style.textStyle(
        editor.editorState,
        editor.editorState.getTextNode(path: [0]),
      );
      expect(textStyle, _newTextStyle);

      style = style.lerp(CheckboxPluginStyle.dark, 1.0) as CheckboxPluginStyle;
      expect(style.textStyle, CheckboxPluginStyle.dark.textStyle);
    });

    testWidgets('BulletedListPluginStyle', (tester) async {
      final editor = tester.editor..insertTextNode('Welcome to AppFlowy');
      await editor.startTesting();

      BulletedListPluginStyle style = BulletedListPluginStyle.light;
      style = style.copyWith(
        padding: (_, __) => EdgeInsets.zero,
        textStyle: (_, __) => _newTextStyle,
      );

      final padding = style.padding(
        editor.editorState,
        editor.editorState.getTextNode(path: [0]),
      );
      expect(padding, EdgeInsets.zero);

      final textStyle = style.textStyle(
        editor.editorState,
        editor.editorState.getTextNode(path: [0]),
      );
      expect(textStyle, _newTextStyle);

      style = style.lerp(BulletedListPluginStyle.dark, 1.0)
          as BulletedListPluginStyle;
      expect(style.textStyle, BulletedListPluginStyle.dark.textStyle);
    });

    testWidgets('NumberListPluginStyle', (tester) async {
      final editor = tester.editor..insertTextNode('Welcome to AppFlowy');
      await editor.startTesting();

      NumberListPluginStyle style = NumberListPluginStyle.light;
      style = style.copyWith(
        padding: (_, __) => EdgeInsets.zero,
        textStyle: (_, __) => _newTextStyle,
      );

      final padding = style.padding(
        editor.editorState,
        editor.editorState.getTextNode(path: [0]),
      );
      expect(padding, EdgeInsets.zero);

      final textStyle = style.textStyle(
        editor.editorState,
        editor.editorState.getTextNode(path: [0]),
      );
      expect(textStyle, _newTextStyle);

      style =
          style.lerp(NumberListPluginStyle.dark, 1.0) as NumberListPluginStyle;
      expect(style.textStyle, NumberListPluginStyle.dark.textStyle);
    });

    testWidgets('QuotedTextPluginStyle', (tester) async {
      final editor = tester.editor..insertTextNode('Welcome to AppFlowy');
      await editor.startTesting();

      QuotedTextPluginStyle style = QuotedTextPluginStyle.light;
      style = style.copyWith(
        padding: (_, __) => EdgeInsets.zero,
        textStyle: (_, __) => _newTextStyle,
      );

      final padding = style.padding(
        editor.editorState,
        editor.editorState.getTextNode(path: [0]),
      );
      expect(padding, EdgeInsets.zero);

      final textStyle = style.textStyle(
        editor.editorState,
        editor.editorState.getTextNode(path: [0]),
      );
      expect(textStyle, _newTextStyle);

      style =
          style.lerp(QuotedTextPluginStyle.dark, 1.0) as QuotedTextPluginStyle;
      expect(style.textStyle, QuotedTextPluginStyle.dark.textStyle);
    });
  });
}

const _newTextStyle = TextStyle(color: Colors.teal);

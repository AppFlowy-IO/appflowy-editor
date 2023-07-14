import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

import '../infra/testable_editor.dart';
import './typedef_util.dart';

class ArrowTest {
  String text;
  Selection initialSel;
  Selection expSel;
  NodeDecorator? decorator;

  ArrowTest({
    required this.text,
    required this.initialSel,
    required this.expSel,
    this.decorator,
  });
}

Future<void> runArrowLeftTest(
  WidgetTester tester,
  ArrowTest alt, [
  String? reason,
]) async {
  await runArrowTest(tester, alt, LogicalKeyboardKey.arrowLeft, reason);
}

Future<void> runArrowRightTest(
  WidgetTester tester,
  ArrowTest alt, [
  String? reason,
]) async {
  await runArrowTest(tester, alt, LogicalKeyboardKey.arrowRight, reason);
}

Future<void> runArrowTest(
  WidgetTester tester,
  ArrowTest alt,
  LogicalKeyboardKey arrowKey, [
  String? reason,
]) async {
  final editor = tester.editor
    ..addParagraph(initialText: alt.text, decorator: alt.decorator);
  await editor.startTesting();

  await editor.updateSelection(alt.initialSel);

  await simulateKeyDownEvent(arrowKey);
  expect(editor.selection, alt.expSel, reason: reason);

  await editor.dispose();
}

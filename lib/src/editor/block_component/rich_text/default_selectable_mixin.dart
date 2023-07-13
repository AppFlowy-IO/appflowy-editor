import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

mixin DefaultSelectableMixin {
  GlobalKey get forwardKey;
  GlobalKey get containerKey;
  GlobalKey get blockComponentKey;

  SelectableMixin<StatefulWidget> get forward =>
      forwardKey.currentState as SelectableMixin;

  Offset get baseOffset {
    final parentBox = containerKey.currentContext?.findRenderObject();
    final childBox = forwardKey.currentContext?.findRenderObject();
    if (parentBox is RenderBox && childBox is RenderBox) {
      return childBox.localToGlobal(Offset.zero, ancestor: parentBox);
    }
    return Offset.zero;
  }

  Rect getBlockRect() {
    final parentBox = containerKey.currentContext?.findRenderObject();
    final childBox = blockComponentKey.currentContext?.findRenderObject();
    if (parentBox is RenderBox && childBox is RenderBox) {
      final offset = childBox.localToGlobal(Offset.zero, ancestor: parentBox);
      final size = parentBox.size;
      return offset & (size - offset as Size);
    }
    return Rect.zero;
  }

  Position getPositionInOffset(Offset start) =>
      forward.getPositionInOffset(start);

  Rect? getCursorRectInPosition(Position position) =>
      forward.getCursorRectInPosition(position)?.shift(baseOffset);

  List<Rect> getRectsInSelection(Selection selection) => forward
      .getRectsInSelection(selection)
      .map((rect) => rect.shift(baseOffset))
      .toList(growable: false);

  Selection getSelectionInRange(Offset start, Offset end) =>
      forward.getSelectionInRange(start, end);

  Offset localToGlobal(Offset offset) =>
      forward.localToGlobal(offset) - baseOffset;

  Selection? getWordBoundaryInOffset(Offset offset) =>
      forward.getWordBoundaryInOffset(offset);

  Selection? getWordBoundaryInPosition(Position position) =>
      forward.getWordBoundaryInPosition(position);

  Position start() => forward.start();

  Position end() => forward.end();

  TextDirection textDirection() => forward.textDirection();
}

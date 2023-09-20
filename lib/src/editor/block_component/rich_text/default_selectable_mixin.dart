import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

mixin DefaultSelectableMixin {
  GlobalKey get forwardKey;
  GlobalKey get containerKey;
  GlobalKey get blockComponentKey;

  SelectableMixin<StatefulWidget> get forward =>
      forwardKey.currentState as SelectableMixin;

  Offset baseOffset({
    bool shiftWithBaseOffset = false,
  }) {
    if (shiftWithBaseOffset) {
      final parentBox = containerKey.currentContext?.findRenderObject();
      final childBox = forwardKey.currentContext?.findRenderObject();
      if (parentBox is RenderBox && childBox is RenderBox) {
        return childBox.localToGlobal(Offset.zero, ancestor: parentBox);
      }
    }
    return Offset.zero;
  }

  Rect getBlockRect({
    bool shiftWithBaseOffset = false,
  }) {
    final parentBox = containerKey.currentContext?.findRenderObject();
    final childBox = blockComponentKey.currentContext?.findRenderObject();
    if (parentBox is RenderBox && childBox is RenderBox) {
      final offset = childBox.localToGlobal(Offset.zero, ancestor: parentBox);
      final size = parentBox.size;
      if (shiftWithBaseOffset) {
        return offset & (size - offset as Size);
      }
      return Offset.zero & (size - offset as Size);
    }
    return Rect.zero;
  }

  Position getPositionInOffset(Offset start) =>
      forward.getPositionInOffset(start);

  Rect? getCursorRectInPosition(
    Position position, {
    bool shiftWithBaseOffset = false,
  }) =>
      forward.getCursorRectInPosition(position)?.shift(
            baseOffset(
              shiftWithBaseOffset: shiftWithBaseOffset,
            ),
          );

  List<Rect> getRectsInSelection(
    Selection selection, {
    bool shiftWithBaseOffset = false,
  }) =>
      forward
          .getRectsInSelection(selection)
          .map(
            (rect) => rect.shift(
              baseOffset(
                shiftWithBaseOffset: shiftWithBaseOffset,
              ),
            ),
          )
          .toList(growable: false);

  Selection getSelectionInRange(Offset start, Offset end) =>
      forward.getSelectionInRange(start, end);

  Offset localToGlobal(
    Offset offset, {
    bool shiftWithBaseOffset = false,
  }) =>
      forward.localToGlobal(offset) -
      baseOffset(
        shiftWithBaseOffset: shiftWithBaseOffset,
      );

  Selection? getWordBoundaryInOffset(Offset offset) =>
      forward.getWordBoundaryInOffset(offset);

  Selection? getWordBoundaryInPosition(Position position) =>
      forward.getWordBoundaryInPosition(position);

  Position start() => forward.start();

  Position end() => forward.end();

  TextDirection textDirection() => forwardKey.currentState != null
      ? forward.textDirection()
      : TextDirection.ltr;
}

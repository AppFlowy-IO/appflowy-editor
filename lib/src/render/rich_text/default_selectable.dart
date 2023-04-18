import 'package:appflowy_editor/src/core/location/position.dart';
import 'package:appflowy_editor/src/core/location/selection.dart';
import 'package:appflowy_editor/src/render/selection/selectable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

mixin DefaultSelectable {
  GlobalKey get forwardKey;

  SelectableMixin<StatefulWidget> get forward =>
      forwardKey.currentState as SelectableMixin;

  Offset get baseOffset {
    final renderBox = forwardKey.currentContext?.findRenderObject();
    final parentData = renderBox?.parentData;
    if (parentData is BoxParentData) {
      return parentData.offset;
    }
    return Offset.zero;
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
}

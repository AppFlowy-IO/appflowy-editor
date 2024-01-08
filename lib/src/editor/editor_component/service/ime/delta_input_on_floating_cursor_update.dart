import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_selection_service.dart';
import 'package:appflowy_editor/src/render/selection/mobile_basic_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Offset? _cursorOffset;

Future<void> onFloatingCursorUpdate(
  RawFloatingCursorPoint point,
  EditorState editorState,
) async {
  Log.input.debug('onFloatingCursorUpdate: ${point.state}, ${point.offset}');

  // support updating the cursor position via the space bar on iOS.
  if (!Platform.isIOS) {
    return;
  }

  final selectionService = editorState.service.selectionService;

  switch (point.state) {
    case FloatingCursorDragState.Start:
      final collapsedCursor = HandleType.collapsed.key;
      final context = collapsedCursor.currentContext;
      if (context == null) {
        return;
      }

      // get global offset of the cursor.
      final renderBox = context.findRenderObject() as RenderBox;
      final offset = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      _cursorOffset = offset + Offset(size.width / 2, size.height / 2);
      disableMagnifier = true;
      selectionService.onPanStart(
        DragStartDetails(
          globalPosition: _cursorOffset!,
          localPosition: Offset.zero,
        ),
        MobileSelectionDragMode.cursor,
      );
      break;
    case FloatingCursorDragState.Update:
      disableMagnifier = true;
      selectionService.onPanUpdate(
        DragUpdateDetails(
          globalPosition: _cursorOffset! + point.offset!,
        ),
        MobileSelectionDragMode.cursor,
      );
      break;
    case FloatingCursorDragState.End:
      _cursorOffset = null;
      disableMagnifier = false;
      selectionService.onPanEnd(
        DragEndDetails(),
        MobileSelectionDragMode.cursor,
      );
      break;
  }
}

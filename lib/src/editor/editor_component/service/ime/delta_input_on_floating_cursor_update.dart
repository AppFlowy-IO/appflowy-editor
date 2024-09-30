import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_selection_service.dart';
import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:appflowy_editor/src/render/selection/mobile_basic_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Offset? _cursorOffset;

Future<void> onFloatingCursorUpdate(
  RawFloatingCursorPoint point,
  EditorState editorState,
) async {
  AppFlowyEditorLog.input.debug(
    'onFloatingCursorUpdate: ${point.state}, ${point.offset}',
  );

  // support updating the cursor position via the space bar on iOS/Android.
  if (PlatformExtension.isDesktopOrWeb) {
    return;
  }

  final selectionService = editorState.service.selectionService;

  switch (point.state) {
    case FloatingCursorDragState.Start:
      final collapsedCursor = HandleType.collapsed.key;
      final context = collapsedCursor.currentContext;
      if (context == null) {
        AppFlowyEditorLog.input.debug(
          'onFloatingCursorUpdateStart: context is null',
        );
        return;
      }

      AppFlowyEditorLog.input.debug(
        'onFloatingCursorUpdateStart: ${point.startLocation}',
      );

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
      final collapsedCursor = HandleType.collapsed.key;
      final context = collapsedCursor.currentContext;
      if (context == null) {
        AppFlowyEditorLog.input.debug(
          'onFloatingCursorUpdateUpdate: context is null',
        );
        return;
      } else {
        AppFlowyEditorLog.input.debug(
          'onFloatingCursorUpdateUpdate: context is not null',
        );
      }
      if (_cursorOffset == null || point.offset == null) {
        return;
      }

      AppFlowyEditorLog.input.debug(
        'onFloatingCursorUpdateUpdate: ${point.offset}',
      );

      disableMagnifier = true;
      selectionService.onPanUpdate(
        DragUpdateDetails(
          globalPosition: _cursorOffset! + point.offset!,
        ),
        MobileSelectionDragMode.cursor,
      );
      break;
    case FloatingCursorDragState.End:
      AppFlowyEditorLog.input.debug(
        'onFloatingCursorUpdateEnd: ${point.offset}',
      );

      _cursorOffset = null;
      disableMagnifier = false;
      selectionService.onPanEnd(
        DragEndDetails(),
        MobileSelectionDragMode.cursor,
      );
      break;
  }
}

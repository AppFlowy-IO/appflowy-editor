import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/find_replace_menu/find_replace_widget.dart';
import 'package:flutter/material.dart';
import '../../editor_state.dart';

abstract class FindReplaceService {
  void show();
  void dismiss();
}

class FindReplaceMenu implements FindReplaceService {
  FindReplaceMenu({
    required this.context,
    required this.editorState,
    required this.replaceFlag,
  });

  final BuildContext context;
  final EditorState editorState;
  final bool replaceFlag;
  final double topOffset = 52;
  final double rightOffset = 40;

  OverlayEntry? _findReplaceMenuEntry;
  bool _selectionUpdateByInner = false;

  @override
  void dismiss() {
    if (_findReplaceMenuEntry != null) {
      editorState.service.keyboardService?.enable();
      editorState.service.scrollService?.enable();
    }

    _findReplaceMenuEntry?.remove();
    _findReplaceMenuEntry = null;

    final isSelectionDisposed =
        editorState.service.selectionServiceKey.currentState == null;
    if (!isSelectionDisposed) {
      final selectionService = editorState.service.selectionService;
      selectionService.currentSelection.removeListener(_onSelectionChange);
    }
  }

  @override
  void show() {
    dismiss();

    final selectionService = editorState.service.selectionService;
    final selectionRects = selectionService.selectionRects;
    if (selectionRects.isEmpty) {
      return;
    }

    _findReplaceMenuEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: topOffset,
          right: rightOffset,
          child: Material(
            borderRadius: BorderRadius.circular(8.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: editorState.editorStyle.selectionColor,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    spreadRadius: 1,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: FindMenuWidget(
                dismiss: dismiss,
                editorState: editorState,
                replaceFlag: replaceFlag,
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_findReplaceMenuEntry!);
  }

  void _onSelectionChange() {
    // workaround: SelectionService has been released after hot reload.
    final isSelectionDisposed =
        editorState.service.selectionServiceKey.currentState == null;
    if (!isSelectionDisposed) {
      final selectionService = editorState.service.selectionService;
      if (selectionService.currentSelection.value == null) {
        return;
      }
    }

    if (_selectionUpdateByInner) {
      _selectionUpdateByInner = false;
      return;
    }

    dismiss();
  }
}

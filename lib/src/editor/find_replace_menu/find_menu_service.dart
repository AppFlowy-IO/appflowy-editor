import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/find_replace_menu/find_replace_widget.dart';
import 'package:flutter/material.dart';

abstract class FindReplaceService {
  void show();
  void dismiss();
}

OverlayEntry? _findReplaceMenuEntry;

class FindReplaceMenu implements FindReplaceService {
  FindReplaceMenu({
    required this.context,
    required this.editorState,
    required this.replaceFlag,
    this.localizations,
    required this.style,
  });

  final BuildContext context;
  final EditorState editorState;
  final bool replaceFlag;
  final FindReplaceLocalizations? localizations;
  final FindReplaceStyle style;

  final double topOffset = 52;
  final double rightOffset = 40;

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
    if (_findReplaceMenuEntry != null) {
      dismiss();
    }

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
                localizations: localizations,
                style: style,
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

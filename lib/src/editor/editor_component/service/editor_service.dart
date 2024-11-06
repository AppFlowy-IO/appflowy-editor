import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart' hide Overlay, OverlayEntry, OverlayState;

class EditorService {
  // selection service
  final selectionServiceKey = GlobalKey(
    debugLabel: 'appflowy_editor_selection_service',
  );
  AppFlowySelectionService get selectionService {
    assert(
      selectionServiceKey.currentState != null &&
          selectionServiceKey.currentState is AppFlowySelectionService,
    );
    return selectionServiceKey.currentState! as AppFlowySelectionService;
  }

  // keyboard service
  final keyboardServiceKey = GlobalKey(
    debugLabel: 'appflowy_editor_keyboard_service',
  );
  AppFlowyKeyboardService? get keyboardService {
    if (keyboardServiceKey.currentState != null &&
        keyboardServiceKey.currentState is AppFlowyKeyboardService) {
      print('Enter normal mode');
      // print(selectionService.currentSelection.value);
      // Selection? select = selectionService.currentSelection.value;
      //NOTE: This causes the editor to freeze up and eats memory alot...
      // keyboardService?.enableKeyBoard(select!);
      //NOTE: Would need to display cursor after closing keyboard
      // print(selectionService.currentSelection);
      //NOTE: Causes and infinite loop & hangs
      // keyboardService?.enable();
      return keyboardServiceKey.currentState! as AppFlowyKeyboardService;
    }
    return null;
  }

  // render plugin service
  // late AppFlowyRenderPlugin renderPluginService;
  late BlockComponentRendererService rendererService;

  // scroll service
  final scrollServiceKey = GlobalKey(
    debugLabel: 'appflowy_editor_scroll_service',
  );
  AppFlowyScrollService? get scrollService {
    if (scrollServiceKey.currentState != null &&
        scrollServiceKey.currentState is AppFlowyScrollService) {
      return scrollServiceKey.currentState! as AppFlowyScrollService;
    }
    return null;
  }
}

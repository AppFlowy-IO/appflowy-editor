import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

ShortcutEventHandler cursorLeftSelect = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection = editorState.service.selectionService.currentSelection.value;
  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }
  final end = selection.end.goLeft(editorState);
  if (end == null) {
    return KeyEventResult.ignored;
  }
  editorState.service.selectionService.updateSelection(
    selection.copyWith(end: end),
  );
  return KeyEventResult.handled;
};

ShortcutEventHandler cursorRightSelect = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection = editorState.service.selectionService.currentSelection.value;
  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }
  final end = selection.end.goRight(editorState);
  if (end == null) {
    return KeyEventResult.ignored;
  }
  editorState.service.selectionService.updateSelection(
    selection.copyWith(end: end),
  );
  return KeyEventResult.handled;
};

ShortcutEventHandler cursorUpSelect = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection = editorState.service.selectionService.currentSelection.value;
  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }
  final end = _moveVertical(editorState);
  if (end == null) {
    return KeyEventResult.ignored;
  }
  editorState.service.selectionService.updateSelection(
    selection.copyWith(end: end),
  );
  return KeyEventResult.handled;
};

ShortcutEventHandler cursorDownSelect = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection = editorState.service.selectionService.currentSelection.value;
  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }
  final end = _moveVertical(editorState, upwards: false);
  if (end == null) {
    return KeyEventResult.ignored;
  }
  editorState.service.selectionService.updateSelection(
    selection.copyWith(end: end),
  );
  return KeyEventResult.handled;
};

ShortcutEventHandler cursorTop = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  if (nodes.isEmpty) {
    return KeyEventResult.ignored;
  }
  final position = editorState.document.root.children
      .whereType<TextNode>()
      .first
      .selectable
      ?.start();
  if (position == null) {
    return KeyEventResult.ignored;
  }
  editorState.service.selectionService.updateSelection(
    Selection.collapsed(position),
  );
  return KeyEventResult.handled;
};

ShortcutEventHandler cursorBottom = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  if (nodes.isEmpty) {
    return KeyEventResult.ignored;
  }
  final position = editorState.document.root.children
      .whereType<TextNode>()
      .last
      .selectable
      ?.end();
  if (position == null) {
    return KeyEventResult.ignored;
  }
  editorState.service.selectionService.updateSelection(
    Selection.collapsed(position),
  );
  return KeyEventResult.handled;
};

ShortcutEventHandler cursorBegin = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  if (nodes.isEmpty) {
    return KeyEventResult.ignored;
  }
  final position = nodes.first.selectable?.start();
  if (position == null) {
    return KeyEventResult.ignored;
  }
  editorState.service.selectionService.updateSelection(
    Selection.collapsed(position),
  );
  return KeyEventResult.handled;
};

ShortcutEventHandler cursorEnd = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  if (nodes.isEmpty) {
    return KeyEventResult.ignored;
  }
  final position = nodes.first.selectable?.end();
  if (position == null) {
    return KeyEventResult.ignored;
  }
  editorState.service.selectionService.updateSelection(
    Selection.collapsed(position),
  );
  return KeyEventResult.handled;
};

ShortcutEventHandler cursorTopSelect = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection = editorState.service.selectionService.currentSelection.value;
  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }

  var start = selection.start;
  var end = selection.end;
  final position = editorState.document.root.children
      .whereType<TextNode>()
      .first
      .selectable
      ?.start();
  if (position != null) {
    end = position;
  }
  editorState.service.selectionService.updateSelection(
    selection.copyWith(start: start, end: end),
  );
  return KeyEventResult.handled;
};

ShortcutEventHandler cursorBottomSelect = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection = editorState.service.selectionService.currentSelection.value;
  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }
  var start = selection.start;
  var end = selection.end;
  final position = editorState.document.root.children
      .whereType<TextNode>()
      .last
      .selectable
      ?.end();
  if (position != null) {
    end = position;
  }
  editorState.service.selectionService.updateSelection(
    selection.copyWith(start: start, end: end),
  );
  return KeyEventResult.handled;
};

ShortcutEventHandler cursorBeginSelect = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection = editorState.service.selectionService.currentSelection.value;
  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }

  var start = selection.start;
  var end = selection.end;
  final position = nodes.last.selectable?.start();
  if (position != null) {
    end = position;
  }

  editorState.service.selectionService.updateSelection(
    selection.copyWith(start: start, end: end),
  );
  return KeyEventResult.handled;
};

ShortcutEventHandler cursorEndSelect = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection = editorState.service.selectionService.currentSelection.value;
  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }

  var start = selection.start;
  var end = selection.end;
  final position = nodes.last.selectable?.end();
  if (position != null) {
    end = position;
  }
  editorState.service.selectionService.updateSelection(
    selection.copyWith(start: start, end: end),
  );
  return KeyEventResult.handled;
};

ShortcutEventHandler cursorUp = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection =
      editorState.service.selectionService.currentSelection.value?.normalized;
  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }

  final upPosition = _moveVertical(editorState);
  editorState.updateCursorSelection(
    upPosition == null ? null : Selection.collapsed(upPosition),
  );

  return KeyEventResult.handled;
};

ShortcutEventHandler cursorDown = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection =
      editorState.service.selectionService.currentSelection.value?.normalized;
  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }

  final downPosition = _moveVertical(editorState, upwards: false);
  editorState.updateCursorSelection(
    downPosition == null ? null : Selection.collapsed(downPosition),
  );

  return KeyEventResult.handled;
};

ShortcutEventHandler cursorLeft = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection =
      editorState.service.selectionService.currentSelection.value?.normalized;
  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }

  Position newPosition = selection.isCollapsed
      ? selection.start.goLeft(editorState) ?? selection.start
      : selection.start;

  editorState.service.selectionService.updateSelection(
    Selection.collapsed(newPosition),
  );

  return KeyEventResult.handled;
};

ShortcutEventHandler cursorRight = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection =
      editorState.service.selectionService.currentSelection.value?.normalized;
  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }

  final newPosition = selection.isCollapsed
      ? selection.start.goRight(editorState) ?? selection.end
      : selection.end;

  editorState.service.selectionService.updateSelection(
    Selection.collapsed(newPosition),
  );

  return KeyEventResult.handled;
};

ShortcutEventHandler cursorLeftWordSelect = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection = editorState.service.selectionService.currentSelection.value;
  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }

  final end =
      selection.end.goLeft(editorState, selectionRange: SelectionRange.word);
  if (end == null) {
    return KeyEventResult.ignored;
  }

  editorState.service.selectionService.updateSelection(
    selection.copyWith(end: end),
  );

  return KeyEventResult.handled;
};

ShortcutEventHandler cursorLeftWordMove = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection =
      editorState.service.selectionService.currentSelection.value?.normalized;

  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }

  final newPosition = selection.start
          .goLeft(editorState, selectionRange: SelectionRange.word) ??
      selection.start;

  editorState.service.selectionService.updateSelection(
    Selection.collapsed(newPosition),
  );

  return KeyEventResult.handled;
};

ShortcutEventHandler cursorRightWordMove = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection =
      editorState.service.selectionService.currentSelection.value?.normalized;

  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }

  final newPosition = selection.start
          .goRight(editorState, selectionRange: SelectionRange.word) ??
      selection.end;

  editorState.service.selectionService.updateSelection(
    Selection.collapsed(newPosition),
  );

  return KeyEventResult.handled;
};

ShortcutEventHandler cursorRightWordSelect = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection = editorState.service.selectionService.currentSelection.value;
  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }

  final end =
      selection.end.goRight(editorState, selectionRange: SelectionRange.word);
  if (end == null) {
    return KeyEventResult.ignored;
  }

  editorState.service.selectionService.updateSelection(
    selection.copyWith(end: end),
  );

  return KeyEventResult.handled;
};

Position? _moveVertical(
  EditorState editorState, {
  bool upwards = true,
}) {
  final selection = editorState.service.selectionService.currentSelection.value;
  final rects = editorState.service.selectionService.selectionRects;
  if (rects.isEmpty || selection == null) {
    return null;
  }

  Offset offset;
  if (selection.isBackward) {
    final rect = rects.reduce(
      (current, next) => current.bottom >= next.bottom ? current : next,
    );
    offset = upwards
        ? rect.topRight.translate(0, -rect.height)
        : rect.bottomRight.translate(0, rect.height);
  } else {
    final rect = rects.reduce(
      (current, next) => current.top <= next.top ? current : next,
    );
    offset = upwards
        ? rect.topLeft.translate(0, -rect.height)
        : rect.bottomLeft.translate(0, rect.height);
  }

  return editorState.service.selectionService.getPositionInOffset(offset);
}

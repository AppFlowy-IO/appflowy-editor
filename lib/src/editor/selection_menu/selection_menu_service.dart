import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/service/default_text_operations/format_rich_text_style.dart';
import 'package:flutter/material.dart';

// TODO: this file is too long, need to refactor.
abstract class SelectionMenuService {
  Offset get offset;
  Alignment get alignment;
  SelectionMenuStyle get style;

  void show();
  void dismiss();

  (double? left, double? top, double? right, double? bottom) getPosition();
}

class SelectionMenu extends SelectionMenuService {
  SelectionMenu({
    required this.context,
    required this.editorState,
    required this.selectionMenuItems,
    this.deleteSlashByDefault = true,
    this.style = SelectionMenuStyle.light,
    this.itemCountFilter = 0,
  });

  final BuildContext context;
  final EditorState editorState;
  final List<SelectionMenuItem> selectionMenuItems;
  final bool deleteSlashByDefault;
  @override
  final SelectionMenuStyle style;

  OverlayEntry? _selectionMenuEntry;
  bool _selectionUpdateByInner = false;
  Offset _offset = Offset.zero;
  Alignment _alignment = Alignment.topLeft;
  int itemCountFilter;

  @override
  void dismiss() {
    if (_selectionMenuEntry != null) {
      editorState.service.keyboardService?.enable();
      editorState.service.scrollService?.enable();
    }

    _selectionMenuEntry?.remove();
    _selectionMenuEntry = null;

    // workaround: SelectionService has been released after hot reload.
    final isSelectionDisposed =
        editorState.service.selectionServiceKey.currentState == null;
    if (!isSelectionDisposed) {
      final selectionService = editorState.service.selectionService;
      selectionService.currentSelection.removeListener(_onSelectionChange);
    }
  }

  @override
  void show() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _show();
    });
  }

  void _show() {
    dismiss();

    final selectionService = editorState.service.selectionService;
    final selectionRects = selectionService.selectionRects;
    if (selectionRects.isEmpty) {
      return;
    }

    calculateSelectionMenuOffset(selectionRects.first);
    final (left, top, right, bottom) = getPosition();

    final editorHeight = editorState.renderBox!.size.height;
    final editorWidth = editorState.renderBox!.size.width;

    _selectionMenuEntry = OverlayEntry(
      builder: (context) {
        return SizedBox(
          width: editorWidth,
          height: editorHeight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              dismiss();
            },
            child: Stack(
              children: [
                Positioned(
                  top: top,
                  bottom: bottom,
                  left: left,
                  right: right,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectionMenuWidget(
                      selectionMenuStyle: style,
                      items: selectionMenuItems
                        ..forEach((element) {
                          element.deleteSlash = deleteSlashByDefault;
                          element.onSelected = () {
                            dismiss();
                          };
                        }),
                      maxItemInRow: 5,
                      editorState: editorState,
                      itemCountFilter: itemCountFilter,
                      menuService: this,
                      onExit: () {
                        dismiss();
                      },
                      onSelectionUpdate: () {
                        _selectionUpdateByInner = true;
                      },
                      deleteSlashByDefault: deleteSlashByDefault,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_selectionMenuEntry!);

    editorState.service.keyboardService?.disable(showCursor: true);
    editorState.service.scrollService?.disable();
    selectionService.currentSelection.addListener(_onSelectionChange);
  }

  @override
  Alignment get alignment {
    return _alignment;
  }

  @override
  Offset get offset {
    return _offset;
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

  @override
  (double? left, double? top, double? right, double? bottom) getPosition() {
    double? left, top, right, bottom;
    switch (alignment) {
      case Alignment.topLeft:
        left = offset.dx;
        top = offset.dy;
        break;
      case Alignment.bottomLeft:
        left = offset.dx;
        bottom = offset.dy;
        break;
      case Alignment.topRight:
        right = offset.dx;
        top = offset.dy;
        break;
      case Alignment.bottomRight:
        right = offset.dx;
        bottom = offset.dy;
        break;
    }

    return (left, top, right, bottom);
  }

  void calculateSelectionMenuOffset(Rect rect) {
    // Workaround: We can customize the padding through the [EditorStyle],
    //  but the coordinates of overlay are not properly converted currently.
    //  Just subtract the padding here as a result.
    const menuHeight = 200.0;
    const menuOffset = Offset(0, 10);
    final editorOffset =
        editorState.renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final editorHeight = editorState.renderBox!.size.height;
    final editorWidth = editorState.renderBox!.size.width;

    // show below default
    _alignment = Alignment.topLeft;
    final bottomRight = rect.bottomRight;
    final topRight = rect.topRight;
    var offset = bottomRight + menuOffset;
    _offset = Offset(
      offset.dx,
      offset.dy,
    );

    // show above
    if (offset.dy + menuHeight >= editorOffset.dy + editorHeight) {
      offset = topRight - menuOffset;
      _alignment = Alignment.bottomLeft;

      _offset = Offset(
        offset.dx,
        MediaQuery.of(context).size.height - offset.dy,
      );
    }

    // show on left
    if (_offset.dx > editorWidth / 2) {
      _alignment = _alignment == Alignment.topLeft
          ? Alignment.topRight
          : Alignment.bottomRight;

      _offset = Offset(
        editorWidth - _offset.dx,
        _offset.dy,
      );
    }
  }
}

final List<SelectionMenuItem> standardSelectionMenuItems = [
  SelectionMenuItem(
    name: AppFlowyEditorLocalizations.current.text,
    icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
      name: 'text',
      isSelected: isSelected,
      style: style,
    ),
    keywords: ['text'],
    handler: (editorState, _, __) {
      insertNodeAfterSelection(editorState, paragraphNode());
    },
  ),
  SelectionMenuItem(
    name: AppFlowyEditorLocalizations.current.heading1,
    icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
      name: 'h1',
      isSelected: isSelected,
      style: style,
    ),
    keywords: ['heading 1, h1'],
    handler: (editorState, _, __) {
      insertHeadingAfterSelection(editorState, 1);
    },
  ),
  SelectionMenuItem(
    name: AppFlowyEditorLocalizations.current.heading2,
    icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
      name: 'h2',
      isSelected: isSelected,
      style: style,
    ),
    keywords: ['heading 2, h2'],
    handler: (editorState, _, __) {
      insertHeadingAfterSelection(editorState, 2);
    },
  ),
  SelectionMenuItem(
    name: AppFlowyEditorLocalizations.current.heading3,
    icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
      name: 'h3',
      isSelected: isSelected,
      style: style,
    ),
    keywords: ['heading 3, h3'],
    handler: (editorState, _, __) {
      insertHeadingAfterSelection(editorState, 3);
    },
  ),
  SelectionMenuItem(
    name: AppFlowyEditorLocalizations.current.image,
    icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
      name: 'image',
      isSelected: isSelected,
      style: style,
    ),
    keywords: ['image'],
    handler: (editorState, menuService, context) {
      final container = Overlay.of(context);
      showImageMenu(container, editorState, menuService);
    },
  ),
  SelectionMenuItem(
    name: AppFlowyEditorLocalizations.current.bulletedList,
    icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
      name: 'bulleted_list',
      isSelected: isSelected,
      style: style,
    ),
    keywords: ['bulleted list', 'list', 'unordered list'],
    handler: (editorState, _, __) {
      insertBulletedListAfterSelection(editorState);
    },
  ),
  SelectionMenuItem(
    name: AppFlowyEditorLocalizations.current.numberedList,
    icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
      name: 'number',
      isSelected: isSelected,
      style: style,
    ),
    keywords: ['numbered list', 'list', 'ordered list'],
    handler: (editorState, _, __) {
      insertNumberedListAfterSelection(editorState);
    },
  ),
  SelectionMenuItem(
    name: AppFlowyEditorLocalizations.current.checkbox,
    icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
      name: 'checkbox',
      isSelected: isSelected,
      style: style,
    ),
    keywords: ['todo list', 'list', 'checkbox list'],
    handler: (editorState, _, __) {
      insertCheckboxAfterSelection(editorState);
    },
  ),
  SelectionMenuItem(
    name: AppFlowyEditorLocalizations.current.quote,
    icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
      name: 'quote',
      isSelected: isSelected,
      style: style,
    ),
    keywords: ['quote', 'refer'],
    handler: (editorState, _, __) {
      insertQuoteAfterSelection(editorState);
    },
  ),
  dividerMenuItem,
  tableMenuItem,
];

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/image_block_component/image_upload_widget.dart';
import 'package:appflowy_editor/src/render/selection_menu/selection_menu_icon.dart';
import 'package:flutter/material.dart';

// TODO: this file is too long, need to refactor.
abstract class SelectionMenuService {
  Offset get topLeft;
  Offset get offset;
  Alignment get alignment;
  SelectionMenuStyle get style;

  void show();
  void dismiss();

  (double left, double? top, double? bottom) getPosition();
}

class SelectionMenu extends SelectionMenuService {
  SelectionMenu({
    required this.context,
    required this.editorState,
    required this.selectionMenuItems,
    this.deleteSlashByDefault = true,
    this.style = SelectionMenuStyle.light,
  });

  final BuildContext context;
  final EditorState editorState;
  final List<SelectionMenuItem> selectionMenuItems;
  final bool deleteSlashByDefault;
  @override
  final SelectionMenuStyle style;

  OverlayEntry? _selectionMenuEntry;
  bool _selectionUpdateByInner = false;
  Offset? _topLeft;
  Offset _offset = Offset.zero;
  Alignment _alignment = Alignment.topLeft;
  bool showBelow = true;

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
    dismiss();

    final selectionService = editorState.service.selectionService;
    final selectionRects = selectionService.selectionRects;
    if (selectionRects.isEmpty) {
      return;
    }
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
    showBelow = true;
    _alignment = Alignment.bottomLeft;
    final bottomRight = selectionRects.first.bottomRight;
    final topRight = selectionRects.first.topRight;
    var offset = bottomRight + menuOffset;
    // overflow
    if (offset.dy + menuHeight >= editorOffset.dy + editorHeight) {
      // show above
      offset = topRight - menuOffset;
      showBelow = false;
      _alignment = Alignment.topLeft;
    }
    _topLeft = offset;
    _offset = Offset(
      offset.dx,
      showBelow ? offset.dy : MediaQuery.of(context).size.height - offset.dy,
    );

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
                  top: showBelow ? _offset.dy : null,
                  bottom: showBelow ? null : _offset.dy,
                  left: offset.dx,
                  right: 0,
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
                      menuService: this,
                      onExit: () {
                        dismiss();
                      },
                      onSelectionUpdate: () {
                        _selectionUpdateByInner = true;
                      },
                    ),
                  ),
                )
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
  (double, double?, double?) getPosition() {
    final left = _offset.dx;
    double? top;
    double? bottom;
    if (!showBelow) {
      bottom = _offset.dy;
    } else {
      top = _offset.dy;
    }
    return (left, top, bottom);
  }

  @override
  Offset get topLeft {
    return _topLeft ?? Offset.zero;
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
];

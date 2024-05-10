import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/desktop_selection_service.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_selection_service.dart';
import 'package:flutter/material.dart' hide Overlay, OverlayEntry;
import 'package:provider/provider.dart';

class SelectionServiceWidget extends StatefulWidget {
  const SelectionServiceWidget({
    super.key,
    this.cursorColor = const Color(0xFF00BCF0),
    this.selectionColor = const Color.fromARGB(53, 111, 201, 231),
    this.showMagnifier = true,
    this.contextMenuItems,
    required this.child,
  });

  final Widget child;
  final Color cursorColor;
  final Color selectionColor;
  final List<List<ContextMenuItem>>? contextMenuItems;

  /// Show the magnifier or not.
  ///
  /// only works on iOS or Android.
  final bool showMagnifier;

  @override
  State<SelectionServiceWidget> createState() => _SelectionServiceWidgetState();
}

class _SelectionServiceWidgetState extends State<SelectionServiceWidget>
    with WidgetsBindingObserver
    implements AppFlowySelectionService {
  final forwardKey = GlobalKey(
    debugLabel: 'forward_to_platform_selection_service',
  );
  AppFlowySelectionService get forward =>
      forwardKey.currentState as AppFlowySelectionService;

  @override
  Widget build(BuildContext context) {
    if (PlatformExtension.isDesktopOrWeb) {
      return DesktopSelectionServiceWidget(
        key: forwardKey,
        cursorColor: widget.cursorColor,
        selectionColor: widget.selectionColor,
        contextMenuItems: widget.contextMenuItems,
        child: widget.child,
      );
    }

    final editorState = context.read<EditorState>();
    return MobileSelectionServiceWidget(
      key: forwardKey,
      cursorColor: widget.cursorColor,
      selectionColor: widget.selectionColor,
      showMagnifier: widget.showMagnifier,
      magnifierSize: editorState.editorStyle.magnifierSize,
      child: widget.child,
    );
  }

  @override
  void clearCursor() => forward.clearCursor();

  @override
  void clearSelection() => forward.clearSelection();

  @override
  List<Node> get currentSelectedNodes => forward.currentSelectedNodes;

  @override
  ValueNotifier<Selection?> get currentSelection => forward.currentSelection;

  @override
  Node? getNodeInOffset(Offset offset) => forward.getNodeInOffset(offset);

  @override
  Position? getPositionInOffset(Offset offset) =>
      forward.getPositionInOffset(offset);

  @override
  void registerGestureInterceptor(SelectionGestureInterceptor interceptor) =>
      forward.registerGestureInterceptor(interceptor);

  @override
  List<Rect> get selectionRects => forward.selectionRects;

  @override
  void unregisterGestureInterceptor(String key) =>
      forward.unregisterGestureInterceptor(key);

  @override
  void updateSelection(Selection? selection) =>
      forward.updateSelection(selection);

  @override
  Selection? onPanStart(
    DragStartDetails details,
    MobileSelectionDragMode mode,
  ) =>
      forward.onPanStart(details, mode);

  @override
  Selection? onPanUpdate(
    DragUpdateDetails details,
    MobileSelectionDragMode mode,
  ) =>
      forward.onPanUpdate(details, mode);

  @override
  void onPanEnd(
    DragEndDetails details,
    MobileSelectionDragMode mode,
  ) =>
      forward.onPanEnd(details, mode);
}

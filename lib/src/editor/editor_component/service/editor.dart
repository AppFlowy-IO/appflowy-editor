import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/service/context_menu/built_in_context_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// workaround for the issue:
// the popover will grab the focus even if it's inside the editor
// setup a global value to indicate whether the focus should be grabbed
// increase the value when the popover is opened
// decrease the value when the popover is closed
// only grab the focus when the value is 0
// the operation must be paired
ValueNotifier<int> keepEditorFocusNotifier = ValueNotifier(0);

class AppFlowyEditor extends StatefulWidget {
  AppFlowyEditor({
    super.key,
    required this.editorState,
    Map<String, BlockComponentBuilder>? blockComponentBuilders,
    List<CharacterShortcutEvent>? characterShortcutEvents,
    List<CommandShortcutEvent>? commandShortcutEvents,
    List<List<ContextMenuItem>>? contextMenuItems,
    this.editable = true,
    this.autoFocus = false,
    this.focusedSelection,
    this.shrinkWrap = false,
    this.scrollController,
    this.editorStyle = const EditorStyle.desktop(),
    this.header,
    this.footer,
    this.focusNode,
  })  : blockComponentBuilders =
            blockComponentBuilders ?? standardBlockComponentBuilderMap,
        characterShortcutEvents =
            characterShortcutEvents ?? standardCharacterShortcutEvents,
        commandShortcutEvents =
            commandShortcutEvents ?? standardCommandShortcutEvents,
        contextMenuItems = contextMenuItems ?? standardContextMenuItems;

  final EditorState editorState;

  final EditorStyle editorStyle;

  /// Block component builders
  ///
  /// Pass the [standardBlockComponentBuilderMap] as well
  ///   if you simply want to extend it with a new one.
  ///
  /// For example, if you want to add a new block component:
  ///
  /// ```dart
  /// AppFlowyEditor(
  ///   blockComponentBuilders: {
  ///     ...standardBlockComponentBuilderMap,
  ///     'my_block_component': MyBlockComponentBuilder(),
  ///   },
  /// );
  /// ```
  ///
  /// Also, you can override the standard block component:
  ///
  /// ```dart
  /// AppFlowyEditor(
  ///   blockComponentBuilders: {
  ///     ...standardBlockComponentBuilderMap,
  ///     'paragraph': MyParagraphBlockComponentBuilder(),
  ///   },
  /// );
  /// ```
  final Map<String, BlockComponentBuilder> blockComponentBuilders;

  /// Character event handlers
  ///
  /// Pass the [standardCharacterShortcutEvents] as well
  ///   if you simply want to extend it with a new one.
  ///
  /// For example, if you want to add a new character shortcut event:
  ///
  /// ```dart
  /// AppFlowyEditor(
  ///  characterShortcutEvents: [
  ///   ...standardCharacterShortcutEvents,
  ///   [YOUR_SHORTCUT_EVENT],
  ///  ],
  /// );
  /// ```
  final List<CharacterShortcutEvent> characterShortcutEvents;

  /// Command event handlers
  ///
  /// Pass the [standardCommandShortcutEvents] as well
  ///   if you simply want to extend it with a new one.
  ///
  /// For example, if you want to add a new command shortcut event:
  ///
  /// ```dart
  /// AppFlowyEditor(
  ///   commandShortcutEvents: [
  ///     ...standardCommandShortcutEvents,
  ///     [YOUR_SHORTCUT_EVENT],
  ///   ],
  /// );
  /// ```
  final List<CommandShortcutEvent> commandShortcutEvents;

  /// The context menu items.
  ///
  /// They will be shown when the user right click on the editor.
  ///
  /// A divider will be added between each list.
  final List<List<ContextMenuItem>> contextMenuItems;

  /// Provide a scrollController to control the scroll behavior
  ///   if you need to custom the scroll behavior.
  ///
  /// Otherwise, the editor will create a scrollController inside.
  final ScrollController? scrollController;

  /// Set the value to false to disable editing.
  final bool editable;

  /// Set the value to true to focus the editor on the start of the document.
  final bool autoFocus;

  /// Set the value to focus the editor on the specified selection.
  ///
  /// only works when [autoFocus] is true.
  final Selection? focusedSelection;

  final FocusNode? focusNode;

  /// AppFlowy Editor use column as the root widget.
  ///
  /// You can provide a header and/or a footer to the editor.
  final Widget? header;
  final Widget? footer;

  /// if true, the editor will be sized to its contents.
  ///
  /// You should wrap the editor with a sized widget if you set this value to true.
  ///
  /// Notes: Must provide a scrollController when shrinkWrap is true.
  final bool shrinkWrap;

  @override
  State<AppFlowyEditor> createState() => _AppFlowyEditorState();
}

class _AppFlowyEditorState extends State<AppFlowyEditor> {
  Widget? services;

  EditorState get editorState => widget.editorState;

  @override
  void initState() {
    super.initState();

    if (widget.shrinkWrap && widget.scrollController == null) {
      throw ArgumentError(
        'scrollController must be provided when shrinkWrap is true.',
      );
    }

    editorState.editorStyle = widget.editorStyle;
    editorState.renderer = _renderer;
    editorState.editable = widget.editable;

    // auto focus
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _autoFocusIfNeeded();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppFlowyEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    editorState.editorStyle = widget.editorStyle;
    editorState.editable = widget.editable;

    if (editorState.service != oldWidget.editorState.service) {
      editorState.renderer = _renderer;
    }

    services = null;
  }

  @override
  Widget build(BuildContext context) {
    services ??= _buildServices(context);

    return Provider.value(
      value: editorState,
      child: FocusScope(
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => services!,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildServices(BuildContext context) {
    Widget child = Container(
      padding: widget.editorStyle.padding,
      child: editorState.renderer.build(
        context,
        editorState.document.root,
      ),
    );

    if (widget.header != null || widget.footer != null) {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.header != null) widget.header!,
          child,
          if (widget.footer != null) widget.footer!,
        ],
      );
    }

    if (widget.editable) {
      child = SelectionServiceWidget(
        key: editorState.service.selectionServiceKey,
        cursorColor: widget.editorStyle.cursorColor,
        selectionColor: widget.editorStyle.selectionColor,
        contextMenuItems: widget.contextMenuItems,
        child: KeyboardServiceWidget(
          key: editorState.service.keyboardServiceKey,
          characterShortcutEvents: widget.characterShortcutEvents,
          commandShortcutEvents: widget.commandShortcutEvents,
          focusNode: widget.focusNode,
          child: child,
        ),
      );
    }
    return ScrollServiceWidget(
      key: editorState.service.scrollServiceKey,
      shrinkWrap: widget.shrinkWrap,
      scrollController: widget.scrollController,
      child: child,
    );
  }

  void _autoFocusIfNeeded() {
    if (widget.editable && widget.autoFocus) {
      editorState.updateSelectionWithReason(
        widget.focusedSelection ??
            Selection.single(
              path: [0],
              startOffset: 0,
            ),
        reason: SelectionUpdateReason.uiEvent,
      );
    }
  }

  BlockComponentRendererService get _renderer => BlockComponentRenderer(
        builders: {...widget.blockComponentBuilders},
      );
}

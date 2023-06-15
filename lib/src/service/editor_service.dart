import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/flutter/overlay.dart';
import 'package:flutter/material.dart' hide Overlay, OverlayEntry;
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
  @Deprecated('Use AppFlowyEditor.custom or AppFlowyEditor.standard instead')
  const AppFlowyEditor({
    super.key,
    required this.editorState,
    this.customBuilders = const {},
    this.blockComponentBuilders = const {},
    this.shortcutEvents = const [],
    this.characterShortcutEvents = const [],
    this.commandShortcutEvents = const [],
    this.selectionMenuItems = const [],
    this.toolbarItems = const [],
    this.editable = true,
    this.autoFocus = false,
    this.focusedSelection,
    this.customActionMenuBuilder,
    this.shrinkWrap = false,
    this.scrollController,
    this.themeData,
    this.editorStyle = const EditorStyle.desktop(),
    this.header,
    this.focusNode,
  });

  const AppFlowyEditor.custom({
    Key? key,
    required EditorState editorState,
    ScrollController? scrollController,
    bool editable = true,
    bool autoFocus = false,
    Selection? focusedSelection,
    EditorStyle? editorStyle,
    Map<String, BlockComponentBuilder> blockComponentBuilders = const {},
    List<CharacterShortcutEvent> characterShortcutEvents = const [],
    List<CommandShortcutEvent> commandShortcutEvents = const [],
    List<SelectionMenuItem> selectionMenuItems = const [],
    Widget? header,
    FocusNode? focusNode,
    bool shrinkWrap = false,
  }) : this(
          key: key,
          editorState: editorState,
          scrollController: scrollController,
          editable: editable,
          autoFocus: autoFocus,
          focusedSelection: focusedSelection,
          blockComponentBuilders: blockComponentBuilders,
          characterShortcutEvents: characterShortcutEvents,
          commandShortcutEvents: commandShortcutEvents,
          selectionMenuItems: selectionMenuItems,
          editorStyle: editorStyle ?? const EditorStyle.desktop(),
          header: header,
          focusNode: focusNode,
          shrinkWrap: shrinkWrap,
        );

  AppFlowyEditor.standard({
    Key? key,
    required EditorState editorState,
    ScrollController? scrollController,
    bool editable = true,
    bool autoFocus = false,
    Selection? focusedSelection,
    EditorStyle? editorStyle,
    Widget? header,
    FocusNode? focusNode,
    bool shrinkWrap = false,
  }) : this(
          key: key,
          editorState: editorState,
          scrollController: scrollController,
          editable: editable,
          autoFocus: autoFocus,
          focusedSelection: focusedSelection,
          blockComponentBuilders: standardBlockComponentBuilderMap,
          characterShortcutEvents: standardCharacterShortcutEvents,
          commandShortcutEvents: standardCommandShortcutEvents,
          editorStyle: editorStyle ?? const EditorStyle.desktop(),
          header: header,
          focusNode: focusNode,
          shrinkWrap: shrinkWrap,
        );

  final EditorState editorState;

  final EditorStyle editorStyle;

  final Map<String, BlockComponentBuilder> blockComponentBuilders;

  /// Character event handlers
  final List<CharacterShortcutEvent> characterShortcutEvents;

  // Command event handlers
  final List<CommandShortcutEvent> commandShortcutEvents;

  final ScrollController? scrollController;

  final Positioned Function(
    BuildContext context,
    List<ActionMenuItem> items,
  )? customActionMenuBuilder;

  /// Set the value to false to disable editing.
  final bool editable;

  /// Set the value to true to focus the editor on the start of the document.
  final bool autoFocus;

  final Selection? focusedSelection;

  final Widget? header;

  final FocusNode? focusNode;

  /// if true, the editor will be sized to its contents.
  final bool shrinkWrap;

  /// Render plugins.
  @Deprecated('Use blockComponentBuilders instead.')
  final NodeWidgetBuilders customBuilders;

  @Deprecated('Use FloatingToolbar or MobileToolbar instead.')
  final List<ToolbarItem> toolbarItems;

  /// Keyboard event handlers.
  @Deprecated('Use characterShortcutEvents or commandShortcutEvents instead.')
  final List<ShortcutEvent> shortcutEvents;

  @Deprecated('Customize the style that block component provides instead.')
  final ThemeData? themeData;

  @Deprecated('Use customSlashCommand instead')
  final List<SelectionMenuItem> selectionMenuItems;

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
    editorState.selectionMenuItems = widget.selectionMenuItems;
    editorState.renderer = _renderer;
    editorState.editable = widget.editable;

    // auto focus
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _autoFocusIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant AppFlowyEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    editorState.editorStyle = widget.editorStyle;
    editorState.editable = widget.editable;

    if (editorState.service != oldWidget.editorState.service) {
      editorState.selectionMenuItems = widget.selectionMenuItems;
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServices(BuildContext context) {
    Widget child = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.header != null) widget.header!,
        Container(
          padding: widget.editorStyle.padding,
          child: editorState.renderer.build(
            context,
            editorState.document.root,
          ),
        ),
      ],
    );
    if (widget.editable) {
      child = SelectionServiceWidget(
        key: editorState.service.selectionServiceKey,
        cursorColor: widget.editorStyle.cursorColor,
        selectionColor: widget.editorStyle.selectionColor,
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

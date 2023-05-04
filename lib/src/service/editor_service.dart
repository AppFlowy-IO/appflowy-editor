import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/image_block_component/image_block_component.dart';
import 'package:appflowy_editor/src/flutter/overlay.dart';
import 'package:appflowy_editor/src/service/shortcut_event/built_in_shortcut_events.dart';
import 'package:flutter/material.dart' hide Overlay, OverlayEntry;
import 'package:provider/provider.dart';

const standardBlockComponentConfiguration = BlockComponentConfiguration();

final Map<String, BlockComponentBuilder> standardBlockComponentBuilderMap = {
  'document': DocumentComponentBuilder(),
  'paragraph': const TextBlockComponentBuilder(
    configuration: standardBlockComponentConfiguration,
  ),
  'todo_list': TodoListBlockComponentBuilder(
    configuration: standardBlockComponentConfiguration.copyWith(
      placeholderText: (_) => 'To-do',
    ),
  ),
  'bulleted_list': BulletedListBlockComponentBuilder(
    configuration: standardBlockComponentConfiguration.copyWith(
      placeholderText: (_) => 'List',
    ),
  ),
  'numbered_list': NumberedListBlockComponentBuilder(
    configuration: standardBlockComponentConfiguration.copyWith(
      placeholderText: (_) => 'List',
    ),
  ),
  'quote': QuoteBlockComponentBuilder(
    configuration: standardBlockComponentConfiguration.copyWith(
      placeholderText: (_) => 'Quote',
    ),
  ),
  'heading': HeadingBlockComponentBuilder(
    configuration: standardBlockComponentConfiguration.copyWith(
      placeholderText: (node) =>
          'Heading ${node.attributes[HeadingBlockKeys.level]}',
    ),
  ),
  'image': const ImageBlockComponentBuilder(),
};

final List<CharacterShortcutEvent> standardCharacterShortcutEvents = [
  // '\n'
  insertNewLineAfterBulletedList,
  insertNewLineAfterTodoList,
  insertNewLineAfterNumberedList,
  insertNewLine,

  // bulleted list
  formatAsteriskToBulletedList,
  formatMinusToBulletedList,

  // numbered list
  formatNumberToNumberedList,

  // quote
  formatGreaterToQuote,

  // heading
  formatSignToHeading,

  // checkbox
  // format unchecked box, [] or -[]
  formatEmptyBracketsToUncheckedBox,
  formatHyphenEmptyBracketsToUncheckedBox,

  // format checked box, [x] or -[x]
  formatFilledBracketsToCheckedBox,
  formatHyphenFilledBracketsToCheckedBox,

  // slash
  slashCommand,

  // markdown syntax
  ...markdownSyntaxShortcutEvents,
];

final List<CommandShortcutEvent> standardCommandShortcutEvents = [
  // undo, redo
  undoCommand,
  redoCommand,

  // backspace
  convertToParagraphCommand,
  backspaceCommand,
  deleteLeftWordCommand,
  deleteLeftSentenceCommand,

  // arrow keys
  ...arrowLeftKeys,
  ...arrowRightKeys,
  ...arrowUpKeys,
  ...arrowDownKeys,

  //
  homeCommand,
  endCommand,

  //
  toggleTodoListCommand,
  ...toggleMarkdownCommands,

  //
  indentCommand,
  outdentCommand,

  exitEditingCommand,

  //
  pageUpCommand,
  pageDownCommand,

  //
  selectAllCommand,
];

class AppFlowyEditor extends StatefulWidget {
  AppFlowyEditor({
    Key? key,
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
    this.showDefaultToolbar = true,
    this.shrinkWrap = false,
    this.scrollController,
    ThemeData? themeData,
  }) : super(key: key) {
    this.themeData = themeData ??
        ThemeData.light().copyWith(
          extensions: [
            ...lightEditorStyleExtension,
            ...lightPluginStyleExtension,
          ],
        );
  }

  AppFlowyEditor.standard({
    Key? key,
    required EditorState editorState,
    ScrollController? scrollController,
    bool editable = true,
    bool autoFocus = false,
    ThemeData? themeData,
  }) : this(
          key: key,
          editorState: editorState,
          scrollController: scrollController,
          themeData: themeData,
          editable: editable,
          autoFocus: autoFocus,
          blockComponentBuilders: standardBlockComponentBuilderMap,
          characterShortcutEvents: standardCharacterShortcutEvents,
          commandShortcutEvents: standardCommandShortcutEvents,
        );

  final EditorState editorState;

  /// Render plugins.
  final NodeWidgetBuilders customBuilders;

  final Map<String, BlockComponentBuilder> blockComponentBuilders;

  /// Keyboard event handlers.
  final List<ShortcutEvent> shortcutEvents;

  /// Character event handlers
  final List<CharacterShortcutEvent> characterShortcutEvents;

  // Command event handlers
  final List<CommandShortcutEvent> commandShortcutEvents;

  final bool showDefaultToolbar;
  final List<SelectionMenuItem> selectionMenuItems;

  final List<ToolbarItem> toolbarItems;

  final bool editable;

  /// Set the value to true to focus the editor on the start of the document.
  final bool autoFocus;

  final Selection? focusedSelection;

  final Positioned Function(BuildContext context, List<ActionMenuItem> items)?
      customActionMenuBuilder;

  /// If false the Editor is inside an [AppFlowyScroll]
  final bool shrinkWrap;

  late final ThemeData themeData;

  final ScrollController? scrollController;

  @override
  State<AppFlowyEditor> createState() => _AppFlowyEditorState();
}

class _AppFlowyEditorState extends State<AppFlowyEditor> {
  Widget? services;

  EditorState get editorState => widget.editorState;
  EditorStyle get editorStyle =>
      editorState.themeData.extension<EditorStyle>() ?? EditorStyle.light;

  @override
  void initState() {
    super.initState();

    editorState.selectionMenuItems = widget.selectionMenuItems;
    editorState.toolbarItems = widget.toolbarItems;
    editorState.themeData = widget.themeData;
    editorState.renderer = _blockComponentRendererService;
    editorState.editable = widget.editable;
    editorState.characterShortcutEvents = widget.characterShortcutEvents;

    // auto focus
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
    });
  }

  @override
  void didUpdateWidget(covariant AppFlowyEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (editorState.service != oldWidget.editorState.service) {
      editorState.selectionMenuItems = widget.selectionMenuItems;
      editorState.toolbarItems = widget.toolbarItems;
      editorState.renderer = _blockComponentRendererService;
    }

    editorState.themeData = widget.themeData;
    editorState.editable = widget.editable;
    editorState.characterShortcutEvents = widget.characterShortcutEvents;
    services = null;
  }

  @override
  Widget build(BuildContext context) {
    services ??= _buildServices(context);

    return Provider.value(
      value: editorState,
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (context) => services!,
          ),
        ],
      ),
    );
  }

  Widget _buildScroll({required Widget child}) {
    if (widget.shrinkWrap) {
      return child;
    }

    return AppFlowyScroll(
      // key: editorState.service.scrollServiceKey,
      child: child,
    );
  }

  Widget _buildServices(BuildContext context) {
    return Theme(
      data: widget.themeData,
      child: _buildScroll(
        child: ScrollServiceWidget(
          key: editorState.service.scrollServiceKey,
          scrollController: widget.scrollController,
          child: Container(
            color: editorStyle.backgroundColor,
            padding: editorStyle.padding!,
            child: SelectionServiceWidget(
              key: editorState.service.selectionServiceKey,
              cursorColor: editorStyle.cursorColor!,
              selectionColor: editorStyle.selectionColor!,
              child: AppFlowySelection(
                // key: editorState.service.selectionServiceKey,
                cursorColor: editorStyle.cursorColor!,
                selectionColor: editorStyle.selectionColor!,
                editorState: editorState,
                editable: widget.editable,
                child: KeyboardServiceWidget(
                  characterShortcutEvents: widget.characterShortcutEvents,
                  commandShortcutEvents: widget.commandShortcutEvents,
                  child: AppFlowyInput(
                    key: editorState.service.inputServiceKey,
                    editorState: editorState,
                    editable: widget.editable,
                    child: AppFlowyKeyboard(
                      key: editorState.service.keyboardServiceKey,
                      editable: widget.editable,
                      shortcutEvents: [
                        ...widget.shortcutEvents,
                        ...builtInShortcutEvents,
                      ],
                      editorState: editorState,
                      child: FlowyToolbar(
                        showDefaultToolbar: widget.showDefaultToolbar,
                        key: editorState.service.toolbarServiceKey,
                        editorState: editorState,
                        child: editorState.renderer.build(
                          context,
                          editorState.document.root,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BlockComponentRendererService get _blockComponentRendererService =>
      BlockComponentRenderer(
        builders: {...widget.blockComponentBuilders},
      );
}

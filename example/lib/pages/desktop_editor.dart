import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/drag_to_reorder_editor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DesktopEditor extends StatefulWidget {
  const DesktopEditor({
    super.key,
    required this.editorState,
    this.textDirection = TextDirection.ltr,
  });

  final EditorState editorState;
  final TextDirection textDirection;

  @override
  State<DesktopEditor> createState() => _DesktopEditorState();
}

class _DesktopEditorState extends State<DesktopEditor> {
  EditorState get editorState => widget.editorState;

  late final EditorScrollController editorScrollController;

  late EditorStyle editorStyle;
  late Map<String, BlockComponentBuilder> blockComponentBuilders;
  late List<CommandShortcutEvent> commandShortcuts;

  @override
  void initState() {
    super.initState();

    editorScrollController = EditorScrollController(
      editorState: editorState,
      shrinkWrap: false,
    );

    editorStyle = _buildDesktopEditorStyle();
    blockComponentBuilders = _buildBlockComponentBuilders();
    commandShortcuts = _buildCommandShortcuts();
  }

  @override
  void dispose() {
    editorScrollController.dispose();
    editorState.dispose();

    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();

    editorStyle = _buildDesktopEditorStyle();
    blockComponentBuilders = _buildBlockComponentBuilders();
    commandShortcuts = _buildCommandShortcuts();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingToolbar(
      items: [
        paragraphItem,
        ...headingItems,
        ...markdownFormatItems,
        quoteItem,
        bulletedListItem,
        numberedListItem,
        linkItem,
        buildTextColorItem(),
        buildHighlightColorItem(),
        ...textDirectionItems,
        ...alignmentItems,
      ],
      tooltipBuilder: (context, _, message, child) {
        return Tooltip(
          message: message,
          preferBelow: false,
          child: child,
        );
      },
      editorState: editorState,
      textDirection: widget.textDirection,
      editorScrollController: editorScrollController,
      child: Directionality(
        textDirection: widget.textDirection,
        child: AppFlowyEditor(
          editorState: editorState,
          editorScrollController: editorScrollController,
          blockComponentBuilders: blockComponentBuilders,
          commandShortcutEvents: commandShortcuts,
          editorStyle: editorStyle,
          enableAutoComplete: true,
          autoCompleteTextProvider: _buildAutoCompleteTextProvider,
          dropTargetStyle: const AppFlowyDropTargetStyle(
            color: Colors.red,
          ),
          contextMenuBuilder: (context, position, editorState, onPressed) {
            return ContextMenu(
              position: position,
              editorState: editorState,
              items: standardContextMenuItems,
              onPressed: onPressed,
            );
          },
          header: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Image.asset(
              'assets/images/header.png',
              fit: BoxFit.fitWidth,
              height: 150,
            ),
          ),
          footer: _buildFooter(),
        ),
      ),
    );
  }

  // showcase 1: customize the editor style.
  EditorStyle _buildDesktopEditorStyle() {
    return EditorStyle.desktop(
      cursorWidth: 2.0,
      cursorColor: Colors.blue,
      selectionColor: Colors.grey.shade300,
      textStyleConfiguration: TextStyleConfiguration(
        text: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.black,
        ),
        code: GoogleFonts.architectsDaughter(),
        bold: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      maxWidth: 640,
      textSpanOverlayBuilder: _buildTextSpanOverlay,
    );
  }

  List<Widget> _buildTextSpanOverlay(
    BuildContext context,
    Node node,
    SelectableMixin delegate,
  ) {
    final delta = node.delta;
    if (delta == null) {
      return [];
    }
    final widgets = <Widget>[];
    final textInserts = delta.whereType<TextInsert>();
    int index = 0;
    for (final textInsert in textInserts) {
      final rects = delegate.getRectsInSelection(
        Selection(
          start: Position(path: node.path, offset: index),
          end: Position(
            path: node.path,
            offset: index + textInsert.length,
          ),
        ),
      );
      // Add a hover menu to the linked text.
      if (rects.isNotEmpty && textInsert.attributes?.href != null) {
        widgets.add(
          Positioned(
            left: rects.first.left,
            top: rects.first.top,
            child: HoverMenu(
              child: Container(
                color: Colors.red.withValues(alpha: 0.5),
                width: rects.first.width,
                height: rects.first.height,
              ),
              itemBuilder: (context) => Material(
                color: Colors.blue,
                child: SizedBox(
                  width: 200,
                  height: 48,
                  child: Text(
                    'This is a hover menu:\n${textInsert.attributes?.href}',
                  ),
                ),
              ),
            ),
          ),
        );
      }
      index += textInsert.length;
    }
    return widgets;
  }

  // showcase 2: customize the block style
  Map<String, BlockComponentBuilder> _buildBlockComponentBuilders() {
    final map = {
      ...standardBlockComponentBuilderMap,

      // columns block
      ColumnBlockKeys.type: ColumnBlockComponentBuilder(),
      ColumnsBlockKeys.type: ColumnsBlockComponentBuilder(),
    };
    // customize the image block component to show a menu
    map[ImageBlockKeys.type] = ImageBlockComponentBuilder(
      showMenu: true,
      menuBuilder: (node, _) {
        return const Positioned(
          right: 10,
          child: Text('⭐️ Here is a menu!'),
        );
      },
    );
    // customize the heading block component
    final levelToFontSize = [
      30.0,
      26.0,
      22.0,
      18.0,
      16.0,
      14.0,
    ];
    map[HeadingBlockKeys.type] = HeadingBlockComponentBuilder(
      textStyleBuilder: (level) => GoogleFonts.poppins(
        fontSize: levelToFontSize.elementAtOrNull(level - 1) ?? 14.0,
        fontWeight: FontWeight.w600,
      ),
    );
    // customize the padding
    map.forEach((key, value) {
      value.configuration = value.configuration.copyWith(
        padding: (node) {
          if (node.type == ColumnsBlockKeys.type ||
              node.type == ColumnBlockKeys.type) {
            return EdgeInsets.zero;
          }
          return const EdgeInsets.symmetric(vertical: 8.0);
        },
        blockSelectionAreaMargin: (_) => const EdgeInsets.symmetric(
          vertical: 1.0,
        ),
      );

      if (key != PageBlockKeys.type) {
        value.showActions = (_) => true;
        value.actionBuilder = (context, actionState) {
          return DragToReorderAction(
            blockComponentContext: context,
            builder: value,
          );
        };
      }
    });
    return map;
  }

  // showcase 3: customize the command shortcuts
  List<CommandShortcutEvent> _buildCommandShortcuts() {
    return [
      // customize the highlight color
      customToggleHighlightCommand(
        style: ToggleColorsStyle(
          highlightColor: Colors.orange.shade700,
        ),
      ),
      ...[
        ...standardCommandShortcutEvents
          ..removeWhere(
            (el) => el == toggleHighlightCommand,
          ),
      ],
      ...findAndReplaceCommands(
        context: context,
        localizations: FindReplaceLocalizations(
          find: 'Find',
          previousMatch: 'Previous match',
          nextMatch: 'Next match',
          close: 'Close',
          replace: 'Replace',
          replaceAll: 'Replace all',
          noResult: 'No result',
        ),
      ),
    ];
  }

  Widget _buildFooter() {
    return SizedBox(
      height: 100,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          // check if the document is empty, if so, add a new paragraph block.
          if (editorState.document.root.children.isEmpty) {
            final transaction = editorState.transaction;
            transaction.insertNode(
              [0],
              paragraphNode(),
            );
            await editorState.apply(transaction);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              editorState.selection = Selection.collapsed(
                Position(path: [0]),
              );
            });
          }
        },
      ),
    );
  }

  String? _buildAutoCompleteTextProvider(
    BuildContext context,
    Node node,
    TextSpan? textSpan,
  ) {
    final editorState = context.read<EditorState>();
    final selection = editorState.selection;
    final delta = node.delta;
    if (selection == null ||
        delta == null ||
        !selection.isCollapsed ||
        selection.endIndex != delta.length ||
        !node.path.equals(selection.start.path)) {
      return null;
    }
    final text = delta.toPlainText();
    // An example, if the text ends with 'hello', then show the autocomplete.
    if (text.endsWith('hello')) {
      return ' world';
    }
    return null;
  }
}

class HoverMenu extends StatefulWidget {
  final Widget child;
  final WidgetBuilder itemBuilder;

  const HoverMenu({
    super.key,
    required this.child,
    required this.itemBuilder,
  });

  @override
  HoverMenuState createState() => HoverMenuState();
}

class HoverMenuState extends State<HoverMenu> {
  OverlayEntry? overlayEntry;

  bool canCancelHover = true;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (details) {
        overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(overlayEntry!);
      },
      onExit: (details) {
        // delay the removal of the overlay entry to avoid flickering.
        Future.delayed(const Duration(milliseconds: 100), () {
          if (canCancelHover) {
            overlayEntry?.remove();
          }
        });
      },
      child: widget.child,
    );
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        child: MouseRegion(
          cursor: SystemMouseCursors.text,
          hitTestBehavior: HitTestBehavior.opaque,
          onEnter: (details) {
            canCancelHover = false;
          },
          onExit: (details) {
            canCancelHover = true;
          },
          child: widget.itemBuilder(context),
        ),
      ),
    );
  }
}

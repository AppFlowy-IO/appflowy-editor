import 'package:appflowy_editor/appflowy_editor.dart';
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
    assert(PlatformExtension.isDesktopOrWeb);
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
          header: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Image.asset(
              'assets/images/header.png',
              fit: BoxFit.fitWidth,
              height: 150,
            ),
          ),
          footer: const SizedBox(
            height: 100,
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 200.0),
    );
  }

  // showcase 2: customize the block style
  Map<String, BlockComponentBuilder> _buildBlockComponentBuilders() {
    final map = {
      ...standardBlockComponentBuilderMap,
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
        padding: (_) => const EdgeInsets.symmetric(vertical: 8.0),
      );
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

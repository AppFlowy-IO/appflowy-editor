import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MobileEditor extends StatefulWidget {
  const MobileEditor({
    super.key,
    required this.editorState,
    required this.onEditorStateChange,
    this.editorStyle,
  });

  final EditorState editorState;
  final EditorStyle? editorStyle;
  final void Function(EditorState editorState) onEditorStateChange;

  @override
  State<MobileEditor> createState() => _MobileEditorState();
}

class _MobileEditorState extends State<MobileEditor> {
  EditorState get editorState => widget.editorState;

  late final EditorScrollController editorScrollController;

  late EditorStyle editorStyle;
  late Map<String, BlockComponentBuilder> blockComponentBuilders;

  @override
  void initState() {
    super.initState();

    // customize the log configuration
    editorState.logConfiguration
      ..handler = debugPrint
      ..level = LogLevel.off;

    // listen to editor state change
    editorState.transactionStream.listen((event) {
      if (event.$1 == TransactionTime.after) {
        widget.onEditorStateChange(editorState);
      }
    });

    editorScrollController = EditorScrollController(
      editorState: editorState,
      shrinkWrap: false,
    );

    editorStyle = _buildMobileEditorStyle();
    blockComponentBuilders = _buildBlockComponentBuilders();
  }

  @override
  void reassemble() {
    super.reassemble();

    editorStyle = _buildMobileEditorStyle();
    blockComponentBuilders = _buildBlockComponentBuilders();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // build appflowy editor
        Expanded(
          child: AppFlowyEditor(
            editorStyle: editorStyle,
            editorState: editorState,
            editorScrollController: editorScrollController,
            blockComponentBuilders: blockComponentBuilders,
            // showcase 3: customize the header and footer.
            header: Image.asset(
              'assets/images/icon.jpeg',
              fit: BoxFit.fitWidth,
              height: 100,
            ),
            footer: const SizedBox(
              height: 100,
            ),
          ),
        ),
        // build mobile toolbar
        MobileToolbar(
          editorState: editorState,
          toolbarItems: [
            textDecorationMobileToolbarItem,
            buildTextAndBackgroundColorMobileToolbarItem(),
            headingMobileToolbarItem,
            todoListMobileToolbarItem,
            listMobileToolbarItem,
            linkMobileToolbarItem,
            quoteMobileToolbarItem,
            dividerMobileToolbarItem,
            codeMobileToolbarItem,
          ],
        ),
      ],
    );
  }

  // showcase 1: customize the editor style.
  EditorStyle _buildMobileEditorStyle() {
    return EditorStyle.mobile(
      cursorColor: Colors.blue,
      selectionColor: Colors.blue.shade200,
      textStyleConfiguration: TextStyleConfiguration(
        text: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black,
        ),
        code: GoogleFonts.badScript(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
    );
  }

  // showcase 2: customize the block style
  Map<String, BlockComponentBuilder> _buildBlockComponentBuilders() {
    final map = {
      ...standardBlockComponentBuilderMap,
    };
    // customize the heading block component
    final levelToFontSize = [
      24.0,
      22.0,
      20.0,
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
    return map;
  }
}

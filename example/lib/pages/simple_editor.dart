import 'dart:convert';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class SimpleEditor extends StatelessWidget {
  const SimpleEditor({
    super.key,
    required this.jsonString,
    required this.themeData,
    required this.onEditorStateChange,
  });

  final Future<String> jsonString;
  final ThemeData themeData;
  final void Function(EditorState editorState) onEditorStateChange;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: jsonString,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          final editorState = EditorState(
            document: Document.fromJson(
              Map<String, Object>.from(
                json.decode(snapshot.data!),
              ),
            ),
          );
          editorState.logConfiguration
            ..handler = debugPrint
            ..level = LogLevel.all;
          onEditorStateChange(editorState);
          final scrollController = ScrollController();
          if (PlatformExtension.isDesktopOrWeb) {
            return FloatingToolbar(
              items: [
                paragraphItem,
                ...headingItems,
                placeholderItem,
                ...markdownFormatItems,
                placeholderItem,
                quoteItem,
                bulletedListItem,
                numberedListItem,
                placeholderItem,
                linkItem,
                colorItem,
              ],
              editorState: editorState,
              scrollController: scrollController,
              child: _buildEditor(
                context,
                editorState,
                scrollController,
              ),
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: _buildEditor(context, editorState, scrollController),
                ),
                if (Platform.isIOS || Platform.isAndroid)
                  _buildMobileToolbar(context, editorState),
              ],
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildEditor(
    BuildContext context,
    EditorState editorState,
    ScrollController? scrollController,
  ) {
    return AppFlowyEditor(
      editorState: editorState,
      themeData: themeData,
      autoFocus: editorState.document.isEmpty,
      scrollController: scrollController,
      blockComponentBuilders: {
        'document': DocumentComponentBuilder(),
        'paragraph': TextBlockComponentBuilder(),
        'todo_list': TodoListBlockComponentBuilder(),
        'bulleted_list': BulletedListBlockComponentBuilder(),
        'numbered_list': NumberedListBlockComponentBuilder(),
        'quote': QuoteBlockComponentBuilder(),
        'heading': HeadingBlockComponentBuilder(),
      },
      characterShortcutEvents: [
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
      ],
      commandShortcutEvents: [
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
      ],
    );
  }

  Widget _buildMobileToolbar(BuildContext context, EditorState editorState) {
    return MobileToolbar(editorState: editorState);
  }
}

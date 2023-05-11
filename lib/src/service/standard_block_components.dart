import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/image_block_component/image_block_component.dart';

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
  showLinkMenuCommand,

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

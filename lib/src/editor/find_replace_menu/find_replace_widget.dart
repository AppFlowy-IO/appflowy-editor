import 'package:appflowy_editor/appflowy_editor.dart';
import 'find_replace_menu_icon_button.dart';
import 'package:flutter/material.dart';

const double _iconButtonSize = 30;

class FindAndReplaceMenuWidget extends StatefulWidget {
  const FindAndReplaceMenuWidget({
    super.key,
    this.localizations,
    this.defaultFindText = '',
    this.caseSensitive = false,
    required this.onDismiss,
    required this.editorState,
    required this.showReplaceMenu,
    required this.style,
    this.showRegexButton = true,
    this.showCaseSensitiveButton = true,
  });

  final EditorState editorState;
  final VoidCallback onDismiss;

  /// Whether to show the replace menu or not
  final bool showReplaceMenu;

  /// The style of the find and replace menu
  ///
  /// only works for SearchService, not for SearchServiceV2
  final FindReplaceStyle style;
  final bool showRegexButton;
  final bool showCaseSensitiveButton;

  /// The localizations of the find and replace menu
  final FindReplaceLocalizations? localizations;

  /// The default text to search for
  final String defaultFindText;

  /// Whether the search should be case sensitive or not
  final bool caseSensitive;

  @override
  State<FindAndReplaceMenuWidget> createState() =>
      _FindAndReplaceMenuWidgetState();
}

class _FindAndReplaceMenuWidgetState extends State<FindAndReplaceMenuWidget> {
  final focusNode = FocusNode();
  final replaceFocusNode = FocusNode();
  final findController = TextEditingController();
  final replaceController = TextEditingController();
  String queriedPattern = '';
  bool showRegexButton = true;
  bool showCaseSensitiveButton = true;
  bool showReplaceMenu = false;

  late SearchServiceV3 searchService = SearchServiceV3(
    editorState: widget.editorState,
  );

  @override
  void initState() {
    super.initState();
    showReplaceMenu = widget.showReplaceMenu;
    showRegexButton = widget.showRegexButton;
    showCaseSensitiveButton = widget.showCaseSensitiveButton;

    showReplaceMenu = widget.showReplaceMenu;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: FindMenu(
            onDismiss: widget.onDismiss,
            editorState: widget.editorState,
            style: widget.style,
            searchService: searchService,
            defaultFindText: widget.defaultFindText,
            caseSensitive: widget.caseSensitive,
            localizations: widget.localizations,
            showReplaceMenu: showReplaceMenu,
            onShowReplace: (value) => setState(() {
              showReplaceMenu = value;
            }),
          ),
        ),
        showReplaceMenu
            ? Padding(
                padding: const EdgeInsets.only(
                  bottom: 8.0,
                ),
                child: ReplaceMenu(
                  editorState: widget.editorState,
                  searchService: searchService,
                  localizations: widget.localizations,
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

class FindMenu extends StatefulWidget {
  const FindMenu({
    super.key,
    this.localizations,
    this.defaultFindText = '',
    this.caseSensitive = false,
    this.showReplaceMenu = false,
    required this.onDismiss,
    required this.editorState,
    required this.style,
    required this.searchService,
    required this.onShowReplace,
    this.showRegexButton = true,
    this.showCaseSensitiveButton = true,
  });

  final EditorState editorState;
  final VoidCallback onDismiss;

  /// The style of the find and replace menu
  ///
  /// only works for SearchService, not for SearchServiceV2
  final FindReplaceStyle style;

  /// The localizations of the find and replace menu
  final FindReplaceLocalizations? localizations;

  /// The default text to search for
  final String defaultFindText;

  /// Whether the search should be case sensitive or not
  final bool caseSensitive;

  /// Whether to show the replace menu or not
  final bool showReplaceMenu;

  final bool showRegexButton;
  final bool showCaseSensitiveButton;

  final void Function(bool showReplaceMenu) onShowReplace;

  final SearchServiceV3 searchService;

  @override
  State<FindMenu> createState() => _FindMenuState();
}

class _FindMenuState extends State<FindMenu> {
  final findTextFieldFocusNode = FocusNode();

  final findTextEditingController = TextEditingController();

  String queriedPattern = '';

  bool showReplaceMenu = false;
  bool caseSensitive = false;

  bool showRegexButton = true;
  bool showCaseSensitiveButton = true;

  @override
  void initState() {
    super.initState();

    showReplaceMenu = widget.showReplaceMenu;
    caseSensitive = widget.caseSensitive;

    showRegexButton = widget.showRegexButton;
    showCaseSensitiveButton = widget.showCaseSensitiveButton;

    widget.searchService.matchWrappes.addListener(_setState);
    widget.searchService.currentSelectedIndex.addListener(_setState);

    findTextEditingController.addListener(_searchPattern);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      findTextFieldFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.searchService.matchWrappes.removeListener(_setState);
    widget.searchService.currentSelectedIndex.removeListener(_setState);
    widget.searchService.dispose();
    findTextEditingController.removeListener(_searchPattern);
    findTextEditingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // the selectedIndex from searchService is 0-based
    final selectedIndex = widget.searchService.selectedIndex + 1;
    final matches = widget.searchService.matchWrappes.value;
    return Row(
      children: [
        // expand/collapse button
        FindAndReplaceMenuIconButton(
          icon: Icon(
            showReplaceMenu ? Icons.expand_less : Icons.expand_more,
          ),
          onPressed: () {
            widget.onShowReplace(!showReplaceMenu);
            setState(() {
              showReplaceMenu = !showReplaceMenu;
            });
          },
        ),
        // find text field
        SizedBox(
          width: 200,
          height: 30,
          child: TextField(
            key: const Key('findTextField'),
            focusNode: findTextFieldFocusNode,
            controller: findTextEditingController,
            onSubmitted: (_) {
              widget.searchService.navigateToMatch();

              // after update selection or navigate to match, the editor
              //  will request focus, here's a workaround to request the
              //  focus back to the findTextField
              Future.delayed(const Duration(milliseconds: 50), () {
                FocusScope.of(context).requestFocus(
                  findTextFieldFocusNode,
                );
              });
            },
            decoration: _buildInputDecoration(
              widget.localizations?.find ??
                  AppFlowyEditorLocalizations.current.find,
            ),
          ),
        ),
        // the count of matches
        Container(
          constraints: const BoxConstraints(minWidth: 80),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            matches.isEmpty
                ? widget.localizations?.noResult ?? 'No Result'
                : '$selectedIndex of ${matches.length}',
          ),
        ),
        // previous match button
        FindAndReplaceMenuIconButton(
          iconButtonKey: const Key('previousMatchButton'),
          onPressed: () => widget.searchService.navigateToMatch(moveUp: true),
          icon: const Icon(Icons.arrow_upward),
          tooltip: widget.localizations?.previousMatch ??
              AppFlowyEditorLocalizations.current.previousMatch,
        ),
        // next match button
        FindAndReplaceMenuIconButton(
          iconButtonKey: const Key('nextMatchButton'),
          onPressed: () => widget.searchService.navigateToMatch(),
          icon: const Icon(Icons.arrow_downward),
          tooltip: widget.localizations?.nextMatch ??
              AppFlowyEditorLocalizations.current.nextMatch,
        ),
        FindAndReplaceMenuIconButton(
          iconButtonKey: const Key('closeButton'),
          onPressed: widget.onDismiss,
          icon: const Icon(Icons.close),
          tooltip: widget.localizations?.close ??
              AppFlowyEditorLocalizations.current.closeFind,
        ),
        // regex button
        if (showRegexButton)
          FindAndReplaceMenuIconButton(
            key: const Key('findRegexButton'),
            onPressed: () {
              setState(() {
                widget.searchService.regex = !widget.searchService.regex;
              });
              _searchPattern();
            },
            icon: EditorSvg(
              name: 'regex',
              width: 20,
              height: 20,
              color: widget.searchService.regex ? Colors.black : Colors.grey,
            ),
            tooltip: AppFlowyEditorLocalizations.current.regex,
          ),
        // case sensitive button
        if (showCaseSensitiveButton)
          FindAndReplaceMenuIconButton(
            key: const Key('caseSensitiveButton'),
            onPressed: () {
              setState(() {
                widget.searchService.caseSensitive =
                    !widget.searchService.caseSensitive;
              });
              _searchPattern();
            },
            icon: EditorSvg(
              name: 'case_sensitive',
              width: 20,
              height: 20,
              color: widget.searchService.caseSensitive
                  ? Colors.black
                  : Colors.grey,
            ),
            tooltip: AppFlowyEditorLocalizations.current.caseSensitive,
          ),
      ],
    );
  }

  void _searchPattern() {
    if (findTextEditingController.text.isEmpty) {
      return;
    }
    widget.searchService.findAndHighlight(findTextEditingController.text);
    setState(() => queriedPattern = findTextEditingController.text);
  }

  void _setState() {
    setState(() {});
  }
}

class ReplaceMenu extends StatefulWidget {
  const ReplaceMenu({
    super.key,
    required this.editorState,
    required this.searchService,
    this.localizations,
  });

  final EditorState editorState;

  /// The localizations of the find and replace menu
  final FindReplaceLocalizations? localizations;

  final SearchServiceV3 searchService;

  @override
  State<ReplaceMenu> createState() => _ReplaceMenuState();
}

class _ReplaceMenuState extends State<ReplaceMenu> {
  final replaceTextFieldFocusNode = FocusNode();
  final replaceTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // placeholder for aligning the replace menu
        const SizedBox(
          width: _iconButtonSize,
        ),
        SizedBox(
          width: 200,
          height: 30,
          child: TextField(
            key: const Key('replaceTextField'),
            focusNode: replaceTextFieldFocusNode,
            autofocus: false,
            controller: replaceTextEditingController,
            onSubmitted: (_) {
              _replaceSelectedWord();

              Future.delayed(const Duration(milliseconds: 50), () {
                FocusScope.of(context).requestFocus(
                  replaceTextFieldFocusNode,
                );
              });
            },
            decoration: _buildInputDecoration(
              widget.localizations?.replace ??
                  AppFlowyEditorLocalizations.current.replace,
            ),
          ),
        ),
        FindAndReplaceMenuIconButton(
          iconButtonKey: const Key('replaceSelectedButton'),
          onPressed: _replaceSelectedWord,
          icon: const Icon(Icons.find_replace),
          tooltip: widget.localizations?.replace ??
              AppFlowyEditorLocalizations.current.replace,
        ),
        FindAndReplaceMenuIconButton(
          iconButtonKey: const Key('replaceAllButton'),
          onPressed: () => widget.searchService.replaceAllMatches(
            replaceTextEditingController.text,
          ),
          icon: const Icon(Icons.change_circle_outlined),
          tooltip: widget.localizations?.replaceAll ??
              AppFlowyEditorLocalizations.current.replaceAll,
        ),
      ],
    );
  }

  void _replaceSelectedWord() {
    widget.searchService.replaceSelectedWord(replaceTextEditingController.text);
  }
}

InputDecoration _buildInputDecoration(String hintText) {
  return InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    border: const OutlineInputBorder(),
    hintText: hintText,
  );
}

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/find_replace_menu/search_service.dart';
import 'package:flutter/material.dart';

const double _iconSize = 20;
const double _iconButtonSize = 40;

class FindMenuWidget extends StatefulWidget {
  const FindMenuWidget({
    super.key,
    required this.dismiss,
    required this.editorState,
    required this.replaceFlag,
    this.localizations,
    required this.style,
  });

  final VoidCallback dismiss;
  final EditorState editorState;
  final bool replaceFlag;
  final FindReplaceLocalizations? localizations;
  final FindReplaceStyle style;

  @override
  State<FindMenuWidget> createState() => _FindMenuWidgetState();
}

class _FindMenuWidgetState extends State<FindMenuWidget> {
  final focusNode = FocusNode();
  final replaceFocusNode = FocusNode();
  final findController = TextEditingController();
  final replaceController = TextEditingController();
  String queriedPattern = '';
  bool replaceFlag = false;
  late SearchService searchService;

  @override
  void initState() {
    super.initState();
    replaceFlag = widget.replaceFlag;
    searchService = SearchService(
      editorState: widget.editorState,
      style: SearchStyle(
        selectedHighlightColor: widget.style.selectedHighlightColor,
        unselectedHighlightColor: widget.style.unselectedHighlightColor,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    findController.addListener(_searchPattern);
  }

  @override
  void dispose() {
    findController.removeListener(_searchPattern);
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _iconButton(
              onPressed: () => setState(
                () => replaceFlag = !replaceFlag,
              ),
              iconSize: _iconSize,
              icon: replaceFlag
                  ? const Icon(Icons.expand_less)
                  : const Icon(Icons.expand_more),
            ),
            SizedBox(
              width: 200,
              height: 30,
              child: TextField(
                key: const Key('findTextField'),
                focusNode: focusNode,
                controller: findController,
                onSubmitted: (_) {
                  searchService.navigateToMatch();

                  // Workaround for editor forcing focus
                  Future.delayed(const Duration(milliseconds: 50)).then(
                    (value) => FocusScope.of(context).requestFocus(focusNode),
                  );
                },
                decoration: _buildInputDecoration(
                  widget.localizations?.find ??
                      AppFlowyEditorLocalizations.current.find,
                ),
              ),
            ),
            _iconButton(
              key: const Key('previousMatchButton'),
              iconSize: _iconSize,
              onPressed: () => searchService.navigateToMatch(moveUp: true),
              icon: const Icon(Icons.arrow_upward),
              tooltip: widget.localizations?.previousMatch ??
                  AppFlowyEditorLocalizations.current.previousMatch,
            ),
            _iconButton(
              key: const Key('nextMatchButton'),
              iconSize: _iconSize,
              onPressed: () => searchService.navigateToMatch(),
              icon: const Icon(Icons.arrow_downward),
              tooltip: widget.localizations?.nextMatch ??
                  AppFlowyEditorLocalizations.current.nextMatch,
            ),
            _iconButton(
              key: const Key('closeButton'),
              iconSize: _iconSize,
              onPressed: () {
                widget.dismiss();
                searchService.findAndHighlight(
                  queriedPattern,
                  unhighlight: true,
                );
                queriedPattern = '';
              },
              icon: const Icon(Icons.close),
              tooltip: widget.localizations?.close ??
                  AppFlowyEditorLocalizations.current.closeFind,
            ),
            _iconButton(
              key: const Key('findRegex'),
              iconSize: _iconSize,
              onPressed: () {
                setState(() {
                  searchService.isRegex = !searchService.isRegex;
                });
              },
              icon: Text(
                'R*',
                style: TextStyle(
                  color: searchService.isRegex ? Colors.black : Colors.grey,
                ),
              ),
              tooltip: AppFlowyEditorLocalizations.current.regex,
            ),
            _iconButton(
              key: const Key('caseSensitive'),
              iconSize: _iconSize,
              onPressed: () {
                setState(() {
                  searchService.caseSensitive = !searchService.caseSensitive;
                });
              },
              icon: Text(
                'Cc',
                style: TextStyle(
                  color:
                      searchService.caseSensitive ? Colors.black : Colors.grey,
                ),
              ),
              tooltip: AppFlowyEditorLocalizations.current.caseSensitive,
            ),
          ],
        ),
        replaceFlag
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 2 * _iconSize,
                  ),
                  SizedBox(
                    width: 200,
                    height: 30,
                    child: TextField(
                      key: const Key('replaceTextField'),
                      focusNode: replaceFocusNode,
                      autofocus: false,
                      controller: replaceController,
                      onSubmitted: (_) {
                        _replaceSelectedWord();

                        Future.delayed(const Duration(milliseconds: 50)).then(
                          (value) => FocusScope.of(context)
                              .requestFocus(replaceFocusNode),
                        );
                      },
                      decoration: _buildInputDecoration(
                        widget.localizations?.replace ??
                            AppFlowyEditorLocalizations.current.replace,
                      ),
                    ),
                  ),
                  _iconButton(
                    key: const Key('replaceSelectedButton'),
                    onPressed: () => _replaceSelectedWord(),
                    icon: const Icon(Icons.find_replace),
                    iconSize: _iconSize,
                    tooltip: widget.localizations?.replace ??
                        AppFlowyEditorLocalizations.current.replace,
                  ),
                  _iconButton(
                    key: const Key('replaceAllButton'),
                    onPressed: () => _replaceAllMatches(),
                    icon: const Icon(Icons.change_circle_outlined),
                    iconSize: _iconSize,
                    tooltip: widget.localizations?.replaceAll ??
                        AppFlowyEditorLocalizations.current.replaceAll,
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _iconButton({
    Key? key,
    VoidCallback? onPressed,
    required Widget icon,
    double? iconSize,
    String? tooltip,
  }) {
    return SizedBox(
      width: _iconButtonSize,
      height: _iconButtonSize,
      child: IconButton(
        key: key,
        onPressed: onPressed,
        icon: icon,
        iconSize: iconSize,
        tooltip: tooltip,
      ),
    );
  }

  void _searchPattern() {
    searchService.findAndHighlight(findController.text);
    setState(() => queriedPattern = findController.text);
  }

  void _replaceSelectedWord() {
    if (findController.text != queriedPattern) {
      _searchPattern();
    }
    searchService.replaceSelectedWord(replaceController.text);
  }

  void _replaceAllMatches() {
    if (findController.text != queriedPattern) {
      _searchPattern();
    }
    searchService.replaceAllMatches(replaceController.text);
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      border: const OutlineInputBorder(),
      hintText: hintText,
    );
  }
}

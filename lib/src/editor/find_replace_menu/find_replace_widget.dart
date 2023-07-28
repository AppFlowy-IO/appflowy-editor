import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/find_replace_menu/search_service.dart';
import 'package:flutter/material.dart';

const double _iconSize = 20;

class FindMenuWidget extends StatefulWidget {
  const FindMenuWidget({
    super.key,
    required this.dismiss,
    required this.editorState,
    required this.replaceFlag,
    required this.localizations,
    required this.style,
  });

  final VoidCallback dismiss;
  final EditorState editorState;
  final bool replaceFlag;
  final FindReplaceLocalizations localizations;
  final FindReplaceStyle style;

  @override
  State<FindMenuWidget> createState() => _FindMenuWidgetState();
}

class _FindMenuWidgetState extends State<FindMenuWidget> {
  final focusNode = FocusNode();
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
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(
                () => replaceFlag = !replaceFlag,
              ),
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
                onSubmitted: (_) => searchService.navigateToMatch(),
                decoration: _buildInputDecoration(widget.localizations.find),
              ),
            ),
            IconButton(
              key: const Key('previousMatchButton'),
              iconSize: _iconSize,
              onPressed: () => searchService.navigateToMatch(moveUp: true),
              icon: const Icon(Icons.arrow_upward),
              tooltip: widget.localizations.previousMatch,
            ),
            IconButton(
              key: const Key('nextMatchButton'),
              iconSize: _iconSize,
              onPressed: () => searchService.navigateToMatch(),
              icon: const Icon(Icons.arrow_downward),
              tooltip: widget.localizations.nextMatch,
            ),
            IconButton(
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
              tooltip: widget.localizations.close,
            ),
          ],
        ),
        replaceFlag
            ? Row(
                children: [
                  SizedBox(
                    width: 200,
                    height: 30,
                    child: TextField(
                      key: const Key('replaceTextField'),
                      autofocus: false,
                      controller: replaceController,
                      onSubmitted: (_) => _replaceSelectedWord(),
                      decoration:
                          _buildInputDecoration(widget.localizations.replace),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _replaceSelectedWord(),
                    icon: const Icon(Icons.find_replace),
                    iconSize: _iconSize,
                    tooltip: widget.localizations.replace,
                  ),
                  IconButton(
                    key: const Key('replaceAllButton'),
                    onPressed: () => _replaceAllMatches(),
                    icon: const Icon(Icons.change_circle_outlined),
                    iconSize: _iconSize,
                    tooltip: widget.localizations.replaceAll,
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ],
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

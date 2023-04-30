import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/render/find_replace_menu/search_service.dart';
import 'package:flutter/material.dart';

class FindMenuWidget extends StatefulWidget {
  const FindMenuWidget({
    super.key,
    required this.dismiss,
    required this.editorState,
  });

  final VoidCallback dismiss;
  final EditorState editorState;

  @override
  State<FindMenuWidget> createState() => _FindMenuWidgetState();
}

class _FindMenuWidgetState extends State<FindMenuWidget> {
  final findController = TextEditingController();
  final replaceController = TextEditingController();
  String queriedPattern = '';
  bool replaceFlag = false;
  late SearchService searchService;

  @override
  void initState() {
    super.initState();
    searchService = SearchService(
      editorState: widget.editorState,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() {
                replaceFlag = !replaceFlag;
              }),
              icon: replaceFlag
                  ? const Icon(Icons.expand_less)
                  : const Icon(Icons.expand_more),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: SizedBox(
                width: 200,
                height: 50,
                child: TextField(
                  autofocus: true,
                  controller: findController,
                  onSubmitted: (_) => _searchPattern(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter text to search',
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _navigateToMatchedIndex(moveUp: true),
              icon: const Icon(Icons.arrow_upward),
              tooltip: 'Previous Match',
            ),
            IconButton(
              onPressed: () => _navigateToMatchedIndex(),
              icon: const Icon(Icons.arrow_downward),
              tooltip: 'Next Match',
            ),
            IconButton(
              onPressed: () {
                widget.dismiss();
                searchService.unHighlight(queriedPattern);
                setState(() {
                  queriedPattern = '';
                });
              },
              icon: const Icon(Icons.close),
              tooltip: 'Close',
            ),
          ],
        ),
        replaceFlag
            ? Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: SizedBox(
                      width: 200,
                      height: 50,
                      child: TextField(
                        autofocus: false,
                        controller: replaceController,
                        onSubmitted: (_) => _replaceSelectedWord(),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Replace',
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _replaceSelectedWord(),
                    icon: const Icon(Icons.find_replace),
                    tooltip: 'Replace',
                  ),
                  IconButton(
                    onPressed: () => _replaceAllMatches(),
                    icon: const Icon(Icons.change_circle_outlined),
                    tooltip: 'Replace All',
                  ),
                ],
              )
            : const SizedBox(height: 0),
      ],
    );
  }

  void _searchPattern() {
    searchService.findAndHighlight(findController.text);
    setState(() {
      queriedPattern = findController.text;
    });
  }

  void _navigateToMatchedIndex({bool moveUp = false}) {
    searchService.navigateToMatch(moveUp);
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
}

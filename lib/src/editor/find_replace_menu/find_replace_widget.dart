import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/find_replace_menu/search_service.dart';
import 'package:appflowy_editor/src/editor/find_replace_menu/search_service_v2.dart';
import 'package:flutter/material.dart';

const double _iconSize = 15;
const double _iconButtonSize = 30;

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
  late SearchServiceV2 searchService;

  bool caseSensitive = false;

  @override
  void initState() {
    super.initState();
    replaceFlag = widget.replaceFlag;
    searchService = SearchServiceV2(
      editorState: widget.editorState,
      style: SearchStyle(
        selectedHighlightColor: widget.style.selectedHighlightColor,
        unselectedHighlightColor: widget.style.unselectedHighlightColor,
      ),
    );
    searchService.matchedPositions.addListener(() {
      setState(() {});
    });
    searchService.currentSelectedIndex.addListener(() {
      setState(() {});
    });

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
    final selectedIndex = searchService.selectedIndex + 1;
    final matches = searchService.matchedPositions.value;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              FindMenuIconButton(
                buttonKey: const Key('expandButton'),
                iconSize: _iconSize,
                onPressed: () {
                  setState(
                    () => replaceFlag = !replaceFlag,
                  );
                },
                icon: Icon(
                  replaceFlag ? Icons.expand_less : Icons.expand_more,
                  size: _iconSize,
                ),
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
              Container(
                constraints: const BoxConstraints(minWidth: 80),
                child: Center(
                  child: Text(
                    matches.isEmpty
                        ? 'No results'
                        : '$selectedIndex of ${matches.length}',
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color:
                      caseSensitive ? Colors.blue.shade400 : Colors.transparent,
                  borderRadius: BorderRadius.circular(0.0),
                ),
                child: FindMenuIconButton(
                  buttonKey: const Key('previousMatchButton'),
                  iconSize: _iconSize,
                  onPressed: () => setState(() {
                    caseSensitive = !caseSensitive;
                    searchService.caseSensitive = caseSensitive;
                  }),
                  icon: const Icon(Icons.keyboard_capslock),
                  tooltip: 'Aa',
                ),
              ),
              FindMenuIconButton(
                buttonKey: const Key('previousMatchButton'),
                iconSize: _iconSize,
                onPressed: () => searchService.navigateToMatch(moveUp: true),
                icon: const Icon(Icons.arrow_upward),
                tooltip: widget.localizations?.previousMatch ??
                    AppFlowyEditorLocalizations.current.previousMatch,
              ),
              FindMenuIconButton(
                buttonKey: const Key('nextMatchButton'),
                iconSize: _iconSize,
                onPressed: () => searchService.navigateToMatch(),
                icon: const Icon(Icons.arrow_downward),
                tooltip: widget.localizations?.nextMatch ??
                    AppFlowyEditorLocalizations.current.nextMatch,
              ),
              FindMenuIconButton(
                buttonKey: const Key('closeButton'),
                iconSize: _iconSize,
                onPressed: () {
                  widget.dismiss();
                  searchService.findAndHighlight(
                    queriedPattern,
                    unHighlight: true,
                  );
                  queriedPattern = '';
                },
                icon: const Icon(Icons.close),
                tooltip: widget.localizations?.close ??
                    AppFlowyEditorLocalizations.current.closeFind,
              ),
            ],
          ),
        ),
        replaceFlag
            ? Padding(
                padding: const EdgeInsets.only(
                  bottom: 8.0,
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: _iconButtonSize,
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
                    FindMenuIconButton(
                      buttonKey: const Key('replaceSelectedButton'),
                      onPressed: () => _replaceSelectedWord(),
                      icon: const Icon(Icons.find_replace),
                      iconSize: _iconSize,
                      tooltip: widget.localizations?.replace ??
                          AppFlowyEditorLocalizations.current.replace,
                    ),
                    FindMenuIconButton(
                      buttonKey: const Key('replaceAllButton'),
                      onPressed: () => _replaceAllMatches(),
                      icon: const Icon(Icons.change_circle_outlined),
                      iconSize: _iconSize,
                      tooltip: widget.localizations?.replaceAll ??
                          AppFlowyEditorLocalizations.current.replaceAll,
                    ),
                  ],
                ),
              )
            : const SizedBox(),
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

class FindMenuIconButton extends StatelessWidget {
  const FindMenuIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconSize,
    this.tooltip,
    this.buttonKey,
  });

  final Widget icon;
  final Key? buttonKey;
  final VoidCallback? onPressed;
  final double? iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _iconButtonSize,
      height: _iconButtonSize,
      child: IconButton(
        key: buttonKey,
        onPressed: onPressed,
        icon: icon,
        iconSize: iconSize,
        tooltip: tooltip,
      ),
    );
  }
}

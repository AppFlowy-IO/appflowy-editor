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
  final controller = TextEditingController();
  String queriedPattern = '';
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
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: SizedBox(
            width: 200,
            height: 50,
            child: TextField(
              autofocus: true,
              controller: controller,
              onSubmitted: (_) => _searchPattern(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter text to search',
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => _searchPattern(),
          icon: const Icon(Icons.search),
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
        ),
      ],
    );
  }

  void _searchPattern() {
    searchService.findAndHighlight(controller.text);
    setState(() {
      queriedPattern = controller.text;
    });
  }
}

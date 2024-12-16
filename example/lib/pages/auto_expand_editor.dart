import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class AutoExpandEditor extends StatelessWidget {
  const AutoExpandEditor({
    super.key,
    required this.editorState,
  });

  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Custom Theme For Editor'),
        titleTextStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: IntrinsicHeight(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              constraints: const BoxConstraints(
                maxHeight: 360,
                maxWidth: 400,
              ),
              child: IntrinsicHeight(
                child: AppFlowyEditor(
                  editorState: editorState,
                  shrinkWrap: true,
                  autoScrollEdgeOffset: 24,
                  editorStyle: const EditorStyle.desktop(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  blockComponentBuilders: _buildBlockComponentBuilders(),
                  editorScrollController: EditorScrollController(
                    editorState: editorState,
                    shrinkWrap: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, BlockComponentBuilder> _buildBlockComponentBuilders() {
    return standardBlockComponentBuilderMap.map(
      (key, value) {
        // hide the placeholder for all block components
        // and customize the padding for all block components
        value.configuration = value.configuration.copyWith(
          placeholderText: (_) => '',
          padding: (_) => const EdgeInsets.symmetric(
            vertical: 2,
          ),
        );
        // hide the actions for all block components
        value.showActions = (_) => false;
        return MapEntry(key, value);
      },
    );
  }
}

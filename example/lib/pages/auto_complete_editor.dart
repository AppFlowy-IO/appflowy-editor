import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final _options = {
  'hello ': 'world',
  'support@g': 'mail.com',
  'appflowy ': 'editor',
};

class AutoCompleteEditor extends StatelessWidget {
  const AutoCompleteEditor({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 100),
              Container(
                height: 500,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                ),
                child: AppFlowyEditor(
                  editorState: EditorState(
                    document: Document.blank(withInitialText: true),
                  ),
                  commandShortcutEvents: [
                    tabToAutoCompleteCommand,
                    ...standardCommandShortcutEvents,
                  ],
                  enableAutoComplete: true,
                  autoCompleteTextProvider: (context, node, textSpan) {
                    final editorState = context.read<EditorState>();
                    final selection = editorState.selection;
                    final delta = node.delta;
                    if (selection == null ||
                        delta == null ||
                        !selection.isCollapsed ||
                        selection.endIndex != delta.length ||
                        !node.path.equals(selection.start.path)) {
                      return null;
                    }
                    final text = delta.toPlainText().toLowerCase();
                    for (final option in _options.keys) {
                      if (text.endsWith(option)) {
                        return _options[option];
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'AutoComplete Options: $_options',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

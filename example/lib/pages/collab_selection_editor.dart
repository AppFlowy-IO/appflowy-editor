import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CollabSelectionEditor extends StatefulWidget {
  const CollabSelectionEditor({super.key});

  @override
  State<CollabSelectionEditor> createState() => _CollabSelectionEditorState();
}

class _CollabSelectionEditorState extends State<CollabSelectionEditor> {
  late final Future<String> future;

  EditorState? editorState;

  late final List<RemoteSelection> remoteSelections = [
    RemoteSelection(
      id: '1',
      selection: Selection(
        start: Position(path: [0], offset: 0),
        end: Position(path: [0], offset: 5),
      ),
      selectionColor: Colors.red,
      cursorColor: Colors.red,
      builder: _buildSelectionFlag,
    ),
    // collapsed selection
    RemoteSelection(
      id: '2',
      selection: Selection.collapsed(
        Position(path: [1], offset: 3),
      ),
      selectionColor: Colors.yellow,
      cursorColor: Colors.yellow,
      builder: _buildSelectionFlag,
    ),
    // multi-line selection
    RemoteSelection(
      id: '3',
      selection: Selection(
        start: Position(path: [2], offset: 0),
        end: Position(path: [3], offset: 5),
      ),
      selectionColor: Colors.green,
      cursorColor: Colors.green,
      builder: _buildSelectionFlag,
    ),
  ];

  @override
  void initState() {
    super.initState();

    future = PlatformExtension.isDesktopOrWeb
        ? rootBundle.loadString('assets/example.json')
        : rootBundle.loadString('assets/mobile_example.json').then((value) {
            return value;
          });
  }

  @override
  void dispose() {
    editorState?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<String>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                editorState?.dispose();
                editorState ??= EditorState(
                  document: Document.fromJson(jsonDecode(snapshot.data!)),
                );
                return AppFlowyEditor(
                  editorState: editorState!,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              editorState?.remoteSelections.value = [...remoteSelections];
            },
            child: const Text('Add Selection'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionFlag(
    BuildContext context,
    RemoteSelection remoteSelection,
    Rect rect,
  ) {
    final selection = remoteSelection.selection;
    if (selection.isCollapsed) {
      return Positioned(
        top: rect.top - 5.0,
        left: rect.right,
        child: const Text(
          'Lucas.Xu',
          style: TextStyle(
            backgroundColor: Colors.yellow,
            color: Colors.black,
            fontSize: 10,
          ),
        ),
      );
    }

    return Positioned(
      top: rect.top - 5.0,
      left: rect.left,
      child: const Text(
        'Guest',
        style: TextStyle(
          backgroundColor: Colors.yellow,
          color: Colors.black,
          fontSize: 10,
        ),
      ),
    );
  }
}

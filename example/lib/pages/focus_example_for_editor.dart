import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FocusExampleForEditor extends StatefulWidget {
  const FocusExampleForEditor({super.key});

  @override
  State<FocusExampleForEditor> createState() => _FocusExampleForEditorState();
}

class _FocusExampleForEditorState extends State<FocusExampleForEditor> {
  late final Future<EditorState> editorState;

  @override
  void initState() {
    super.initState();

    final jsonString = PlatformExtension.isDesktopOrWeb
        ? rootBundle.loadString('assets/example.json')
        : rootBundle.loadString('assets/mobile_example.json');
    editorState = jsonString.then((value) {
      return EditorState(
        document: Document.fromJson(
          Map<String, Object>.from(
            json.decode(value),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Focus Node Example'),
        titleTextStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 400,
            child: FutureBuilder(
              future: editorState,
              builder: (context, snapshot) {
                return !snapshot.hasData
                    ? const Center(child: CircularProgressIndicator())
                    : AppFlowyEditor(
                        editorState: snapshot.data!,
                        header: const TextField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Header: Please input something ...',
                          ),
                        ),
                        footer: const TextField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Footer: Please input something ...',
                          ),
                        ),
                      );
              },
            ),
          ),
          const TextField(
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Please input something ...',
            ),
          ),
        ],
      ),
    );
  }
}

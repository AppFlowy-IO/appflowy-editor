import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:example/pages/desktop_editor.dart';
import 'package:example/pages/mobile_editor.dart';

import 'package:appflowy_editor/appflowy_editor.dart';

class Editor extends StatefulWidget {
  const Editor({
    super.key,
    required this.jsonString,
    required this.onEditorStateChange,
    this.editorStyle,
    this.textDirection = TextDirection.ltr,
  });

  final Future<String> jsonString;
  final EditorStyle? editorStyle;
  final void Function(EditorState editorState) onEditorStateChange;

  final TextDirection textDirection;

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  bool isInitialized = false;

  EditorState? editorState;
  WordCountService? wordCountService;

  @override
  void didUpdateWidget(covariant Editor oldWidget) {
    if (oldWidget.jsonString != widget.jsonString) {
      editorState = null;
      isInitialized = false;
    }
    super.didUpdateWidget(oldWidget);
  }

  int wordCount = 0;
  int charCount = 0;

  void registerWordCounter() {
    wordCountService?.removeListener(onWordCountUpdate);
    wordCountService?.dispose();

    wordCountService = WordCountService(editorState: editorState!)..register();
    wordCountService!.addListener(onWordCountUpdate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        wordCount = wordCountService!.wordCount;
        charCount = wordCountService!.charCount;
      });
    });
  }

  void onWordCountUpdate() {
    setState(() {
      wordCount = wordCountService!.wordCount;
      charCount = wordCountService!.charCount;
    });
  }

  @override
  void dispose() {
    editorState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColoredBox(
          color: Colors.white,
          child: FutureBuilder<String>(
            future: widget.jsonString,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                if (!isInitialized || editorState == null) {
                  isInitialized = true;
                  EditorState editorState = EditorState(
                    document: Document.fromJson(
                      Map<String, Object>.from(
                        json.decode(snapshot.data!),
                      ),
                    ),
                  );

                  editorState.logConfiguration
                    ..handler = debugPrint
                    ..level = LogLevel.off;

                  editorState.transactionStream.listen((event) {
                    if (event.$1 == TransactionTime.after) {
                      widget.onEditorStateChange(editorState);
                    }
                  });

                  this.editorState = editorState;
                  registerWordCounter();
                }

                if (PlatformExtension.isDesktopOrWeb) {
                  return DesktopEditor(
                    editorState: editorState!,
                    textDirection: widget.textDirection,
                  );
                } else if (PlatformExtension.isMobile) {
                  return MobileEditor(editorState: editorState!);
                }
              }

              return const SizedBox.shrink();
            },
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(8),
                bottomLeft: PlatformExtension.isMobile
                    ? const Radius.circular(8)
                    : Radius.zero,
              ),
            ),
            child: Text(
              'Word Count: $wordCount  |  Character Count: $charCount',
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }
}

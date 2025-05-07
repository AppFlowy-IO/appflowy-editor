import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class AnimatedMarkdownPage extends StatefulWidget {
  const AnimatedMarkdownPage({super.key});

  @override
  State<AnimatedMarkdownPage> createState() => _AnimatedMarkdownPageState();
}

class _AnimatedMarkdownPageState extends State<AnimatedMarkdownPage>
    with TickerProviderStateMixin {
  int offset = 0;
  String markdown = '';
  bool isTimerActive = false;
  late Timer markdownInputTimer;
  late Timer markdownOutputTimer;

  late EditorState editorState;
  late EditorScrollController scrollController;

  // animation tweens
  final Map<String, (AnimationController, Animation<double>)> _animations = {};

  @override
  void initState() {
    super.initState();

    editorState = _parseMarkdown(markdown);
    scrollController = EditorScrollController(
      editorState: editorState,
      shrinkWrap: true,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    editorState.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: IntrinsicHeight(
          child: AppFlowyEditor(
            editorState: editorState,
            editorScrollController: scrollController,
            shrinkWrap: true,
            // the editor is not editable in the chat
            editable: false,
            disableAutoScroll: true,
            editorStyle: const EditorStyle.desktop(),
            blockWrapper: (
              context, {
              required Node node,
              required Widget child,
            }) {
              if (!_animations.containsKey(node.id)) {
                final controller = AnimationController(
                  vsync: this,
                  duration: const Duration(milliseconds: 2000),
                );
                final fade = Tween<double>(
                  begin: 0,
                  end: 1,
                ).animate(controller);
                _animations[node.id] = (controller, fade);
                controller.forward();
              }
              final (controller, fade) = _animations[node.id]!;

              return AnimatedBuilder(
                animation: fade,
                builder: (context, childWidget) {
                  return ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [fade.value, fade.value],
                        colors: const [
                          Colors.white,
                          Colors.transparent,
                        ],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Opacity(
                      opacity: fade.value,
                      child: childWidget,
                    ),
                  );
                },
                child: child,
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isTimerActive) {
            _stopTimer();
          } else {
            _startTimer();
          }
        },
        child: isTimerActive
            ? const Icon(Icons.stop)
            : const Icon(Icons.play_arrow),
      ),
    );
  }

  void _startTimer() {
    if (isTimerActive) {
      // stop the timer and reset the offset
      _stopTimer();

      return;
    }

    isTimerActive = true;

    markdownInputTimer =
        Timer.periodic(const Duration(milliseconds: 50), (timer) {
      markdown = _markdown.substring(0, offset);

      offset += 30;

      if (offset >= _markdown.length) {
        timer.cancel();
      }
    });

    markdownOutputTimer =
        Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (offset >= _markdown.length) {
        return;
      }

      markdown = _markdown.substring(0, offset);

      final editorState = _parseMarkdown(
        markdown,
        previousDocument: this.editorState.document,
      );
      if (editorState.document.last?.id != this.editorState.document.last?.id) {
        setState(() {
          this.editorState.dispose();
          this.editorState = editorState;
          scrollController.dispose();
          scrollController = EditorScrollController(
            editorState: editorState,
            shrinkWrap: true,
          );
        });
      }
    });
  }

  void _stopTimer() {
    if (!isTimerActive) {
      return;
    }

    isTimerActive = false;
    markdownInputTimer.cancel();
    markdownOutputTimer.cancel();

    setState(() {
      markdown = '';
      offset = 0;
      final editorState = _parseMarkdown(
        markdown,
        previousDocument: this.editorState.document,
      );
      this.editorState.dispose();
      this.editorState = editorState;
      scrollController.dispose();
      scrollController = EditorScrollController(
        editorState: editorState,
        shrinkWrap: true,
      );

      _animations.clear();
    });
  }

  EditorState _parseMarkdown(
    String markdown, {
    Document? previousDocument,
  }) {
    // merge the nodes from the previous document with the new document to keep the same node ids
    final document = markdownToDocument(markdown);
    final documentIterator = NodeIterator(
      document: document,
      startNode: document.root,
    );
    if (previousDocument != null) {
      final previousDocumentIterator = NodeIterator(
        document: previousDocument,
        startNode: previousDocument.root,
      );
      while (
          documentIterator.moveNext() && previousDocumentIterator.moveNext()) {
        final currentNode = documentIterator.current;
        final previousNode = previousDocumentIterator.current;
        if (currentNode.path.equals(previousNode.path)) {
          currentNode.id = previousNode.id;
        }
      }
    }
    final editorState = EditorState(document: document);
    return editorState;
  }
}

const _markdown = '''# AnimationGPT Export Options

* AnimationGPT typically supports multiple export formats to accommodate different use cases and platforms

Here's what you should know about exporting animations from AnimationGPT:

* **Common Export Formats:**
  * **MP4 video** - Standard video format with good quality and compression
  * **GIF** - Perfect for simple animations to share on social media or messaging apps
  * **WebM** - Web-optimized video format that works well for online embedding
  * **PNG sequence** - Individual frames for further editing in other software

* **Quality and Resolution Options:**
  * Most exports allow selecting resolution (720p, 1080p, etc.)
  * Quality settings to balance file size and visual fidelity
  * Frame rate options (24fps, 30fps, 60fps) depending on your needs
  * Some premium tiers may offer higher resolution exports

* **Platform-Specific Exports:**
  * Social media optimized presets (Instagram, TikTok, YouTube)
  * Aspect ratio options (16:9, 1:1, 9:16 for stories/reels)
  * File size optimization for different platforms

* **Embedding Options:**
  * HTML embed codes for websites and blogs
  * iFrame support for content management systems
  * API integration for more advanced implementations (may require developer knowledge)

* **Sharing Features:**
  * Direct sharing to social media platforms
  * Shareable links to your animations
  * Team/collaboration sharing options in some versions

* **Export Limitations:**
  * Free tier users may have watermarks or limited export options
  * Higher resolution exports might require premium subscriptions
  * Some formats may have file size restrictions

* **Tips for Exporting:**
  * Choose GIFs for simple, short animations (under 10 seconds)
  * Use MP4 for longer animations with sound
  * Consider your end platform before choosing export settings
  * Test your animation on the intended platform to ensure it displays correctly

Most users find the export process straightforward with a simple interface for selecting format, quality, and destination. If you have specific platform requirements, check the export presets to see if AnimationGPT offers optimized settings for your needs."
''';

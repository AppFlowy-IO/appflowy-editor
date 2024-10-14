import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/auto_complete_editor.dart';
import 'package:example/pages/auto_expand_editor.dart';
import 'package:example/pages/collab_editor.dart';
import 'package:example/pages/collab_selection_editor.dart';
import 'package:example/pages/customize_theme_for_editor.dart';
import 'package:example/pages/drag_to_reorder_editor.dart';
import 'package:example/pages/editor.dart';
import 'package:example/pages/editor_list.dart';
import 'package:example/pages/fixed_toolbar_editor.dart';
import 'package:example/pages/focus_example_for_editor.dart';
import 'package:example/pages/markdown_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_platform/universal_platform.dart';

enum ExportFileType {
  documentJson,
  markdown,
  pdf,
  delta,
}

extension on ExportFileType {
  String get extension {
    switch (this) {
      case ExportFileType.documentJson:
      case ExportFileType.delta:
        return 'json';
      case ExportFileType.markdown:
        return 'md';
      case ExportFileType.pdf:
        return 'pdf';
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late WidgetBuilder _widgetBuilder;
  late EditorState _editorState;
  late Future<String> _jsonString;

  @override
  void initState() {
    super.initState();

    _jsonString = UniversalPlatform.isDesktopOrWeb
        ? rootBundle.loadString('assets/example.json')
        : rootBundle.loadString('assets/mobile_example.json');

    _widgetBuilder = (context) => Editor(
          jsonString: _jsonString,
          onEditorStateChange: (editorState) {
            _editorState = editorState;
          },
        );
  }

  @override
  void reassemble() {
    super.reassemble();

    _widgetBuilder = (context) => Editor(
          jsonString: _jsonString,
          onEditorStateChange: (editorState) {
            _editorState = editorState;
            _jsonString = Future.value(
              jsonEncode(_editorState.document.toJson()),
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: UniversalPlatform.isDesktopOrWeb,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 134, 46, 247),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('AppFlowy Editor'),
      ),
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: _widgetBuilder(context),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            child: Image.asset(
              'assets/images/icon.jpeg',
              fit: BoxFit.fill,
            ),
          ),

          // AppFlowy Editor Demo
          _buildSeparator(context, 'AppFlowy Editor Demo'),
          _buildListTile(context, 'With Example.json', () {
            final jsonString = UniversalPlatform.isDesktopOrWeb
                ? rootBundle.loadString('assets/example.json')
                : rootBundle.loadString('assets/mobile_example.json');
            _loadEditor(context, jsonString);
          }),
          _buildListTile(context, 'With Large Document (10000+ lines)', () {
            final nodes = List.generate(
              10000,
              (index) =>
                  paragraphNode(text: '$index ${generateRandomString(50)}'),
            );
            final editorState = EditorState(
              document: Document(root: pageNode(children: nodes)),
            );
            final jsonString = Future.value(
              jsonEncode(editorState.document.toJson()),
            );
            _loadEditor(context, jsonString);
          }),
          _buildListTile(context, 'With Example.html', () async {
            final htmlString =
                await rootBundle.loadString('assets/example.html');
            final html = htmlToDocument(htmlString);
            final jsonString = Future<String>.value(
              jsonEncode(
                html.toJson(),
              ).toString(),
            );
            if (context.mounted) {
              _loadEditor(context, jsonString);
            }
          }),
          _buildListTile(context, 'With Empty Document', () {
            final jsonString = Future<String>.value(
              jsonEncode(
                EditorState.blank(withInitialText: true).document.toJson(),
              ).toString(),
            );
            _loadEditor(context, jsonString);
          }),

          // Theme Demo
          _buildSeparator(context, 'Showcases'),
          _buildListTile(context, 'Drag to reorder', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DragToReorderEditor(),
              ),
            );
          }),
          _buildListTile(context, 'Markdown Editor', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MarkdownEditor(),
              ),
            );
          }),
          _buildListTile(context, 'Auto complete Editor', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AutoCompleteEditor(),
              ),
            );
          }),
          _buildListTile(context, 'Collab Editor', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CollabEditor(),
              ),
            );
          }),
          _buildListTile(context, 'Collab Selection', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CollabSelectionEditor(),
              ),
            );
          }),
          _buildListTile(context, 'Custom Theme', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomizeThemeForEditor(),
              ),
            );
          }),
          _buildListTile(context, 'RTL', () {
            final jsonString = rootBundle.loadString(
              'assets/arabic_example.json',
            );
            _loadEditor(
              context,
              jsonString,
              textDirection: TextDirection.rtl,
            );
          }),
          _buildListTile(context, 'Focus Example', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FocusExampleForEditor(),
              ),
            );
          }),
          _buildListTile(context, 'Editor List', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditorList(),
              ),
            );
          }),
          _buildListTile(context, 'Fixed Toolbar', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FixedToolbarExample(),
              ),
            );
          }),

          _buildListTile(context, 'Auto Expand Editor', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AutoExpandEditor(
                  editorState: EditorState.blank(),
                ),
              ),
            );
          }),

          // Encoder Demo
          _buildSeparator(context, 'Export To X Demo'),
          _buildListTile(context, 'Export To JSON', () {
            _exportFile(_editorState, ExportFileType.documentJson);
          }),
          _buildListTile(context, 'Export to Markdown', () {
            _exportFile(_editorState, ExportFileType.markdown);
          }),

          _buildListTile(context, 'Export to PDF', () {
            _exportFile(_editorState, ExportFileType.pdf);
          }),

          // Decoder Demo
          _buildSeparator(context, 'Import From X Demo'),
          _buildListTile(context, 'Import From Document JSON', () {
            _importFile(ExportFileType.documentJson);
          }),
          _buildListTile(context, 'Import From Markdown', () {
            _importFile(ExportFileType.markdown);
          }),
          _buildListTile(context, 'Import From Quill Delta', () {
            _importFile(ExportFileType.delta);
          }),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String text,
    VoidCallback? onTap,
  ) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 16),
      title: Text(
        text,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap?.call();
      },
    );
  }

  Widget _buildSeparator(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _loadEditor(
    BuildContext context,
    Future<String> jsonString, {
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    final completer = Completer<void>();
    _jsonString = jsonString;
    setState(
      () {
        _widgetBuilder = (context) => Editor(
              jsonString: _jsonString,
              onEditorStateChange: (editorState) {
                _editorState = editorState;
              },
              textDirection: textDirection,
            );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      completer.complete();
    });
    return completer.future;
  }

  void _exportFile(
    EditorState editorState,
    ExportFileType fileType,
  ) async {
    var result = '';

    switch (fileType) {
      case ExportFileType.documentJson:
        result = jsonEncode(editorState.document.toJson());
        break;
      case ExportFileType.markdown:
        result = documentToMarkdown(editorState.document);
        break;
      case ExportFileType.pdf:
        result = documentToMarkdown(editorState.document);
        break;

      case ExportFileType.delta:
        throw UnimplementedError();
    }

    if (kIsWeb) {
      final blob = html.Blob([result], 'text/plain', 'native');
      html.AnchorElement(
        href: html.Url.createObjectUrlFromBlob(blob).toString(),
      )
        ..setAttribute('download', 'document.${fileType.extension}')
        ..click();
    } else if (UniversalPlatform.isMobile) {
      final appStorageDirectory = await getApplicationDocumentsDirectory();

      final path = File(
        '${appStorageDirectory.path}/${DateTime.now()}.${fileType.extension}',
      );
      await path.writeAsString(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This document is saved to the ${appStorageDirectory.path}',
            ),
          ),
        );
      }
    } else {
      // for desktop
      final path = await FilePicker.platform.saveFile(
        fileName: 'document.${fileType.extension}',
      );
      if (path != null) {
        await File(path).writeAsString(result);
        if (fileType == ExportFileType.pdf) {
          final pdf = await PdfHTMLEncoder(
            fontFallback: [
              await PdfGoogleFonts.notoColorEmoji(),
              await PdfGoogleFonts.notoColorEmojiRegular(),
            ],
          ).convert(result);

          await File(path).writeAsBytes(await pdf.save());
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This document is saved to the $path'),
            ),
          );
        }
      }
    }
  }

  void _importFile(ExportFileType fileType) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: [fileType.extension],
      type: FileType.custom,
    );
    var plainText = '';
    if (!kIsWeb) {
      final path = result?.files.single.path;
      if (path == null) {
        return;
      }
      plainText = await File(path).readAsString();
    } else {
      final bytes = result?.files.first.bytes;
      if (bytes == null) {
        return;
      }
      plainText = const Utf8Decoder().convert(bytes);
    }

    var jsonString = '';
    switch (fileType) {
      case ExportFileType.documentJson:
        jsonString = plainText;
        break;
      case ExportFileType.markdown:
        jsonString = jsonEncode(markdownToDocument(plainText).toJson());
        break;
      case ExportFileType.delta:
        final delta = Delta.fromJson(jsonDecode(plainText));
        final document = quillDeltaEncoder.convert(delta);
        jsonString = jsonEncode(document.toJson());
        break;
      case ExportFileType.pdf:
        throw UnimplementedError();
    }

    if (mounted) {
      _loadEditor(context, Future<String>.value(jsonString));
    }
  }
}

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
    List.generate(len, (index) => r.nextInt(33) + 89),
  );
}

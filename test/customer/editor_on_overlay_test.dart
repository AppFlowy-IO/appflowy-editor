import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('customize highlight color', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // tap the open editor button
    final openEditorButton = find.byType(FloatingActionButton);
    await tester.tap(openEditorButton);
    await tester.pumpAndSettle();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Placeholder(),
      floatingActionButton: FloatingActionButton(
        onPressed: _insertEditorOnOverlay,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _insertEditorOnOverlay() {
    final overlayEntry = OverlayEntry(
      builder: (_) {
        return AppFlowyEditor(
          editorState: EditorState.blank(),
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(overlayEntry);
  }
}

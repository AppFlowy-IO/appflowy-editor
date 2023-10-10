import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  await AppFlowyEditorLocalizations.load(
    const Locale.fromSubtags(languageCode: 'en'),
  );

  testWidgets('custom error block', (tester) async {
    final editorState = EditorState.blank(withInitialText: false);
    editorState.document.insert(
      [0],
      [
        Node(
          type: 'not_exist',
          attributes: {
            'text': 'line 1',
          },
        ),
        Node(
          type: 'heading',
          attributes: {},
        ),
      ],
    );
    final widget = ErrorEditor(
      editorState: editorState,
    );
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(find.byType(ErrorBlockComponentWidget), findsNWidgets(2));
  });
}

class ErrorEditor extends StatelessWidget {
  const ErrorEditor({
    super.key,
    required this.editorState,
  });

  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  width: 1000,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                  ),
                  child: AppFlowyEditor(
                    editorState: editorState,
                    blockComponentBuilders: {
                      ...standardBlockComponentBuilderMap,
                      errorBlockComponentBuilderKey:
                          ErrorBlockComponentBuilder(),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorBlockComponentBuilder extends BlockComponentBuilder {
  ErrorBlockComponentBuilder({
    super.configuration,
  });

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return ErrorBlockComponentWidget(
      key: node.key,
      node: node,
      configuration: configuration,
      showActions: showActions(node),
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
    );
  }

  @override
  bool validate(Node node) => true;
}

class ErrorBlockComponentWidget extends BlockComponentStatefulWidget {
  const ErrorBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<ErrorBlockComponentWidget> createState() =>
      _DividerBlockComponentWidgetState();
}

class _DividerBlockComponentWidgetState extends State<ErrorBlockComponentWidget>
    with BlockComponentConfigurable {
  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: const Text('error'),
    );
  }
}

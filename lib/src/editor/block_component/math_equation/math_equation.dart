import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathEquationBlockKeys {
  const MathEquationBlockKeys._();

  static const String type = 'math_equation';

  static const String formula = 'formula';
}

Node mathEquationNode({
  String formula = '',
}) {
  final attributes = {
    MathEquationBlockKeys.formula: formula,
  };
  return Node(
    type: MathEquationBlockKeys.type,
    attributes: attributes,
  );
}

class MathEquationBlockComponentBuilder extends BlockComponentBuilder {
  MathEquationBlockComponentBuilder({
    super.configuration,
  });

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return MathEquationBlockComponentWidget(
      key: node.key,
      node: node,
      configuration: configuration,
    );
  }

  @override
  bool validate(Node node) =>
      node.children.isEmpty &&
      node.attributes[MathEquationBlockKeys.formula] is String;
}

class MathEquationBlockComponentWidget extends BlockComponentStatefulWidget {
  const MathEquationBlockComponentWidget({
    Key? key,
    required super.node,
    super.configuration = const BlockComponentConfiguration(),
  }) : super(key: key);

  @override
  State<MathEquationBlockComponentWidget> createState() =>
      MathEquationBlockComponentWidgetState();
}

class MathEquationBlockComponentWidgetState
    extends State<MathEquationBlockComponentWidget>
    with BlockComponentConfigurable<MathEquationBlockComponentWidget> {
  late final EditorState editorState;

  @override
  void initState() {
    super.initState();
    editorState = context.read<EditorState>();
  }

  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  @override
  Widget build(BuildContext context) {
    final formula =
        widget.node.attributes[MathEquationBlockKeys.formula] as String;

    return InkWell(
      onTap: _showEditingDialog,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        decoration: BoxDecoration(
          color: formula.isNotEmpty
              ? Colors.transparent
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
        child: formula.isEmpty
            ? _buildPlaceholderWidget(context)
            : _buildMathEquation(context, formula),
      ),
    );
  }

  Widget _buildPlaceholderWidget(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Row(
          children: [
            const Icon(Icons.text_fields_outlined),
            const SizedBox(width: 10),
            Text('Add Math Equation'),
          ],
        ),
      ),
    );
  }

  Widget _buildMathEquation(BuildContext context, String formula) {
    return Center(
        child: Math.tex(
      formula,
      mathStyle: MathStyle.display,
      textStyle: TextStyle(fontSize: 20),
    ));
  }

  void _showEditingDialog() {
    final TextEditingController controller =
        TextEditingController(text: widget.node.attributes['formula']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Math Equation'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter math equation...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateMathEquation(controller.text);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateMathEquation(String mathEquation) {
    final transaction = editorState.transaction
      ..updateNode(
        widget.node,
        {MathEquationBlockKeys.formula: mathEquation},
      );
    editorState.apply(transaction);
  }
}

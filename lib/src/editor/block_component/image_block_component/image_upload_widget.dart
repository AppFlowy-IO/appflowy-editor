import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

void showImageMenu(
  OverlayState container,
  EditorState editorState,
  SelectionMenuService menuService,
) {
  menuService.dismiss();

  final topLeft = menuService.topLeft;
  final imageMenuEntry = FullScreenOverlayEntry(
    top: topLeft.dy,
    left: topLeft.dx,
    builder: (context) => UploadImageMenu(
      backgroundColor: Colors.white, // TODO: customize the color
      width: MediaQuery.of(context).size.width * 0.5,
      onSubmitted: editorState.insertImageNode,
      onUpload: editorState.insertImageNode,
    ),
  ).build();
  container.insert(imageMenuEntry);
}

class UploadImageMenu extends StatefulWidget {
  const UploadImageMenu({
    Key? key,
    this.backgroundColor = Colors.white,
    this.width = 300,
    required this.onSubmitted,
    required this.onUpload,
  }) : super(key: key);

  final Color backgroundColor;
  final double width;
  final void Function(String text) onSubmitted;
  final void Function(String text) onUpload;

  @override
  State<UploadImageMenu> createState() => _UploadImageMenuState();
}

class _UploadImageMenuState extends State<UploadImageMenu> {
  final _textEditingController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            spreadRadius: 1,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
        // borderRadius: BorderRadius.circular(6.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16.0),
          _buildInput(),
          const SizedBox(height: 18.0),
          _buildUploadButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Text(
      'URL Image',
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 14.0,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInput() {
    return TextField(
      focusNode: _focusNode,
      style: const TextStyle(fontSize: 14.0),
      textAlign: TextAlign.left,
      controller: _textEditingController,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: 'URL',
        hintStyle: const TextStyle(fontSize: 14.0),
        contentPadding: const EdgeInsets.all(16.0),
        isDense: true,
        suffixIcon: IconButton(
          padding: const EdgeInsets.all(4.0),
          icon: const FlowySvg(
            name: 'clear',
            width: 24,
            height: 24,
          ),
          onPressed: _textEditingController.clear,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: Color(0xFFBDBDBD)),
        ),
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 48,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color(0xFF00BCF0)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        onPressed: () => widget.onUpload(_textEditingController.text),
        child: const Text(
          'Upload',
          style: TextStyle(color: Colors.white, fontSize: 14.0),
        ),
      ),
    );
  }
}

extension on EditorState {
  Future<void> insertImageNode(String src) async {
    final selection = this.selection;
    if (selection == null || !selection.isCollapsed) {
      return;
    }
    final node = getNodeAtPath(selection.end.path);
    if (node == null) {
      return;
    }
    final transaction = this.transaction;
    // if the current node is empty paragraph, replace it with image node
    if (node.type == 'paragraph' && (node.delta?.isEmpty ?? false)) {
      transaction
        ..insertNode(node.path, imageNode(url: src))
        ..deleteNode(node);
    } else {
      transaction.insertNode(node.path.next, imageNode(url: src));
    }

    return apply(transaction);
  }
}

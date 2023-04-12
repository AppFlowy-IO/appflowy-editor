import 'package:appflowy_editor/src/core/document/node.dart';
import 'package:appflowy_editor/src/editor_state.dart';
import 'package:appflowy_editor/src/infra/flowy_svg.dart';
import 'package:appflowy_editor/src/render/selection_menu/selection_menu_service.dart';
import 'package:appflowy_editor/src/render/style/editor_style.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

OverlayEntry? _imageUploadMenu;
EditorState? _editorState;
String? imageName;

void showImageUploadMenu(
  EditorState editorState,
  SelectionMenuService menuService,
  BuildContext context,
) {
  menuService.dismiss();

  _imageUploadMenu?.remove();
  _imageUploadMenu = OverlayEntry(
    builder: (context) => Positioned(
      top: menuService.topLeft.dy,
      left: menuService.topLeft.dx,
      child: Material(
        child: ImageUploadMenu(
          editorState: editorState,
          onSubmitted: (text) {
            editorState.insertImageNode(text, 'file');
          },
          onUpload: (text) {
            editorState.insertImageNode(text, 'network');
          },
        ),
      ),
    ),
  );

  Overlay.of(context).insert(_imageUploadMenu!);

  editorState.service.selectionService.currentSelection
      .addListener(_dismissImageUploadMenu);
}

void _dismissImageUploadMenu() {
  _imageUploadMenu?.remove();
  _imageUploadMenu = null;

  _editorState?.service.selectionService.currentSelection
      .removeListener(_dismissImageUploadMenu);
  _editorState = null;
}

class ImageUploadMenu extends StatefulWidget {
  const ImageUploadMenu({
    Key? key,
    required this.onSubmitted,
    required this.onUpload,
    this.editorState,
  }) : super(key: key);

  final void Function(String text) onSubmitted;
  final void Function(String text) onUpload;
  final EditorState? editorState;

  @override
  State<ImageUploadMenu> createState() => _ImageUploadMenuState();
}

class _ImageUploadMenuState extends State<ImageUploadMenu> {
  final _textEditingController = TextEditingController();
  final _focusNode = FocusNode();
  String? _fileName;
  String? src;
  String? srcName;
  List<PlatformFile>? _paths;

  EditorStyle? get style => widget.editorState?.editorStyle;

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

  void _pickFiles() async {
    _resetState();
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: FileType.image,
        onFileLoading: (FilePickerStatus status) =>
            _logException(status.toString()),
        allowedExtensions: ['jpg', 'png', 'gif'],
        allowMultiple: true,
      ))
          ?.files;
    } on PlatformException catch (e) {
      _logException('Unsupported Operation  ${e.toString()}');
    } catch (e) {
      _logException(e.toString());
    }
    if (!mounted) return;

    if (_paths != null) {
      final lastPath = _paths!.last;
      imageName = lastPath.name;

      if (lastPath.path != null) {
        widget.onSubmitted(lastPath.path.toString());
      }
    }
  }

  void _resetState() {
    if (!mounted) return;
    setState(() {
      _fileName = null;
      _paths = null;
    });
  }

  void _logException(String msg) {
    debugPrint(msg);
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController =
        TabController(initialIndex: 1, length: 2, vsync: this);
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: style?.selectionMenuBackgroundColor ?? Colors.white,
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
          TabBar(
            controller: tabController,
            tabs: [
              _buildHeader(context, 'Upload Image'),
              _buildHeader(context, 'URL Image'),
            ],
          ),
          SizedBox(
            height: 200.0,
            child: TabBarView(
              controller: tabController,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16.0),
                    _buildFileInput(context),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildURLInput(),
                    const SizedBox(height: 18.0),
                    _buildUploadButton(context),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18.0),
          _buildUploadButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Text(
      title,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 14.0,
        color: style?.selectionMenuItemTextColor ?? Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildURLInput() {
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

  Widget _buildFileInput(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 48,
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xFF00BCF0)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)))),
        onPressed: _pickFiles,
        child: const Text(
          'Pick from computer',
          style: TextStyle(color: Colors.white, fontSize: 14.0),
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
  void insertImageNode(String src, String type) {
    final selection = service.selectionService.currentSelection.value;
    if (selection == null) {
      return;
    }
    final imageNode = Node(
      type: 'image',
      attributes: {
        'image_src': src,
        'type': type,
        'name': imageName,
        'align': 'center',
      },
    );
    final transaction = this.transaction;
    transaction.insertNode(
      selection.start.path,
      imageNode,
    );
    apply(transaction);
  }
}

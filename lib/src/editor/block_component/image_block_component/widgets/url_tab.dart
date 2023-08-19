import 'package:flutter/material.dart';
import './widget_helpers.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

final _regex = RegExp('^(http|https)://');
bool isUrlValid = true;
bool validateUrl(String url) {
  return url.isNotEmpty && _regex.hasMatch(url);
}

class BuildUrlTab extends StatefulWidget {
  const BuildUrlTab({
    super.key,
    required this.onUpload,
    required this.onSubmitted,
    required this.textEditingController,
    required this.focusNode,
  });

  final void Function(String text) onUpload;
  final void Function(String text) onSubmitted;
  final TextEditingController textEditingController;
  final FocusNode focusNode;

  @override
  State<BuildUrlTab> createState() => _BuildUrlTab();
}

class _BuildUrlTab extends State<BuildUrlTab> {
  String? _imageUrl;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16.0),
        BuildUrlInput(
          focusNode: widget.focusNode,
          textEditingController: widget.textEditingController,
          onSubmitted: widget.onSubmitted,
        ),
        const SizedBox(height: 18.0),
        if (!isUrlValid) const BuildInvalidText(),
        const SizedBox(height: 18.0),
        Align(
          alignment: Alignment.centerRight,
          child: BuildUploadButton(
            context,
            localImagePath: _imageUrl,
            onUpload: widget.onUpload,
            textEditingController: widget.textEditingController,
            onValidateUrl: (result) {
              isUrlValid = result;
            },
          ),
        )
      ],
    );
  }
}

class BuildUrlInput extends StatefulWidget {
  const BuildUrlInput({
    super.key,
    required this.focusNode,
    required this.textEditingController,
    required this.onSubmitted,
  });
  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final void Function(String text) onSubmitted;

  @override
  State<BuildUrlInput> createState() => _BuildUrlInput();
}

class _BuildUrlInput extends State<BuildUrlInput> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      style: const TextStyle(fontSize: 14.0),
      textAlign: TextAlign.left,
      controller: widget.textEditingController,
      onSubmitted: (text) {
        if (validateUrl(text)) {
          widget.onSubmitted(text);
        } else {
          setState(() {
            isUrlValid = false;
          });
        }
      },
      decoration: InputDecoration(
        hintText: 'URL',
        hintStyle: const TextStyle(fontSize: 14.0),
        contentPadding: const EdgeInsets.all(16.0),
        isDense: true,
        suffixIcon: IconButton(
          padding: const EdgeInsets.all(4.0),
          icon: const EditorSvg(
            name: 'clear',
            width: 24,
            height: 24,
          ),
          onPressed: widget.textEditingController.clear,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: Color(0xFFBDBDBD)),
        ),
      ),
    );
  }
}

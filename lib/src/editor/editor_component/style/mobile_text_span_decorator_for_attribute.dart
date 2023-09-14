import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Support mobile platform
///   - customize the href text span
TextSpan mobileTextSpanDecoratorForAttribute(
  BuildContext context,
  Node node,
  int index,
  TextInsert text,
  TextSpan textSpan,
) {
  final attributes = text.attributes;
  if (attributes == null) {
    return textSpan;
  }
  final editorState = context.read<EditorState>();

  final hrefAddress = attributes[AppFlowyRichTextKeys.href] as String?;
  if (hrefAddress != null) {
    Timer? timer;

    final tapGestureRecognizer = TapGestureRecognizer()
      ..onTapUp = (_) async {
        if (timer != null && timer!.isActive) {
          // Implement single tap logic
          safeLaunchUrl(hrefAddress);
          timer!.cancel();
          return;
        }
      };

    tapGestureRecognizer.onTapDown = (_) {
      final selection = Selection.single(
        path: node.path,
        startOffset: index,
        endOffset: index + text.text.length,
      );
      editorState.updateSelectionWithReason(
        selection,
        reason: SelectionUpdateReason.uiEvent,
      );

      timer = Timer(const Duration(milliseconds: 500), () {
        // Implement long tap logic
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppFlowyEditorLocalizations.current.editLink),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              content: LinkEditForm(
                node: node,
                index: index,
                hrefText: text.text,
                hrefAddress: hrefAddress,
                editorState: editorState,
                selection: selection,
              ),
            );
          },
        );
      });
    };
    return TextSpan(
      style: textSpan.style,
      text: text.text,
      recognizer: tapGestureRecognizer,
    );
  }

  return textSpan;
}

class LinkEditForm extends StatefulWidget {
  const LinkEditForm({
    super.key,
    required this.node,
    required this.index,
    required this.hrefText,
    required this.hrefAddress,
    required this.editorState,
    required this.selection,
  });
  final Node node;
  final int index;
  final String hrefText;
  final String hrefAddress;
  final EditorState editorState;
  final Selection selection;

  @override
  State<LinkEditForm> createState() => _LinkEditFormState();
}

class _LinkEditFormState extends State<LinkEditForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var hrefAddressTextEditingController =
        TextEditingController(text: widget.hrefAddress);
    var hrefTextTextEditingController =
        TextEditingController(text: widget.hrefText);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            key: const Key('Text TextFormField'),
            autofocus: true,
            controller: hrefTextTextEditingController,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppFlowyEditorLocalizations.current.linkTextHint;
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: AppFlowyEditorLocalizations.current.linkText,
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.clear_rounded,
                  size: 16,
                ),
                onPressed: hrefTextTextEditingController.clear,
              ),
            ),
          ),
          TextFormField(
            key: const Key('Url TextFormField'),
            controller: hrefAddressTextEditingController,
            keyboardType: TextInputType.url,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppFlowyEditorLocalizations.current.linkAddressHint;
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: AppFlowyEditorLocalizations.current.urlHint,
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.clear_rounded,
                  size: 16,
                ),
                onPressed: hrefAddressTextEditingController.clear,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: Text(
                  AppFlowyEditorLocalizations.current.removeLink,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onPressed: () async {
                  final transaction = widget.editorState.transaction
                    ..formatText(
                      widget.node,
                      widget.index,
                      widget.hrefText.length,
                      {BuiltInAttributeKey.href: null},
                    );
                  await widget.editorState
                      .apply(transaction)
                      .whenComplete(() => Navigator.of(context).pop());
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: Text(AppFlowyEditorLocalizations.current.done),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final bool textChanged =
                        hrefTextTextEditingController.text != widget.hrefText;
                    final bool addressChanged =
                        hrefAddressTextEditingController.text !=
                            widget.hrefAddress;

                    if (textChanged && addressChanged) {
                      final transaction = widget.editorState.transaction
                        ..replaceText(
                          widget.node,
                          widget.index,
                          widget.hrefText.length,
                          hrefTextTextEditingController.text,
                          attributes: {
                            AppFlowyRichTextKeys.href:
                                hrefAddressTextEditingController.text,
                          },
                        );
                      await widget.editorState.apply(transaction).whenComplete(
                            () => Navigator.of(context).pop(),
                          );
                    } else if (textChanged && !addressChanged) {
                      final transaction = widget.editorState.transaction
                        ..replaceText(
                          widget.node,
                          widget.index,
                          widget.hrefText.length,
                          hrefTextTextEditingController.text,
                        );
                      await widget.editorState.apply(transaction).whenComplete(
                            () => Navigator.of(context).pop(),
                          );
                    } else if (!textChanged && addressChanged) {
                      await widget.editorState.formatDelta(widget.selection, {
                        AppFlowyRichTextKeys.href:
                            hrefAddressTextEditingController.value.text,
                      }).whenComplete(() => Navigator.of(context).pop());
                    } else {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The style of the editor.
///
/// You can customize the style of the editor by passing the [EditorStyle] to
///  the [AppFlowyEditor].
///
class EditorStyle {
  const EditorStyle({
    required this.padding,
    required this.cursorColor,
    required this.selectionColor,
    required this.textStyleConfiguration,
    required this.textSpanDecorator,
  });

  /// The padding of the editor.
  final EdgeInsets padding;

  /// The cursor color
  final Color cursorColor;

  /// The selection color
  final Color selectionColor;

  /// Customize the text style of the editor.
  ///
  /// All the text-based components will use this configuration to build their
  ///   text style.
  ///
  /// Notes, this configuration is only for the common config of text style and
  ///   it maybe override if the text block has its own [BlockComponentConfiguration].
  final TextStyleConfiguration textStyleConfiguration;

  /// Customize the built-in or custom text span.
  ///
  /// For example, you can add a custom text span for the mention text
  ///   or override the built-in text span.
  final TextSpanDecoratorForAttribute? textSpanDecorator;

  const EditorStyle.desktop({
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? cursorColor,
    Color? selectionColor,
    TextStyleConfiguration? textStyleConfiguration,
    TextSpanDecoratorForAttribute? textSpanDecorator,
  }) : this(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 100),
          cursorColor: cursorColor ?? const Color(0xFF00BCF0),
          selectionColor:
              selectionColor ?? const Color.fromARGB(53, 111, 201, 231),
          textStyleConfiguration: textStyleConfiguration ??
              const TextStyleConfiguration(
                text: TextStyle(fontSize: 16, color: Colors.black),
              ),
          textSpanDecorator:
              textSpanDecorator ?? defaultTextSpanDecoratorForAttribute,
        );

  const EditorStyle.mobile({
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? cursorColor,
    Color? selectionColor,
    TextStyleConfiguration? textStyleConfiguration,
    TextSpanDecoratorForAttribute? textSpanDecorator,
  }) : this(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
          cursorColor: cursorColor ?? const Color(0xFF00BCF0),
          selectionColor:
              selectionColor ?? const Color.fromARGB(53, 111, 201, 231),
          textStyleConfiguration: textStyleConfiguration ??
              const TextStyleConfiguration(
                text: TextStyle(fontSize: 16, color: Colors.black),
              ),
          textSpanDecorator:
              textSpanDecorator ?? mobileTextSpanDecoratorForAttribute,
        );

  EditorStyle copyWith({
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? cursorColor,
    Color? selectionColor,
    TextStyleConfiguration? textStyleConfiguration,
    TextSpanDecoratorForAttribute? textSpanDecorator,
  }) {
    return EditorStyle(
      padding: padding ?? this.padding,
      cursorColor: cursorColor ?? this.cursorColor,
      selectionColor: selectionColor ?? this.selectionColor,
      textStyleConfiguration:
          textStyleConfiguration ?? this.textStyleConfiguration,
      textSpanDecorator: textSpanDecorator ?? this.textSpanDecorator,
    );
  }
}

/// Support Desktop and Web platform
///   - customize the href text span
TextSpan defaultTextSpanDecoratorForAttribute(
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
  final href = attributes[AppFlowyRichTextKeys.href] as String?;
  if (href != null) {
    // add a tap gesture recognizer to the text span
    Timer? timer;
    int tapCount = 0;
    final tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        // implement a simple double tap logic
        tapCount += 1;
        timer?.cancel();
        if (tapCount == 2 || !editorState.editable) {
          tapCount = 0;
          safeLaunchUrl(href);
          return;
        }
        timer = Timer(const Duration(milliseconds: 200), () {
          tapCount = 0;
          final selection = Selection.single(
            path: node.path,
            startOffset: index,
            endOffset: index + text.text.length,
          );
          editorState.updateSelectionWithReason(
            selection,
            reason: SelectionUpdateReason.uiEvent,
          );
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            showLinkMenu(context, editorState, selection, true);
          });
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
                                hrefAddressTextEditingController.text
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
          )
        ],
      ),
    );
  }
}

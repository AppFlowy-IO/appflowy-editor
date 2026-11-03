import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor.dart';
import 'package:flutter/material.dart';

class TenThousandLinksShowcase extends StatefulWidget {
  const TenThousandLinksShowcase({super.key});

  @override
  State<TenThousandLinksShowcase> createState() =>
      _TenThousandLinksShowcaseState();
}

class _TenThousandLinksShowcaseState extends State<TenThousandLinksShowcase> {
  late final Future<String> _jsonString = _buildLinksDocument();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('10,000 Links Showcase')),
      body: Editor(
        jsonString: _jsonString,
        onEditorStateChange: (_) {},
      ),
    );
  }

  Future<String> _buildLinksDocument() {
    final document = Document(
      root: pageNode(
        children: List.generate(
          10000,
          (index) => paragraphNode(
            delta: Delta()
              ..insert(
                'Link ${index + 1}',
                attributes: {
                  AppFlowyRichTextKeys.href:
                      'https://example.com/links/${index + 1}',
                },
              ),
          ),
        ),
      ),
    );

    return Future.value(jsonEncode(document.toJson()));
  }
}

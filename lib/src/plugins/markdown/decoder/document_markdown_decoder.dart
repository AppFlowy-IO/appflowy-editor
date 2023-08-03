import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:path/path.dart' as p;

class DocumentMarkdownDecoder extends Converter<String, Document> {
  final imageRegex = RegExp(r'^!\[[^\]]*\]\((.*?)\)');
  final assetRegex = RegExp(r'^\[[^\]]*\]\((.*?)\)');
  final htmlRegex = RegExp('^(http|https)://');
  final numberedlistRegex = RegExp(r'^\d+\. ');

  // Reference: https://stackoverflow.com/a/6041965
  final linkRegExp = RegExp(
    r"(http|ftp|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])",
  );

  @override
  Document convert(String input) {
    final lines = input.split('\n');
    final document = Document.blank();
    // In the below while loop we iterate through each line of the input markdown
    // if the line starts with ``` it means there are chances it may be a code block
    // so it iterates through all the lines(using another while loop) storing them in a
    // string variable codeblock until it finds another ``` which marks the end of code
    // block it then sends this to convert _convertLineToNode function .
    // If we reach the end of lines and we still haven't found ``` then we will treat the
    // line starting with ``` as a regular paragraph and continue the main while loop from
    // a temporary pointer which stored the line number of the line with starting ```
    int i = 0;
    while (i < lines.length) {
      if (lines[i].startsWith('```') &&
          lines[i].endsWith('```') &&
          lines[i].length > 3) {
        document.insert([i], [_convertLineToNode(lines[i])]);
        i++;
      } else if (lines[i].startsWith("```")) {
        String codeBlock = "";
        codeBlock += "${lines[i]}\n";
        int tempLinePointer = i;
        i++;
        while (i < lines.length && !lines[i].endsWith("```")) {
          codeBlock += "${lines[i]}\n";
          i++;
        }

        if (i == lines.length) {
          i = tempLinePointer;
          document.insert([i], [_convertLineToNode(lines[i])]);
          i++;
        } else {
          codeBlock += lines[i];
          document.insert([tempLinePointer], [_convertLineToNode(codeBlock)]);
          i++;
        }
      } else {
        document.insert([i], [_convertLineToNode(lines[i])]);
        i++;
      }
    }

    return document;
  }

  Node _convertLineToNode(String line) {
    final decoder = DeltaMarkdownDecoder();
    // Heading Style
    if (line.startsWith('### ')) {
      return headingNode(
        level: 3,
        delta: decoder.convert(line.substring(4)),
      );
    } else if (line.startsWith('## ')) {
      return headingNode(
        level: 2,
        delta: decoder.convert(line.substring(3)),
      );
    } else if (line.startsWith('# ')) {
      return headingNode(
        level: 1,
        delta: decoder.convert(line.substring(2)),
      );
    } else if (line.startsWith('- [ ] ')) {
      return todoListNode(
        checked: false,
        delta: decoder.convert(line.substring(6)),
      );
    } else if (line.startsWith('- [x] ')) {
      return todoListNode(
        checked: true,
        delta: decoder.convert(line.substring(6)),
      );
    } else if (line.startsWith('> ')) {
      return quoteNode(delta: decoder.convert(line.substring(2)));
    } else if (line.startsWith('- ') || line.startsWith('* ')) {
      return bulletedListNode(delta: decoder.convert(line.substring(2)));
    } else if (line.isNotEmpty && RegExp('^-*').stringMatch(line) == line) {
      return Node(type: 'divider');
    } else if (line.startsWith('```') && line.endsWith('```')) {
      return _codeBlockNodeFromMarkdown(line, decoder);
    } else if (imageRegex.hasMatch(line.trim())) {
      final filePath = extractImagePath(line.trim());
      // checking if filepath is present or if the filepath is an image or not
      if (filePath == null ||
          !['.png', '.jpg', 'jpeg'].contains(p.extension(filePath))) {
        return paragraphNode(text: line.trim());
      }
      return imageNode(url: filePath);
    } else if (assetRegex.hasMatch(line.trim())) {
      // this might be a url or a file like pdf, videos, etc
      final filepath = extractFilePath(line.trim());
      if (filepath != null && !htmlRegex.hasMatch(filepath)) {
        return paragraphNode(text: line);
      }
    } else if (numberedlistRegex.hasMatch(line)) {
      return numberedListNode(
        delta: decoder.convert(line.substring(line.indexOf('.') + 1)),
      );
    } else if (linkRegExp.hasMatch(line)) {
      final delta = deltaFromLineWithLinks(line);
      return paragraphNode(delta: delta);
    }

    if (line.isNotEmpty) {
      return paragraphNode(delta: decoder.convert(line));
    }

    return paragraphNode(delta: Delta());
  }

  String? extractImagePath(String text) {
    final match = imageRegex.firstMatch(text);
    return match?.group(1);
  }

  String? extractFilePath(String text) {
    final match = assetRegex.firstMatch(text);
    return match?.group(1);
  }

  Delta deltaFromLineWithLinks(String line, [Delta? delta]) {
    final matches = linkRegExp.allMatches(line).toList();
    final nodeDelta = delta ?? Delta();

    int lastUrlOffset = 0;
    for (final match in matches) {
      if (lastUrlOffset < match.start) {
        nodeDelta.insert(line.substring(lastUrlOffset, match.start));
      }

      final link = line.substring(match.start, match.end);
      nodeDelta.insert(link, attributes: {AppFlowyRichTextKeys.href: link});
      lastUrlOffset = match.end;
    }

    final lastMatch = matches.last;
    if (lastMatch.end - 1 < line.length - 1) {
      nodeDelta.insert(line.substring(lastMatch.end));
    }

    return nodeDelta;
  }

  Node _codeBlockNodeFromMarkdown(
    String markdown,
    DeltaMarkdownDecoder decoder,
  ) {
    // This if conditions checks for cases like - ````` where we can see
    // it starts with ``` as well as end with ``` but is not a valid code block
    // so this is treated like a normal paragraph
    if (!markdown.contains('\n') &&
        markdown.split('`').length - 1 == markdown.length) {
      return paragraphNode(delta: decoder.convert(markdown));
    }
    const codeMarker = '```';
    int codeStartIndex = markdown.indexOf(codeMarker);
    int codeEndIndex = markdown.indexOf(
      codeMarker,
      codeStartIndex + codeMarker.length,
    );
    // This if condition is for handling cases like ```\n`
    // In this case codeStartIndex = 0 and codeEndIndex = -1
    if (codeEndIndex < codeStartIndex) {
      return paragraphNode(delta: decoder.convert(markdown));
    }
    String codeBlock = markdown.substring(
      codeStartIndex + codeMarker.length,
      codeEndIndex,
    );
    List<String> codeLines = codeBlock.trim().split('\n');

    // This if condition will handle cases like ```hello world```
    // this would be treated as a code block with hello world as its content
    if (codeLines[0].split(' ').length > 1) {
      return Node(
        type: 'code',
        attributes: {
          'delta': decoder.convert(codeBlock).toJson(),
          'language': null
        },
      );
    }
    final language = codeLines[0].trim();
    final codeContent = codeLines.sublist(1).join('\n');

    return Node(
      type: 'code',
      attributes: {
        'delta': decoder.convert(codeContent).toJson(),
        'language': language.isEmpty ? null : language
      },
    );
  }
}

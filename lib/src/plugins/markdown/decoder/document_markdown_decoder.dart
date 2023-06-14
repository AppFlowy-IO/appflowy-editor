import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';

class DocumentMarkdownDecoder extends Converter<String, Document> {
  @override
  Document convert(String input) {
    final lines = input.split('\n');
    final document = Document.blank();
    //previously
    // for (var i = 0; i < lines.length; i++) {
    //   document.insert([i], [_convertLineToNode(lines[i])]);
    // }
    int i = 0;
    //In the below while loop we iterate through each line of the input markdown
    //if the line starts with ``` it means there are chances it may be a code block
    // so it iterates through all the lines(using another while loop) storing them in a
    //string variable codeblock until it fing another ``` which marks the end of code
    // block it then sends this to convert _convertLineToNode function .
    // If we reach the end of lines and we still haven't found ``` thenwe will treat the
    // line starting with ``` as a regular paragraph and continue the main while loop from
    // a temporary pointer which stored the line number of the line with starting ```

    while (i < lines.length) {
      if (lines[i].startsWith("```")) {
        String codeBlock = "";
        codeBlock += "${lines[i]}\n";
        int tempLinePointer = i;
        i++;
        while (!lines[i].endsWith("```") && i < lines.length) {
          codeBlock += "${lines[i]}\n";
          i++;
        }

        if (i == lines.length) {
          document.insert([i], [_convertLineToNode(lines[i])]);
          i = tempLinePointer;
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
        attributes: {'delta': decoder.convert(line.substring(4)).toJson()},
      );
    } else if (line.startsWith('## ')) {
      return headingNode(
        level: 2,
        attributes: {'delta': decoder.convert(line.substring(3)).toJson()},
      );
    } else if (line.startsWith('# ')) {
      return headingNode(
        level: 1,
        attributes: {'delta': decoder.convert(line.substring(2)).toJson()},
      );
    } else if (line.startsWith('- [ ] ')) {
      return todoListNode(
        checked: false,
        attributes: {'delta': decoder.convert(line.substring(6)).toJson()},
      );
    } else if (line.startsWith('- [x] ')) {
      return todoListNode(
        checked: true,
        attributes: {'delta': decoder.convert(line.substring(6)).toJson()},
      );
    } else if (line.startsWith('> ')) {
      return quoteNode(
        attributes: {'delta': decoder.convert(line.substring(2)).toJson()},
      );
    } else if (line.startsWith('- ') || line.startsWith('* ')) {
      return bulletedListNode(
        attributes: {'delta': decoder.convert(line.substring(2)).toJson()},
      );
    } else if (line.isNotEmpty && RegExp('^-*').stringMatch(line) == line) {
      return Node(type: 'divider');
    } else if (line.startsWith('```') && line.endsWith('```')){
      return _codeBlockNodeFromMarkdown(line, decoder);
    }

    if (line.isNotEmpty) {
      return paragraphNode(
        attributes: {'delta': decoder.convert(line).toJson()},
      );
    }


    return paragraphNode(
      attributes: {'delta': Delta().toJson()},
    );
  }

  Node _codeBlockNodeFromMarkdown(
      String markdown, DeltaMarkdownDecoder decoder) {
    String codeStartMarker = "```";
    String codeEndMarker = "```";
    String language = "";
    String codeContent = "";
    int codeStartIndex = markdown.indexOf(codeStartMarker);
    int codeEndIndex = markdown.indexOf(
        codeEndMarker, codeStartIndex + codeStartMarker.length);

    String codeBlock = markdown.substring(
        codeStartIndex + codeStartMarker.length, codeEndIndex);
    List<String> codeLines = codeBlock.trim().split('\n');

    language = codeLines[0].trim();
    List<String> codeContentLines = codeLines.sublist(1);
    codeContent = codeContentLines.join('\n');

    return Node(type: 'code', attributes: {
      'delta': decoder.convert(codeContent).toJson(),
      'language': language
    });
  }
}

import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('document_markdown.dart tests', () {
    test('markdownToDocument()', () {
      final document = markdownToDocument(markdownDocument);
      final data = Map<String, Object>.from(json.decode(testDocument));

      expect(document.toJson(), data);
    });

    test('soft line break with two spaces', () {
      const markdown = 'first line  \nsecond line';
      final document = markdownToDocument(markdown);
      expect(document.root.children.length, 2);
      expect(document.root.children[0].delta?.toPlainText(), 'first line');
      expect(document.root.children[1].delta?.toPlainText(), 'second line');
    });

    test('documentToMarkdown()', () {
      final document = markdownToDocument(markdownDocument);
      final markdown = documentToMarkdown(document);

      expect(markdown, markdownDocumentEncoded);
    });

    test('paragraph + image with single \n', () {
      const markdown = '''This is the first line
![image](https://example.com/image.png)''';
      final document = markdownToDocument(markdown);
      final nodes = document.root.children;
      expect(nodes.length, 2);
      expect(nodes[0].delta?.toPlainText(), 'This is the first line');
      expect(nodes[1].attributes['url'], 'https://example.com/image.png');
    });

    test('paragraph + image with double \n', () {
      const markdown = '''This is the first line

![image](https://example.com/image.png)''';
      final document = markdownToDocument(markdown);
      final nodes = document.root.children;
      expect(nodes.length, 2);
      expect(nodes[0].delta?.toPlainText(), 'This is the first line');
      expect(nodes[1].attributes['url'], 'https://example.com/image.png');
    });

    test('paragraph + image without \n', () {
      const markdown =
          '''This is the first line![image](https://example.com/image.png)''';
      final document = markdownToDocument(markdown);
      final nodes = document.root.children;
      expect(nodes.length, 2);
      expect(nodes[0].delta?.toPlainText(), 'This is the first line');
      expect(nodes[1].attributes['url'], 'https://example.com/image.png');
    });

    test('paragraph + image with custom style', () {
      const markdown = '''![](http://test.com/1.png)
**第一幕：奇葩公司新规**
入职第一天发现我们公司有个祖传制度——迟到1分钟要讲1个笑话。前台小姐姐神秘兮兮地说："上周市场部Jason讲了三个谐音梗，现在还在走廊罚站呢。"我盯着手机屏幕的9:01分，感觉今天要成为《饥饿游戏》真人版主角。

`![](http://test.com/2.png)
**第二幕：社恐の终极挑战**
当我抱着简历冲进会议室时，行政总监、HR和部门主管突然集体转身。别问，问就是三堂会审现场。更可怕的是行政总监脖子上挂着"今日段子质检员"工牌，手里还攥着评分表！此时投影仪突然发出放屁般的故障音，大老板推门而入："听说新同事准备了特别节目？"''';
      final document = markdownToDocument(markdown);
      final nodes = document.root.children;
      expect(nodes.length, 6); // 2 images + 4 paragraphs
      expect(nodes[0].attributes['url'], 'http://test.com/1.png');
      expect(nodes[1].delta?.toPlainText(), '第一幕：奇葩公司新规');
      expect(
        nodes[2].delta?.toPlainText(),
        '入职第一天发现我们公司有个祖传制度——迟到1分钟要讲1个笑话。前台小姐姐神秘兮兮地说："上周市场部Jason讲了三个谐音梗，现在还在走廊罚站呢。"我盯着手机屏幕的9:01分，感觉今天要成为《饥饿游戏》真人版主角。',
      );

      expect(nodes[3].attributes['url'], 'http://test.com/2.png');
      expect(nodes[4].delta?.toPlainText(), '第二幕：社恐の终极挑战');
      expect(
        nodes[5].delta?.toPlainText(),
        '当我抱着简历冲进会议室时，行政总监、HR和部门主管突然集体转身。别问，问就是三堂会审现场。更可怕的是行政总监脖子上挂着"今日段子质检员"工牌，手里还攥着评分表！此时投影仪突然发出放屁般的故障音，大老板推门而入："听说新同事准备了特别节目？"',
      );
    });
  });
}

const testDocument = '''{
  "document": {
    "type": "page",
    "children": [
      {
        "type": "heading",
        "data": {"level": 1, "delta": [{"insert": "Heading 1"}]}
      },
      {
        "type": "heading",
        "data": {"level": 2, "delta": [{"insert": "Heading 2"}]}
      },
      {
        "type": "heading",
        "data": {"level": 3, "delta": [{"insert": "Heading 3"}]}
      },
      {"type": "divider"}
    ]
  }
}''';

const markdownDocument = """
# Heading 1
## Heading 2
### Heading 3
---""";

const markdownDocumentEncoded = """
# Heading 1
## Heading 2
### Heading 3
---
""";

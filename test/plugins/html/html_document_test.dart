import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('html_document_test.dart', () {
    // Foo Bar
    test('sample 1', () {
      const html = '<p>Foo Bar</p>';
      final document = htmlToDocument(html);
      expect(document.root.children.length, 1);
      expect(document.nodeAtPath([0])!.type, ParagraphBlockKeys.type);
      expect(document.nodeAtPath([0])!.delta!.toPlainText(), 'Foo Bar');
    });

    // * Foo
    // * Bar
    // * Baz
    test('sample 2', () {
      const html = '''<ul>
<li>Foo</li>
<li>Bar</li>
<li>Baz</li>
</ul>''';
      final document = htmlToDocument(html);
      expect(document.root.children.length, 3);
      expect(document.nodeAtPath([0])!.type, BulletedListBlockKeys.type);
      expect(document.nodeAtPath([0])!.delta!.toPlainText(), 'Foo');
      expect(document.nodeAtPath([1])!.type, BulletedListBlockKeys.type);
      expect(document.nodeAtPath([1])!.delta!.toPlainText(), 'Bar');
      expect(document.nodeAtPath([2])!.type, BulletedListBlockKeys.type);
      expect(document.nodeAtPath([2])!.delta!.toPlainText(), 'Baz');
    });

    // Hello
    // * Foo
    // * Bar
    // * Baz
    test('sample 3', () {
      const html = '''<p>Hello</p>
<ul>
<li>Foo</li>
<li>Bar</li>
<li>Baz</li>
</ul>''';
      final document = htmlToDocument(html);
      expect(document.root.children.length, 4);
      expect(document.nodeAtPath([0])!.type, ParagraphBlockKeys.type);
      expect(document.nodeAtPath([0])!.delta!.toPlainText(), 'Hello');
      expect(document.nodeAtPath([1])!.type, BulletedListBlockKeys.type);
      expect(document.nodeAtPath([1])!.delta!.toPlainText(), 'Foo');
      expect(document.nodeAtPath([2])!.type, BulletedListBlockKeys.type);
      expect(document.nodeAtPath([2])!.delta!.toPlainText(), 'Bar');
      expect(document.nodeAtPath([3])!.type, BulletedListBlockKeys.type);
      expect(document.nodeAtPath([3])!.delta!.toPlainText(), 'Baz');
    });

    // * Foo
    //  * Bar
    //    * Baz
    test('sample 4', () {
      const html = '''<ul>
<li>Foo
<ul>
<li>Bar
<ul>
<li>Baz</li>
</ul>
</li>
</ul>
</li>
</ul>''';
      final document = htmlToDocument(html);
      expect(document.root.children.length, 1);
      final foo = document.nodeAtPath([0])!;
      final bar = document.nodeAtPath([0, 0])!;
      final baz = document.nodeAtPath([0, 0, 0])!;
      expect(foo.type, BulletedListBlockKeys.type);
      expect(foo.delta!.toPlainText(), 'Foo');
      expect(bar.parent, foo);
      expect(bar.type, BulletedListBlockKeys.type);
      expect(bar.delta!.toPlainText(), 'Bar');
      expect(baz.parent, bar);
      expect(baz.type, BulletedListBlockKeys.type);
      expect(baz.delta!.toPlainText(), 'Baz');
    });

    // copy from Notion
    // There's a line with different formats, such as **bold**, __italic__, underline, ~~strikethrough~~, and `inline code`.
    test('sample 5', () {
      const html =
          '''<meta charset='utf-8'>There&#x27;s a line with different formats, such as <span style="font-weight:600" data-token-index="1" class="notion-enable-hover">bold</span>, <span style="font-style:italic" data-token-index="3" class="notion-enable-hover">italic</span>, <span style="color:inherit;border-bottom:0.05em solid;word-wrap:break-word" data-token-index="5" class="notion-enable-hover">underline</span>, <span style="text-decoration:line-through" data-token-index="7" class="notion-enable-hover">strikethrough</span>, and <span style="font-family:&quot;SFMono-Regular&quot;, Menlo, Consolas, &quot;PT Mono&quot;, &quot;Liberation Mono&quot;, Courier, monospace;line-height:normal;background:rgba(135,131,120,0.15);color:#EB5757;border-radius:3px;font-size:85%;padding:0.2em 0.4em" data-token-index="9" spellcheck="false" class="notion-enable-hover">inline code</span>.''';
      final document = htmlToDocument(html);
      final delta = document.nodeAtPath([0])!.delta!;
      expect(
        delta.toJson(),
        [
          {"insert": "There's a line with different formats, such as "},
          {
            "insert": "bold",
            "attributes": {"bold": true},
          },
          {"insert": ", "},
          {
            "insert": "italic",
            "attributes": {"italic": true},
          },
          {"insert": ", underline, "},
          {
            "insert": "strikethrough",
            "attributes": {"strikethrough": true},
          },
          {"insert": ", and "},
          {
            "insert": "inline code",
            "attributes": {
              "bg_color": "0x26878378",
              "font_color": "0xffeb5757",
            },
          },
          {"insert": "."},
        ],
      );
    });

    // sample 6
    // 1. Foo
    // 2. Bar
    // 3. Baz
    test('sample 6', () {
      const html = '''<ol>
<li>Foo</li>
<li>Bar</li>
<li>Baz</li>
</ol>''';
      final document = htmlToDocument(html);
      expect(document.nodeAtPath([0])!.type, NumberedListBlockKeys.type);
      expect(document.nodeAtPath([0])!.delta!.toPlainText(), 'Foo');
      expect(document.nodeAtPath([1])!.type, NumberedListBlockKeys.type);
      expect(document.nodeAtPath([1])!.delta!.toPlainText(), 'Bar');
      expect(document.nodeAtPath([2])!.type, NumberedListBlockKeys.type);
      expect(document.nodeAtPath([2])!.delta!.toPlainText(), 'Baz');
    });

    test('sample 7', () {
      const html = '''<ol>
<li>Foo
<ol>
<li>Bar
<ol>
<li>Baz</li>
</ol>
</li>
</ol>
</li>
</ol>''';
      final document = htmlToDocument(html);
      expect(document.root.children.length, 1);
      final foo = document.nodeAtPath([0])!;
      final bar = document.nodeAtPath([0, 0])!;
      final baz = document.nodeAtPath([0, 0, 0])!;
      expect(foo.type, NumberedListBlockKeys.type);
      expect(foo.delta!.toPlainText(), 'Foo');
      expect(bar.parent, foo);
      expect(bar.type, NumberedListBlockKeys.type);
      expect(bar.delta!.toPlainText(), 'Bar');
      expect(baz.parent, bar);
      expect(baz.type, NumberedListBlockKeys.type);
      expect(baz.delta!.toPlainText(), 'Baz');
    });
  });

  test('sample 8', () {
    const html = '''<ol>
<li><strong>Foo</strong></li>
<li><em>Bar</em></li>
<li><s>Baz</s></li>
</ol>
<ul>
<li><strong>Foo</strong></li>
<li><em>Bar</em></li>
<li><s>Baz</s></li>
</ul>''';
    final document = htmlToDocument(html);
    expect(document.root.children.length, 6);
    final foo1 = document.nodeAtPath([0])!;
    final bar1 = document.nodeAtPath([1])!;
    final baz1 = document.nodeAtPath([2])!;
    final foo2 = document.nodeAtPath([3])!;
    final bar2 = document.nodeAtPath([4])!;
    final baz2 = document.nodeAtPath([5])!;
    expect(foo1.type, NumberedListBlockKeys.type);
    expect(foo1.delta!.toPlainText(), 'Foo');
    expect(bar1.type, NumberedListBlockKeys.type);
    expect(bar1.delta!.toPlainText(), 'Bar');
    expect(baz1.type, NumberedListBlockKeys.type);
    expect(baz1.delta!.toPlainText(), 'Baz');
    expect(foo2.type, BulletedListBlockKeys.type);
    expect(foo2.delta!.toPlainText(), 'Foo');
    expect(bar2.type, BulletedListBlockKeys.type);
    expect(bar2.delta!.toPlainText(), 'Bar');
    expect(baz2.type, BulletedListBlockKeys.type);
    expect(baz2.delta!.toPlainText(), 'Baz');
  });

  // copy from Notion
  // There's a line with different formats, such as **bold**, __italic__, underline, ~~strikethrough~~, and `inline code`.
  test('sample 9', () {
    const html =
        '''<p>Hello</p><p>There's a line with different formats, such as <strong>bold</strong>, <em>italic</em>, underline, <s>strikethrough</s>, and <code>inline code</code>.</p>''';
    final document = htmlToDocument(html);
    expect(document.root.children.length, 2);
    final delta = document.nodeAtPath([1])!.delta!;
    expect(
      delta.toJson(),
      [
        {"insert": "There's a line with different formats, such as "},
        {
          "insert": "bold",
          "attributes": {"bold": true},
        },
        {"insert": ", "},
        {
          "insert": "italic",
          "attributes": {"italic": true},
        },
        {"insert": ", underline, "},
        {
          "insert": "strikethrough",
          "attributes": {"strikethrough": true},
        },
        {"insert": ", and "},
        {
          "insert": "inline code",
          "attributes": {"code": true},
        },
        {"insert": "."},
      ],
    );
  });

  test('sample 10', () {
    const html =
        '''<meta charset='utf-8'><span style="color: rgb(36, 36, 36); font-family: source-serif-pro, Georgia, Cambria, &quot;Times New Roman&quot;, Times, serif; font-size: 20px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: -0.06px; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">DTrace is a<span> </span></span><mark class="ael aco ao" style="box-sizing: inherit; cursor: pointer; color: currentcolor; background-color: rgb(187, 219, 186); font-family: source-serif-pro, Georgia, Cambria, &quot;Times New Roman&quot;, Times, serif; font-size: 20px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: -0.06px; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;"><strong class="mq fp" style="box-sizing: inherit; font-weight: 700; font-family: source-serif-pro, Georgia, Cambria, &quot;Times New Roman&quot;, Times, serif;"><em class="mp" style="box-sizing: inherit; font-style: italic;">dynamic tracing</em></strong></mark><mark class="ael aco ao" style="box-sizing: inherit; cursor: pointer; color: currentcolor; background-color: rgb(187, 219, 186); font-family: source-serif-pro, Georgia, Cambria, &quot;Times New Roman&quot;, Times, serif; font-size: 20px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: -0.06px; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;"><span> </span>technology</mark><span style="color: rgb(36, 36, 36); font-family: source-serif-pro, Georgia, Cambria, &quot;Times New Roman&quot;, Times, serif; font-size: 20px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: -0.06px; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;"><span> </span>that can be used to locate<span> </span></span><mark class="acn aco ao" style="box-sizing: inherit; cursor: pointer; background-color: rgb(232, 243, 232); color: currentcolor; font-family: source-serif-pro, Georgia, Cambria, &quot;Times New Roman&quot;, Times, serif; font-size: 20px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: -0.06px; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;">system performance issues</mark><span style="color: rgb(36, 36, 36); font-family: source-serif-pro, Georgia, Cambria, &quot;Times New Roman&quot;, Times, serif; font-size: 20px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: -0.06px; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">, obtain information about<span> </span></span><mark class="acn aco ao" style="box-sizing: inherit; cursor: pointer; background-color: rgb(232, 243, 232); color: currentcolor; font-family: source-serif-pro, Georgia, Cambria, &quot;Times New Roman&quot;, Times, serif; font-size: 20px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: -0.06px; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;">system function calls</mark><span style="color: rgb(36, 36, 36); font-family: source-serif-pro, Georgia, Cambria, &quot;Times New Roman&quot;, Times, serif; font-size: 20px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: -0.06px; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">, or monitor system runtime information. And worth noting is that DTrace is<span> </span></span><mark class="acn aco ao" style="box-sizing: inherit; cursor: pointer; background-color: rgb(232, 243, 232); color: currentcolor; font-family: source-serif-pro, Georgia, Cambria, &quot;Times New Roman&quot;, Times, serif; font-size: 20px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: -0.06px; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;"><strong class="mq fp" style="box-sizing: inherit; font-weight: 700; font-family: source-serif-pro, Georgia, Cambria, &quot;Times New Roman&quot;, Times, serif;">non-intrusive</strong></mark><span style="color: rgb(36, 36, 36); font-family: source-serif-pro, Georgia, Cambria, &quot;Times New Roman&quot;, Times, serif; font-size: 20px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: -0.06px; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;"><span> </span>to existing code. Also, there is no need to modify the existing code or use<span> </span></span><mark class="acn aco ao" style="box-sizing: inherit; cursor: pointer; background-color: rgb(232, 243, 232); color: currentcolor; font-family: source-serif-pro, Georgia, Cambria, &quot;Times New Roman&quot;, Times, serif; font-size: 20px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: -0.06px; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial;">instrumentation technology</mark><span style="color: rgb(36, 36, 36); font-family: source-serif-pro, Georgia, Cambria, &quot;Times New Roman&quot;, Times, serif; font-size: 20px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: -0.06px; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; white-space: normal; background-color: rgb(255, 255, 255); text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;"><span> </span>to obtain more system information.</span>''';
    final document = htmlToDocument(html);
    expect(document.root.children.length, 1);
    final delta = document.nodeAtPath([0])!.delta!;
    expect(
      delta.toJson(),
      [
        {
          "insert": "DTrace is a ",
          "attributes": {"bg_color": "0xffffffff", "font_color": "0xff242424"},
        },
        {
          "insert": "dynamic tracing",
          "attributes": {
            "bg_color": "0xffbbdbba",
            "bold": true,
            "italic": true,
          },
        },
        {
          "insert": " technology",
          "attributes": {"bg_color": "0xffbbdbba"},
        },
        {
          "insert": " that can be used to locate ",
          "attributes": {"bg_color": "0xffffffff", "font_color": "0xff242424"},
        },
        {
          "insert": "system performance issues",
          "attributes": {"bg_color": "0xffe8f3e8"},
        },
        {
          "insert": ", obtain information about ",
          "attributes": {"bg_color": "0xffffffff", "font_color": "0xff242424"},
        },
        {
          "insert": "system function calls",
          "attributes": {"bg_color": "0xffe8f3e8"},
        },
        {
          "insert":
              ", or monitor system runtime information. And worth noting is that DTrace is ",
          "attributes": {"bg_color": "0xffffffff", "font_color": "0xff242424"},
        },
        {
          "insert": "non-intrusive",
          "attributes": {"bg_color": "0xffe8f3e8", "bold": true},
        },
        {
          "insert":
              " to existing code. Also, there is no need to modify the existing code or use ",
          "attributes": {"bg_color": "0xffffffff", "font_color": "0xff242424"},
        },
        {
          "insert": "instrumentation technology",
          "attributes": {"bg_color": "0xffe8f3e8"},
        },
        {
          "insert": " to obtain more system information.",
          "attributes": {"bg_color": "0xffffffff", "font_color": "0xff242424"},
        }
      ],
    );
  });
}

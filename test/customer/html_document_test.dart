import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('customer html document test', () {
    test('paste text from ChatGPT', () {
      const html = '''
<meta charset='utf-8'><h2 data-start="283" data-end="314">Key Pain Points &amp; Challenges</h2>
<ol data-start="316" data-end="4630">
<li data-start="316" data-end="870">
<p data-start="319" data-end="361"><strong data-start="319" data-end="359">Accuracy, Hallucinations &amp; Omissions</strong></p>
<ul data-start="365" data-end="870">
<li data-start="365" data-end="569">
<p data-start="367" data-end="569">AI may mis-transcribe or “hallucinate” content (i.e. generate text that was never spoken). In high-stakes settings (e.g. medical, legal) this is especially risky. <span class="" data-state="closed"><span class="ms-1 inline-flex max-w-full items-center relative top-[-0.094rem] animate-[show_150ms_ease-in]" data-testid="webpage-citation-pill"><a href="https://apnews.com/article/90020cdf5fa16c79ca2e5b6c4c9bbb14?utm_source=chatgpt.com" target="_blank" rel="noopener" alt="https://apnews.com/article/90020cdf5fa16c79ca2e5b6c4c9bbb14?utm_source=chatgpt.com" class="flex h-4.5 overflow-hidden rounded-xl px-2 text-[9px] font-medium transition-colors duration-150 ease-in-out text-token-text-secondary! bg-[#F4F4F4]! dark:bg-[#303030]!"><span class="relative start-0 bottom-0 flex h-full w-full items-center"><span class="flex h-4 w-full items-center justify-between absolute"><span class="max-w-[15ch] grow truncate overflow-hidden text-center">Elite Asia</span><span class="-me-1 flex h-full items-center rounded-full px-1 text-[#8F8F8F]">+5</span></span><span class="flex h-4 w-full items-center justify-between"><span class="max-w-[15ch] grow truncate overflow-hidden text-center">AP News</span><span class="-me-1 flex h-full items-center rounded-full px-1 text-[#8F8F8F]">+5</span></span><span class="flex h-4 w-full items-center justify-between absolute"><span class="max-w-[15ch] grow truncate overflow-hidden text-center">WIRED</span><span class="-me-1 flex h-full items-center rounded-full px-1 text-[#8F8F8F]">+5</span></span></span></a></span></span></p>
</li>
<li data-start="573" data-end="743">
<p data-start="575" data-end="743">Technical jargon, acronyms, domain-specific vocabulary, accents, dialects, or overlapping speech still lead to high error rates. <span class="" data-state="closed"><span class="ms-1 inline-flex max-w-full items-center relative top-[-0.094rem] animate-[show_150ms_ease-in]" data-testid="webpage-citation-pill"><a href="https://go.verbit.ai/blog/automatic-transcription-the-pros-and-cons-of-ai-solutions/?utm_source=chatgpt.com" target="_blank" rel="noopener" alt="https://go.verbit.ai/blog/automatic-transcription-the-pros-and-cons-of-ai-solutions/?utm_source=chatgpt.com" class="flex h-4.5 overflow-hidden rounded-xl px-2 text-[9px] font-medium transition-colors duration-150 ease-in-out text-token-text-secondary! bg-[#F4F4F4]! dark:bg-[#303030]!"><span class="relative start-0 bottom-0 flex h-full w-full items-center"><span class="flex h-4 w-full items-center justify-between absolute"><span class="max-w-[15ch] grow truncate overflow-hidden text-center">blog.huddles.app</span><span class="-me-1 flex h-full items-center rounded-full px-1 text-[#8F8F8F]">+3</span></span><span class="flex h-4 w-full items-center justify-between"><span class="max-w-[15ch] grow truncate overflow-hidden text-center">go.verbit.ai</span><span class="-me-1 flex h-full items-center rounded-full px-1 text-[#8F8F8F]">+3</span></span><span class="flex h-4 w-full items-center justify-between absolute"><span class="max-w-[15ch] grow truncate overflow-hidden text-center">eff-inc.com</span><span class="-me-1 flex h-full items-center rounded-full px-1 text-[#8F8F8F]">+3</span></span></span></a></span></span></p>
</li>
<li data-start="747" data-end="870">
<p data-start="749" data-end="870">Silence, nonverbal cues, or pauses are sometimes incorrectly annotated or filled. <span class="" data-state="closed"><span class="ms-1 inline-flex max-w-full items-center relative top-[-0.094rem] animate-[show_150ms_ease-in]" data-testid="webpage-citation-pill"><a href="https://blog.huddles.app/what-are-the-limitations-of-ai-in-taking-meeting-notes/?utm_source=chatgpt.com" target="_blank" rel="noopener" alt="https://blog.huddles.app/what-are-the-limitations-of-ai-in-taking-meeting-notes/?utm_source=chatgpt.com" class="flex h-4.5 overflow-hidden rounded-xl px-2 text-[9px] font-medium transition-colors duration-150 ease-in-out text-token-text-secondary! bg-[#F4F4F4]! dark:bg-[#303030]!"><span class="relative start-0 bottom-0 flex h-full w-full items-center"><span class="flex h-4 w-full items-center justify-between"><span class="max-w-[15ch] grow truncate overflow-hidden text-center">blog.huddles.app</span><span class="-me-1 flex h-full items-center rounded-full px-1 text-[#8F8F8F]">+1</span></span></span></a></span></span></p></li></ul></li></ol>
''';
      final document = htmlToDocument(html);
      final children = document.root.children;
      expect(children.length, 2);
      // heading 2 - Key Pain Points & Challenges
      expect(children[0].type, HeadingBlockKeys.type);
      expect(children[0].delta!.toPlainText(), 'Key Pain Points & Challenges');

      // numbered list - Accuracy, Hallucinations & Omissions
      expect(children[1].type, NumberedListBlockKeys.type);
      expect(
        children[1].delta!.toPlainText(),
        'Accuracy, Hallucinations & Omissions',
      );

      // its children - 3 bulleted list items
      final children1 = children[1].children;
      expect(children1.length, 3);
      expect(
        children1.every((child) => child.type == BulletedListBlockKeys.type),
        isTrue,
      );
    });
  });
}

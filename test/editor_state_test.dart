import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('editor state', () {
    test('broadcast the transaction', () async {
      final editorState = EditorState.blank(
        withInitialText: false,
      );
      int count = 0;
      editorState.transactionStream.listen((event) {
        count++;
        final time = event.$1;
        switch (time) {
          case TransactionTime.before:
            expect(editorState.getNodeAtPath([0]), null);
            break;
          case TransactionTime.after:
            expect(
              editorState.getNodeAtPath([0])!.type,
              ParagraphBlockKeys.type,
            );
            break;
        }
      });
      final transaction = editorState.transaction;
      transaction.insertNode([0], paragraphNode(text: 'Hello World!'));
      await editorState.apply(transaction);
      expect(count, 2);
    });
  });
}

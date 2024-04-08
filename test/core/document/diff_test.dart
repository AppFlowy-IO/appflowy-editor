import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoid/non_secure.dart';

void main() async {
  group('diff.dart', () {
    Node buildNodeWithId(String id, String text) {
      return Node(
        type: ParagraphBlockKeys.type,
        attributes: {
          ParagraphBlockKeys.delta: (Delta()..insert(text)).toJson(),
        },
        id: id,
      );
    }

    Future<Document> apply(Document document, List<Operation> ops) async {
      final editorState = EditorState(document: document);
      final transaction = editorState.transaction;
      for (final op in ops) {
        transaction.add(op);
      }
      await editorState.apply(transaction, isRemote: true);
      return editorState.document;
    }

    test('text changes', () async {
      final id = nanoid(6);
      final documentA = Document.blank()
        ..insert([0], [buildNodeWithId(id, 'Hello World')]);
      final documentB = Document.blank()
        ..insert([0], [buildNodeWithId(id, 'Hello AppFlowy!')]);

      final ops = diffDocuments(documentA, documentB);
      expect(ops.length, 1);
      final op = ops.first;
      expect(op, isA<UpdateOperation>());
      expect((op as UpdateOperation).path, [0]);

      final expectation = jsonEncode(documentB.toJson());
      expect(
        jsonEncode((await apply(documentA, ops)).toJson()),
        expectation,
      );
    });

    test('insert', () async {
      final id1 = nanoid(6);
      final id2 = nanoid(6);
      final documentA = Document.blank()
        ..insert(
          [0],
          [buildNodeWithId(id1, 'Hello AppFlowy!')],
        );
      final documentB = Document.blank()
        ..insert([
          0,
        ], [
          buildNodeWithId(id1, 'Hello AppFlowy!'),
          buildNodeWithId(id2, 'Hello World!'),
        ]);

      final ops = diffDocuments(documentA, documentB);
      expect(ops.length, 1);
      final op = ops.first;
      expect(op, isA<InsertOperation>());
      expect((op as InsertOperation).path, [1]);

      final expectation = jsonEncode(documentB.toJson());
      expect(
        jsonEncode((await apply(documentA, ops)).toJson()),
        expectation,
      );
    });

    test('delete', () async {
      final id1 = nanoid(6);
      final id2 = nanoid(6);
      final documentA = Document.blank()
        ..insert(
          [0],
          [buildNodeWithId(id1, 'Hello AppFlowy!')],
        );
      final documentB = Document.blank()
        ..insert([
          0,
        ], [
          buildNodeWithId(id1, 'Hello AppFlowy!'),
          buildNodeWithId(id2, 'Hello World!'),
        ]);

      final ops = diffDocuments(documentB, documentA);
      expect(ops.length, 1);
      final op = ops.first;
      expect(op, isA<DeleteOperation>());
      expect((op as DeleteOperation).path, [1]);

      final expectation = jsonEncode(documentA.toJson());
      expect(
        jsonEncode((await apply(documentB, ops)).toJson()),
        expectation,
      );
    });

    test('continuous insert ', () async {
      final id1 = nanoid(6);
      final id2 = nanoid(6);
      final id3 = nanoid(6);
      final id4 = nanoid(6);
      final id5 = nanoid(6);
      final documentA = Document.blank()
        ..insert(
          [0],
          [buildNodeWithId(id1, 'Hello AppFlowy!')],
        );
      final documentB = Document.blank()
        ..insert([
          0,
        ], [
          buildNodeWithId(id1, 'Hello AppFlowy!'),
          buildNodeWithId(id2, '1'),
          buildNodeWithId(id3, '2'),
          buildNodeWithId(id4, '3'),
          buildNodeWithId(id5, '4'),
        ]);

      final ops = diffDocuments(documentA, documentB);
      expect(ops.length, 1);
      final op = ops.first;
      expect(op, isA<InsertOperation>());
      expect((op as InsertOperation).path, [1]);
      expect(
        op.nodes.map((e) => e.delta!.toPlainText()),
        ['1', '2', '3', '4'],
      );

      final expectation = jsonEncode(documentB.toJson());
      expect(
        jsonEncode((await apply(documentA, ops)).toJson()),
        expectation,
      );
    });

    test('continuous delete ', () async {
      final id1 = nanoid(6);
      final id2 = nanoid(6);
      final id3 = nanoid(6);
      final id4 = nanoid(6);
      final id5 = nanoid(6);
      final documentA = Document.blank()
        ..insert(
          [0],
          [
            buildNodeWithId(id1, 'Hello AppFlowy!'),
            buildNodeWithId(id2, '1'),
            buildNodeWithId(id3, '2'),
            buildNodeWithId(id4, '3'),
            buildNodeWithId(id5, '4'),
          ],
        );
      final documentB = Document.blank()
        ..insert([
          0,
        ], [
          buildNodeWithId(id1, 'Hello AppFlowy!'),
        ]);

      final ops = diffDocuments(documentA, documentB);
      expect(ops.length, 1);
      final op = ops.first;
      expect(op, isA<DeleteOperation>());
      expect((op as DeleteOperation).path, [1]);
      expect(
        op.nodes.map((e) => e.delta!.toPlainText()),
        ['1', '2', '3', '4'],
      );

      final expectation = jsonEncode(documentB.toJson());
      expect(
        jsonEncode((await apply(documentA, ops)).toJson()),
        expectation,
      );
    });
  });
}

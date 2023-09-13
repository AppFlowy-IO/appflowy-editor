import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('operation.dart', () {
    test('Operation.fromJson throws', () {
      expect(() => Operation.fromJson(), throwsA(isA<UnimplementedError>()));
    });

    test('InsertOperation.hashCode', () {
      const ip1 = InsertOperation([0], []);
      const ip2 = InsertOperation([0], []);

      expect(ip1 == ip2, true);
      expect(ip1.hashCode == ip2.hashCode, true);
    });

    test('DeleteOperation.hashCode', () {
      const dp1 = DeleteOperation([0], []);
      const dp2 = DeleteOperation([0], []);

      expect(dp1 == dp2, true);
      expect(dp1.hashCode == dp2.hashCode, true);
    });

    test('UpdateOperation.hashCode', () {
      const attr = {'a': 1};
      const up1 = UpdateOperation([0], attr, {});
      const up2 = UpdateOperation([0], attr, {});

      expect(up1 == up2, true);
      expect(up1.hashCode == up2.hashCode, true);
    });

    test('UpdateTextOperation.hashCode', () {
      final up1 = UpdateTextOperation([0], Delta(), Delta());
      final up2 = UpdateTextOperation([0], Delta(), Delta());

      expect(up1 == up2, true);
      expect(up1.hashCode == up2.hashCode, true);
    });

    test('test insert operation', () {
      final node = Node(type: 'example');
      final op = InsertOperation([0], [node]);
      final json = op.toJson();
      expect(json, {
        'op': 'insert',
        'path': [0],
        'nodes': [
          {
            'type': 'example',
          }
        ],
      });
      expect(InsertOperation.fromJson(json), op);
      expect(op.invert().invert(), op);
      expect(op.copyWith(), op);
    });

    test('test update operation', () {
      const op = UpdateOperation([0], {'a': 1}, {'a': 0});
      final json = op.toJson();
      expect(json, {
        'op': 'update',
        'path': [0],
        'attributes': {'a': 1},
        'oldAttributes': {'a': 0},
      });
      expect(UpdateOperation.fromJson(json), op);
      expect(op.invert().invert(), op);
      expect(op.copyWith(), op);
    });

    test('test delete operation', () {
      final node = Node(type: 'example');
      final op = DeleteOperation([0], [node]);
      final json = op.toJson();
      expect(json, {
        'op': 'delete',
        'path': [0],
        'nodes': [
          {
            'type': 'example',
          }
        ],
      });
      expect(DeleteOperation.fromJson(json), op);
      expect(op.invert().invert(), op);
      expect(op.copyWith(), op);
    });

    test('test update text operation', () {
      final app = Delta()..insert('App');
      final appflowy = Delta()
        ..retain(3)
        ..insert('Flowy');
      final op = UpdateTextOperation([0], app, appflowy.invert(app));
      final json = op.toJson();
      expect(json, {
        'op': 'update_text',
        'path': [0],
        'delta': [
          {'insert': 'App'},
        ],
        'inverted': [
          {'retain': 3},
          {'delete': 5},
        ],
      });
      expect(UpdateTextOperation.fromJson(json), op);
      expect(op.invert().invert(), op);
      expect(op.copyWith(), op);
    });

    test('transformOperation() a is InsertOperation', () {
      final n1 = Node(type: 'paragraph');
      final n2 = Node(type: 'example');

      final ip = InsertOperation([0], [n1, n2]);
      final dp = DeleteOperation([0], [n2]);

      final operation = transformOperation(ip, dp) as DeleteOperation;

      expect(operation.nodes.length, 1);
      expect(operation.nodes.first.delta, null);
      expect(operation.nodes.first.type, 'example');
    });

    test('transformOperation() a is DeleteOperation', () {
      final n1 = Node(type: 'paragraph');
      final n2 = Node(type: 'example');

      final ip = InsertOperation([0], [n1, n2]);
      final dp = DeleteOperation([0], [n2]);

      final operation = transformOperation(dp, ip) as InsertOperation;

      expect(operation.nodes.length, 2);
      expect(operation.nodes.first.type, 'paragraph');
      expect(operation.nodes.last.type, 'example');
    });

    test('transformOperation() a is UpdateOperation', () {
      final n1 = Node(type: 'paragraph');

      const up = UpdateOperation([0], {'a': 1}, {});
      final dp = DeleteOperation([0], [n1]);

      final operation = transformOperation(up, dp) as DeleteOperation;

      expect(operation.nodes.length, 1);
      expect(operation.nodes.first.type, 'paragraph');
    });

    test('transformOperation() a and b is DeleteOperation', () {
      final n1 = Node(type: 'paragraph');

      final dp1 = DeleteOperation([1, 0, 1], [n1]);
      final dp2 = DeleteOperation([1, 0], [n1]);

      final operation = transformOperation(dp1, dp2) as DeleteOperation;

      expect(operation.nodes.length, 1);
      expect(operation.nodes.first.type, 'paragraph');
    });
  });
}

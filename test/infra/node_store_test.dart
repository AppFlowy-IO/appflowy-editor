import 'package:appflowy_editor/src/infra/node_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NodeStore', () {
    test('saveNodes', () {
      NodeStore.saveNodes([]);
      expect(NodeStore.getNodes(), []);
    });
    test('clearNodes', () {
      NodeStore.saveNodes([]);
      NodeStore.clearNodes();
      expect(NodeStore.getNodes(), null);
    });
  });
}
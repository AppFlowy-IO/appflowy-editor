import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){
  test('isLeavingTableVertically', (){
    assert(isLeavingTableVertically(1, 1));
    assert(isLeavingTableVertically(-1, 1));
    assert(!isLeavingTableVertically(0, 1));
    assert(!isLeavingTableVertically(1, 2));
    assert(isLeavingTableVertically(2, 2));
  });

  test('getSibling', (){
    final root = Node(type: 'root');
    final mid = Node(type: 'mid');
    root.insert(Node(type: 'left'));
    root.insert(mid);
    root.insert(Node(type: 'right'));
    final left = getSibling(mid, true);
    assert(left != null);
    assert(left!.type == 'left');

    final right = getSibling(mid, false);
    assert(right != null);
    assert(right!.type == 'right');

    assert(getSibling(left!, true) == null);
    assert(getSibling(left!, false) != null);
    assert(getSibling(left!, false)!.type == 'mid');
    assert(getSibling(right!, false) == null);
    assert(getSibling(right!, true) != null);
    assert(getSibling(right!, true)!.type == 'mid');
  });
}
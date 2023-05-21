import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/src/render/find_replace_menu/search_algorithm.dart';

void main() {
  group('SearchAlgorithm', () {
    late SearchAlgorithm searchAlgorithm;

    setUpAll(() {
      searchAlgorithm = SearchAlgorithm();
    });

    test('searchAlgorithm returns the index of the only found pattern', () {
      const pattern = 'Appflowy';
      const text = 'Welcome to Appflowy 😁';

      List<int> result = searchAlgorithm.boyerMooreSearch(pattern, text);
      expect(result, [11]);
    });

    test('searchAlgorithm returns the index of the multiple found patterns',
        () {
      const pattern = 'Appflowy';
      const text = '''
Welcome to Appflowy 😁. Appflowy is an open-source alternative to Notion. 
With Appflowy, you can build detailed lists of to-do for different 
projects while tracking the status of each one. With Appflowy, you can 
visualize items in a database moving through stages of a process, or 
grouped by property. Design and modify Appflowy your way with an 
open core codebase. Appflowy is built with Flutter and Rust.
      ''';

      List<int> result = searchAlgorithm.boyerMooreSearch(pattern, text);
      expect(result, [11, 24, 80, 196, 324, 371]);
    });

    test('searchAlgorithm returns empty list if pattern is not found', () {
      const pattern = 'Flutter';
      const text = 'Welcome to Appflowy 😁';

      final result = searchAlgorithm.boyerMooreSearch(pattern, text);

      expect(result, []);
    });

    test('searchAlgorithm returns pattern index if pattern is non-ASCII', () {
      const pattern = '😁';
      const text = 'Welcome to Appflowy 😁';

      List<int> result = searchAlgorithm.boyerMooreSearch(pattern, text);
      expect(result, [20]);
    });

    test('searchAlgorithm returns pattern index if pattern is not separate word', () {
      const pattern = 'App';
      const text = 'Welcome to Appflowy 😁';

      List<int> result = searchAlgorithm.boyerMooreSearch(pattern, text);
      expect(result, [11]);
    });

    test('searchAlgorithm returns empty list bcz it is case sensitive', () {
      const pattern = 'APPFLOWY';
      const text = 'Welcome to Appflowy 😁';

      List<int> result = searchAlgorithm.boyerMooreSearch(pattern, text);
      expect(result, []);
    });
  });
}

import 'package:web/web.dart' as web;

/// The value of `window.navigator.platform`, lowercased.
///
/// Uses `package:web` so that the library can compile to WebAssembly —
/// `dart:html`-based packages like `universal_html` cannot.
String get navigatorPlatform => web.window.navigator.platform.toLowerCase();

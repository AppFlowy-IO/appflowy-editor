/// Stub used on non-web platforms, where `window.navigator` doesn't exist.
///
/// The web implementation lives in `navigator_platform_web.dart`.
String get navigatorPlatform => '';

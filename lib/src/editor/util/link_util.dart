import 'package:string_validator/string_validator.dart';

bool isUri(String text) {
  final lowerText = text.toLowerCase();
  return isURL(text) ||
      isCustomUrL(text) ||
      lowerText.startsWith('mailto:') ||
      lowerText.startsWith('file:');
}

/// return true if the text looks like [xxx://xxx]
bool isCustomUrL(String text) => customUrlRegex.hasMatch(text);

final customUrlRegex =
    RegExp(r'^[a-zA-Z0-9]+:\/\/[^\/\s].*$', caseSensitive: false);

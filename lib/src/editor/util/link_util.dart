import 'package:string_validator/string_validator.dart';

bool isUri(String text) {
  final lowerText = text.toLowerCase();
  return isURL(text) ||
      lowerText.startsWith('mailto:') ||
      lowerText.startsWith('file:');
}

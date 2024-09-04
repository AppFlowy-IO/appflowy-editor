import 'package:string_validator/string_validator.dart';

bool isUri(String text) {
  return isURL(text) || isMailTo(text) || isFile(text);
}

bool isMailTo(String text) {
  const mailToPrefix = 'mailto:';
  return text.startsWith(mailToPrefix) &&
      isEmail(text.substring(mailToPrefix.length));
}

bool isFile(String text) {
  return text.startsWith('file:/');
}

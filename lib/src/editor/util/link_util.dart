import 'package:string_validator/string_validator.dart';

bool isUri(String text) {
  return isURL(text) || isMailTo(text);
}

bool isMailTo(String text) {
  const mailToPrefix = 'mailto:';
  return text.startsWith(mailToPrefix) &&
      isEmail(text.substring(mailToPrefix.length));
}

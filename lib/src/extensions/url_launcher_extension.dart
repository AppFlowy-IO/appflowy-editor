import 'package:url_launcher/url_launcher_string.dart';

Future<bool> safeLaunchUrl(String? href) async {
  if (href == null) {
    return Future.value(false);
  }
  final uri = Uri.parse(href);
  
  // Security: Prevent execution of dangerous URI schemes (XSS)
  final validSchemes = ['http', 'https', 'mailto', 'tel', 'sms'];
  if (uri.scheme.isNotEmpty && !validSchemes.contains(uri.scheme.toLowerCase())) {
    return Future.value(false);
  }

  // url_launcher cannot open a link without scheme.
  final newHref = (uri.scheme.isNotEmpty ? href : 'http://$href').trim();
  if (await canLaunchUrlString(newHref)) {
    await launchUrlString(newHref);
  }

  return Future.value(true);
}

Future<bool> Function(String? href) editorLaunchUrl = safeLaunchUrl;

class UrlValidator {
  static const _url =
      r"^((((H|h)(T|t)|(F|f))(T|t)(P|p)((S|s)?))\://)?(www.|[a-zA-Z0-9].)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,6}(\:[0-9]{1,5})*(/($|[a-zA-Z0-9\.\,\;\?\'\\\+&amp;%\$#\=~_\-]+))*$";

  static bool isValidUrl(String url) {
    // Regular expression for a simple URL validation
    final RegExp urlRegExp = RegExp(
      _url,
      caseSensitive: false,
      multiLine: false,
    );

    return urlRegExp.hasMatch(url);
  }
}

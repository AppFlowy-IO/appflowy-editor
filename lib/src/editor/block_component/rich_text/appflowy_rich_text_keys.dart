class AppFlowyRichTextKeys {
  static String bold = 'bold';
  static String italic = 'italic';
  static String underline = 'underline';
  static String strikethrough = 'strikethrough';
  static String textColor = 'font_color';
  static String backgroundColor = 'bg_color';
  static String findBackgroundColor = 'find_bg_color';
  static String code = 'code';
  static String href = 'href';
  static String fontFamily = 'font_family';
  static String fontSize = 'font_size';

  static List<String> supportSliced = [
    bold,
    italic,
    underline,
    strikethrough,
    textColor,
    backgroundColor,
  ];

  // The values supported toggled even if the selection is collapsed.
  static List<String> supportToggled = [
    bold,
    italic,
    underline,
    strikethrough,
    code,
    fontFamily,
    textColor,
    backgroundColor,
  ];
}

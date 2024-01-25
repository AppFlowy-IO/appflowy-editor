import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';

String shortcutTooltips(
  String? macOSString,
  String? windowsString,
  String? linuxString,
) {
  if (kIsWeb) return '';
  if (Platform.isMacOS && macOSString != null) {
    return '\n$macOSString';
  } else if (Platform.isWindows && windowsString != null) {
    return '\n$windowsString';
  } else if (Platform.isLinux && linuxString != null) {
    return '\n$linuxString';
  }
  return '';
}

String getTooltipText(String id) {
  switch (id) {
    case 'underline':
      return '${AppFlowyEditorL10n.current.underline}${shortcutTooltips('⌘ + U', 'CTRL + U', 'CTRL + U')}';
    case 'bold':
      return '${AppFlowyEditorL10n.current.bold}${shortcutTooltips('⌘ + B', 'CTRL + B', 'CTRL + B')}';
    case 'italic':
      return '${AppFlowyEditorL10n.current.italic}${shortcutTooltips('⌘ + I', 'CTRL + I', 'CTRL + I')}';
    case 'strikethrough':
      return '${AppFlowyEditorL10n.current.strikethrough}${shortcutTooltips('⌘ + SHIFT + S', 'CTRL + SHIFT + S', 'CTRL + SHIFT + S')}';
    case 'code':
      return '${AppFlowyEditorL10n.current.embedCode}${shortcutTooltips('⌘ + E', 'CTRL + E', 'CTRL + E')}';
    case 'align_left':
      return AppFlowyEditorL10n.current.textAlignLeft;
    case 'align_center':
      return AppFlowyEditorL10n.current.textAlignCenter;
    case 'align_right':
      return AppFlowyEditorL10n.current.textAlignRight;
    case 'text_direction_auto':
      return AppFlowyEditorL10n.current.auto;
    case 'text_direction_ltr':
      return AppFlowyEditorL10n.current.ltr;
    case 'text_direction_rtl':
      return AppFlowyEditorL10n.current.rtl;
    default:
      return '';
  }
}

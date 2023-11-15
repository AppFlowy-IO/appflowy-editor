import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum AFMobileIcons {
  textDecoration('toolbar_icons/text_decoration'),
  bold('toolbar_icons/bold'),
  italic('toolbar_icons/italic'),
  underline('toolbar_icons/underline'),
  strikethrough('toolbar_icons/strikethrough'),
  code('toolbar_icons/code'),
  color('toolbar_icons/color'),
  link('toolbar_icons/link'),
  heading('toolbar_icons/heading'),
  h1('toolbar_icons/h1'),
  h2('toolbar_icons/h2'),
  h3('toolbar_icons/h3'),
  list('toolbar_icons/list'),
  bulletedList('toolbar_icons/bulleted_list'),
  numberedList('toolbar_icons/numbered_list'),
  checkbox('toolbar_icons/checkbox'),
  quote('toolbar_icons/quote'),
  divider('toolbar_icons/divider'),
  close('toolbar_icons/close');

  final String iconPath;
  const AFMobileIcons(this.iconPath);
}

/// {@tool snippet}
/// All the icons are from AFMobileIcons enum.
///
/// ```dart
/// AFMobileIcon(
///       afMobileIcons: AFMobileIcons.bold,
///       size: 24,
///       color: Colors.black,
///)
/// ```
/// {@end-tool}
class AFMobileIcon extends StatelessWidget {
  const AFMobileIcon({
    super.key,
    required this.afMobileIcons,
    this.size = 24,
    this.color,
  });

  final AFMobileIcons afMobileIcons;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/mobile/${afMobileIcons.iconPath}.svg',
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      fit: BoxFit.fill,
      height: size,
      width: size,
      package: 'appflowy_editor',
    );
  }
}

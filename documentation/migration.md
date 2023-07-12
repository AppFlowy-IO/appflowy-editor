# Migration Guide

## From 1.1.0 to 1.2.0

- `AppFlowyEditor.custom` and `AppFlowyEditor.standard` have been removed. Use `AppFlowyEditor.` instead.
  - For now, we provide the default values to the `blockComponentBuilders`, `characterShortcutEvents`, and `commandShortcutEvents` if you do not customize them.
- `DefaultSelectable` has been renamed to `DefaultSelectableMixin`
- `FlowyRichText` has been renamed to `AppFlowyRichText`.
- Added new parameter called `context`(BuildContext) into `TextSpanDecoratorForAttribute`.
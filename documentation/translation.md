# Translate AppFlowy Editor

You can help Appflowy Editor in supporting various languages by contributing. Follow the steps below sequentially to contribute translations.

## Steps to modify an existing translation
Translation files are located in: `lib/l10n/`
1. Install the Visual Studio Code plugin: [Flutter intl](https://marketplace.visualstudio.com/items?itemName=localizely.flutter-intl)
2. Modify the specific translation file.
3. Save the file and the translation will be generated automatically.

## Steps to add new language
Translation files are located in: `lib/l10n/`
1. Install the Visual Studio Code plugin: [Flutter intl](https://marketplace.visualstudio.com/items?itemName=localizely.flutter-intl)
2. Copy the `intl_en.arb` as a base translation and rename the new file to `intl_<new_locale>.arb`
3. Modify the new translation file.
4. Save the file and the translation will be generated automatically.

## Modify the locale of the editor

If you want to try the changes you made, you can modify the locale of the editor by changing the `supportedLocales` variable in [example/lib/main.dart](../example/lib/main.dart) to the locale you want to test.

```dart
// example/lib/main.dart
// Change this:
supportedLocales: AppFlowyEditorLocalizations.delegate.supportedLocales,
// to the locale you want to test, for example fr_FR:
supportedLocales: const [Locale('fr', 'FR')],
```

Or you can do it interactively by adding a Floating Action Button to the page. Edit [example/lib/home_page.dart](../example/lib/home_page.dart):

> You need to rebuild to see the changes of the translated strings.

```dart
// example/lib/home_page.dart
class _HomePageState extends State<HomePage> {
  // other code...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // other code...
      floatingActionButton: FloatingActionButton(
        onPressed: toggleLocale,
        child: const Icon(Icons.language),
      ),
    );
  }

  void toggleLocale() {
    final locale = Intl.getCurrentLocale();
        if (locale.startsWith('en')) {
      // Change to the locale you want to test
      AppFlowyEditorLocalizations.load(const Locale('pt', 'BR')); 
    } else {
      AppFlowyEditorLocalizations.load(const Locale('en', 'US'));
    }
  }
```

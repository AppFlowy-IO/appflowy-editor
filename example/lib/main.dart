import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AppFlowyEditorLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData.light(useMaterial3: true),
    );
  }
}

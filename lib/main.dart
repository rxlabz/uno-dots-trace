import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'editor/desktop_editor_controller.dart';
import 'editor/editor.dart';
import 'editor/mac_editor.dart';
import 'figure_drawer.dart';
import 'services/figure_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  //await prefs.clear();

  final service = FigureService(prefs);

  runApp(MacApp(service));
}

class App extends StatelessWidget {
  final FigureService service;

  const App(this.service, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editorController = DesktopEditorController(service)..init();

    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      //home: ResizerScreen(),
      home: FigureEditorScreen(controller: editorController),
      routes: {
        '/editor': (context) =>
            FigureEditorScreen(controller: editorController),
        '/drawer': (context) => const FigureDrawingScreen()
      },
    );
  }
}

class MacApp extends StatelessWidget {
  final FigureService service;

  const MacApp(this.service, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editorController = DesktopEditorController(service)..init();

    return MacosApp(
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.light,
      //home: ResizerScreen(),
      home: MacFigureEditorScreen(controller: editorController),
      routes: {
        '/editor': (context) =>
            FigureEditorScreen(controller: editorController),
        '/drawer': (context) => const FigureDrawingScreen()
      },
    );
  }
}

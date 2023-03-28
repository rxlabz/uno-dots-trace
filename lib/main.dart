import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'editor/desktop_editor_controller.dart';
import 'editor/mac_editor.dart';
import 'services/figure_service.dart';

const minSize = Size(1280, 960);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: minSize,
    minimumSize: minSize,
    skipTaskbar: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final prefs = await SharedPreferences.getInstance();

  final service = FigureService(prefs);

  runApp(MacApp(service));
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
      home: MacFigureEditorScreen(controller: editorController),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'src/editor/desktop_editor_controller.dart';
import 'src/editor/mac_editor.dart';
import 'src/services/figure_service.dart';

const minSize = Size(1280, 960);

/// Desktop MacosUI App
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initWindow();

  final prefs = await SharedPreferences.getInstance();

  final service = FigureService(prefs);

  runApp(MacApp(service));
}

Future<void> initWindow() async {
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
}

/// MacosApp
class MacApp extends StatelessWidget {
  final FigureService service;

  const MacApp(this.service, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editorController = DesktopEditorController(service)..init();

    return MacosApp(
      theme: MacosThemeData.light(),
      themeMode: ThemeMode.light,
      home: MacFigureEditorScreen(controller: editorController),
    );
  }
}

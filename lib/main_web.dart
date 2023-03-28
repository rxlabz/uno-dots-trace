import 'package:flutter/material.dart';

import 'editor/editor_controller.dart';
import 'editor/web_editor.dart';

void main() async {
  runApp(const WebApp());
}

class WebApp extends StatelessWidget {
  const WebApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editorController = EditorController();

    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
          backgroundColor: Colors.blueGrey.shade200,
        ),
      ),
      home: WebEditorScreen(controller: editorController),
    );
  }
}

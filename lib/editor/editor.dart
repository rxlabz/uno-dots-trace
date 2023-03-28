import 'package:flutter/material.dart';

import 'desktop_editor_controller.dart';
import 'editor_canvas.dart';
import 'image_controller.dart';

class FigureEditorScreen extends StatelessWidget {
  final DesktopEditorController controller;

  final ImageNotifier imageController = ImageNotifier();

  FigureEditorScreen({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/drawer'),
            icon: const Icon(Icons.photo),
          )
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 200,
            color: Colors.blueGrey.shade50,
            child: Column(
              children: [
                const Flexible(child: Text('Dessins')),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: controller.figures,
                    builder: (context, figures, child) {
                      return ListView(
                        children: figures
                            .map(
                              (figure) => ListTile(
                                title: Text(figure.title),
                                onTap: () => controller.open(figure),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ColoredBox(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: TextField(
                              controller: controller.titleController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: controller.save,
                          child: const Text('Save'),
                        ),
                        ElevatedButton(
                          onPressed: controller.clear,
                          child: const Text('Clear'),
                        ),
                        ElevatedButton(
                          onPressed: imageController.selectImage,
                          child: const Text('Image'),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: ValueListenableBuilder(
                    valueListenable: controller.toolSelection,
                    builder: (context, value, _) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ToggleButtons(
                          isSelected: value,
                          selectedColor: Colors.cyan,
                          onPressed: controller.selectTool,
                          children: const [
                            Icon(Icons.edit),
                            Icon(Icons.pan_tool_alt),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: imageController,
                    builder: (context, file, child) => ValueListenableBuilder(
                      valueListenable: controller.toolSelection,
                      builder: (context, selection, _) =>
                          FigureEditorCanvas(controller: controller),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

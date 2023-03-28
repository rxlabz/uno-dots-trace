import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import 'desktop_editor_controller.dart';
import 'editor_canvas.dart';

class MacFigureEditorScreen extends StatelessWidget {
  final DesktopEditorController controller;

  const MacFigureEditorScreen({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      sidebar: Sidebar(
        minWidth: 200,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade900,
        ),
        top: TextButton.icon(
          onPressed: controller.newFigure,
          icon: const MacosIcon(CupertinoIcons.add_circled),
          label: const Text('Nouvelle figure'),
        ),
        builder: (context, scroller) {
          return MacosTheme(
            data: MacosThemeData.dark(),
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                if (controller.selectionIndex == null) {
                  return const CircularProgressIndicator();
                }

                final figures = controller.figures.value;
                return SidebarItems(
                  items: figures
                      .map(
                        (e) => SidebarItem(
                          label: Text(e.title),
                          leading: const MacosIcon(CupertinoIcons.doc),
                        ),
                      )
                      .toList(),
                  currentIndex: controller.selectionIndex!,
                  onChanged: (newIndex) => controller.open(figures[newIndex]),
                );
              },
            ),
          );
        },
      ),
      child: ColoredBox(
        color: Colors.blueGrey.shade200,
        child: Column(
          children: [
            AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return ColoredBox(
                    color: Colors.blueGrey.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 240,
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: MacosTextField(
                                controller: controller.titleController,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: controller.save,
                            child: const Text('Save'),
                          ),
                          const Spacer(),
                          ValueListenableBuilder(
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
                                    Icon(CupertinoIcons.arrow_up_right),
                                  ],
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: [
                                MacosSwitch(
                                  value: controller.randomIncrement,
                                  onChanged: (value) =>
                                      controller.randomIncrement = value,
                                ),
                                const Text('Random step'),
                              ],
                            ),
                          ),
                          MacosIconButton(
                            onPressed: () async {
                              if (await controller.imageController
                                  .selectImage()) {
                                controller.selectTool(1);
                              }
                            },
                            icon: const MacosIcon(CupertinoIcons.photo),
                          ),
                          MacosIconButton(
                            onPressed: controller.clear,
                            icon: const MacosIcon(CupertinoIcons.clear),
                          ),
                          MacosIconButton(
                            onPressed: controller.toPDF,
                            icon: const MacosIcon(CupertinoIcons.printer),
                          ),
                          MacosIconButton(
                            onPressed: controller.delete,
                            icon: const MacosIcon(
                              CupertinoIcons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: controller.toolSelection,
                builder: (context, selection, _) => FigureEditorCanvas(
                  controller: controller,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

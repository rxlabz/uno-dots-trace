import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

import 'desktop_editor_controller.dart';
import 'editor_canvas.dart';

/// editor screen displays :
/// - list of saved figures
/// - tool bar
/// - and canvas
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
          label: const Text('New Page'),
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
                            width: 200,
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28.0),
                            child: Row(
                              children: [
                                MacosIconButton(
                                  onPressed: controller.selectImage,
                                  icon: const MacosIcon(CupertinoIcons.photo),
                                ),
                                const Text('Background image')
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ToggleButtons(
                              isSelected: controller.toolSelection,
                              selectedColor: Colors.cyan,
                              onPressed: controller.selectToolMode,
                              children: const [
                                Icon(Icons.edit),
                                Icon(Icons.pan_tool_alt),
                                Icon(CupertinoIcons.arrow_up_right),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ToggleButtons(
                              isSelected: controller.orientationSelection,
                              color: Colors.blueGrey.shade700,
                              selectedColor: Colors.blueGrey.shade300,
                              onPressed: (_) => controller.toggleOrientation(),
                              children: const [
                                Icon(Icons.landscape),
                                Icon(Icons.portrait),
                              ],
                            ),
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
                          const VerticalDivider(
                              color: Colors.blueGrey, width: 20, thickness: 1),
                          MacosIconButton(

                            onPressed: controller.undo,
                            icon: const MacosIcon(
                              Icons.undo,
                              color: Color(0xFF546E7A),
                            ),
                          ),
                          MacosIconButton(
                            onPressed: controller.toPDF,
                            icon: const MacosIcon(CupertinoIcons.printer),
                          ),
                          MacosIconButton(
                            onPressed: controller.figures.value.isEmpty
                                ? null
                                : controller.delete,
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
            Expanded(child: FigureEditorCanvas(controller: controller))
          ],
        ),
      ),
    );
  }
}

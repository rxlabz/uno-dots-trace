import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'editor_canvas.dart';
import 'editor_controller.dart';

class WebEditorScreen extends StatelessWidget {
  const WebEditorScreen({required this.controller, super.key});

  final EditorController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: Colors.blueGrey.shade200,
        child: Column(
          children: [
            _EditorToolbar(controller: controller),
            Expanded(
              child: FigureEditorCanvas(controller: controller),
            )
          ],
        ),
      ),
    );
  }
}

class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({required this.controller});

  final EditorController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: Colors.blueGrey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Row(
              children: [
                const Icon(
                  Icons.polyline_outlined,
                  color: Colors.blueGrey,
                  size: 48,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uno-Dots-Trace',
                      style: textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () =>
                          launchUrlString('https://twitter.com/rxlabz'),
                      child: const Text('Dot2dot Editor by rxlabz'),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Row(
                    children: [
                      TextButton.icon(
                        icon: const Icon(
                          Icons.add_photo_alternate,
                          color: Color(0xFF546E7A),
                        ),
                        label: const Text('Background image'),
                        onPressed: controller.selectImage,
                      ),
                    ],
                  ),
                ),
                const Text('Tools'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ToggleButtons(
                    isSelected: controller.toolSelection,
                    selectedColor: Colors.blueGrey.shade300,
                    color: Colors.blueGrey.shade700,
                    onPressed: controller.selectTool,
                    children: const [
                      Icon(Icons.polyline),
                      Icon(Icons.pan_tool),
                      Icon(Icons.control_camera),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 28.0),
                  child: Text('Orientation'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Switch(
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
                IconButton(
                  tooltip: 'Delete last point',
                  onPressed: controller.undo,
                  icon: const Icon(
                    Icons.undo,
                    color: Color(0xFF546E7A),
                  ),
                ),
                IconButton(
                  tooltip: 'Save as PDF',
                  onPressed: controller.toPDF,
                  icon: const Icon(
                    Icons.sim_card_download_outlined,
                    color: Color(0xFF546E7A),
                  ),
                ),
                IconButton(
                  tooltip: 'Source',
                  onPressed: () => launchUrlString(
                      'https://github.com/rxlabz/uno-dots-trace'),
                  icon: const Icon(
                    Icons.code,
                    color: Color(0xFF546E7A),
                  ),
                ),
                IconButton(
                  tooltip: 'Help',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const HelpDialog(),
                  ),
                  icon: const Icon(
                    Icons.help,
                    color: Color(0xFF546E7A),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 640,
      /*height: 480,*/
      child: Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            InstructionStep(
              index: 1,
              label: 'Select an image (optional)',
              icon: Icons.add_photo_alternate,
            ),
            InstructionStep(
              index: 2,
              label: 'Draw your dot-to-dot figure',
              icon: Icons.polyline,
            ),
            InstructionStep(
              index: 3,
              label: 'Edit your dots ( double clic on a point to delete it )',
              icon: Icons.control_camera,
            ),
            InstructionStep(
              index: 4,
              label: 'Download your PDF',
              icon: Icons.sim_card_download_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class InstructionStep extends StatelessWidget {
  final int index;
  final String label;
  final IconData? icon;
  const InstructionStep(
      {required this.index, required this.label, this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineSmall;
    final indexStyle = Theme.of(context).primaryTextTheme.headlineMedium;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade700,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('$index', style: indexStyle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(icon, size: 42, color: Colors.blueGrey),
          ),
          Text(label, style: style),
        ],
      ),
    );
  }
}

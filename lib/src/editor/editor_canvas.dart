import 'dart:math' hide Point;
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart' as qv;

import '../model.dart';
import 'widgets/rszr.dart';
import 'widgets/draggable_image_box.dart';
import 'editor_controller.dart';
import 'widgets/web_file_image.dart'
    if (dart.library.io) 'widgets/desktop_file_image.dart';

const landscapeWidth = 1024.0;
const portraitWidth = 768.0;

final rd = Random();

const nodeRadius = 4.0;

class FigureEditorCanvas extends StatelessWidget {
  final EditorController controller;

  const FigureEditorCanvas({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final image = controller.image;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: controller.aspectRatio,
                child: LayoutBuilder(builder: (context, constraints) {
                  controller.size =
                      Size(constraints.maxWidth, constraints.maxHeight);
                  return Material(
                    color: Colors.white,
                    elevation: 5,
                    child: ValueListenableBuilder(
                      valueListenable: controller.points,
                      builder: (context, points, child) {
                        return GestureDetector(
                          onTapDown: controller.toolMode.isPen
                              ? (e) => controller.addPoint(e.localPosition)
                              : null,
                          child: EditorCanvas(
                            points: points,
                            mode: controller.toolMode,
                            backgroundImage: image,
                            onPointUpdate: controller.updatePoint,
                            onDeletePoint: (index) =>
                                controller.deletePoint(index),
                            onDeleteImage: controller.deleteImage,
                            onClear: controller.clear,
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
          );
        });
  }
}

class EditorCanvas extends StatelessWidget {
  final PlatformFile? backgroundImage;
  final List<Point> points;

  final void Function(int, Offset) onPointUpdate;

  final ValueChanged<int> onDeletePoint;

  final EditorMode mode;

  final VoidCallback onDeleteImage;

  final VoidCallback onClear;

  const EditorCanvas({
    required this.points,
    required this.mode,
    required this.onPointUpdate,
    required this.onDeletePoint,
    required this.onDeleteImage,
    required this.onClear,
    this.backgroundImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final indexes = [1];
    for (final p in qv.enumerate(points.skip(1))) {
      final last = indexes.last + max<int>(1, rd.nextInt(4));
      indexes.add(last);
    }

    return Stack(
      children: [
        if (backgroundImage != null)
          DraggableBox(
            Resizer(
              onDelete: onDeleteImage,
              child: buildImageFromFile(backgroundImage!),
            ),
          ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !mode.isPen,
            child: CustomPaint(
              painter: PointPainter(points.map((e) => e.position)),
            ),
          ),
        ),
        for (final p in qv.enumerate(points))
          Positioned(
            top: p.value.position.dy,
            left: p.value.position.dx,
            child: GestureDetector(
              onPanUpdate: (d) =>
                  onPointUpdate(p.index, p.value.position + d.delta),
              onDoubleTap: () => onDeletePoint(p.index),
              child: EditablePointView(point: p.value, selected: false),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            tooltip: 'Clear all points',
            padding: const EdgeInsets.all(8),
            splashRadius: 16,
            onPressed: onClear,
            icon: const Icon(Icons.clear, color: Colors.red),
          ),
        ),
      ],
    );
  }
}

class EditablePointView extends StatelessWidget {
  final Point point;
  final bool selected;

  const EditablePointView({
    required this.point,
    required this.selected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? Colors.blue : Colors.green,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '${point.id}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class PointPainter extends CustomPainter {
  final Iterable<Offset> points;

  PointPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPoints(
      PointMode.polygon,
      points.toList(),
      Paint()..style = PaintingStyle.stroke,
    );

    drawNodes(canvas);
  }

  void drawNodes(Canvas canvas) {
    for (final p in points) {
      canvas.drawCircle(p, nodeRadius, Paint());
    }
  }

  @override
  bool shouldRepaint(covariant PointPainter oldDelegate) {
    return points.length != oldDelegate.points.length;
  }
}

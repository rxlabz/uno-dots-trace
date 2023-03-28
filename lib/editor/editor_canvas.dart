import 'dart:math' hide Point;
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart' as qv;

import '../model.dart';
import '../rszr.dart';
import 'draggable_image_box.dart';
import 'editor_controller.dart';

const landscapeWidth = 1024.0;
const portraitWidth = 768.0;

class FigureEditorCanvas extends StatelessWidget {
  final EditorController controller;

  const FigureEditorCanvas({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.orientation,
      builder: (context, value, _) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AspectRatio(
              aspectRatio: value.isLandscape ? 1.414 : 0.707,
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
                        onTapDown: controller.mode.isPen
                            ? (e) => controller.addPoint(e.localPosition)
                            : null,
                        child: ValueListenableBuilder(
                          valueListenable: controller.selectedPointIndex,
                          builder: (context, selectedPointIndex, _) =>
                              ValueListenableBuilder(
                            valueListenable: controller.imageController,
                            builder: (context, img, _) => EditorCanvas(
                              points: points,
                              mode: controller.mode,
                              backgroundImage: img,
                              onPointUpdate: controller.updatePoint,
                              selectedPointIndex: selectedPointIndex,
                              onDeletePoint: (index) =>
                                  controller.deletePoint(index),
                              onSelectPoint: (index) =>
                                  controller.selectPoint(index),
                              onDeleteImage: controller.imageController.clear,
                              onClear: controller.clear,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

final rd = Random();

class EditorCanvas extends StatelessWidget {
  final PlatformFile? backgroundImage;
  final List<Point> points;

  final void Function(int, Offset) onPointUpdate;

  final ValueChanged<int> onDeletePoint;

  final ValueChanged<int> onSelectPoint;

  final EditorMode mode;

  final int? selectedPointIndex;

  final VoidCallback onDeleteImage;

  final VoidCallback onClear;

  const EditorCanvas({
    required this.points,
    required this.mode,
    required this.selectedPointIndex,
    required this.onPointUpdate,
    required this.onSelectPoint,
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
              child: Image.memory(
                backgroundImage!.bytes!,
                fit: BoxFit.contain,
              ),
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
              child: EditablePointView(
                point: p.value,
                selected: p.index == selectedPointIndex,
              ),
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
  /*final int index;
  final Offset position;*/
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

const nodeRadius = 4.0;

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

/*@override
  bool? hitTest(Offset position) {
    return false;// TODO: implement hitTest
    //return super.hitTest(position);
  }*/
}

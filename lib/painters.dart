import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'model.dart';

/// dessine les lignes validées
class FigurePainter extends CustomPainter {
  final List<Point> points;

  FigurePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPoints(
      PointMode.polygon,
      points.map((e) => e.position).toList(),
      Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant FigurePainter oldDelegate) =>
      points.length != oldDelegate.points.length;
}

/// dessine la ligne en cours
class GesturePainter extends CustomPainter {
  final Tuple2<Offset, Offset> line;

  GesturePainter(this.line);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(line.first, line.last, Paint());
  }

  @override
  bool shouldRepaint(covariant GesturePainter oldDelegate) =>
      oldDelegate.line != line;
}

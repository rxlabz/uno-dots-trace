import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:quiver/iterables.dart';

import '../model.dart';
import '../services/pdf_service_web.dart'
    if (dart.library.io) '../services/pdf_service.dart';
import 'image_controller.dart';

//const toPdfScale = 0.5;

final rd = Random();

enum EditorMode {
  pen,
  hand,
  point;

  bool get isPen => this == pen;
}

extension OrientationHelper on Orientation {
  bool get isLandscape => this == Orientation.landscape;
}

class EditorController extends ChangeNotifier {
  final pdfService = PDFService();

  bool _randomIncrement = false;

  late Size size;
  bool get randomIncrement => _randomIncrement;

  set randomIncrement(bool value) {
    _randomIncrement = value;
    _updatePointIndexes();
  }

  int get step => _randomIncrement ? rd.nextInt(3) + 1 : 1;

  ValueNotifier<List<bool>> toolSelection = ValueNotifier([true, false, false]);

  ValueNotifier<List<Point>> points = ValueNotifier([]);

  ValueNotifier<Orientation> orientation = ValueNotifier(Orientation.landscape);

  List<bool> get orientationSelection => [isLandscape, !isLandscape];

  bool get isLandscape => orientation.value.isLandscape;

  EditorMode get mode =>
      EditorMode.values[toolSelection.value.indexWhere((element) => element)];

  ValueNotifier<int?> selectedPointIndex = ValueNotifier(null);

  final ImageNotifier imageController;

  EditorController() : imageController = ImageNotifier();

  @override
  void dispose() {
    imageController.removeListener(notifyListeners);
    super.dispose();
  }

  void addPoint(Offset p) {
    final nextId = points.value.isEmpty ? 1 : points.value.last.id + step;
    points.value = [...points.value..add(Point(p, nextId))];
  }

  void updatePoint(int index, Offset newPosition) {
    final updatedPoint = points.value[index].copyWith(newPosition: newPosition);
    points.value = [
      ...points.value..replaceRange(index, index + 1, [updatedPoint])
    ];
  }

  void _updatePointIndexes() {
    if (points.value.isEmpty) return;

    int lastIndex = 1;
    final randomizedPoints = <Point>[points.value.first];
    for (final p in points.value.skip(1)) {
      final newIndex = lastIndex + step;
      randomizedPoints.add(p.copyWith(newId: newIndex));
      lastIndex = newIndex;
    }

    points.value = randomizedPoints;

    notifyListeners();
  }

  void deletePoint(int index) {
    points.value = [...points.value..removeAt(index)];
  }

  Future<void> toPDF() async {
    // point le plus à droite
    // point le plus bas
    final scale = 550 / (isLandscape ? size.height : size.width);

    final p = pw.Page(
      orientation: isLandscape
          ? pw.PageOrientation.landscape
          : pw.PageOrientation.portrait,
      margin: const pw.EdgeInsets.all(10),
      build: (c) {
        return pw.Center(
          child: pw.Stack(
            children: enumerate(points.value).map(
              (e) {
                final p = e.value.position *
                    scale /*computeNodePosition(e.value.position)*/;
                return pw.Positioned(
                  left: p.dx,
                  top: p.dy,
                  child: pw.Row(
                    children: [
                      pw.Container(
                        decoration: const pw.BoxDecoration(
                          color: pdf.PdfColorGrey(.2),
                          shape: pw.BoxShape.circle,
                        ),
                        width: 4,
                        height: 4,
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 5),
                        child: pw.Text(
                          ' ${e.value.id}',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: pdf.PdfColorGrey(.1),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
          ),
        );
      },
    );

    final doc = pw.Document(
      creator: "uno dots trace",
      title: 'Uno dots trace',
    );
    doc.addPage(p);

    pdfService.save(doc);
  }

  void selectTool(int index) {
    toolSelection.value =
        List.generate(EditorMode.values.length, (i) => index == i);
  }

  void toggleOrientation() => orientation.value =
      isLandscape ? Orientation.portrait : Orientation.landscape;

  void selectPoint(int index) => selectedPointIndex.value = index;

  void clear() => points.value = [];

  void undo() {
    if (points.value.isEmpty) return;

    deletePoint(points.value.length - 1);
  }
}

const landscapeSize = Size(1024, 1024 * 0.707);

const portraitSize = Size(768, 768);

Offset computeNodePosition(
  Offset p, {
  orientation = Orientation.landscape,
  double delta = 30,
}) {
  final center = (orientation == Icons.landscape ? landscapeSize : portraitSize)
      .center(Offset.zero);
  final x = p.dx > center.dx ? p.dx : p.dx - delta;
  final y = p.dy > center.dy ? p.dy : p.dy - delta;

  return Offset(x, y);
}

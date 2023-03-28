import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:quiver/iterables.dart';

import '../model.dart';
import '../services/pdf_service_web.dart'
    if (dart.library.io) '../services/pdf_service.dart';

final rd = Random();

const scaleRefWidth = 550.0;

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

  ValueNotifier<List<Point>> points = ValueNotifier([]);

  List<bool> get toolSelection => List.generate(
      EditorMode.values.length, (index) => EditorMode.values[index] == _mode);

  EditorMode _mode = EditorMode.pen;

  EditorMode get mode => _mode;

  Orientation orientation = Orientation.landscape;
  //ValueNotifier<Orientation> orientation = ValueNotifier(Orientation.landscape);

  PlatformFile? _image;
  PlatformFile? get image => _image;

  List<bool> get orientationSelection => [isLandscape, !isLandscape];

  bool get isLandscape => orientation.isLandscape;

  ValueNotifier<int?> selectedPointIndex = ValueNotifier(null);

  EditorController();

  bool get randomIncrement => _randomIncrement;

  set randomIncrement(bool value) {
    _randomIncrement = value;
    _updatePointIndexes();
  }

  int get step => _randomIncrement ? rd.nextInt(3) + 1 : 1;

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
    final scale = scaleRefWidth / (isLandscape ? size.height : size.width);

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
                final p = e.value.position * scale;
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
    _mode = EditorMode.values[index];
    notifyListeners();
  }

  void toggleOrientation() {
    orientation = isLandscape ? Orientation.portrait : Orientation.landscape;
    notifyListeners();
  }

  void selectPoint(int index) => selectedPointIndex.value = index;

  void clear() => points.value = [];

  void undo() {
    if (points.value.isEmpty) return;

    deletePoint(points.value.length - 1);
  }

  Future<void> selectImage() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select an image',
      type: FileType.image,
      allowMultiple: false,
    );
    final files = result?.files;

    if (files != null && files.isNotEmpty && (files.first.bytes != null || files.first.path != null)) {
      _image = files.first;
      selectTool(1);

      //notifyListeners();
    }

  }

  void deleteImage() {
    _image = null;
    notifyListeners();
  }
}

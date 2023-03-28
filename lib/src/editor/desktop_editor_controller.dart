import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:quiver/iterables.dart';
import 'package:uuid/uuid.dart';

import '../model.dart';
import '../services/figure_service.dart';
import 'editor_controller.dart';

const _uuid = Uuid();

class DesktopEditorController extends EditorController {
  final FigureService service;

  Figure? selection;

  int? get selectionIndex =>
      selection == null ? 0 : figures.value.indexOf(selection!);

  TextEditingController titleController;

  ValueNotifier<List<Figure>> figures = ValueNotifier([]);

  DesktopEditorController(this.service)
      : titleController = TextEditingController(text: 'New document');

  Future<void> init() async {
    figures.value = [...(await service.load()).map((e) => Figure.fromJson(e))]
        .reversed
        .toList();

    if (figures.value.isNotEmpty) {
      selection = figures.value.first;
    }

    newFigure();
  }

  void newFigure() {
    final newFigure = Figure(
      id: _uuid.v4(),
      title: 'New document',
      points: enumerate(points.value).map((e) => e.value).toList(),
    );
    figures.value = [newFigure, ...figures.value];

    selection = newFigure;
    notifyListeners();
  }

  void open(Figure figure) {
    selection = figure;
    points.value = figure.points;
    titleController.text = figure.title;
    notifyListeners();
  }

  /// génére le json et enregistre un fichier local
  void save() {
    final selectionIndex =
        figures.value.indexWhere((element) => element.id == selection!.id);

    final updatedFigure = Figure(
      id: selection!.id,
      title: titleController.text,
      points: enumerate(points.value).map((e) => e.value).toList(),
    );
    selection = updatedFigure;

    final update = [...figures.value]
      ..replaceRange(selectionIndex, selectionIndex + 1, [updatedFigure]);
    figures.value = update;
    service.save(
      figures.value
          .where((element) => element.points.isNotEmpty)
          .map((e) => jsonEncode(e.toJson()))
          .toList(),
    );
    notifyListeners();
  }

  void delete() async {
    final newFigures = [...(figures.value..removeAt(selectionIndex!))];

    figures.value = newFigures;
    open(newFigures.first);
    await service.save(
      newFigures
          .where((element) => element.points.isNotEmpty)
          .map((e) => jsonEncode(e.toJson()))
          .toList(),
    );

    notifyListeners();
  }
}

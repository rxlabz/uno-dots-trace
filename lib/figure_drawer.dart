import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'model.dart';
import 'painters.dart';
import 'widgets.dart';

class FigureDrawingScreen extends StatelessWidget {
  const FigureDrawingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Body(),
    );
  }
}

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.shade50,
      constraints: const BoxConstraints.expand(),
      child: Center(
        child: Material(
          elevation: 3,
          child: SizedBox(
            width: 1024,
            height: 768,
            child: FigureCanvas(
              figure: Figure(id: '1-abc', title: 'ligne', points: [
                Point(const Offset(100, 100), 1),
                Point(const Offset(200, 200), 2),
                Point(const Offset(300, 300), 3),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class CanvasController extends ChangeNotifier {
  final Figure figure;

  final ValueNotifier<int> counter = ValueNotifier(0);

  Point? hovered;

  List<Point> completePoints;

  //int get index => counter.value;

  CanvasController(this.figure) : completePoints = [figure.points.first];

  void addPoint(Point p) {
    completePoints.add(p);

    if (completePoints.length == figure.points.length) {
      print('COMPLETE !!!');
    }

    //notifyListeners();
  }

  void updateHover(Point? p) {
    hovered = p;
    notifyListeners();
  }

  void release() {
    if (hovered?.id == figure.points[counter.value].id + 1) {
      addPoint(hovered!);
      counter.value = counter.value + 1;
      notifyListeners();
    }
  }
}

class GestureLayerController extends ValueNotifier<Tuple2<Offset, Offset>?> {
  late Offset delta;

  GestureLayerController() : super(null);

  void update(Tuple2<Offset, Offset>? newValue) => value = newValue == null
      ? null
      : Tuple2(newValue.first - delta, newValue.last - delta);
}

/// affichage des points et des layers de gestures et de dessin
class FigureCanvas extends StatelessWidget {
  final Figure figure;

  final CanvasController controller;

  final GestureLayerController gestureController;

  FigureCanvas({required this.figure, super.key})
      : controller = CanvasController(figure),
        gestureController = GestureLayerController();

  @override
  Widget build(BuildContext context) {
    final render = context.findRenderObject() as RenderBox?;
    if (render == null) {
      return const CircularProgressIndicator();
    }

    final position = render.localToGlobal(Offset.zero);

    gestureController.delta = position;

    return ValueListenableBuilder(
        valueListenable: controller.counter,
        builder: (context, value, child) {
          final p = figure.points[value];
          return Stack(
            children: [
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) => controller.hovered != null
                    ? Text('${controller.hovered!.id}')
                    : const Text('/'),
              ),
              ValueListenableBuilder(
                valueListenable: gestureController,
                builder: (context, value, child) {
                  //print('ON NEW GESTURE... $value');
                  if (value == null) return const SizedBox.shrink();

                  return Positioned.fill(
                    child: CustomPaint(painter: GesturePainter(value)),
                  );
                },
              ),
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) => Positioned.fill(
                  child: CustomPaint(
                      painter: FigurePainter(controller.completePoints)),
                ),
              ),
              for (final p in figure.points.where((element) => element != p))
                AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      return PointView(
                        key: Key('point-${p.id}'),
                        point: p,
                        isHovered: controller.hovered == p,
                        //isNext: p.number == 2,
                        onHovered: controller.updateHover,
                      );
                    }),
              ActivePointView(
                key: Key('point-${p.id}'),
                point: p,
                //isNext: p.number == 2,
                onGesture: gestureController.update,
                onRelease: () {
                  controller.release();
                  gestureController.update(null);
                },
              ),
            ],
          );
        });
  }
}

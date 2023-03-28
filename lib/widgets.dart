import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'model.dart';

class GestureController extends ValueNotifier<Tuple2<Offset, Offset?>?> {
  Tuple2<Offset, Offset>? get result =>
      value?.item1 != null && value?.item2 != null
          ? Tuple2(value!.item1, value!.item2!)
          : null;

  GestureController() : super(null);

  void init(Offset p) {
    value = Tuple2<Offset, Offset?>(p, null);
  }

  void update(Offset p) => value = value?.withItem2(p);

  void clear() => value = null;
}

class ActivePointView extends StatelessWidget {
  final Point point;
  //final bool isNext;
  final ValueChanged<Tuple2<Offset, Offset>>? onGesture;
  final VoidCallback? onRelease;

  final GestureController controller;

  ActivePointView({
    required this.point,
    //required this.isNext,
    required this.onGesture,
    required this.onRelease,
    super.key,
  }) : controller = GestureController();

  final double size = 48;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: point.position.dy - size / 2,
      left: point.position.dx - size / 2,
      child: GestureDetector(
        onPanStart: (details) => controller.init(details.globalPosition),
        onPanUpdate: (details) {
          controller.update(details.globalPosition);
          if (controller.result != null) onGesture?.call(controller.result!);
        },
        onPanEnd: (details) {
          onRelease?.call();
          controller.clear();
        },
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          width: size,
          height: size,
          child: Center(
            child: Text(
              '${point.id}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}

class PointView extends StatelessWidget {
  final Point point;
  final ValueChanged<Point?>? onHovered;

  final bool isHovered;

  final GestureController controller;

  PointView({
    required this.point,
    required this.isHovered,
    required this.onHovered,
    super.key,
  }) : controller = GestureController();

  @override
  Widget build(BuildContext context) {
    final double size = isHovered ? 58 : 48;

    return Positioned(
      top: point.position.dy - size / 2,
      left: point.position.dx - size / 2,
      child: MouseRegion(
        onEnter: (e) => onHovered?.call(point),
        onExit: (e) => onHovered?.call(null),
        hitTestBehavior: HitTestBehavior.translucent,
        opaque: false,
        /*onHover: (e)=>print(e),*/
        child: Container(
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
          width: size,
          height: size,
          child: Center(
            child: Text(
              '${point.id}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}

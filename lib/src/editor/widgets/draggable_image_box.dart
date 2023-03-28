import 'package:flutter/material.dart';

class DraggableItemController extends ValueNotifier<Offset> {
  DraggableItemController() : super(Offset.zero);

  void update(Offset newPosition) => value = value + newPosition;
}

class DraggableBox extends StatefulWidget {
  final Widget image;

  const DraggableBox(this.image, {super.key});

  @override
  State<DraggableBox> createState() => _DraggableBoxState();
}

class _DraggableBoxState extends State<DraggableBox> {
  Offset position = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        child: widget.image,
        onPanUpdate: (d) => setState(() => position = position + d.delta),
      ),
    );
  }
}

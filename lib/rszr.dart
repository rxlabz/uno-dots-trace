import 'package:flutter/material.dart';

class Resizer extends StatefulWidget {
  final Widget child;

  final VoidCallback onDelete;

  const Resizer({required this.child, required this.onDelete, super.key});

  @override
  ResizerState createState() => ResizerState();
}

class ResizerState extends State<Resizer> {
  double width = 400;
  //double height = 200;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.blueGrey,
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: width,
              child: widget.child,
            ),
          ),
          IconButton(
            onPressed: widget.onDelete,
            icon: const Icon(Icons.delete_forever, color: Colors.red),
          ),
          Positioned(
            left: width,
            bottom: 0,
            child: GestureDetector(
              onPanUpdate: (d) {
                width += d.delta.dx;
                //height += d.delta.dy;

                setState(() {});
              },
              child: const Handler(),
            ),
          ),
        ],
      ),
    );
  }
}

class Handler extends StatelessWidget {
  final double size;
  final double radius;

  const Handler({super.key, this.size = 16, this.radius = 4});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        color: Colors.grey,
        borderRadius: BorderRadius.circular(radius),
      ),
      width: size,
      height: size,
    );
  }
}

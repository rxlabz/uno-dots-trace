import 'dart:convert';
import 'dart:ui';

import 'package:tuple/tuple.dart';

class Figure {
  final String id;
  final String title;
  final List<Point> points;

  Figure({required this.id, required this.title, required this.points});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'points': points.map((e) => e.toJson()).toList(),
    };
  }

  factory Figure.fromJson(String json) {
    final data = jsonDecode(json);

    final rawPoints = List.from(data['points']);
    return Figure(
        id: data['id'],
        title: data['title'],
        points: rawPoints.map((e) => Point.fromJson(e)).toList());
  }
}

class Point {
  final Offset position;
  final int id;

  Point(this.position, this.id);

  Point copyWith({Offset? newPosition, int? newId}) =>
      Point(newPosition ?? position, newId ?? id);

  Map<String, dynamic> toJson() => {
        'id': id,
        'x': position.dx.toInt(),
        'y': position.dy.toInt(),
      };

  factory Point.fromJson(Map<String, dynamic> data) {
    return Point(
      Offset((data['x'] as int).toDouble(), (data['y'] as int).toDouble()),
      data['id'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          id == other.id;

  @override
  int get hashCode => position.hashCode ^ id.hashCode;
}

extension TupleUtils on Tuple2<Offset, Offset> {
  Offset get first => item1;
  Offset get last => item2;
}

import 'dart:math';

import 'vertex.dart';

extension PointSize on Point<num> {
  num get width => x;
  num get height => y;

  Vertex2 get toVertex2 => Vertex2(x: x, y: y);
}

extension RectangleSize on Rectangle<num> {
  Point<num> get size => Point<num>(width, height);

  Rectangle<num> divide(Point<num> other) {
    return Rectangle(
        left / other.x, top / other.y, width / other.x, height / other.y);
  }
}

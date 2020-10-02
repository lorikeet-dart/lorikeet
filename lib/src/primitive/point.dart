import 'dart:math';

import 'vertex.dart';

extension PointSize on Point<num> {
  num get width => x;
  num get height => y;

  Point<num> multiplyPoint(Point<num> other) => Point(x * other.x, y * other.y);

  Vertex2 get toVertex2 => Vertex2(x: x, y: y);
}

extension RectangleSize on Rectangle<num> {
  Point<num> get size => Point<num>(width, height);

  Rectangle<num> expand(num value) => Rectangle(
      left - value, top - value, width + 2 * value, height + 2 * value);

  Rectangle<num> divide(Point<num> other) {
    return Rectangle(
        left / other.x, top / other.y, width / other.x, height / other.y);
  }
}

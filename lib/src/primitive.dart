import 'dart:typed_data';

class Position {
  num x;

  num y;

  Position({this.x = 0, this.y = 0});
}

class Color {
  double r;

  double g;

  double b;

  double a;

  Color({this.r = 0, this.g = 0, this.b = 0, this.a = 0});

  int get rInt => (r * 255).toInt();

  int get gInt => (r * 255).toInt();

  int get bInt => (r * 255).toInt();

  int get aInt => (r * 255).toInt();

  Float32List get asList => Float32List.fromList([r, g, b, a]);

  Uint8List get asIntList => Uint8List.fromList([rInt, gInt, bInt, aInt]);
}

class Background {
  Color color;

  dynamic image;

  Background({this.color, this.image});
}

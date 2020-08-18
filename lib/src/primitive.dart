import 'dart:typed_data';

class Vertex2 {
  num x;

  num y;

  Vertex2({this.x = 0, this.y = 0});
}

class Vertex2s {
  Float32List _data;

  Vertex2s.length(int length) {
    _data = Float32List(length * 2);
  }

  int get count => _data.length ~/ 2;

  void operator []=(int index, Vertex2 vertex) {
    _data[index * 2] = vertex.x;
    _data[index * 2 + 1] = vertex.y;
  }

  Vertex2 operator [](int index) {
    return Vertex2(x: _data[index * 2], y: _data[index * 2 + 1]);
  }

  void set(Iterable<Vertex2> vertices, [int start = 0]) {
    for (final v in vertices) {
      this[start++] = v;
    }
  }

  Float32List get asList => _data;

  List<Vertex2> get asVertexList =>
      List<Vertex2>.generate(count, (index) => this[index]);
}

class Color {
  double r;

  double g;

  double b;

  double a;

  Color({this.r = 0, this.g = 0, this.b = 0, this.a = 0});

  void copyFrom(Color other) {
    r = other.r;
    g = other.g;
    b = other.b;
    a = other.a;
  }

  int get rInt => (r * 255).toInt();

  int get gInt => (r * 255).toInt();

  int get bInt => (r * 255).toInt();

  int get aInt => (r * 255).toInt();

  Float32List get asList => Float32List.fromList([r, g, b, a]);

  Uint8List get asIntList => Uint8List.fromList([rInt, gInt, bInt, aInt]);
}

class Colors {
  Float32List _data;

  Colors.length(int length) {
    _data = Float32List(length * 4);
  }

  int get count => _data.length ~/ 2;

  void operator []=(int index, Color color) {
    _data[index * 2] = color.r;
    _data[index * 2 + 1] = color.g;
    _data[index * 2 + 2] = color.b;
    _data[index * 2 + 3] = color.a;
  }

  Color operator [](int index) {
    return Color(
        r: _data[index * 2],
        g: _data[index * 2 + 1],
        b: _data[index * 2],
        a: _data[index * 2 + 1]);
  }

  void set(Iterable<Color> colors, [int start = 0]) {
    for (final color in colors) {
      this[start++] = color;
    }
  }

  List<Color> get asList => List<Color>.generate(count, (index) => this[index]);
}

class Background {
  final color = Color();

  dynamic image;

  Background({Color color, this.image}) {
    if (color != null) {
      this.color.copyFrom(color);
    }
  }
}

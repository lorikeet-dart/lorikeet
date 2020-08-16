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
  Color color;

  dynamic image;

  Background({this.color, this.image});
}

class Matrix4 {
  final _data = Float32List(16);

  Matrix4(
      {double cell00 = 0.0,
      double cell01 = 0.0,
      double cell02 = 0.0,
      double cell03 = 0.0,
      double cell10 = 0.0,
      double cell11 = 0.0,
      double cell12 = 0.0,
      double cell13 = 0.0,
      double cell20 = 0.0,
      double cell21 = 0.0,
      double cell22 = 0.0,
      double cell23 = 0.0,
      double cell30 = 0.0,
      double cell31 = 0.0,
      double cell32 = 0.0,
      double cell33 = 0.0}) {
    set(0, 0, cell00);
    set(0, 1, cell01);
    set(0, 2, cell02);
    set(0, 3, cell03);
    set(1, 0, cell10);
    set(1, 1, cell11);
    set(1, 2, cell12);
    set(1, 3, cell13);
    set(2, 0, cell20);
    set(2, 1, cell21);
    set(2, 2, cell22);
    set(2, 3, cell23);
    set(3, 0, cell30);
    set(3, 1, cell31);
    set(3, 2, cell32);
    set(3, 3, cell33);
  }

  Matrix4.fromList(Iterable<double> data) {
    int index = 0;
    for (final v in data) {
      _data[index] = v;
    }
  }

  void copyFrom(Matrix4 other) {
    for (int i = 0; i < 16; i++) {
      _data[i] = other[i];
    }
  }

  double operator [](int index) {
    return _data[index];
  }

  void operator []=(int index, double value) {
    _data[index] = value;
  }

  double get(int row, int col) => _data[row * 4 + col];
  void set(int row, int col, double value) => _data[(row * 4) + col] = value;

  static Matrix4 ortho(double left, double right, double bottom, double top,
      double near, double far) {
    final double rml = right - left;
    final double rpl = right + left;
    final double tmb = top - bottom;
    final double tpb = top + bottom;
    final double fmn = far - near;
    final double fpn = far + near;

    return Matrix4(
      cell00: 2 / rml,
      cell11: 2 / tmb,
      cell22: -2 / fmn,
      cell33: 1.0,
      cell03: -rpl / rml,
      cell13: -tpb / tmb,
      cell23: -fpn / fmn,
    );
  }

  Float32List get items => _data;
}

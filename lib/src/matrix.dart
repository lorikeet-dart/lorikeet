import 'dart:typed_data';
import 'dart:math' as math;

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

  Matrix4.I() {
    set(0, 0, 1);
    set(1, 1, 1);
    set(2, 2, 1);
    set(3, 3, 1);
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

  Vertex4 row(int r) {
    int i = r * 4;
    return Vertex4(x: _data[i++], y: _data[i++], z: _data[i++], w: _data[i++]);
  }

  Vertex4 col(int c) {
    return Vertex4(
        x: _data[0 + c], y: _data[4 + c], z: _data[8 + c], w: _data[12 + c]);
  }

  double get(int row, int col) => _data[row * 4 + col];
  void set(int row, int col, double value) => _data[(row * 4) + col] = value;

  double get cell00 => _data[0];
  set cell00(double value) => _data[0] = value;

  double get cell01 => _data[1];
  set cell01(double value) => _data[1] = value;

  double get cell02 => _data[2];
  set cell02(double value) => _data[2] = value;

  double get cell03 => _data[3];
  set cell03(double value) => _data[3] = value;

  double get cell10 => _data[4];
  set cell10(double value) => _data[4] = value;

  double get cell11 => _data[5];
  set cell11(double value) => _data[5] = value;

  double get cell12 => _data[6];
  set cell12(double value) => _data[6] = value;

  double get cell13 => _data[7];
  set cell13(double value) => _data[7] = value;

  double get cell20 => _data[8];
  set cell20(double value) => _data[8] = value;

  double get cell21 => _data[9];
  set cell21(double value) => _data[9] = value;

  double get cell22 => _data[10];
  set cell22(double value) => _data[10] = value;

  double get cell23 => _data[11];
  set cell23(double value) => _data[11] = value;

  double get cell30 => _data[12];
  set cell30(double value) => _data[12] = value;

  double get cell31 => _data[13];
  set cell31(double value) => _data[13] = value;

  double get cell32 => _data[14];
  set cell32(double value) => _data[14] = value;

  double get cell33 => _data[15];
  set cell33(double value) => _data[15] = value;

  Vertex4 multipleVertex4(Vertex4 v) {
    final ret = Vertex4();
    for (int i = 0; i < 4; i++) {
      ret[i] = row(i).dot(v);
    }

    return ret;
  }

  Matrix4 multiply(Matrix4 other) {
    final ret = Matrix4();

    for (int i = 0; i < 4; i++) {
      final r = row(i);
      for (int j = 0; j < 4; j++) {
        ret.set(i, j, r.dot(other.col(j)));
      }
    }

    return ret;
  }

  void assign(Matrix4 other) {
    _data.setRange(0, 16, other.items);
  }

  void translate(
      {double x = 0.0, double y = 0.0, double z = 0.0, double w = 1.0}) {
    _data[3] = (cell00 * x) + (cell01 * y) + (cell02 * z) + (cell03 * w);
    _data[7] = (cell10 * x) + (cell11 * y) + (cell12 * z) + (cell13 * w);
    _data[11] = (cell20 * x) + (cell21 * y) + (cell22 * z) + (cell23 * w);
    _data[15] = (cell30 * x) + (cell31 * y) + (cell32 * z) + (cell33 * w);
  }

  void scale({num x = 1, num y = 1, num z = 1}) {
    cell00 *= x;
    cell01 *= y;
    cell02 *= z;

    cell10 *= x;
    cell11 *= y;
    cell12 *= z;

    cell20 *= x;
    cell21 *= y;
    cell22 *= z;

    cell30 *= x;
    cell31 *= y;
    cell32 *= z;
  }

  void rotateZ(double radians) {
    final cosTheta = math.cos(radians);
    final sinTheta = math.sin(radians);

    double cell00Copy = cell00;
    double cell01Copy = cell01;
    double cell10Copy = cell10;
    double cell11Copy = cell11;
    double cell20Copy = cell20;
    double cell21Copy = cell21;
    double cell30Copy = cell30;
    double cell31Copy = cell31;

    cell00 = cell00Copy * cosTheta + cell01Copy * sinTheta;
    cell01 = cell00Copy * -sinTheta + cell01Copy * cosTheta;

    cell10 = cell10Copy * cosTheta + cell11Copy * sinTheta;
    cell11 = cell10Copy * -sinTheta + cell11Copy * cosTheta;

    cell20 = cell20Copy * cosTheta + cell21Copy * sinTheta;
    cell21 = cell20Copy * -sinTheta + cell21Copy * cosTheta;

    cell30 = cell30Copy * cosTheta + cell31Copy * sinTheta;
    cell31 = cell30Copy * -sinTheta + cell31Copy * cosTheta;
  }

  @override
  String toString() {
    final sb = StringBuffer('(');

    for (int i = 0; i < 4; i++) {
      final r = row(i);
      sb.writeln('${r.x}, ${r.y}, ${r.z}, ${r.w}');
    }
    sb.writeln(')');

    return sb.toString();
  }

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

double degToRad(num deg) => (deg / 180) * math.pi;

class Vertex2 {
  num x;

  num y;

  Vertex2({this.x = 0, this.y = 0});

  Vertex4 toVertex4({num z = 0, num w = 1}) => Vertex4(x: x, y: y, z: z, w: w);

  @override
  String toString() => 'Vertex2($x, $y)';
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

class Vertex4 {
  num x;

  num y;

  num z;

  num w;

  Vertex4({this.x = 0, this.y = 0, this.z = 0, this.w = 0});

  num dot(Vertex4 other) =>
      x * other.x + y * other.y + z * other.z + w * other.w;

  void operator []=(int index, num value) {
    switch (index) {
      case 0:
        x = value;
        break;
      case 1:
        y = value;
        break;
      case 2:
        z = value;
        break;
      case 3:
        w = value;
        break;
      default:
        throw Exception('invalid index: $index');
    }
  }

  @override
  String toString() => 'Vertex4($x, $y, $z, $w)';
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

import 'dart:typed_data';

import 'package:lorikeet/src/primitive.dart';

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

  double get(int row, int col) => _data[row * 4 + col];
  void set(int row, int col, double value) => _data[(row * 4) + col] = value;

  Vertex4 multipleVertex4(Vertex4 v) {
    final ret = Vertex4();
    for (int i = 0; i < 4; i++) {
      ret[i] = row(i).dot(v);
    }

    return ret;
  }

  // TODO translation

  // TODO rotation

  // TODO scale

  @override
  String toString() {
    final sb = StringBuffer('(');

    for(int i = 0; i < 4; i++) {
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

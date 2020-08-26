import 'dart:typed_data';
import 'dart:math' as math;

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

  void translate(
      {double x = 0.0, double y = 0.0, double z = 0.0, double w = 1.0}) {
    _data[3] = (cell00 * x) + (cell01 * y) + (cell02 * z) + (cell03 * w);
    _data[7] = (cell10 * x) + (cell11 * y) + (cell12 * z) + (cell13 * w);
    _data[11] = (cell20 * x) + (cell21 * y) + (cell22 * z) + (cell23 * w);
    _data[15] = (cell30 * x) + (cell31 * y) + (cell32 * z) + (cell33 * w);
  }

  void scale({num x = 1, num y = 1, num z = 1}) {
    cell00 *= x;
    cell11 *= y;
    cell22 *= z;
  }

  /*
  void rotateX(double radians) {
    final cosTheta = math.cos(radians);
    final sinTheta = math.sin(radians);

    double cell01Copy = cell01;
    double cell02Copy = cell02;
    double cell11Copy = cell11;
    double cell12Copy = cell12;
    double cell21Copy = cell21;
    double cell22Copy = cell22;
    double cell31Copy = cell31;
    double cell32Copy = cell32;

    cell01 = cell01Copy * cosTheta + cell02Copy * sinTheta;
    cell02 = cell01Copy * -sinTheta + cell02Copy * cosTheta;

    cell11 = cell11Copy * cosTheta + cell12Copy * sinTheta;
    cell12 = cell11Copy * -sinTheta + cell12Copy * cosTheta;

    cell21 = cell21Copy * cosTheta + cell22Copy * sinTheta;
    cell22 = cell21Copy * -sinTheta + cell22Copy * cosTheta;

    cell31 = cell31Copy * cosTheta + cell32Copy * sinTheta;
    cell32 = cell31Copy * -sinTheta + cell32Copy * cosTheta;
  }*/

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

import 'dart:typed_data';
import 'dart:math' as math;

class Vertex2 {
  num x;

  num y;

  Vertex2({this.x = 0, this.y = 0});

  factory Vertex2.fromPoint(math.Point<num> p) => Vertex2(x: p.x, y: p.y);

  Vertex4 toVertex4({num z = 0, num w = 1}) => Vertex4(x: x, y: y, z: z, w: w);

  void divideByPoint(math.Point<num> other) {
    x /= other.x;
    y /= other.y;
  }

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

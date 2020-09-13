import 'dart:typed_data';

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

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
}

class Background {
  Color color;

  Background({this.color});
}

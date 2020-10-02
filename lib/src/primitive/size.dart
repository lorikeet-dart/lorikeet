abstract class Size {}

class RelativeSize implements Size {
  num width;

  num height;

  RelativeSize({this.width, this.height});
}

class AbsoluteSize implements Size {
  num width;

  num height;

  AbsoluteSize({this.width, this.height});
}

class Position {}

class RelativePosition implements Position {
  num x;

  num y;

  RelativePosition({this.x, this.y});
}

class AbsolutePosition implements Position {
  num x;

  num y;

  AbsolutePosition({this.x, this.y});
}

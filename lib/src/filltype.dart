import 'dart:html';

enum FillType {
  stretch, // Stretches the texture to fill the polygon
  cover,
  contain,
  repeat,
}

extension PointSize on Point<num> {
  num get width => x;
  num get height => y;
}

extension RectangleSize on Rectangle<num> {
  Point<num> get size => Point<num>(width, height);
}

Point<num> computeContain(Point<num> box, Point<num> tex) {
  num width;
  num height;

  if (tex.width <= box.width && tex.height <= box.height) {
    width = box.width / tex.width;
    height = box.height / tex.height;
  } else if (tex.width > box.width && tex.height > box.height) {
    if (box.width >= box.height) {
      width = box.width;
      height = box.width * (tex.height / tex.width);
      if (height > box.height) {
        height = box.height;
        width = box.height * (tex.width / tex.height);
      }
    } else {
      height = box.height;
      width = box.height * (tex.width / tex.height);
      if (width > box.width) {
        width = box.width;
        height = box.width * (tex.height / tex.width);
      }
    }
    width = box.width / width;
    height = box.height / height;
  } else if (tex.width > box.width) {
    width = 1.0;
    height = (box.height * tex.width) / (box.width * tex.height);
  } else if (tex.height > box.height) {
    height = 1.0;
    width = (box.width * tex.height) / (box.height * tex.width);
  }

  return Point<num>(width, height);
}

Point<num> computeCover(Point<num> box, Point<num> tex) {
  num width;
  num height;

  if (tex.width >= box.width && tex.height >= box.height) {
    width = box.width / tex.width;
    height = box.height / tex.height;
  } else if (tex.width < box.width && tex.height < box.height) {
    if (box.width <= box.height) {
      width = box.width;
      height = box.width * (tex.height / tex.width);
      if (height < box.height) {
        height = box.height;
        width = box.height * (tex.width / tex.height);
      }
    } else {
      height = box.height;
      width = box.height * (tex.width / tex.height);
      if (width < box.width) {
        width = box.width;
        height = box.width * (tex.height / tex.width);
      }
    }
    width = box.width / width;
    height = box.height / height;
  } else if (tex.width < box.width) {
    width = 1.0;
    height = (box.height * tex.width) / (box.width * tex.height);
  } else if (tex.height < box.height) {
    height = 1.0;
    width = (box.width * tex.height) / (box.height * tex.width);
  }

  return Point<num>(width, height);
}

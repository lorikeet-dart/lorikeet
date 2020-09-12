import 'dart:math';

import 'dart:web_gl';
import 'matrix.dart';
import 'filltype.dart';

export 'matrix.dart';
export 'filltype.dart';

class ImageProperties {
  final Tex texture;

  final Rectangle<num> textureRegion;

  final Point<num> position;

  final Point<num> anchorPoint;

  final FillType fillType;

  final Point<num> size;

  ImageProperties(this.texture,
      {this.textureRegion,
      this.position = const Point(0, 0),
      this.anchorPoint = const Point(0, 0),
      this.fillType = FillType.normal,
      this.size = const Point<num>(100, 100)}) {
    if (texture == null) {
      throw Exception('image cannot be null');
    }
  }
}

class Background {
  final Color color;

  final ImageProperties image;

  Background({Color color, this.image}) : color = color ?? Color();
}

class Tex {
  final int width;

  final int height;

  final Texture texture;

  Tex({this.width, this.height, this.texture});

  Point<num> get size => Point<num>(width, height);
}

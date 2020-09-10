import 'dart:math';

import 'dart:web_gl';
import 'matrix.dart';
import 'filltype.dart';

export 'matrix.dart';
export 'filltype.dart';

class BackgroundPosition {
  final Point<num> position;

  final Point<num> anchorPoint;

  final FillType fillType;

  BackgroundPosition(
      {this.position = const Point(0, 0),
      this.anchorPoint = const Point(0, 0),
      this.fillType = FillType.normal});
}

class Background {
  final color = Color();

  Tex image;

  Rectangle<num> textureRegion;

  BackgroundPosition position;

  Background(
      {Color color,
      this.image,
      this.textureRegion,
      BackgroundPosition position}) {
    if (color != null) {
      this.color.copyFrom(color);
    }

    this.position = position ?? BackgroundPosition();
  }
}

class Tex {
  final int width;

  final int height;

  final Texture texture;

  Tex({this.width, this.height, this.texture});

  Point<num> get size => Point<num>(width, height);
}

import 'dart:math';

import 'dart:web_gl';
import 'matrix.dart';

export 'matrix.dart';

enum FillType {
  stretch, // Stretches the texture to fill the polygon
  cover,
  contain,
  repeat,
}

class BackgroundPosition {
  Point<num> position = Point(0, 0);

  Point<num> anchorPoint = Point(0, 0);

  FillType fillType = FillType.stretch;
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

    if(position != null) {
      this.position = position;
    }
  }
}

class Tex {
  final int width;

  final int height;

  final Texture texture;

  Tex({this.width, this.height, this.texture});

  Point<num> get size => Point<num>(width, height);
}

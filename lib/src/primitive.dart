import 'dart:math';
import 'dart:typed_data';

import 'dart:web_gl';
import 'matrix.dart';

export 'matrix.dart';

enum FillType {
  none,
  cover,
  contain,
  repeat,
}

class Background {
  final color = Color();

  Tex image;

  Vertex2s texCoords = Vertex2s.length(6);

  Rectangle<num> textureRegion;

  Background({Color color, this.image, this.textureRegion}) {
    if (color != null) {
      this.color.copyFrom(color);
    }

    if (image == null) {
      texCoords[0] = Vertex2(x: 0, y: 0);
      texCoords[1] = Vertex2(x: 1.0, y: 0.0);
      texCoords[2] = Vertex2(x: 1.0, y: 1.0);
      texCoords[3] = Vertex2(x: 0.0, y: 0.0);
      texCoords[4] = Vertex2(x: 0.0, y: 1.0);
      texCoords[5] = Vertex2(x: 1.0, y: 1.0);
    } else {
      final rect = textureRegion ?? Rectangle(0, 0, image.width, image.height);

      texCoords[0] = Vertex2.fromPoint(rect.topLeft)..divideByPoint(image.size);
      texCoords[1] = Vertex2.fromPoint(rect.topRight)
        ..divideByPoint(image.size);
      texCoords[2] = Vertex2.fromPoint(rect.bottomRight)
        ..divideByPoint(image.size);
      texCoords[3] = Vertex2.fromPoint(rect.topLeft)..divideByPoint(image.size);
      texCoords[4] = Vertex2.fromPoint(rect.bottomLeft)
        ..divideByPoint(image.size);
      texCoords[5] = Vertex2.fromPoint(rect.bottomRight)
        ..divideByPoint(image.size);
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

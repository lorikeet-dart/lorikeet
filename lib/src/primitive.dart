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

  Vertex2s texCoords;

  Background({Color color, this.image}) {
    if (color != null) {
      this.color.copyFrom(color);
    }

    texCoords = Vertex2s.length(6);
    texCoords[0] = Vertex2(x: 0, y: 0);
    texCoords[1] = Vertex2(x: 1.0, y: 0.0);
    texCoords[2] = Vertex2(x: 1.0, y: 1.0);
    texCoords[3] = Vertex2(x: 0.0, y: 0.0);
    texCoords[4] = Vertex2(x: 0.0, y: 1.0);
    texCoords[5] = Vertex2(x: 1.0, y: 1.0);
  }
}

class Tex {
  final int width;

  final int height;

  final Texture texture;

  Tex({this.width, this.height, this.texture});
}

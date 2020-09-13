import 'dart:math';

import 'package:lorikeet/src/core/core.dart';
import 'package:lorikeet/src/primitive/primitive.dart';

class Object2D {
  final Rectangle box;

  int order = 0;

  Vertex2s vertices;

  final Vertex2s texCoords;

  final bool repeatTexture;

  final Background background;

  final transformationMatrix = Matrix4.I();

  final Rectangle<num> textureRegion;

  Object2D(
    this.box,
    this.vertices, {
    this.order = 0,
    this.background,
    Matrix4 transformationMatrix,
    this.texCoords,
    this.repeatTexture,
    this.textureRegion,
  }) {
    if (transformationMatrix != null) {
      this.transformationMatrix.copyFrom(transformationMatrix);
    }
  }

  Rectangle boundingBox() {
    num minX;
    num minY;
    num maxX;
    num maxY;

    for (final v in vertices.asVertexList) {
      if (minX == null || v.x < minX) minX = v.x;
      if (maxX == null || v.x > maxX) maxX = v.x;
      if (minY == null || v.y < minY) minY = v.y;
      if (maxY == null || v.y > maxY) maxY = v.y;
    }

    return Rectangle(minX, minY, maxX - minX, maxY - minY);
  }

  static Object2D rectangularMesh(
    Rectangle<num> box, {
    Matrix4 transformationMatrix,
    Transform transform,
    Background background,
  }) {
    final vertices = Vertex2s.length(6);
    vertices[0] = Vertex2(x: box.left, y: box.top);
    vertices[1] = Vertex2(x: box.left + box.width, y: box.top);
    vertices[2] = Vertex2(x: box.left + box.width, y: box.top + box.height);
    vertices[3] = Vertex2(x: box.left, y: box.top);
    vertices[4] = Vertex2(x: box.left, y: box.top + box.height);
    vertices[5] = Vertex2(x: box.left + box.width, y: box.top + box.height);

    transformationMatrix ??= Matrix4.I();
    transform ??= Transform();

    if (transform.hasTransform) {
      num tx = box.left + ((box.width * transform.anchorPointPercent.x) / 100);
      num ty = box.top + ((box.height * transform.anchorPointPercent.y) / 100);
      transformationMatrix.translate(x: tx, y: ty);

      if (transform.translate != null) {
        transformationMatrix.translate(
            x: transform.translate.x, y: transform.translate.y);
      }

      if (transform.rotation != null) {
        transformationMatrix.rotateZ(transform.rotation);
      }

      if (transform.scale != null) {
        transformationMatrix.scale(x: transform.scale.x, y: transform.scale.y);
      }

      transformationMatrix.translate(x: -tx, y: -ty);
    }

    Vertex2s texCoords = Vertex2s.length(6);
    bool repeatTexture = false;

    Rectangle<num> textureRegion = Rectangle<num>(0, 0, 1.0, 1.0);

    final image = background.image;
    if (image != null) {
      final tex = image.textureRegion ??
          Rectangle.fromPoints(Point(0, 0), image.texture.size);

      Point<num> texSize = Point(
          tex.width * image.size.x / 100, tex.height * image.size.y / 100);
      Point<num> result;

      if (image.fillType == FillType.normal) {
        result = computeNormal(box.size, texSize);
      } else if (image.fillType == FillType.stretch) {
        result = Point<num>(1, 1);
      } else if (image.fillType == FillType.contain) {
        result = computeContain(box.size, texSize);
      } else if (image.fillType == FillType.cover) {
        result = computeCover(box.size, texSize);
      } else if (image.fillType == FillType.repeat) {
        result = computeRepeat(box.size, texSize);
        repeatTexture = true;
      }

      texCoords[0] = Vertex2(x: 0, y: 0);
      texCoords[1] = Vertex2(x: result.width, y: 0.0);
      texCoords[2] = Vertex2(x: result.width, y: result.height);
      texCoords[3] = Vertex2(x: 0.0, y: 0.0);
      texCoords[4] = Vertex2(x: 0.0, y: result.height);
      texCoords[5] = Vertex2(x: result.width, y: result.height);

      textureRegion = tex.divide(image.texture.size);
    }

    return Object2D(box, vertices,
        transformationMatrix: transformationMatrix,
        texCoords: texCoords,
        background: background,
        repeatTexture: repeatTexture,
        textureRegion: textureRegion);
  }
}

class Transform {
  final num rotation;
  final Point<num> translate;
  final Point<num> scale;
  final Point<num> anchorPointPercent;

  Transform(
      {this.rotation,
      this.translate,
      this.scale,
      this.anchorPointPercent = const Point<num>(50, 50)});

  bool get hasTransform =>
      rotation != null || translate != null || scale != null;
}

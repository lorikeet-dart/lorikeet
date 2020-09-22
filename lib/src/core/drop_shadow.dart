import 'dart:math';

import 'package:lorikeet/src/core/object2d.dart';
import 'package:lorikeet/src/primitive/primitive.dart';

class DropShadow {
  final Point<int> offset;

  final num blur;

  final int spread;

  final Color color;

  DropShadow(
      {this.offset = const Point(0, 0),
      this.blur = 0,
      this.spread = 0,
      Color color})
      : color = color ?? Color(a: 1);
}

class DropShadowMesh implements Mesh2D {
  final Rectangle box;

  final Vertex2s vertices;

  final Vertex2s texCoords;

  final transformationMatrix = Matrix4.I();

  final Color color;

  final double blur;

  DropShadowMesh(this.box, this.vertices, this.texCoords,
      {Matrix4 transformationMatrix, this.color, this.blur}) {
    if (transformationMatrix != null) {
      this.transformationMatrix.copyFrom(transformationMatrix);
    }
  }

  static DropShadowMesh make(Rectangle<num> box, DropShadow shadow,
      {List<Point<num>> path,
      Matrix4 transformationMatrix,
      Transform transform}) {
    box = box.expand(shadow.spread);
    box = Rectangle(box.left + shadow.offset.x, box.top + shadow.offset.y,
        box.width, box.height);

    Vertex2s vertices;
    Vertex2s texCoords;

    if (path == null) {
      vertices = Vertex2s.length(6);
      vertices[0] = Vertex2(x: box.left, y: box.top);
      vertices[1] = Vertex2(x: box.left + box.width, y: box.top);
      vertices[2] = Vertex2(x: box.left + box.width, y: box.top + box.height);
      vertices[3] = Vertex2(x: box.left, y: box.top);
      vertices[4] = Vertex2(x: box.left + box.width, y: box.top + box.height);
      vertices[5] = Vertex2(x: box.left, y: box.top + box.height);

      texCoords = Vertex2s.length(6);
      texCoords[0] = Vertex2(x: 0, y: 0);
      texCoords[1] = Vertex2(x: 1, y: 0);
      texCoords[2] = Vertex2(x: 1, y: 1);
      texCoords[3] = Vertex2(x: 0, y: 0);
      texCoords[4] = Vertex2(x: 1, y: 1);
      texCoords[5] = Vertex2(x: 0, y: 1);
    } else {
      // TODO validate that polygon is simple and clockwise
      final numTriangles = path.length - 2;
      final points = path
          .map((p) => Vertex2(
              x: box.left + (p.x * box.width / 100),
              y: box.top + (p.y * box.height / 100)))
          .toList();

      final texPoints =
          path.map((p) => Vertex2(x: p.x / 100, y: p.y / 100)).toList();
      vertices = Vertex2s.length(numTriangles * 3);
      texCoords = Vertex2s.length(numTriangles * 3);
      for (int i = 0; i < numTriangles; i++) {
        vertices[(i * 3) + 0] = points[0];
        vertices[(i * 3) + 1] = points[i + 1];
        vertices[(i * 3) + 2] = points[i + 2];

        texCoords[(i * 3) + 0] = texPoints[0];
        texCoords[(i * 3) + 1] = texPoints[i + 1];
        texCoords[(i * 3) + 2] = texPoints[i + 2];
      }
    }

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

    return DropShadowMesh(box, vertices, texCoords,
        transformationMatrix: transformationMatrix,
        color: shadow.color,
        blur: shadow.blur);
  }
}

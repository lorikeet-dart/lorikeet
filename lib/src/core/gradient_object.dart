import 'dart:math';
import 'dart:typed_data';

import 'package:lorikeet/src/core/core.dart';
import 'package:lorikeet/src/core/linear_gradient.dart';
import 'package:lorikeet/src/primitive/primitive.dart';

class LinearGradientMesh implements Mesh2D {
  final Rectangle box;

  final Vertex2s vertices;

  final Vertex2s texCoords;

  final transformationMatrix = Matrix4.I();

  final Color color;

  final num baseSlope;

  final num baseC;

  final num perpSlope;

  final num totalDistance;

  final Colors colors;

  final List<double> stops;

  LinearGradientMesh(this.box, this.vertices, this.texCoords,
      {Matrix4 transformationMatrix,
      Color color,
      this.baseSlope,
      this.baseC,
      this.perpSlope,
      this.totalDistance,
      this.colors,
      this.stops})
      : color = color ?? Color() {
    if (transformationMatrix != null) {
      this.transformationMatrix.copyFrom(transformationMatrix);
    }
  }

  static LinearGradientMesh make(Rectangle<num> box, LinearGradient gradient,
      {List<Point<num>> path,
      Matrix4 transformationMatrix,
      Transform transform,
      Color color}) {
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

    num angle = gradient.angle % 360;
    if (angle.isNegative) {
      angle = 360 - angle;
    }
    final baseSlope = tan(degToRad(angle));

    Point<num> basePoint, endPoint;
    if (angle < 90) {
      basePoint = Point(1, 0);
      endPoint = Point(0, 1);
    } else if (angle < 180) {
      basePoint = Point(1, 1);
      endPoint = Point(0, 0);
    } else if (angle < 270) {
      basePoint = Point(1, 0);
      endPoint = Point(0, 1);
    } else {
      basePoint = Point(0, 0);
      endPoint = Point(1, 1);
    }

    final baseC = basePoint.y - baseSlope * basePoint.x;
    final perpSlope = tan(degToRad(angle + 90));
    final totalDistance = _distance(baseSlope, perpSlope, basePoint, endPoint);

    return LinearGradientMesh(box, vertices, texCoords,
        transformationMatrix: transformationMatrix,
        color: color,
        baseC: baseC,
        baseSlope: baseSlope,
        perpSlope: perpSlope,
        totalDistance: totalDistance,
        colors: Colors.fromList(gradient.stops.map((e) => e.color).toList()),
        stops: gradient.stops.map((e) => e.percentage.toDouble()).toList());
  }
}

Point _perpendicularIntercept(num slope, num perpSlope, num c, num perpC) {
  num x = (c - perpC)/(perpSlope - slope);
  num y = slope * x + c;

  return Point(x, y);
}

num _distance(num slope, num perpSlope, Point line1, Point line2) {
  final c2 = line2.y - slope * line2.x;

  final cPerp = line1.y - perpSlope * line1.x;

  final i1 = _perpendicularIntercept(slope, perpSlope, c2, cPerp);

  return line1.distanceTo(i1);
}
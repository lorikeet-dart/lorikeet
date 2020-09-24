import 'dart:math';

import 'package:lorikeet/lorikeet.dart';

class BMChar {
  final Tex texture;

  final Rectangle<num> textureRegion;

  BMChar({this.texture, this.textureRegion});
}

// TODO implement outline, shadow
class BMCharMesh implements Mesh2D {
  final Rectangle box;

  final Vertex2s vertices;

  final Vertex2s texCoords;

  final transformationMatrix = Matrix4.I();

  final Tex texture;

  final Rectangle<num> textureRegion;

  BMCharMesh(
      {this.box,
      this.vertices,
      this.texCoords,
      Matrix4 transformationMatrix,
      this.texture,
      this.textureRegion});
}

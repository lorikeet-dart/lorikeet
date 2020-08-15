import 'package:lorikeet/src/matrix.dart';



abstract class DisplayObject {}

class Group implements DisplayObject {
  List<DisplayObject> children;
}

class Mesh implements DisplayObject {
  List<Position> vertices;

  List<Background> background;

  Matrix2D localTransformationMatrix;

  Shader shader;

  static Mesh rectangularMesh(Position topLeft, int width, int height) {
    return Mesh();
  }
}
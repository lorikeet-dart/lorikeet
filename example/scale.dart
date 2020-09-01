import 'package:lorikeet/src/matrix.dart';

void main() {
  final mat = Matrix4.I();
  print(mat);

  mat.scale(x: 2, y: 2);
  print(mat);

  print(mat.multipleVertex4(Vertex4(x: 2, y: 2)));
}
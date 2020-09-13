import 'package:lorikeet/src/primitive/primitive.dart';

void main() {
  final mat = Matrix4.I();
  print(mat);

  mat.rotateZ(degToRad(45));
  print(mat);

  mat.translate(x: 125, y: 125);
  print(mat);
}

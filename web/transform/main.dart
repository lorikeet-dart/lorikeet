import 'dart:html';

import 'package:lorikeet/lorikeet.dart';

Future<void> main() async {
  final CanvasElement canvas = querySelector('#rectangle');

  final renderer = Renderer.makeRenderer(canvas,
      clearColor: Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0));

  await renderer.loadTextureFromUrl('dart', '/static/img/dart.png');

  final objects = <Object2D>[];

  {
    final rect = Object2D.rectangularMesh(Rectangle(100, 100, 50, 50),
        background: Background(
            color: Color(g: 1.0, a: 1.0),
            image: ImageProperties(renderer.getTexture('dart'),
                fillType: FillType.stretch)));
    objects.add(rect);
  }

  {
    final rect = Object2D.rectangularMesh(Rectangle(100, 100, 50, 50),
        transformationMatrix: Matrix4.I()
          ..translate(x: 125, y: 125)
          ..rotateZ(degToRad(45))
          ..translate(x: -125, y: -125),
        background: Background(
            color: Color(r: 1.0, a: 1.0),
            image: ImageProperties(renderer.getTexture('dart'),
                fillType: FillType.stretch)));
    objects.add(rect);
  }

  {
    final rect = Object2D.rectangularMesh(Rectangle(250, 250, 50, 50),
        background: Background(
            color: Color(g: 1.0, a: 1.0),
            image: ImageProperties(renderer.getTexture('dart'),
                fillType: FillType.stretch)));
    objects.add(rect);
  }

  {
    final rect = Object2D.rectangularMesh(Rectangle(250, 250, 50, 50),
        transform: Transform(rotation: degToRad(45), scale: Point(0.5, 0.5)),
        background: Background(
            color: Color(r: 1.0, a: 1.0),
            image: ImageProperties(renderer.getTexture('dart'),
                fillType: FillType.stretch)));
    objects.add(rect);
  }

  /*
  {
    final rect = Object2D.rectangularMesh(
      renderer,
      Rectangle(250, 250, 50, 50),
      transform: Transform(rotation: degToRad(45)/*, scale: Point(0.5, 0.5)*/),
    )..background = Background(
        color: Color(r: 1.0, a: 1.0), image: renderer.getTexture('dart'));
    objects.add(rect);
  }*/

  {
    final rect = Object2D.rectangularMesh(Rectangle(100, 100, 50, 50),
        transformationMatrix: Matrix4.I()
          // ..translate(x: 25, y: 25)
          ..rotateZ(degToRad(45))
        // ..translate(x: -25, y: -25),
        ,
        background: Background(
            color: Color(b: 1.0, a: 1.0),
            image: ImageProperties(renderer.getTexture('dart'),
                fillType: FillType.stretch)));
    objects.add(rect);
  }

  void render() {
    renderer.render(objects);
    /*window.requestAnimationFrame((highResTime) {
      render();
    });*/
  }

  window.requestAnimationFrame((highResTime) {
    render();
  });
}

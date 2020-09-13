import 'dart:html';

import 'package:lorikeet/lorikeet.dart';

Future<void> main() async {
  final CanvasElement canvas = querySelector('#rectangle');

  final renderer = Renderer.makeRenderer(canvas,
      clearColor: Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0));

  await renderer.loadTextureFromUrl('dart', '/static/img/dart.png');

  final objects = <Object2D>[];

  {
    final rect = Object2D.rectangularMesh(Rectangle(10, 10, 250, 250),
        background: Background(
            color: Color(r: 1.0, a: 1.0),
            image: ImageProperties(renderer.getTexture('dart'))));
    objects.add(rect);
  }

  {
    final rect = Object2D.rectangularMesh(Rectangle(200, 200, 250, 250),
        background: Background(color: Color(g: 1.0, a: 0.5)));
    objects.add(rect);
  }

  {
    final rect = Object2D.rectangularMesh(Rectangle(240, 10, 250, 250),
        background: Background(color: Color(a: 0.5)));
    objects.add(rect);
  }

  {
    final rect = Object2D.rectangularMesh(Rectangle(10, 240, 250, 250),
        background: Background(color: Color(r: 1, g: 1, b: 1, a: 0.5)));
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

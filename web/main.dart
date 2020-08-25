import 'dart:html';
import 'dart:web_gl';

import 'package:lorikeet/src/matrix.dart';
import 'package:lorikeet/src/object_renderer.dart';
import 'package:lorikeet/src/primitive.dart';
import 'package:lorikeet/src/render.dart';

Future<void> main() async {
  final CanvasElement canvas = querySelector('#rectangle');
  canvas.width = 500;
  canvas.height = 500;
  final RenderingContext2 ctx = canvas.getContext('webgl2');
  ctx.viewport(0, 0, 500, 500);

  final renderer = Renderer.makeRenderer(ctx,
      clearColor: Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0),
      projectionMatrix: Matrix4.ortho(0, 500, 500, 0, -1000.0, 1000.0));

  await renderer.loadTextureFromUrl('dart', '/static/img/dart.png');

  final objects = <Object2D>[];

  {
    final rect =
        Object2D.rectangularMesh(renderer, Vertex2(x: 10, y: 10), 250, 250)
          ..background = Background(
              color: Color(r: 1.0, a: 1.0), image: renderer.getTexture('dart'));
    objects.add(rect);
  }

  {
    final rect =
        Object2D.rectangularMesh(renderer, Vertex2(x: 200, y: 200), 250, 250)
          ..background = Background(color: Color(g: 1.0, a: 0.1));
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

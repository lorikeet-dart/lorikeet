import 'dart:html';
import 'dart:web_gl';

import 'package:lorikeet/src/matrix.dart';
import 'package:lorikeet/src/object_renderer.dart';
import 'package:lorikeet/src/primitive.dart';
import 'package:lorikeet/src/render.dart';

Future<void> main() async {
  final CanvasElement canvas = querySelector('#rectangle');
  canvas.width = 2000;
  canvas.height = 2000;
  final RenderingContext2 ctx = canvas.getContext('webgl2', {
    'premultipliedAlpha': false // Ask for non-premultiplied alpha
  });
  ctx.viewport(0, 0, 2000, 2000);

  final renderer = Renderer.makeRenderer(ctx,
      clearColor: Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0),
      projectionMatrix: Matrix4.ortho(0, 2000, 2000, 0, -1000.0, 1000.0));

  await renderer.loadTextureFromUrl('dart', '/static/img/dart.png');

  final objects = <Object2D>[];

  {
    final rect = Object2D.rectangularMesh(renderer, Rectangle(50, 50, 400, 400),
        background: Background(
            color: Color(r: 1.0, a: 1.0),
            image: ImageProperties(renderer.getTexture('dart'),
                fillType: FillType.repeat)));
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
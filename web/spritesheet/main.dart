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
  final RenderingContext2 ctx = canvas.getContext('webgl2', {
    'premultipliedAlpha': false // Ask for non-premultiplied alpha
  });
  ctx.viewport(0, 0, 500, 500);

  final renderer = Renderer.makeRenderer(ctx,
      clearColor: Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0),
      projectionMatrix: Matrix4.ortho(0, 500, 500, 0, -1000.0, 1000.0));

  await renderer.loadTextureFromUrl('spritesheet', '/static/img/spritesheet.png');

  final objects = <Object2D>[];

  {
    final rect =
        Object2D.rectangularMesh(renderer, Rectangle(100, 100, 128, 128))
          ..background = Background(
              color: Color(r: 0.5, g: 0.5, a: 1),
              image: renderer.getTexture('spritesheet'),
              textureRegion: Rectangle(128, 128, 128, 128));
    objects.add(rect);
  }

  void render() {
    renderer.render(objects);
    window.requestAnimationFrame((highResTime) {
      render();
    });
  }

  window.requestAnimationFrame((highResTime) {
    render();
  });
}

import 'dart:html';
import 'dart:web_gl';

import 'package:lorikeet/src/matrix.dart';
import 'package:lorikeet/src/object_renderer.dart';
import 'package:lorikeet/src/primitive.dart';
import 'package:lorikeet/src/render.dart';

void main() {
  final CanvasElement canvas = querySelector('#rectangle');
  final RenderingContext2 ctx = canvas.getContext('webgl2');
  ctx.viewport(0, 0, 500, 500);

  final renderer = Renderer.makeRenderer(ctx,
      clearColor: Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0),
      projectionMatrix: Matrix4.ortho(0, 500, 0, 500, -1000.0, 1000.0));

  final rect =
      Object2D.rectangularMesh(renderer, Vertex2(x: 10, y: 10), 10, 10)
        ..background = Background(color: Color(r: 1.0, a: 1.0));

  void render() {
    renderer.render([rect]);
    window.requestAnimationFrame((highResTime) {
      render();
    });
  }

  window.requestAnimationFrame((highResTime) {
    render();
  });
}

import 'dart:html';

import 'package:lorikeet/lorikeet.dart';

Future<void> main() async {
  final CanvasElement canvas = querySelector('#rectangle');

  final renderer = Renderer.makeRenderer(canvas,
      clearColor: Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0));

  await renderer.loadTextureFromUrl('dart', '/static/img/dart.png');

  final watch = Timeline()..start();

  /*

  {
    final rect = Object2D.make(Rectangle(200, 200, 250, 250),
        background: Background(color: Color(g: 1.0, a: 0.5)));
    objects.add(rect);
  }


   */

  void render() {
    final seconds = watch.inSeconds ~/ 5;
    int rotation = seconds % 36;

    final objects = <Mesh2D>[];

    {
      final rect = LinearGradientMesh.make(
          Rectangle(10, 10, 90, 90),
          LinearGradient.between(Color(r: 1, a: 1), Color(b: 1, a: 1),
              angle: 0),
          color: Color(r: 1, a: 1));
      objects.add(rect);
    }

    {
      final rect = LinearGradientMesh.make(
          Rectangle(110, 10, 90, 90),
          LinearGradient.between(Color(r: 1, a: 1), Color(b: 1, a: 1),
              angle: rotation * 10),
          color: Color(r: 1, a: 1));
      objects.add(rect);
    }

    renderer.render(objects);
    window.requestAnimationFrame((highResTime) {
      render();
    });
  }

  window.requestAnimationFrame((highResTime) {
    render();
  });
}

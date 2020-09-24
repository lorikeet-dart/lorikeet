import 'dart:html';

import 'package:lorikeet/lorikeet.dart';

Future<void> main() async {
  final CanvasElement canvas = querySelector('#rectangle');

  final renderer = Renderer.makeRenderer(canvas,
      clearColor: Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0));

  await renderer.loadTextureFromUrl('dart', '/static/img/dart.png');

  final watch = Timeline()..start();

  void render() {
    final objects = <Mesh2D>[];

    {
      {
        final rect = DropShadowMesh.make(
            Rectangle(10, 10, 90, 90), DropShadow(offset: Point(5, 5)));
        objects.add(rect);
      }

      {
        final rect = Object2D.make(Rectangle(10, 10, 90, 90),
            background: Background(color: Color(b: 1, a: 1)));
        objects.add(rect);
      }
    }
    {
      {
        final rect = Object2D.make(Rectangle(110, 10, 90, 90),
            background: Background(color: Color(r: 1, g: 1, b: 1, a: 1)));
        objects.add(rect);
      }

      {
        final rect = DropShadowMesh.make(
            Rectangle(110, 10, 90, 90), DropShadow(blur: 0.3));
        objects.add(rect);
      }
    }
    {
      {
        final rect = DropShadowMesh.make(Rectangle(200, 200, 90, 90),
            DropShadow(blur: 0.3, spread: 50, offset: Point(10, 10)));
        objects.add(rect);
      }
      {
        final rect = Object2D.make(Rectangle(200, 200, 90, 90),
            background: Background(color: Color(b: 1, a: 1)));
        objects.add(rect);
      }
    }
    {
      {
        final rect = DropShadowMesh.make(
            Rectangle(400, 200, 90, 90),
            DropShadow(
                color: Color(g: 1, b: 0.7, a: 1),
                blur: 0.1,
                spread: 10,
                offset: Point(2, 2)));
        objects.add(rect);
      }
      {
        final rect = Object2D.make(Rectangle(400, 200, 90, 90),
            background: Background(color: Color(b: 1, a: 1)));
        objects.add(rect);
      }
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

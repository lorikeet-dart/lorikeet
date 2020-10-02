import 'dart:html';

import 'package:lorikeet/lorikeet.dart';

Future<void> main() async {
  final CanvasElement canvas = querySelector('#rectangle');

  final renderer = Renderer.makeRenderer(canvas,
      clearColor: Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0));

  await renderer.loadTextureFromUrl('dart', '/static/img/dart.png');

  final objects = <Object2D>[];

  {
    {
      final rect = Object2D.make(Rectangle(50, 50, 250, 250),
          background: Background(
              color: Color(r: 1.0, a: 1.0),
              image: ImageProperties(renderer.getTexture('dart'),
                  anchorPoint: Point(0.5, 0.5), position: Point(0.5, 0.5))));
      objects.add(rect);
    }

    {
      final rect = Object2D.make(Rectangle(350, 50, 250, 250),
          background: Background(
              color: Color(r: 1.0, a: 1.0),
              image: ImageProperties(renderer.getTexture('dart'),
                  anchorPoint: Point(1, 1), position: Point(1, 1))));
      objects.add(rect);
    }

    {
      final rect = Object2D.make(Rectangle(650, 50, 250, 250),
          background: Background(
              color: Color(r: 1.0, a: 1.0),
              image: ImageProperties(renderer.getTexture('dart'),
                  anchorPoint: Point(0, 1), position: Point(0, 1))));
      objects.add(rect);
    }

    {
      final rect = Object2D.make(Rectangle(950, 50, 250, 250),
          background: Background(
              color: Color(r: 1.0, a: 1.0),
              image: ImageProperties(renderer.getTexture('dart'),
                  anchorPoint: Point(0, 0), position: Point(0, 0))));
      objects.add(rect);
    }

    {
      final rect = Object2D.make(Rectangle(1250, 50, 250, 250),
          background: Background(
              color: Color(r: 1.0, a: 1.0),
              image: ImageProperties(renderer.getTexture('dart'),
                  anchorPoint: Point(1, 0), position: Point(1, 0))));
      objects.add(rect);
    }
  }

  {
    {
      final rect = Object2D.make(Rectangle(50, 350, 250, 250),
          background: Background(
              color: Color(r: 1.0, a: 1.0),
              image: ImageProperties(renderer.getTexture('dart'),
                  anchorPoint: Point(0.5, 0.5),
                  position: Point(0.5, 0.5),
                  scale: Point(2, 2))));
      objects.add(rect);
    }

    {
      final rect = Object2D.make(Rectangle(350, 350, 250, 250),
          background: Background(
              color: Color(r: 1.0, a: 1.0),
              image: ImageProperties(renderer.getTexture('dart'),
                  anchorPoint: Point(1, 1),
                  position: Point(1, 1),
                  scale: Point(2, 2))));
      objects.add(rect);
    }

    {
      final rect = Object2D.make(Rectangle(650, 350, 250, 250),
          background: Background(
              color: Color(r: 1.0, a: 1.0),
              image: ImageProperties(renderer.getTexture('dart'),
                  anchorPoint: Point(0, 1),
                  position: Point(0, 1),
                  scale: Point(2, 2))));
      objects.add(rect);
    }

    {
      final rect = Object2D.make(Rectangle(950, 350, 250, 250),
          background: Background(
              color: Color(r: 1.0, a: 1.0),
              image: ImageProperties(renderer.getTexture('dart'),
                  anchorPoint: Point(0, 0),
                  position: Point(0, 0),
                  scale: Point(2, 2))));
      objects.add(rect);
    }

    {
      final rect = Object2D.make(Rectangle(1250, 350, 250, 250),
          background: Background(
              color: Color(r: 1.0, a: 1.0),
              image: ImageProperties(renderer.getTexture('dart'),
                  anchorPoint: Point(1, 0),
                  position: Point(1, 0),
                  scale: Point(2, 2))));
      objects.add(rect);
    }
  }

  /*
  {
    final rect = Object2D.make(Rectangle(50, 550, 300, 150),
        background: Background(
            color: Color(r: 1.0, a: 1.0),
            image: ImageProperties(renderer.getTexture('dart'))));
    objects.add(rect);
  }

  {
    final rect = Object2D.make(Rectangle(550, 50, 150, 300),
        background: Background(
            color: Color(r: 1.0, a: 1.0),
            image: ImageProperties(renderer.getTexture('dart'))));
    objects.add(rect);
  }

  {
    final rect = Object2D.make(Rectangle(550, 550, 250, 300),
        background: Background(
            color: Color(r: 1.0, a: 1.0),
            image: ImageProperties(renderer.getTexture('dart'))));
    objects.add(rect);
  }
   */

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

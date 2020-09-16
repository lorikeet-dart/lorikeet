import 'dart:html';

import 'package:lorikeet/lorikeet.dart';

Future<void> main() async {
  final CanvasElement canvas = querySelector('#rectangle');

  final renderer = Renderer.makeRenderer(canvas,
      clearColor: Color(r: 0.9, g: 0.9, b: 0.9, a: 1.0));

  await renderer.loadTextureFromUrl('dart', '/static/img/dart.png');

  final objects = <Object2D>[];

  // Smaller than box
  {
    final rect = Object2D.make(Rectangle(50, 50, 250, 250),
        background: Background(
            color: Color(r: 0.8, g: 0.8, b: 0.6, a: 1.0),
            image: ImageProperties(renderer.getTexture('dart'),
                fillType: FillType.contain)));
    objects.add(rect);
  }

  // Wider than box
  {
    final rect = Object2D.make(Rectangle(50, 350, 150, 250),
        background: Background(
            color: Color(r: 0.8, g: 0.8, b: 0.6, a: 1.0),
            image: ImageProperties(renderer.getTexture('dart'),
                fillType: FillType.contain)));
    objects.add(rect);
  }

  // Taller than box
  {
    final rect = Object2D.make(Rectangle(350, 50, 250, 150),
        background: Background(
            color: Color(r: 0.8, g: 0.8, b: 0.6, a: 1.0),
            image: ImageProperties(renderer.getTexture('dart'),
                fillType: FillType.contain)));
    objects.add(rect);
  }

  // Wider and taller than box
  {
    final rect = Object2D.make(Rectangle(350, 350, 150, 100),
        background: Background(
            color: Color(r: 0.8, g: 0.8, b: 0.6, a: 1.0),
            image: ImageProperties(renderer.getTexture('dart'),
                fillType: FillType.contain)));
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

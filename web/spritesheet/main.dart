import 'dart:html';

import 'package:lorikeet/src/matrix.dart';
import 'package:lorikeet/src/object_renderer.dart';
import 'package:lorikeet/src/primitive.dart';
import 'package:lorikeet/src/render.dart';

Future<void> main() async {
  final CanvasElement canvas = querySelector('#rectangle');

  final renderer = Renderer.makeRenderer(canvas,
      clearColor: Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0));

  await renderer.loadTextureFromUrl(
      'spritesheet', '/static/img/spritesheet.png');

  final objects = <Object2D>[];

  {
    final rect = Object2D.rectangularMesh(renderer, Rectangle(10, 10, 128, 128),
        background: Background(
            color: Color(r: 0.5, g: 0.5, a: 1),
            image: ImageProperties(renderer.getTexture('spritesheet'),
                textureRegion: Rectangle(128, 128, 128, 128))));
    objects.add(rect);
  }

  {
    final rect = Object2D.rectangularMesh(
        renderer, Rectangle(150, 10, 256, 256),
        background: Background(
            color: Color(r: 0.5, g: 0.5, a: 1),
            image: ImageProperties(renderer.getTexture('spritesheet'),
                textureRegion: Rectangle(128, 128, 128, 128),
                fillType: FillType.repeat)));
    objects.add(rect);
  }

  {
    final rect = Object2D.rectangularMesh(
        renderer, Rectangle(450, 10, 256, 256),
        background: Background(
            color: Color(r: 0.5, g: 0.5, a: 1),
            image: ImageProperties(renderer.getTexture('spritesheet'),
                textureRegion: Rectangle(128, 128, 128, 128),
                fillType: FillType.cover)));
    objects.add(rect);
  }

  {
    final rect = Object2D.rectangularMesh(
        renderer, Rectangle(750, 10, 100, 100),
        background: Background(
            color: Color(r: 0.5, g: 0.5, a: 1),
            image: ImageProperties(renderer.getTexture('spritesheet'),
                textureRegion: Rectangle(128, 128, 128, 128),
                fillType: FillType.contain)));
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

import 'dart:html';

import 'package:lorikeet/lorikeet.dart';

Future<void> main() async {
  final CanvasElement canvas = querySelector('#rectangle');

  final renderer = Renderer.makeRenderer(canvas,
      clearColor: Color(r: 0.5, g: 0.5, b: 0.5, a: 1.0));

  await renderer.loadTextureFromUrl(
      'spritesheet', '/static/img/spritesheet.png');

  final frames = [
    Rectangle(0, 0, 128, 128),
    Rectangle(0, 128, 128, 128),
    Rectangle(128, 0, 128, 128),
    Rectangle(128, 128, 128, 128)
  ];

  final watch = Timeline()..start();

  void render() {
    final seconds = watch.inMilliseconds ~/ 50;
    int frame = seconds % frames.length;

    final objects = <Object2D>[];

    {
      final rect = Object2D.rectangularMesh(
          renderer, Rectangle(100, 100, 128, 128),
          background: Background(
              color: Color(r: 0.5, g: 0.5, a: 1),
              image: ImageProperties(renderer.getTexture('spritesheet'),
                  textureRegion: frames[frame])));
      objects.add(rect);
    }

    renderer.render(objects);
    window.requestAnimationFrame((highResTime) {
      render();
    });
  }

  render();
}

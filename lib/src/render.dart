import 'dart:web_gl';

import 'package:lorikeet/src/glutil/uniform.dart';
import 'package:lorikeet/src/object_renderer.dart';
import 'package:lorikeet/src/primitive.dart';

class Renderer {
  Color clearColor = Color();

  final projectionMatrix = Matrix4();

  RenderingContext2 ctx;

  final textures = <String, Texture>{};

  final Texture noTexture;

  Program currentProgram;

  Renderer._(
      {this.ctx, this.noTexture, this.clearColor, Matrix4 projectionMatrix}) {
    if (projectionMatrix != null) {
      projectionMatrix.copyFrom(projectionMatrix);
    }
  }

  void useProgram(Program program) {
    if (currentProgram == program) {
      return;
    }

    ctx.useProgram(program);
    currentProgram = program;
  }

  void render(List<Object2D> objects) {
    objects.sort((a, b) => a.order - b.order);

    ctx.clearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
    ctx.clear(WebGL.COLOR_BUFFER_BIT);

    for (final object in objects) {
      object.shader.render(this, object);
    }
  }

  static Renderer makeRenderer(RenderingContext2 ctx, {Color clearColor}) {
    clearColor ??= Color();
    final noTexture = makePixelTexture(ctx, Color());

    return Renderer._(ctx: ctx, clearColor: clearColor, noTexture: noTexture);
  }
}

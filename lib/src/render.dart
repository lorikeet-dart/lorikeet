import 'dart:html';
import 'dart:web_gl';

import 'package:lorikeet/src/glutil/uniform.dart';
import 'package:lorikeet/src/matrix.dart';
import 'package:lorikeet/src/object_renderer.dart';
import 'package:lorikeet/src/primitive.dart';

import 'package:image/image.dart' as imageTools;
import 'package:http/http.dart';

class Renderer {
  Color clearColor = Color();

  final projectionMatrix = Matrix4();

  RenderingContext2 ctx;

  final _textures = <String, Tex>{};

  final programs = <String, ObjectRenderer>{};

  final Texture noTexture;

  Program currentProgram;

  Renderer._(
      {this.ctx,
      this.noTexture,
      this.clearColor,
      Matrix4 projectionMatrix,
      Map<String, Tex> textures = const {},
      Map<String, ObjectRenderer> programs = const {}}) {
    if (projectionMatrix != null) {
      this.projectionMatrix.copyFrom(projectionMatrix);
    }

    _textures.addAll(textures);
    this.programs.addAll(programs);
  }

  void useProgram(Program program) {
    if (currentProgram == program) {
      return;
    }

    ctx.useProgram(program);
    currentProgram = program;
  }

  Future<void> loadTextureFromUrl(String key, String url) async {
    final resp = await get(url);
    if (resp.statusCode != 200) {
      throw Exception('error downloading image');
    }

    final data = resp.bodyBytes;
    final decoder = imageTools.findDecoderForData(data);
    if (decoder == null) {
      throw Exception('error finding decoder for image');
    }
    final image = decoder.decodeImage(data);

    final texture = ctx.createTexture();
    ctx.bindTexture(WebGL.TEXTURE_2D, texture);

    ctx.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_MIN_FILTER, WebGL.LINEAR);
    ctx.texParameteri(
        WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_S, WebGL.CLAMP_TO_EDGE);
    ctx.texParameteri(
        WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_T, WebGL.CLAMP_TO_EDGE);

    ctx.texImage2D(WebGL.TEXTURE_2D, 0, WebGL.RGBA, image.width, image.height,
        0, WebGL.RGBA, WebGL.UNSIGNED_BYTE, image.getBytes());

    final tex = Tex(width: image.width, height: image.height, texture: texture);
    _textures[key] = tex;
  }

  Tex getTexture(String key) {
    if(_textures.containsKey(key)) return _textures[key];

    throw Exception('texture with key $key not found');
  }

  void render(List<Object2D> objects) {
    objects.sort((a, b) => a.order - b.order);

    ctx.clearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
    ctx.clear(WebGL.COLOR_BUFFER_BIT);

    for (final object in objects) {
      object.shader.render(this, object);
    }
  }

  static Renderer makeRenderer(RenderingContext2 ctx,
      {Color clearColor, Matrix4 projectionMatrix}) {
    clearColor ??= Color();
    final noTexture = makePixelTexture(ctx, Color());
    final basicObjectRenderer = BasicObjectRenderer.build(ctx);

    return Renderer._(
        ctx: ctx,
        clearColor: clearColor,
        noTexture: noTexture,
        programs: {'basic': basicObjectRenderer},
        projectionMatrix: projectionMatrix);
  }
}

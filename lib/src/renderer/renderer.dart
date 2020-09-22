import 'dart:html';
import 'dart:web_gl';

import 'package:lorikeet/src/glutil/uniform.dart';
import 'package:lorikeet/src/primitive/primitive.dart';
import 'package:lorikeet/src/renderer/drop_shadow.dart';
import 'package:lorikeet/src/renderer/linear_gradient.dart';
import 'package:lorikeet/src/renderer/object_renderer.dart';

import 'package:image/image.dart' as image_tools;
import 'package:http/http.dart';

import 'package:lorikeet/src/core/core.dart';

export 'object_renderer.dart';

class Renderer {
  Color clearColor = Color();

  final projectionMatrix = Matrix4();

  final CanvasElement canvas;

  RenderingContext2 ctx;

  final _textures = <String, Tex>{};

  final Object2DRenderer _object2DRenderer;

  final LinearGradientRenderer _linearGradientRenderer;

  final DropShadowRenderer _dropShadowRenderer;

  final Texture noTexture;

  Program currentProgram;

  Renderer._(
      {this.canvas,
      this.ctx,
      this.noTexture,
      this.clearColor,
      Matrix4 projectionMatrix,
      Map<String, Tex> textures = const {},
      Object2DRenderer object2DRenderer,
      LinearGradientRenderer linearGradientRenderer,
      DropShadowRenderer dropShadowRenderer})
      : _object2DRenderer = object2DRenderer,
        _linearGradientRenderer = linearGradientRenderer,
        _dropShadowRenderer = dropShadowRenderer {
    if (projectionMatrix != null) {
      this.projectionMatrix.copyFrom(projectionMatrix);
    }

    _textures.addAll(textures);
  }

  void adjustSize({int width, int height}) {
    width ??= canvas.clientWidth;
    height ??= canvas.clientHeight;

    canvas.width = width;
    canvas.height = height;
    ctx.viewport(0, 0, width, height);

    projectionMatrix.assign(Matrix4.ortho(
        0, width.toDouble(), height.toDouble(), 0, -1000.0, 1000.0));
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
    final decoder = image_tools.findDecoderForData(data);
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
    if (_textures.containsKey(key)) return _textures[key];

    throw Exception('texture with key $key not found');
  }

  void render(List<Mesh2D> objects) {
    // TODO objects.sort((a, b) => a.order - b.order);

    ctx.clearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
    ctx.clear(WebGL.COLOR_BUFFER_BIT);
    ctx.enable(WebGL.BLEND);
    ctx.blendFunc(WebGL.SRC_ALPHA, WebGL.ONE_MINUS_SRC_ALPHA);

    for (final object in objects) {
      if (object is Object2D) {
        _object2DRenderer.render(this, object);
      } else if (object is LinearGradientMesh) {
        _linearGradientRenderer.render(this, object);
      } else if (object is DropShadowMesh) {
        _dropShadowRenderer.render(this, object);
      } else {
        // TODO implement custom Meshes
        throw Exception('Unknown Mesh type');
      }
    }
  }

  static Renderer makeRenderer(CanvasElement canvas,
      {Color clearColor, Matrix4 projectionMatrix, Map contextAttributes}) {
    clearColor ??= Color();

    final ctx = canvas.getContext('webgl2',
        Map.from(contextAttributes ?? {})..['premultipliedAlpha'] = false);

    final noTexture = makePixelTexture(ctx, Color());
    final object2DRenderer = Object2DRenderer.build(ctx);
    final linearGradientRenderer = LinearGradientRenderer.build(ctx);
    final dropShadowRenderer = DropShadowRenderer.build(ctx);

    final ret = Renderer._(
      canvas: canvas,
      ctx: ctx,
      clearColor: clearColor,
      noTexture: noTexture,
      projectionMatrix: projectionMatrix,
      object2DRenderer: object2DRenderer,
      linearGradientRenderer: linearGradientRenderer,
      dropShadowRenderer: dropShadowRenderer,
    );

    ret.adjustSize();

    return ret;
  }
}

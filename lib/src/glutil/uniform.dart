import 'dart:typed_data';
import 'dart:web_gl';

import 'package:lorikeet/src/matrix.dart';
import 'package:lorikeet/src/object_renderer.dart';
import 'package:lorikeet/src/primitive.dart';

abstract class UniformInfo {
  RenderingContext2 get ctx;

  UniformLocation get location;
}

class FloatUniform implements UniformInfo {
  @override
  final RenderingContext2 ctx;

  @override
  final UniformLocation location;

  FloatUniform({this.ctx, this.location});

  void setData(num data) {
    ctx.uniform1f(location, data);
  }

  static UniformInfo make(
      RenderingContext2 ctx, Program program, String uniformName) {
    final location = ctx.getUniformLocation(program, uniformName);
    return FloatUniform(ctx: ctx, location: location);
  }
}

class ColorUniform implements UniformInfo {
  @override
  final RenderingContext2 ctx;

  @override
  final UniformLocation location;

  ColorUniform({this.ctx, this.location});

  void setData(Color color) {
    ctx.uniform4f(location, color.r, color.g, color.b, color.a);
  }

  static ColorUniform make(
      RenderingContext2 ctx, Program program, String uniformName) {
    final location = ctx.getUniformLocation(program, uniformName);
    return ColorUniform(ctx: ctx, location: location);
  }
}

class Matrix4Uniform implements UniformInfo {
  @override
  final RenderingContext2 ctx;

  @override
  final UniformLocation location;

  Matrix4Uniform({this.ctx, this.location});

  void setData(Matrix4 matrix) {
    ctx.uniformMatrix4fv(location, true, matrix.items);
  }

  static Matrix4Uniform make(
      RenderingContext2 ctx, Program program, String uniformName) {
    final location = ctx.getUniformLocation(program, uniformName);
    return Matrix4Uniform(ctx: ctx, location: location);
  }
}

/// Holds information about index and address of texture unit
class TextureIndex {
  final int index;

  final int pointer;

  const TextureIndex(this.index, this.pointer);

  static const texture0 = TextureIndex(0, WebGL.TEXTURE0);
}

class TextureUniform implements UniformInfo {
  @override
  final RenderingContext2 ctx;

  @override
  final UniformLocation location;

  TextureUniform({this.ctx, this.location});

  void setTexture(TextureIndex textureIndex, Texture texture, TexMode mode) {
    ctx.activeTexture(textureIndex.pointer);
    ctx.bindTexture(WebGL.TEXTURE_2D, texture);

    ctx.texParameteri(
        WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_S, WebGL.CLAMP_TO_EDGE);
    ctx.texParameteri(
        WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_T, WebGL.CLAMP_TO_EDGE);

    /*
    if (mode == TexMode.CLAMP) {
      ctx.texParameteri(
          WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_S, WebGL.CLAMP_TO_EDGE);
      ctx.texParameteri(
          WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_T, WebGL.CLAMP_TO_EDGE);
    } else if (mode == TexMode.REPEAT) {
      ctx.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_S, WebGL.REPEAT);
      ctx.texParameteri(WebGL.TEXTURE_2D, WebGL.TEXTURE_WRAP_T, WebGL.REPEAT);
    }
     */
    ctx.uniform1i(location, textureIndex.index);
  }

  static TextureUniform make(
      RenderingContext2 ctx, Program program, String uniformName) {
    final location = ctx.getUniformLocation(program, uniformName);
    return TextureUniform(ctx: ctx, location: location);
  }
}

class Vertex2Uniform implements UniformInfo {
  @override
  final RenderingContext2 ctx;

  @override
  final UniformLocation location;

  Vertex2Uniform({this.ctx, this.location});

  void setData(Vertex2 data) {
    ctx.uniform2f(location, data.x, data.y);
  }

  static Vertex2Uniform make(
      RenderingContext2 ctx, Program program, String uniformName) {
    final location = ctx.getUniformLocation(program, uniformName);
    return Vertex2Uniform(ctx: ctx, location: location);
  }
}

class BoolUniform implements UniformInfo {
  @override
  final RenderingContext2 ctx;

  @override
  final UniformLocation location;

  BoolUniform({this.ctx, this.location});

  void setData(bool data) {
    ctx.uniform1i(location, data ? 1 : 0);
  }

  static BoolUniform make(
      RenderingContext2 ctx, Program program, String uniformName) {
    final location = ctx.getUniformLocation(program, uniformName);
    return BoolUniform(ctx: ctx, location: location);
  }
}

Texture makePixelTexture(RenderingContext2 ctx, Color color) {
  final texture = ctx.createTexture();
  ctx.bindTexture(WebGL.TEXTURE_2D, texture);
  ctx.texImage2D(WebGL.TEXTURE_2D, 0, WebGL.RGBA, 1, 1, 0, WebGL.RGBA,
      WebGL.UNSIGNED_BYTE, color.asIntList);

  return texture;
}

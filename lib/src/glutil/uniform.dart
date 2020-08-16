import 'dart:typed_data';
import 'dart:web_gl';

import 'package:lorikeet/src/matrix.dart';
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

class Matrix2Uniform implements UniformInfo {
  @override
  final RenderingContext2 ctx;

  @override
  final UniformLocation location;

  Matrix2Uniform({this.ctx, this.location});

  void setData(Matrix2D matrix) {
    ctx.uniformMatrix2fv(location, false, matrix.items);
  }

  static Matrix2Uniform make(
      RenderingContext2 ctx, Program program, String uniformName) {
    final location = ctx.getUniformLocation(program, uniformName);
    return Matrix2Uniform(ctx: ctx, location: location);
  }
}

class Matrix4Uniform implements UniformInfo {
  @override
  final RenderingContext2 ctx;

  @override
  final UniformLocation location;

  Matrix4Uniform({this.ctx, this.location});

  void setData(Matrix4 matrix) {
    ctx.uniformMatrix2fv(location, false, matrix.items);
  }

  static Matrix4Uniform make(
      RenderingContext2 ctx, Program program, String uniformName) {
    final location = ctx.getUniformLocation(program, uniformName);
    return Matrix4Uniform(ctx: ctx, location: location);
  }
}

class TextureUniform implements UniformInfo {
  @override
  final RenderingContext2 ctx;

  @override
  final UniformLocation location;

  TextureUniform({this.ctx, this.location});

  void setTexture(Texture texture) {
    ctx.activeTexture(WebGL.TEXTURE0);
    ctx.bindTexture(WebGL.TEXTURE_2D, texture);

    ctx.uniform1i(location, 0);
  }

  static TextureUniform make(
      RenderingContext2 ctx, Program program, String uniformName) {
    final location = ctx.getUniformLocation(program, uniformName);
    return TextureUniform(ctx: ctx, location: location);
  }
}

Texture makePixelTexture(RenderingContext2 ctx, Color color) {
  final texture = ctx.createTexture();
  ctx.bindTexture(WebGL.TEXTURE_2D, texture);
  ctx.texImage2D(WebGL.TEXTURE_2D, 0, WebGL.RGBA, 1, 1, 0, WebGL.RGBA,
      WebGL.FLOAT, color.asList);

  return texture;
}

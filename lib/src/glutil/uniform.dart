import 'dart:web_gl';

import 'package:lorikeet/src/matrix.dart';
import 'package:lorikeet/src/primitive.dart';

abstract class UniformInfo {
  RenderingContext2 get ctx;

  UniformLocation get location;
}

class FloatUniformInfo implements UniformInfo {
  @override
  final RenderingContext2 ctx;

  @override
  final UniformLocation location;

  FloatUniformInfo({this.ctx, this.location});

  void setData(num data) {
    ctx.uniform1f(location, data);
  }

  static UniformInfo make(
      RenderingContext2 ctx, Program program, String uniformName) {
    final location = ctx.getUniformLocation(program, uniformName);
    return FloatUniformInfo(ctx: ctx, location: location);
  }
}

class ColorUniformInfo implements UniformInfo {
  @override
  final RenderingContext2 ctx;

  @override
  final UniformLocation location;

  ColorUniformInfo({this.ctx, this.location});

  void setData(Color color) {
    ctx.uniform4f(location, color.r, color.g, color.b, color.a);
  }

  static ColorUniformInfo make(
      RenderingContext2 ctx, Program program, String uniformName) {
    final location = ctx.getUniformLocation(program, uniformName);
    return ColorUniformInfo(ctx: ctx, location: location);
  }
}

class Matrix2DUniformInfo implements UniformInfo {
  @override
  final RenderingContext2 ctx;

  @override
  final UniformLocation location;

  Matrix2DUniformInfo({this.ctx, this.location});

  void setData(Matrix2D matrix) {
    ctx.uniformMatrix2fv(location, false, matrix.items);
  }

  static Matrix2DUniformInfo make(
      RenderingContext2 ctx, Program program, String uniformName) {
    final location = ctx.getUniformLocation(program, uniformName);
    return Matrix2DUniformInfo(ctx: ctx, location: location);
  }
}

class TextureUniformInfo implements UniformInfo {
  @override
  final RenderingContext2 ctx;

  @override
  final UniformLocation location;

  TextureUniformInfo({this.ctx, this.location});

  void setTexture(Texture texture) {
    ctx.activeTexture(WebGL.TEXTURE0);
    ctx.bindTexture(WebGL.TEXTURE_2D, texture);

    ctx.uniform1i(location, 0);
  }

  static TextureUniformInfo make(
      RenderingContext2 ctx, Program program, String uniformName) {
    final location = ctx.getUniformLocation(program, uniformName);
    return TextureUniformInfo(ctx: ctx, location: location);
  }
}

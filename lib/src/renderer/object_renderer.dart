import 'dart:math';
import 'dart:web_gl';

import 'package:lorikeet/src/glutil/attribute.dart';
import 'package:lorikeet/src/glutil/uniform.dart';
import 'package:lorikeet/src/primitive/primitive.dart';
import 'package:lorikeet/src/renderer/renderer.dart';
import 'package:lorikeet/src/core/core.dart';

import '../primitive/primitive.dart';

abstract class ObjectRenderer {
  void render(Renderer renderer, Object2D object);
}

class BasicObjectRenderer implements ObjectRenderer {
  final RenderingContext2 ctx;

  final Program program;

  final AttributeInfo position;

  final AttributeInfo texCoords;

  final Matrix4Uniform projectionMatrix;

  final Matrix4Uniform transformationMatrix;

  final ColorUniform bgColorUniform;

  final TextureUniform textureUniform;

  final BoolUniform repeatTexture;

  final Vertex2Uniform texRegionTopLeft;

  final Vertex2Uniform texRegionSize;

  BasicObjectRenderer({
    this.ctx,
    this.program,
    this.position,
    this.texCoords,
    this.transformationMatrix,
    this.projectionMatrix,
    this.bgColorUniform,
    this.textureUniform,
    this.repeatTexture,
    this.texRegionTopLeft,
    this.texRegionSize,
  });

  @override
  void render(Renderer renderer, Object2D object) {
    renderer.useProgram(program);

    final numVertices = object.vertices.count;

    position.set(object.vertices.asList);

    projectionMatrix.setData(renderer.projectionMatrix);
    transformationMatrix.setData(object.transformationMatrix);

    final background = object.background;
    bgColorUniform.setData(background.color);

    if (background.image == null) {
      texCoords.setVertex2(Vertex2());

      repeatTexture.setData(false);

      textureUniform.setTexture(TextureIndex.texture0, renderer.noTexture);
    } else {
      texCoords.set(object.texCoords.asList);

      repeatTexture.setData(object.repeatTexture);
      texRegionTopLeft.setData(object.textureRegion.topLeft.toVertex2);
      texRegionSize.setData(object.textureRegion.size.toVertex2);

      textureUniform.setTexture(
          TextureIndex.texture0, background.image.texture.texture);
    }

    ctx.drawArrays(WebGL.TRIANGLES, 0, numVertices);
  }

  static const vertexShaderSource = '''
attribute vec2 vertex;
attribute vec2 texCoord;

uniform mat4 projectionMatrix;
uniform mat4 transformationMatrix;

varying vec2 vTexCoord;

void main(void){
  gl_Position = projectionMatrix * transformationMatrix * vec4(vertex, 0.0, 1.0);
  vTexCoord = texCoord;
}
  ''';

  static const fragmentShaderSource = '''
precision mediump float;
  
uniform vec4 bgColor;
uniform sampler2D texture;
uniform vec2 texRegionTopLeft;
uniform vec2 texRegionSize;
uniform bool repeatTexture;

varying vec2 vTexCoord;

void main(void) {
  vec2 texCoord = vTexCoord;
  if(repeatTexture) {
    texCoord = vec2((fract(vTexCoord.x) * texRegionSize.x) + texRegionTopLeft.x, 
      (fract(vTexCoord.y) * texRegionSize.y) + texRegionTopLeft.y);
  } else {
    if(vTexCoord.x >= 0.0 && vTexCoord.x <= 1.0) {
      texCoord.x = (fract(vTexCoord.x) * texRegionSize.x) + texRegionTopLeft.x;
    }
    if(vTexCoord.y >= 0.0 && vTexCoord.y <= 1.0) {
      texCoord.y = (fract(vTexCoord.y) * texRegionSize.y) + texRegionTopLeft.y;
    }
  }

  vec4 texColor = texture2D(texture, texCoord);
  gl_FragColor = bgColor * (1.0 - texColor.w) + texColor * texColor.w;
}
  ''';

  static BasicObjectRenderer build(RenderingContext2 ctx) {
    Shader vs = ctx.createShader(WebGL.VERTEX_SHADER);
    ctx.shaderSource(vs, vertexShaderSource);
    ctx.compileShader(vs);

    Shader fs = ctx.createShader(WebGL.FRAGMENT_SHADER);
    ctx.shaderSource(fs, fragmentShaderSource);
    ctx.compileShader(fs);

    Program program = ctx.createProgram();
    ctx.attachShader(program, vs);
    ctx.attachShader(program, fs);
    ctx.linkProgram(program);

    ctx.bindAttribLocation(program, 2, 'tc');

    if (!ctx.getShaderParameter(vs, WebGL.COMPILE_STATUS)) {
      final msg = ctx.getShaderInfoLog(vs);
      throw Exception('Compiling vertex shader failed: $msg');
    }

    if (!ctx.getShaderParameter(fs, WebGL.COMPILE_STATUS)) {
      final msg = ctx.getShaderInfoLog(fs);
      throw Exception('Compiling fragment shader failed: $msg');
    }

    if (!ctx.getProgramParameter(program, WebGL.LINK_STATUS)) {
      final msg = ctx.getProgramInfoLog(program);
      throw Exception('Compiling program failed: $msg');
    }

    final positionAttribute =
        AttributeInfo.makeArrayBuffer(ctx, program, 'vertex');
    ctx.vertexAttribPointer(
        positionAttribute.location, 2, WebGL.FLOAT, false, 0, 0);
    final texCoordsAttribute =
        AttributeInfo.makeArrayBuffer(ctx, program, 'texCoord');
    ctx.vertexAttribPointer(
        texCoordsAttribute.location, 2, WebGL.FLOAT, false, 0, 0);

    final projectionMatrixUniform =
        Matrix4Uniform.make(ctx, program, 'projectionMatrix');
    final transformationMatrixUniform =
        Matrix4Uniform.make(ctx, program, 'transformationMatrix');
    final bgColorUniform = ColorUniform.make(ctx, program, 'bgColor');
    final textureUniform = TextureUniform.make(ctx, program, 'texture');
    final repeatTextureUniform =
        BoolUniform.make(ctx, program, 'repeatTexture');
    final texRegionTopLeftUniform =
        Vertex2Uniform.make(ctx, program, 'texRegionTopLeft');
    final texRegionSizeUniform =
        Vertex2Uniform.make(ctx, program, 'texRegionSize');

    return BasicObjectRenderer(
      ctx: ctx,
      program: program,
      position: positionAttribute,
      texCoords: texCoordsAttribute,
      projectionMatrix: projectionMatrixUniform,
      transformationMatrix: transformationMatrixUniform,
      bgColorUniform: bgColorUniform,
      textureUniform: textureUniform,
      repeatTexture: repeatTextureUniform,
      texRegionTopLeft: texRegionTopLeftUniform,
      texRegionSize: texRegionSizeUniform,
    );
  }
}

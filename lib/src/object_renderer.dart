import 'dart:typed_data';
import 'dart:web_gl';

import 'package:lorikeet/src/glutil/attribute.dart';
import 'package:lorikeet/src/glutil/uniform.dart';
import 'package:lorikeet/src/matrix.dart';
import 'package:lorikeet/src/primitive.dart';
import 'package:lorikeet/src/render.dart';

class Object2D {
  int order;

  Vertex2s vertices;

  Background background;

  Matrix2D transformationMatrix;

  ObjectRenderer shader;

  static Object2D rectangularMesh(Vertex2 topLeft, int width, int height) {
    return Object2D();
  }
}

abstract class ObjectRenderer {
  void render(Renderer renderer, Object2D object);
}

class BasicObjectRenderer implements ObjectRenderer {
  final RenderingContext2 ctx;

  final Program program;

  final AttributeInfo positionAttribute;

  final AttributeInfo texCoordsAttribute;

  final Matrix4Uniform projectionMatrixUniform;

  final Matrix2Uniform transformationMatrixUniform;

  final ColorUniform bgColorUniform;

  final TextureUniform textureUniform;

  final FloatUniform textureOpacityUniform;

  BasicObjectRenderer(
      {this.ctx,
      this.program,
      this.positionAttribute,
      this.texCoordsAttribute,
      this.transformationMatrixUniform,
      this.projectionMatrixUniform,
      this.bgColorUniform,
      this.textureUniform,
      this.textureOpacityUniform});

  @override
  void render(Renderer renderer, Object2D object) {
    renderer.useProgram(program);

    final numVertices = object.vertices.count;

    positionAttribute.set(object.vertices.asList);

    projectionMatrixUniform.setData(renderer.projectionMatrix);
    transformationMatrixUniform.setData(object.transformationMatrix);

    final background = object.background;
    bgColorUniform.setData(background.color);

    if (background.image == null) {
      texCoordsAttribute.setVertex2(Vertex2());

      textureUniform.setTexture(renderer.noTexture);
      textureOpacityUniform.setData(0);
    } else {
      throw Exception('Texture support not implemented yet!');

      // TODO texCoordsAttribute.set(texCoords);
    }

    ctx.drawArrays(WebGL.TRIANGLES, 0, numVertices);
  }

  static const vertexShaderSource = '''
attribute vec2 vertex;
attribute vec2 texCoord;

uniform mat4 projectionMatrix;
uniform mat3 transformationMatrix;

varying vec2 texCoordOut;

void main(void){
   gl_Position = vec4((projectionMatrix * transformationMatrix * vec3(vertex, 1.0)).xy, 0.0, 1.0);
   texCoordOut = texCoord;
}
  ''';

  static const fragmentShaderSource = '''
uniform vec4 bgColor;
uniform sampler2D texture;
uniform float textureOpacity;

varying vec2 texCoord;

void main(void) {
  gl_FragColor = bgColor + texture2D(texture, texCoord) * textureOpacity;
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

    if (!ctx.getShaderParameter(vs, WebGL.COMPILE_STATUS)) {
      final msg = ctx.getShaderInfoLog(vs);
      throw Exception('Compiling vertex shader failed: $msg');
    }

    if (!ctx.getShaderParameter(fs, WebGL.COMPILE_STATUS)) {
      final msg = ctx.getShaderInfoLog(vs);
      throw Exception('Compiling fragment shader failed: $msg');
    }

    if (!ctx.getProgramParameter(program, WebGL.LINK_STATUS)) {
      final msg = ctx.getProgramInfoLog(program);
      throw Exception('Compiling program failed: $msg');
    }

    final vertexAttrbiute =
        AttributeInfo.makeArrayBuffer(ctx, program, 'vertex');
    ctx.vertexAttribPointer(
        vertexAttrbiute.location, 2, WebGL.FLOAT, false, 0, 0);
    final texCoordsAttrbiute =
        AttributeInfo.makeArrayBuffer(ctx, program, 'texCoords');
    ctx.vertexAttribPointer(
        texCoordsAttrbiute.location, 2, WebGL.FLOAT, false, 0, 0);

    final projectionMatrixUniform =
        Matrix4Uniform.make(ctx, program, 'projectionMatrix');
    final transformationMatrixUniform =
        Matrix2Uniform.make(ctx, program, 'transformationMatrix');
    final bgColorUniform = ColorUniform.make(ctx, program, 'bgColor');
    final textureUniform = TextureUniform.make(ctx, program, 'texture');
    final textureOpacityUniform =
        FloatUniform.make(ctx, program, 'textureOpacity');

    return BasicObjectRenderer(
        ctx: ctx,
        program: program,
        positionAttribute: vertexAttrbiute,
        texCoordsAttribute: texCoordsAttrbiute,
        projectionMatrixUniform: projectionMatrixUniform,
        transformationMatrixUniform: transformationMatrixUniform,
        bgColorUniform: bgColorUniform,
        textureUniform: textureUniform,
        textureOpacityUniform: textureOpacityUniform);
  }
}

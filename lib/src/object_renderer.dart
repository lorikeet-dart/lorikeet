import 'dart:web_gl';

import 'package:lorikeet/src/glutil/attribute.dart';
import 'package:lorikeet/src/glutil/uniform.dart';
import 'package:lorikeet/src/matrix.dart';
import 'package:lorikeet/src/primitive.dart';
import 'package:lorikeet/src/render.dart';

class Object2D {
  final Renderer renderer;

  int order = 0;

  Vertex2s vertices;

  Background background = Background();

  final transformationMatrix = Matrix4.I();

  ObjectRenderer shader;

  Object2D(this.renderer, this.vertices,
      {this.order = 0,
      this.background,
      Matrix4 transformationMatrix,
      this.shader}) {
    if (transformationMatrix != null) {
      this.transformationMatrix.copyFrom(transformationMatrix);
    }
  }

  static Object2D rectangularMesh(
      Renderer renderer, Vertex2 topLeft, num width, num height,
      {ObjectRenderer shader, Matrix4 transformationMatrix}) {
    final vertices = Vertex2s.length(6);
    vertices[0] = Vertex2(x: topLeft.x, y: topLeft.y);
    vertices[1] = Vertex2(x: topLeft.x + width, y: topLeft.y);
    vertices[2] = Vertex2(x: topLeft.x + width, y: topLeft.y + height);
    vertices[3] = Vertex2(x: topLeft.x, y: topLeft.y);
    vertices[4] = Vertex2(x: topLeft.x, y: topLeft.y + height);
    vertices[5] = Vertex2(x: topLeft.x + width, y: topLeft.y + height);
    return Object2D(renderer, vertices,
        shader: shader ?? renderer.programs['basic'],
        transformationMatrix: transformationMatrix);
  }
}

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

  BasicObjectRenderer({
    this.ctx,
    this.program,
    this.position,
    this.texCoords,
    this.transformationMatrix,
    this.projectionMatrix,
    this.bgColorUniform,
    this.textureUniform,
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

      textureUniform.setTexture(renderer.noTexture);
    } else {
      texCoords.set(object.background.texCoords.asList);

      textureUniform.setTexture(background.image.texture);
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

varying vec2 vTexCoord;

void main(void) {
  vec4 texColor = texture2D(texture, vTexCoord);
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

    final vertexAttrbiute =
        AttributeInfo.makeArrayBuffer(ctx, program, 'vertex');
    ctx.vertexAttribPointer(
        vertexAttrbiute.location, 2, WebGL.FLOAT, false, 0, 0);
    final texCoordsAttrbiute =
        AttributeInfo.makeArrayBuffer(ctx, program, 'texCoord');
    ctx.vertexAttribPointer(
        texCoordsAttrbiute.location, 2, WebGL.FLOAT, false, 0, 0);

    final projectionMatrixUniform =
        Matrix4Uniform.make(ctx, program, 'projectionMatrix');
    final transformationMatrixUniform =
        Matrix4Uniform.make(ctx, program, 'transformationMatrix');
    final bgColorUniform = ColorUniform.make(ctx, program, 'bgColor');
    final textureUniform = TextureUniform.make(ctx, program, 'texture');

    return BasicObjectRenderer(
      ctx: ctx,
      program: program,
      position: vertexAttrbiute,
      texCoords: texCoordsAttrbiute,
      projectionMatrix: projectionMatrixUniform,
      transformationMatrix: transformationMatrixUniform,
      bgColorUniform: bgColorUniform,
      textureUniform: textureUniform,
    );
  }
}

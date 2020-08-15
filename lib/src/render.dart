import 'dart:typed_data';
import 'dart:web_gl';

import 'package:lorikeet/src/glutil/attribute.dart';
import 'package:lorikeet/src/glutil/uniform.dart';
import 'package:lorikeet/src/matrix.dart';
import 'package:lorikeet/src/primitive.dart';

abstract class ObjectRenderer {
  void render(Renderer renderer, Object2D object);
}

class BasicObjectRenderer implements ObjectRenderer {
  final RenderingContext2 ctx;

  final Program program;

  final AttributeInfo positionAttribute;

  final AttributeInfo texCoordsAttribute;

  final Matrix2DUniformInfo projectionMatrixUniform;

  final ColorUniformInfo bgColorUniform;

  final TextureUniformInfo textureUniform;

  final FloatUniformInfo textureOpacityUniform;

  BasicObjectRenderer(
      {this.ctx,
      this.program,
      this.positionAttribute,
      this.texCoordsAttribute,
      this.projectionMatrixUniform,
      this.bgColorUniform,
      this.textureUniform,
      this.textureOpacityUniform});

  @override
  void render(Renderer renderer, Object2D object) {
    renderer.useProgram(program);

    final numVertices = object.vertices.length;

    final positions = Float32List(numVertices * 2);
    for (int i = 0; i < numVertices; i++) {
      positions[i * 2] = object.vertices[i].x;
      positions[i * 2 + 1] = object.vertices[i].y;
    }
    positionAttribute.set(positions);

    final texCoords = Float32List(numVertices * 2);
    for (int i = 0; i < numVertices; i++) {
      positions[i * 2] = 0; // TODO
      positions[i * 2 + 1] = 0; // TODO
    }
    texCoordsAttribute.set(texCoords);

    projectionMatrixUniform.setData(object.transformationMatrix);

    final background = object.background;
    bgColorUniform.setData(background.color);

    if (background.image == null) {
      textureUniform.setTexture(renderer.noTexture);
      textureOpacityUniform.setData(0);
    } else {
      throw Exception('Texture support not implemented yet!');
    }

    ctx.drawArrays(WebGL.TRIANGLES, 0, numVertices);
  }

  static const vertexShaderSource = '''
attribute vec2 vertex;
attribute vec2 texCoord;

uniform mat3 projectionMatrix;

varying vec2 texCoordOut;

void main(void){
   gl_Position = vec4((projectionMatrix * vec3(vertex, 1.0)).xy, 0.0, 1.0);
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
        Matrix2DUniformInfo.make(ctx, program, 'projectionMatrix');
    final bgColorUniform = ColorUniformInfo.make(ctx, program, 'bgColor');
    final textureUniform = TextureUniformInfo.make(ctx, program, 'texture');
    final textureOpacityUniform =
        FloatUniformInfo.make(ctx, program, 'textureOpacity');

    return BasicObjectRenderer(
        ctx: ctx,
        program: program,
        positionAttribute: vertexAttrbiute,
        texCoordsAttribute: texCoordsAttrbiute,
        projectionMatrixUniform: projectionMatrixUniform,
        bgColorUniform: bgColorUniform,
        textureUniform: textureUniform,
        textureOpacityUniform: textureOpacityUniform);
  }
}

class Object2D {
  int order;

  List<Position> vertices;

  Background background;

  Matrix2D transformationMatrix;

  ObjectRenderer shader;

  static Object2D rectangularMesh(Position topLeft, int width, int height) {
    return Object2D();
  }
}

class Renderer {
  Color clearColor = Color();

  RenderingContext2 ctx;

  final textures = <String, Texture>{};

  final Texture noTexture;

  Program currentProgram;

  Renderer._({this.ctx, this.noTexture, this.clearColor});

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

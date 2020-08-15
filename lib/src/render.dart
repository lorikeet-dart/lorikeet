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

  final AttributeInfo vertexBuffer;

  final AttributeInfo texCoordsBuffer;

  final UniformInfo projectionMatrixUniform;

  final UniformInfo bgColorUniform;

  final UniformInfo textureUniform;

  final UniformInfo textureOpacityUniform;

  BasicObjectRenderer(
      {this.ctx,
      this.program,
      this.vertexBuffer,
      this.texCoordsBuffer,
      this.projectionMatrixUniform,
      this.bgColorUniform,
      this.textureUniform,
      this.textureOpacityUniform});

  @override
  void render(Renderer renderer, Object2D object) {
    renderer.useProgram(program);

    // TODO

    ctx.bufferData(WebGL.ARRAY_BUFFER, vertices, STATIC_DRAW);
    ctx.bindBuffer(WebGL.ARRAY_BUFFER, vbuffer);
    ctx.vertexAttribPointer(aVertexPosition, 2, WebGL.FLOAT, false, 0, 0);

    ctx.bindBuffer(WebGL.ARRAY_BUFFER, tbuffer);
    ctx.vertexAttribPointer(aTextureCoord, 2, WebGL.FLOAT, false, 0, 0);

    ctx.drawArrays(WebGL.TRIANGLES, 0, numItems);
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
    final texCoordsAttrbiute =
        AttributeInfo.makeArrayBuffer(ctx, program, 'texCoords');

    final projectionMatrixUniform =
        Matrix2DUniformInfo.make(ctx, program, 'projectionMatrix');
    final bgColorUniform = ColorUniformInfo.make(ctx, program, 'bgColor');
    final textureUniform = TextureUniformInfo.make(ctx, program, 'texture');
    final textureOpacityUniform =
        FloatUniformInfo.make(ctx, program, 'textureOpacity');

    // TODO

    return BasicObjectRenderer(
        ctx: ctx,
        program: program,
        vertexBuffer: vertexAttrbiute,
        texCoordsBuffer: texCoordsAttrbiute);
  }
}

class Object2D {
  int order;

  List<Position> vertices;

  List<Background> background;

  Matrix2D localTransformationMatrix;

  ObjectRenderer shader;

  static Object2D rectangularMesh(Position topLeft, int width, int height) {
    return Object2D();
  }
}

class Renderer {
  Color clearColor = Color();

  RenderingContext2 ctx;

  List<Texture> textures;

  Program currentProgram;

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
}

import 'dart:math';
import 'dart:web_gl';

import 'package:lorikeet/src/glutil/attribute.dart';
import 'package:lorikeet/src/glutil/uniform.dart';
import 'package:lorikeet/src/matrix.dart';
import 'package:lorikeet/src/primitive.dart';
import 'package:lorikeet/src/render.dart';

enum TexMode { CLAMP, REPEAT }

class Object2D {
  final Renderer renderer;

  final Rectangle box;

  int order = 0;

  Vertex2s vertices;

  final Vertex2s texCoords;

  final TexMode texMode;

  final Background background;

  final transformationMatrix = Matrix4.I();

  ObjectRenderer shader;

  Object2D(this.renderer, this.box, this.vertices,
      {this.order = 0,
      this.background,
      Matrix4 transformationMatrix,
      this.shader,
      this.texCoords,
      this.texMode}) {
    if (transformationMatrix != null) {
      this.transformationMatrix.copyFrom(transformationMatrix);
    }
  }

  Rectangle boundingBox() {
    num minX;
    num minY;
    num maxX;
    num maxY;

    for (final v in vertices.asVertexList) {
      if (minX == null || v.x < minX) minX = v.x;
      if (maxX == null || v.x > maxX) maxX = v.x;
      if (minY == null || v.y < minY) minY = v.y;
      if (maxY == null || v.y > maxY) maxY = v.y;
    }

    return Rectangle(minX, minY, maxX - minX, maxY - minY);
  }

  static Object2D rectangularMesh(
    Renderer renderer,
    Rectangle<num> box, {
    ObjectRenderer shader,
    Matrix4 transformationMatrix,
    Transform transform,
    Background background,
  }) {
    final vertices = Vertex2s.length(6);
    vertices[0] = Vertex2(x: box.left, y: box.top);
    vertices[1] = Vertex2(x: box.left + box.width, y: box.top);
    vertices[2] = Vertex2(x: box.left + box.width, y: box.top + box.height);
    vertices[3] = Vertex2(x: box.left, y: box.top);
    vertices[4] = Vertex2(x: box.left, y: box.top + box.height);
    vertices[5] = Vertex2(x: box.left + box.width, y: box.top + box.height);

    transformationMatrix ??= Matrix4.I();
    transform ??= Transform();

    if (transform.hasTransform) {
      num tx = box.left + ((box.width * transform.anchorPointPercent.x) / 100);
      num ty = box.top + ((box.height * transform.anchorPointPercent.y) / 100);
      transformationMatrix.translate(x: tx, y: ty);

      if (transform.translate != null) {
        transformationMatrix.translate(
            x: transform.translate.x, y: transform.translate.y);
      }

      if (transform.rotation != null) {
        transformationMatrix.rotateZ(transform.rotation);
      }

      if (transform.scale != null) {
        transformationMatrix.scale(x: transform.scale.x, y: transform.scale.y);
      }

      transformationMatrix.translate(x: -tx, y: -ty);
    }

    Vertex2s texCoords = Vertex2s.length(6);
    TexMode texMode = TexMode.CLAMP;

    final image = background.image;
    if (image != null) {
      final tex =
          image.textureRegion ?? Rectangle.fromPoints(Point(0, 0), image.size);

      Point<num> texSize = Point(tex.width * image.size.x / 100,
          tex.height * image.size.y / 100);
      Point<num> result;

      if (image.fillType == FillType.normal) {
        result = computeNormal(box.size, texSize);
      } else if (image.fillType == FillType.stretch) {
        result = Point<num>(1, 1);
      } else if (image.fillType == FillType.contain) {
        result = computeContain(box.size, texSize);
      } else if (image.fillType == FillType.cover) {
        result = computeCover(box.size, texSize);
      } else if (image.fillType == FillType.repeat) {
        result = computeRepeat(box.size, texSize);
        texMode = TexMode.REPEAT;
      }

      texCoords[0] = Vertex2(x: 0, y: 0);
      texCoords[1] = Vertex2(x: result.width, y: 0.0);
      texCoords[2] = Vertex2(x: result.width, y: result.height);
      texCoords[3] = Vertex2(x: 0.0, y: 0.0);
      texCoords[4] = Vertex2(x: 0.0, y: result.height);
      texCoords[5] = Vertex2(x: result.width, y: result.height);
    }

    /* spritesheet
        texCoords[0] = Vertex2.fromPoint(tex.topLeft)
          ..divideByPoint(image.size);
        texCoords[1] = Vertex2.fromPoint(tex.topRight)
          ..divideByPoint(image.size);
        texCoords[2] = Vertex2.fromPoint(tex.bottomRight)
          ..divideByPoint(image.size);
        texCoords[3] = Vertex2.fromPoint(tex.topLeft)
          ..divideByPoint(image.size);
        texCoords[4] = Vertex2.fromPoint(tex.bottomLeft)
          ..divideByPoint(image.size);
        texCoords[5] = Vertex2.fromPoint(tex.bottomRight)
          ..divideByPoint(image.size);
         */

    return Object2D(renderer, box, vertices,
        shader: shader ?? renderer.programs['basic'],
        transformationMatrix: transformationMatrix,
        texCoords: texCoords,
        background: background,
        texMode: texMode);
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

      textureUniform.setTexture(
          WebGL.TEXTURE0, renderer.noTexture, TexMode.REPEAT);
    } else {
      texCoords.set(object.texCoords.asList);

      textureUniform.setTexture(
          WebGL.TEXTURE0, background.image.image.texture, object.texMode);
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

class Transform {
  final num rotation;
  final Point<num> translate;
  final Point<num> scale;
  final Point<num> anchorPointPercent;

  Transform(
      {this.rotation,
      this.translate,
      this.scale,
      this.anchorPointPercent = const Point<num>(50, 50)});

  bool get hasTransform =>
      rotation != null || translate != null || scale != null;
}

import 'dart:web_gl';

import 'package:lorikeet/src/core/core.dart';
import 'package:lorikeet/src/glutil/glutil.dart';
import 'package:lorikeet/src/renderer/renderer.dart';
import 'object_renderer.dart';

class DropShadowRenderer implements Mesh2DRenderer<DropShadowMesh> {
  final RenderingContext2 ctx;

  final Program program;

  final AttributeInfo position;

  final AttributeInfo texCoords;

  final Matrix4Uniform projectionMatrix;

  final Matrix4Uniform transformationMatrix;

  final ColorUniform bgColorUniform;

  final FloatUniform blurUniform;

  DropShadowRenderer({
    this.ctx,
    this.program,
    this.position,
    this.texCoords,
    this.projectionMatrix,
    this.transformationMatrix,
    this.bgColorUniform,
    this.blurUniform,
  });

  @override
  void render(Renderer renderer, DropShadowMesh object) {
    renderer.useProgram(program);

    final numVertices = object.vertices.count;

    position.set(object.vertices.asDataList);

    projectionMatrix.setData(renderer.projectionMatrix);
    transformationMatrix.setData(object.transformationMatrix);

    texCoords.set(object.texCoords.asDataList);
    bgColorUniform.setData(object.color);

    blurUniform.setData(object.blur);
    // TODO

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
uniform float blur;

varying vec2 vTexCoord;

void main(void) {
  float blurXPercent = 1.0;
  if(vTexCoord.x < blur) {
    blurXPercent = vTexCoord.x/blur;
  } else if(vTexCoord.x > 1.0 - blur) {
    blurXPercent = (1.0 - vTexCoord.x)/blur;
  }
  float blurYPercent = 1.0;
  if(vTexCoord.y < blur) {
    blurYPercent = vTexCoord.y/blur;
  } else if(vTexCoord.y > 1.0 - blur) {
    blurYPercent = (1.0 - vTexCoord.y)/blur;
  }
  float blurPercent = blurXPercent * blurYPercent;
  gl_FragColor = vec4(bgColor.xyz, bgColor.w * blurPercent);
}
  ''';

  static DropShadowRenderer build(RenderingContext2 ctx) {
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
      final msg = ctx.getShaderInfoLog(fs);
      throw Exception('Compiling fragment shader failed: $msg');
    }

    if (!ctx.getProgramParameter(program, WebGL.LINK_STATUS)) {
      final msg = ctx.getProgramInfoLog(program);
      throw Exception('Compiling program failed: $msg');
    }

    final positionAttribute =
        AttributeInfo.makeArrayBuffer(ctx, program, 'vertex');
    final texCoordsAttribute =
        AttributeInfo.makeArrayBuffer(ctx, program, 'texCoord');

    final projectionMatrixUniform =
        Matrix4Uniform.make(ctx, program, 'projectionMatrix');
    final transformationMatrixUniform =
        Matrix4Uniform.make(ctx, program, 'transformationMatrix');
    final bgColorUniform = ColorUniform.make(ctx, program, 'bgColor');
    final blurUniform = FloatUniform.make(ctx, program, 'blur');

    return DropShadowRenderer(
      ctx: ctx,
      program: program,
      position: positionAttribute,
      texCoords: texCoordsAttribute,
      projectionMatrix: projectionMatrixUniform,
      transformationMatrix: transformationMatrixUniform,
      bgColorUniform: bgColorUniform,
      blurUniform: blurUniform,
    );
  }
}

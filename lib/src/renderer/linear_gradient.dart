import 'dart:web_gl';

import 'package:lorikeet/src/core/core.dart';
import 'package:lorikeet/src/glutil/glutil.dart';
import 'package:lorikeet/src/renderer/renderer.dart';
import 'object_renderer.dart';

class LinearGradientRenderer implements Mesh2DRenderer<LinearGradientMesh> {
  final RenderingContext2 ctx;

  final Program program;

  final AttributeInfo position;

  final AttributeInfo texCoords;

  final Matrix4Uniform projectionMatrix;

  final Matrix4Uniform transformationMatrix;

  final ColorUniform bgColorUniform;

  final FloatUniform baseC;
  final FloatUniform baseSlope;
  final FloatUniform perpSlope;
  final FloatUniform totalDistance;

  final ColorsUniform colors;
  final FloatsUniform stops;
  final IntUniform stopCount;

  LinearGradientRenderer({
    this.ctx,
    this.program,
    this.position,
    this.texCoords,
    this.projectionMatrix,
    this.transformationMatrix,
    this.bgColorUniform,
    this.baseC,
    this.baseSlope,
    this.perpSlope,
    this.totalDistance,
    this.colors,
    this.stops,
    this.stopCount,
  });

  @override
  void render(Renderer renderer, LinearGradientMesh object) {
    renderer.useProgram(program);

    final numVertices = object.vertices.count;

    position.set(object.vertices.asDataList);

    projectionMatrix.setData(renderer.projectionMatrix);
    transformationMatrix.setData(object.transformationMatrix);

    texCoords.set(object.texCoords.asDataList);
    bgColorUniform.setData(object.color);

    baseC.setData(object.baseC);
    baseSlope.setData(object.baseSlope);
    perpSlope.setData(object.perpSlope);
    totalDistance.setData(object.totalDistance);

    colors.setData(object.colors);
    stops.setData(object.stops);
    stopCount.setData(object.stops.length);

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

#define MAX_STOPS 2
  
uniform vec4 bgColor;
uniform float baseSlope;
uniform float baseC;
uniform float perpSlope;
uniform float totalDistance;

uniform vec4 colors[MAX_STOPS];
uniform float stops[MAX_STOPS];
uniform int stopCount;

varying vec2 vTexCoord;

void main(void) {
  float perpC = vTexCoord.y - perpSlope * vTexCoord.x;
  float projectionX = (perpC - baseC)/(baseSlope - perpSlope);
  float projectionY = baseSlope * projectionX + baseC;
  float distance = sqrt(pow(projectionX - vTexCoord.x, 2.0) + pow(projectionY - vTexCoord.y, 2.0));
  float distancePercent = distance/totalDistance;
  
  float start = stops[0], end = stops[0];
  vec4 color1 = colors[0], color2 = colors[0];
  for(int i = 0; i < MAX_STOPS; i++) {
    if(i == stopCount) {
      break;
    }
  
    if(distancePercent < stops[i]) {
      end = stops[i];
      color2 = colors[i];
      break;
    }
    start = stops[i];
    color1 = colors[i];
    
    end = stops[i];
    color2 = colors[i];
  }
  
  distancePercent = (distancePercent - start)/(end - start);
  
  vec4 gradColor = mix(color1, color2, distancePercent);
  gl_FragColor = bgColor * (1.0 - gradColor.w) + gradColor * gradColor.w;
}
  ''';

  static LinearGradientRenderer build(RenderingContext2 ctx) {
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

    ctx.useProgram(program);

    final positionAttribute =
        AttributeInfo.makeArrayBuffer(ctx, program, 'vertex');
    final texCoordsAttribute =
        AttributeInfo.makeArrayBuffer(ctx, program, 'texCoord');

    final projectionMatrixUniform =
        Matrix4Uniform.make(ctx, program, 'projectionMatrix');
    final transformationMatrixUniform =
        Matrix4Uniform.make(ctx, program, 'transformationMatrix');
    final bgColorUniform = ColorUniform.make(ctx, program, 'bgColor');
    final baseC = FloatUniform.make(ctx, program, 'baseC');
    final baseSlope = FloatUniform.make(ctx, program, 'baseSlope');
    final perpSlope = FloatUniform.make(ctx, program, 'perpSlope');
    final totalDistance = FloatUniform.make(ctx, program, 'totalDistance');
    final colors = ColorsUniform.make(ctx, program, 'colors');
    final stops = FloatsUniform.make(ctx, program, 'stops[0]');
    final stopCount = IntUniform.make(ctx, program, 'stopCount');

    return LinearGradientRenderer(
      ctx: ctx,
      program: program,
      position: positionAttribute,
      texCoords: texCoordsAttribute,
      projectionMatrix: projectionMatrixUniform,
      transformationMatrix: transformationMatrixUniform,
      bgColorUniform: bgColorUniform,
      baseC: baseC,
      baseSlope: baseSlope,
      perpSlope: perpSlope,
      totalDistance: totalDistance,
      colors: colors,
      stops: stops,
      stopCount: stopCount,
    );
  }
}

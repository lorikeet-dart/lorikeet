import 'dart:typed_data';
import 'dart:web_gl';

import 'package:lorikeet/src/primitive/primitive.dart';

class AttributeInfo {
  final RenderingContext2 ctx;

  final Buffer buffer;

  final int location;

  AttributeInfo({this.ctx, this.buffer, this.location});

  void set(TypedData data) {
    ctx.bindBuffer(WebGL.ARRAY_BUFFER, buffer);
    ctx.enableVertexAttribArray(location);
    ctx.vertexAttribPointer(
        location, 2, WebGL.FLOAT, false, 0, 0);
    ctx.bufferData(WebGL.ARRAY_BUFFER, data, WebGL.STATIC_DRAW);
  }

  void setVertex2(Vertex2 vertex) {
    ctx.bindBuffer(WebGL.ARRAY_BUFFER, buffer); // TODO can this be removed?
    ctx.disableVertexAttribArray(location);
    ctx.vertexAttrib2f(location, vertex.x, vertex.y);
  }

  static AttributeInfo makeArrayBuffer(
      RenderingContext2 ctx, Program program, String attributeName) {
    Buffer buffer = ctx.createBuffer();
    ctx.bindBuffer(WebGL.ARRAY_BUFFER, buffer);
    int location = ctx.getAttribLocation(program, attributeName);
    final attributeInfo =
        AttributeInfo(ctx: ctx, buffer: buffer, location: location);

    return attributeInfo;
  }
}

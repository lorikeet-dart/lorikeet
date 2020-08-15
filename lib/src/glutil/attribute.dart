import 'dart:typed_data';
import 'dart:web_gl';

class AttributeInfo {
  final RenderingContext2 ctx;

  final Buffer buffer;

  final int location;

  AttributeInfo({this.ctx, this.buffer, this.location});

  void set(TypedData data) {
    ctx.bindBuffer(WebGL.ARRAY_BUFFER, buffer);
    ctx.bufferData(WebGL.ARRAY_BUFFER, data, WebGL.STATIC_DRAW);
  }

  static AttributeInfo makeArrayBuffer(
      RenderingContext2 ctx, Program program, String attributeName) {
    Buffer buffer = ctx.createBuffer();
    ctx.bindBuffer(WebGL.ARRAY_BUFFER, buffer);
    int location = ctx.getAttribLocation(program, attributeName);
    ctx.enableVertexAttribArray(location);
    final attributeInfo =
        AttributeInfo(ctx: ctx, buffer: buffer, location: location);

    return attributeInfo;
  }
}

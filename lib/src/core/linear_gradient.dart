import 'package:lorikeet/lorikeet.dart';

class ColorStop {
  final Color color;

  final int percentage;

  ColorStop(this.color, this.percentage);
}

class LinearGradient {
  final num angle;

  final Color startColor;

  final Color endColor;

  final List<ColorStop> stops;

  LinearGradient(this.startColor, this.endColor,
      {this.angle = 0, this.stops = const []});
}

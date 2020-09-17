import 'package:lorikeet/lorikeet.dart';

class ColorStop {
  final Color color;

  final num percentage;

  ColorStop(this.color, this.percentage);
}

class LinearGradient {
  final num angle;

  final List<ColorStop> stops;

  LinearGradient({this.angle = 0, this.stops = const []});

  factory LinearGradient.between(Color start, Color end, {num angle}) =>
      LinearGradient(
          angle: angle, stops: [ColorStop(start, 0), ColorStop(end, 1)]);
}

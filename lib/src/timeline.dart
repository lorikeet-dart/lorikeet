import 'package:image/image.dart';

class Timeline {
  Duration _duration = Duration();

  DateTime _recentStart;

  Timeline({Duration initialElapsed}) {
    if (initialElapsed != null) {
      _duration = initialElapsed;
    }
  }

  void start() {
    if (_recentStart != null) {
      throw Exception('Already started!');
    }

    _recentStart = DateTime.now();
  }

  void pause() {
    _duration += elapsed;

    _recentStart = null;
  }

  Duration get elapsed =>
      _duration +
      (_recentStart != null
          ? DateTime.now().difference(_recentStart)
          : Duration());

  int get inMilliseconds => elapsed.inMilliseconds;

  int get inSeconds => elapsed.inSeconds;
}

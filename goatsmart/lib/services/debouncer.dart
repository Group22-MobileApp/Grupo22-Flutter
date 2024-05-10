import 'dart:async';
import 'dart:ui';

class Debouncer {
  final int milliseconds;
  Timer _timer;

  Debouncer({this.milliseconds = 500}) : _timer = Timer(Duration.zero, () {});

  void run(VoidCallback action) {
    if (_timer!= null) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
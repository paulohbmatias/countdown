import 'countdown_status.dart';

abstract class Countdown {
  CountdownStatus get status;
  Duration get duration;
  Duration get remaningTime;
  void reset();
  set duration(Duration duration);
  void stop();
  void play();
  void pause();
  void onTimeChanged(void Function(Duration) callback);
  void onStatusChanged(void Function(CountdownStatus) callback);
  void onDone(void Function() callback);
}

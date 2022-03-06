import 'countdown_status.dart';

abstract class Countdown {
  CountdownStatus get status;
  Duration get duration;
  Duration get remaningTime;
  void reset();
  void setDuration(Duration duration);
  void stop();
  void start();
  void pause();
  void onTimeChanged(void Function(Duration) callback);
  void onStatusChanged(void Function(CountdownStatus) callback);
  void onDone();
}
